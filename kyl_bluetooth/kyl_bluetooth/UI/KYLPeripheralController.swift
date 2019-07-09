//
//  KYLPeripheralController.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/9.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import UIKit
import SVProgressHUD
import BabyBluetooth

class KYLPeripheralController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var manager = KYLOCBluetoothManager()
    var services = NSMutableArray()
    var currPeripher:CBPeripheral?
    let channel:String = "perpheral"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        self.services = NSMutableArray.init();
        SVProgressHUD.showInfo(withStatus: "准备连接设备")
        let button = UIButton.init(type: .custom)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        button.setTitle("😸", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
    
    
    @objc func buttonAction(_ sender:UIButton) -> Void {
        let array = self.manager.KYLFindConnectedPeripherals()
        KYLLog(message: array)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! CharacteristicViewController
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        vc.currPeripheral  = self.currPeripher
        let info = self.services.object(at: (indexPath?.section)!) as! KYLPeripheralInfo
        let characteristic = info.characteristics.object(at: (indexPath?.row)!) as! CBCharacteristic
        vc.characteristic = characteristic
        vc.mananger = self.manager
    }
    

}

 // MARK: - logic

extension KYLPeripheralController {
    func chuanzhi(currentPeripheral:CBPeripheral) -> Void {
        KYLLog(message: currentPeripheral)
        self.currPeripher  = currentPeripheral
        //连接外设
        self.manager.connectToPeripheral(withChannel: self.channel, peripheral: currentPeripheral)
        self.manager.xm_discoverServices { (peripheral, error) in
            for s:CBService in (peripheral?.services)! {
                self.insertSectionToTableView(service: s)
            }
        }
        self.manager.xm_xmDiscoverCharacteristics(atChannel: { (peripheral, service, error) in
            self.insertRowToTableView(service: service!)
        })
        self.manager.xm_readValueForCharacter { (peripheral, characteristics, error) in
            
        }
        self.manager.xm_readValueForDescriptors { (peripheral, descriptor, error) in
            
        }
        self.manager.xm_discoverDescriptorsForCharacteristic { (peripheral, characteristics, error) in
            
        }
        self.manager.xm_disconnect { (central, peripheral, error) in
            
        }
        self.manager.xm_connectState { (state) in
            KYLLog(message: state)
        }
    }
    func insertSectionToTableView(service:CBService) -> Void {
        KYLLog(message: service.uuid.uuidString)
        let info = XMPeripheralInfo.init()
        info.serviceUUID = service.uuid
        self.services.add(info)
        let indexSet = NSIndexSet.init(index: self.services.count - 1)
        self.tableView.insertSections(indexSet as IndexSet, with: .automatic)
    }
    func insertRowToTableView(service:CBService) -> Void{
        var sect:Int = -1
        
        for (index,item) in self.services.enumerated() {
            if ((item as! XMPeripheralInfo).serviceUUID == service.uuid) {
                sect = index;
            }
        }
        
        if sect != -1 {
            let info = self.services.object(at: sect) as! XMPeripheralInfo
            
            for (index,item) in (service.characteristics?.enumerated())! {
                info.characteristics.add(item as CBCharacteristic)
                let indexPath = NSIndexPath.init(row: index, section: sect)
                self.tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            }
            
        }
    
    }
}



//MARK - tabelViewDelegate

extension KYLPeripheralController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.services.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.services.object(at: section) as! XMPeripheralInfo
        return info.characteristics.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = self.services.object(at: indexPath.section) as! XMPeripheralInfo
        let characteristic = info.characteristics.object(at: indexPath.row) as! CBCharacteristic
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = String.init(format: "%@", characteristic.uuid.uuidString)
        cell?.detailTextLabel?.text = characteristic.description
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 50))
        let info = self.services.object(at: section) as! XMPeripheralInfo
        label.text = String.init(format: "%@", info.serviceUUID)
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        return label
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
