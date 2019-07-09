//
//  KYLCharacteristicController.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/9.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import UIKit

class KYLCharacteristicController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var mananger = KYLOCBluetoothManager()
    var sect = NSMutableArray()
    var readValueArray = NSMutableArray()
    var descriptors = NSMutableArray()
    var characteristic:CBCharacteristic?
    var currPeripheral:CBPeripheral?
    let channel =  "CBCharacteristic"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.sect = NSMutableArray.init(array: ["read value","write value","desc","properties"])
        self.readValueArray = NSMutableArray.init()
        self.descriptors = NSMutableArray.init()
        self.mananger.readDetailValueOfCharacteristic(withChannel: self.channel, characteristic: self.characteristic, currPeripheral: self.currPeripheral)
        self.managerDelegate()
        self.setupUI()
    }
    
    func setupUI() {
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 64, width: KSCREEN_WIDTH, height: 100))
        headView.backgroundColor = UIColor.darkGray
        self.view.addSubview(headView)
        let array = [self.currPeripheral?.name,String.init(format: "%@", (self.characteristic?.uuid)!),self.characteristic?.uuid.uuidString]
        for (index,item) in array.enumerated() {
            let label = UILabel.init(frame: CGRect.init(x: 0, y: 30*index, width: Int(KSCREEN_WIDTH), height: 30))
            label.text = item
            label.backgroundColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 18)
            headView.addSubview(label)
        }
        self.tableView.frame = CGRect.init(x: 0, y: (120 + 64), width: KSCREEN_WIDTH, height: (KSCREEN_HEIGHT - 64.0 - 120))
        let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(read), userInfo: nil, repeats: true)
        timer.fire()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - logic

extension KYLCharacteristicController {
    func read() {
        self.currPeripheral?.readRSSI()
    }
    
    /// 根据信号强度算距离
    ///
    /// - Parameter RSSI: 信号强度值
    /// - Returns: 距离
    func getDistanceWith(RSSI:NSNumber) -> CGFloat {
        let power:Float = abs(RSSI.floatValue - 49.0)/(10*4.0)
        return CGFloat(powf(10.0, power)/10.0)
    }
    func managerDelegate(){
        self.mananger.kyl_readValueForCharacter { (peripheral, characteristics, error) in
            if ((characteristics?.value) != nil){
                let data = (characteristics?.value)! as Data
                let string = String.init(data: data, encoding: .utf8)
                if string != nil{
                    KYLLog(message: "数据为空")
                }
                self.insertReadValues(characteristics: characteristics!)
            }
        }
        self.mananger.kyl_discoverDescriptorsForCharacteristic { (peripheral, characteristic, error) in
            
            for item:CBDescriptor in (characteristic?.descriptors)!{
                self.insertDescriptor(descriptor: item)
            }
        }
        self.mananger.kyl_readValueForDescriptors { (peripheral, descriptor, error) in
            for (index,item) in self.descriptors.enumerated(){
                if (item as! CBDescriptor) == descriptor{
                    let cell = self.tableView.cellForRow(at: IndexPath.init(row: index, section: 0))
                    cell?.detailTextLabel?.text = String.init(format: "%@", descriptor?.value as! CVarArg)
                }
            }
        }
        //订阅状态发生改变
        self.mananger.kyl_didUpdateNotificationStateForCharacteristic { (characteristic, error) in
            KYLLog(message: (characteristic?.uuid,(characteristic?.isNotifying)! ? "on" : "off"))
        }
        //实时读取外设的RSSI
        self.mananger.kyl_didReadRSSI { (RSSI, error) in
            KYLLog(message: ("setBlockOnDidReadRSSI:\(RSSI)"))
            let distance:CGFloat? = self.getDistanceWith(RSSI: RSSI!)
            KYLLog(message: distance)
        }
        self.mananger.kyl_readRSSI { (RSSI, error) in
            KYLLog(message: RSSI)
        }
        self.mananger.kyl_blockOnDisconnect { (central, peripheral, error) in
            KYLLog(message: "连接失败")
        }
        //添加重连设备
        self.mananger.kyl_addAutoReconnectPeripheral(self.currPeripheral)
        //写出值成功的回调
        self.mananger.kyl_didWriteValueForCharacteristic { (characteristic, error) in
            if error == nil{
                SVProgressHUD.showInfo(withStatus: "写入成功啦")
            }
        }
    }
    func setNotifiy(sender:UIButton) {
        let btn = sender
        if self.currPeripheral?.state == .disconnected {
            SVProgressHUD.showInfo(withStatus: "peripheral已经断开连接，请重新连接")
            return
        }
        if (self.characteristic?.properties.contains(.notify))! || (self.characteristic?.properties.contains(.indicate))! {
            if (self.characteristic?.isNotifying)! {
                self.mananger.kyl_cancleNotify(with: self.currPeripheral, characteristic: self.characteristic)
                btn.setTitle("通知", for: .normal)
            }else{
                self.currPeripheral?.setNotifyValue(true, for: self.characteristic!)
                self.mananger.kyl_setNotifiy(with: self.currPeripheral, for: self.characteristic, block: { (peripheral, characteristic, error) in
                    if error == nil{
                        SVProgressHUD.showInfo(withStatus: "接收到订阅的数据")
                    }else{
                        SVProgressHUD.showError(withStatus: error as! String!)
                    }
                    self.insertReadValues(characteristics: characteristic!)
                })
                btn.setTitle("取消通知", for: .normal)
            }
        }else{
            SVProgressHUD.showInfo(withStatus: "这个characteristic没有nofity的权限")
        }
    }
    func insertReadValues(characteristics:CBCharacteristic) -> Void {
        var string:String?
        if (characteristics.value != nil) {
            string = String.init(data: characteristics.value!, encoding: .utf8)
        }
        if string == "" {
            print(string as Any)
        }
        self.readValueArray.add(string as Any)
        let indexPath = IndexPath.init(row: self.readValueArray.count-1, section: 0)
        self.tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .middle, animated: true)
    }
    func insertDescriptor(descriptor:CBDescriptor) -> Void {
        self.descriptors.add(descriptor)
        let indexPath = NSIndexPath.init(row: self.descriptors.count - 1, section: 2) as IndexPath
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func writeValue(){
        //        写入五位随机数
        let num = arc4random()%100000
        let string = String.init(format: "%d", num)
        let data = string.data(using: .utf8)
        self.mananger.write(data, to: self.currPeripheral, for: self.characteristic)
    }
}



