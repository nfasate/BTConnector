//
//  ScanDevicesViewController.swift
//  BTConnector
//
//  Created by NILESH_iOS on 21/03/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ScanDevicesDelegate {
    func didSelectScanDevice(deviceName: String)
}

class ScanDevicesViewController: UIViewController {

    @IBOutlet var devicesTableView: UITableView!
    
    var manager: CBCentralManager!
    
    let scanningDelay = 1.0
    var items = [String: [String: Any]]()
    var delegate: ScanDevicesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //manager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ScanDevicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        // Configure the cell...
        if let item = itemForIndexPath(indexPath){
            cell.textLabel?.text = item["name"] as? String
            
            if let rssi = item["rssi"] as? Int {
                cell.detailTextLabel?.text = "\(rssi.description) dBm"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        
        return cell
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> [String: Any]?{
        
        if indexPath.row > items.keys.count{
            return nil
        }
        
        return Array(items.values)[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemForIndexPath(indexPath){
            delegate?.didSelectScanDevice(deviceName: (item["name"] as? String)!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//extension ScanDevicesViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
//    
//    func centralManagerDidUpdateState(_ central: CBCentralManager){
//        if central.state == .poweredOn{
//            manager.scanForPeripherals(withServices: nil, options: nil)
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
//        
//        didReadPeripheral(peripheral, rssi: RSSI)
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
//        
//        didReadPeripheral(peripheral, rssi: RSSI)
//        
//        delay(scanningDelay){
//            peripheral.readRSSI()
//        }
//    }
//    
//    func didReadPeripheral(_ peripheral: CBPeripheral, rssi: NSNumber){
//        
//        if let name = peripheral.name{
//            
//            items[name] = [
//                "name":name,
//                "rssi":rssi
//            ]
//        }
//        devicesTableView.reloadData()
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
//        peripheral.readRSSI()
//    }
//}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
