//
//  ViewController.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/8.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import UIKit
import SVProgressHUD

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var peripherals = NSMutableArray()
    var peripheralsAD = NSMutableArray()
    var manager = KYLOCBluetoothManager()
    var dataSource = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SVProgressHUD.showInfo(withStatus: "准备打开设备")
        self.peripherals = NSMutableArray.init()
        self.peripheralsAD = NSMutableArray.init()
        self.dataSource = NSMutableArray.init()
        self.manager = KYLOCBluetoothManager.default()
        self.setDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.manager.cancleAllConnect()
        self.manager.beginToScan()
    }
    func setDelegate() {
        self.manager.kyl_discoverPeripherals { (central, peripheral, advertisementData, RSSI) in
            //        XMLog(message: (peripheral?.name,RSSI))
            self.insertTableView(peripheral: peripheral!, advertisementData: advertisementData! as NSDictionary)
        }
        self.manager.kyl_setFilter { (peripheralName, advertisementData, RSSI) -> Bool in
            if peripheralName != nil{//设置过滤条件
                return true
            }else{
                return false
            }
        }
    }
    func insertTableView(peripheral:CBPeripheral,advertisementData:NSDictionary) -> Void {
        if !self.peripherals.contains(peripheral) {
            let indexPath = NSIndexPath.init(row: self.peripherals.count, section: 0)
            self.peripherals.add(peripheral)
            self.peripheralsAD.add(advertisementData)
            self.tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
        }
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let peripheral = self.peripherals.object(at: indexPath.row) as! CBPeripheral
        let ad = peripheralsAD.object(at: indexPath.row) as! NSDictionary
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none;
        var localName = String()
        if (ad.object(forKey: "kCBAdvDataLocalName") != nil) {
            localName = ad.object(forKey: "kCBAdvDataLocalName") as! String
        }else{
            localName = peripheral.name!
        }
        cell.textLabel?.text = localName
        cell.detailTextLabel?.text = "读取中...";
        if (ad.object(forKey: "kCBAdvDataServiceUUIDs") != nil) {
            let serviceUUIDs = ad.object(forKey: "kCBAdvDataServiceUUIDs") as! NSArray
            if serviceUUIDs.count > 0 {
                cell.detailTextLabel?.text = String.init(format: "%lu个services", serviceUUIDs.count)
            }else{
                cell.detailTextLabel?.text = "0个services"
            }
        }
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.manager.cancleScan()
        let perVC = segue.destination as! PeripheralViewController
        perVC.manager = self.manager;
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        let per = self.peripherals.object(at: (indexPath?.row)!) as! CBPeripheral
        perVC.currPeripher = per;
        perVC.chuanzhi(currentPeripheral: per)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