//MARK - tabelViewDelegate

extension KYLCharacteristicController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        switch indexPath.section {
        case 0:
            
            cell?.textLabel?.text = self.readValueArray.object(at: indexPath.row) as? String
            let formatter = DateFormatter.init()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            cell?.detailTextLabel?.text = formatter.string(from: NSDate.init() as Date)
            break
        case 1:
            cell?.textLabel?.text = "write a new value"
            break
        case 2:
            let descriptor = self.descriptors[indexPath.row] as! CBDescriptor
            cell?.textLabel?.text = String.init(format: "%@", descriptor.uuid)
            break
        case 3:
            let p = self.characteristic?.properties
            cell?.textLabel?.text = ""
            if (p?.contains(.broadcast))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | Broadcast")
            }
            if (p?.contains(.read))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | Read")
            }
            if (p?.contains(.writeWithoutResponse))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | WriteWithoutResponse")
            }
            if (p?.contains(.write))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | Write")
            }
            if (p?.contains(.notify))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | Notify")
            }
            if (p?.contains(.indicate))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | Indicate")
            }
            if (p?.contains(.authenticatedSignedWrites))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | AuthenticatedSignedWrites")
            }
            if (p?.contains(.extendedProperties))! {
                cell?.textLabel?.text = cell?.textLabel?.text?.appending(" | ExtendedProperties")
            }
            
            break
        default:
            break
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.readValueArray.count
        case 1:
            return 1
        case 2:
            return self.descriptors.count
        case 3:
            return 1
        default:
            return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sect.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KSCREEN_WIDTH, height: 30))
            view.backgroundColor = UIColor.darkGray
            let title = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 30))
            title.text = self.sect[section] as? String
            title.textColor = UIColor.white
            view.addSubview(title)
            let notiButton = UIButton.init(type: .custom)
            notiButton.frame = CGRect.init(x: 100, y: 0, width: 100, height: 30)
            notiButton.setTitle((self.characteristic?.isNotifying)! ?"取消通知":"通知", for: .normal)
            notiButton.backgroundColor = UIColor.darkGray
            notiButton.addTarget(self, action: #selector(setNotifiy(sender:)), for: .touchUpInside)
            if (self.characteristic?.isNotifying)! {
                self.mananger.kyl_setNotifiy(with: self.currPeripheral, for: self.characteristic, block: { (peripheral, characteristics, error) in
                    self.insertReadValues(characteristics: characteristics!)
                })
            }
            view.addSubview(notiButton)
            let writeButton = UIButton.init(type: .custom)
            writeButton.frame = CGRect.init(x: 200, y: 0, width: 100, height: 30)
            writeButton.setTitle("写(0x01)", for: .normal)
            writeButton.backgroundColor = UIColor.darkGray
            writeButton.addTarget(self, action: #selector(writeValue), for: .touchUpInside)
            view.addSubview(writeButton)
            return view
        default:
            let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 30))
            label.text = self.sect[section] as? String
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.darkGray
            return label
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
