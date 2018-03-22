//
//  ViewController.swift
//  BTConnector
//
//  Created by NILESH_iOS on 21/03/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController {

    @IBOutlet var actionTableView: UITableView!
    @IBOutlet var connectBtn: UIButton!
    @IBOutlet var dissconnectBtn: UIButton!
    
    var simpleBluetoothIO: SimpleBluetoothIO!
    var items = [String: [String: Any]]()
    var switchesArray = ["Switch 1", "Switch 2", "Switch 3", "Switch 4", "Switch 5","Switch 6", "Switch 7", "Switch 8"]
    var timerArray = ["", "", "", "", "", "", "", ""]
    
    //var activityIndicatorView: NVActivityIndicatorView?
    var activityData:ActivityData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentActivityIndicator()
    NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData!)
        simpleBluetoothIO = SimpleBluetoothIO(serviceUUID: "19B10010-E8F2-537E-4F6C-D104768A1214", delegate: self)
        simpleBluetoothIO.target = self
        //actionTableView.isHidden = true
        dissconnectBtn.isHidden = true
        getStoredArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getStoredArray() {
        let defaults = UserDefaults.standard
        if let array = defaults.stringArray(forKey: "SavedSwitchesArray") {
            switchesArray = array
        }else {
            defaults.set(switchesArray, forKey: "SavedSwitchesArray")
        }
        actionTableView.reloadData()
    }
    
    func presentEditableTextAlertController(_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Change Title", message: "Please input your new title", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Please input your new title"
        })
        
        let confirmAction = UIAlertAction(title: "Confirm the modification", style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
            print("New Title \(String(describing: alertController.textFields?[0].text))")
            self.switchesArray[indexPath.row] = (alertController.textFields?[0].text)!
            let defaults = UserDefaults.standard
            defaults.set(self.switchesArray, forKey: "SavedSwitchesArray")
            self.actionTableView.reloadData()
        })
        
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("Canelled")
        })
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func connectBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let devicesController = storyboard.instantiateViewController(withIdentifier: "ScanDevicesViewController") as! ScanDevicesViewController
        devicesController.modalPresentationStyle = .overCurrentContext
        devicesController.items = self.items
        devicesController.delegate = self
        self.present(devicesController, animated: true, completion: nil)
    }
    
    @IBAction func dissconnectBtnTapped(_ sender: UIButton) {
        simpleBluetoothIO.disconnectPeripheral()
    }
    
    func presentActivityIndicator() {
        //let frame = CGRect(x: self.view.frame.width/2 - 50, y: self.view.frame.height/2 - 50, width: 100, height: 100)
        //activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballScaleMultiple, color: UIColor.green, padding: 20)
        //self.view.addSubview(activityIndicatorView!)
        
        let size = CGSize(width: 100, height: 100)
        activityData = ActivityData(size: size, message: "", messageFont: UIFont(name: "Georgia", size: 20.0)!, messageSpacing: 5, type: NVActivityIndicatorType.ballScaleMultiple, color: UIColor.green, padding: 20, displayTimeThreshold: 20, minimumDisplayTime: 20, backgroundColor: UIColor.clear, textColor: UIColor(red:1.00, green:0.34, blue:0.22, alpha:0.9))
        
        //activityIndicatorView?.startAnimating()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return switchesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! SwitchTableViewCell
        
        cell.titleLbl.text = switchesArray[indexPath.row]
        cell.timerLbl.text = timerArray[indexPath.row]
        cell.delegate = self
        cell.timerBtn.tag = indexPath.row
        cell.timerLbl.tag = indexPath.row
        cell.switchBtn.tag = indexPath.row
        
        if cell.timerLbl.text != "" {
            cell.timerBtn.tintColor = UIColor(red:1.00, green:0.34, blue:0.22, alpha:0.9)
        }else {
            cell.timerBtn.tintColor = UIColor(red:0.41, green:0.95, blue:0.61, alpha:1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentEditableTextAlertController(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: SimpleBluetoothIODelegate {
    func didDiscoverFailed() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    
    func didConnectToPeripheral(peripheralName: String) {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        actionTableView.isHidden = false
        dissconnectBtn.isHidden = false
        connectBtn.isHidden = true
        switchesArray = ["Switch 1", "Switch 2", "Switch 3", "Switch 4", "Switch 5","Switch 6", "Switch 7", "Switch 8"]
        timerArray = ["", "", "", "", "", "", "", ""]
        
        actionTableView.reloadData()
    }
    
    func didDisconnectFromPeripheral() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        actionTableView.isHidden = true
        dissconnectBtn.isHidden = true
        connectBtn.isHidden = false
        switchesArray = ["Switch 1", "Switch 2", "Switch 3", "Switch 4", "Switch 5","Switch 6", "Switch 7", "Switch 8"]
        timerArray = ["", "", "", "", "", "", "", ""]
        actionTableView.reloadData()
    }
    
    func getDiscoverPeripheral(items: [String : [String : Any]]) {
        self.items = items
        //activityIndicatorView?.stopAnimating()
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    func simpleBluetoothIO(simpleBluetoothIO: SimpleBluetoothIO, didReceiveValue value: Int8) {
        if value > 0 {
            view.backgroundColor = UIColor.yellow
        } else {
            view.backgroundColor = UIColor.black
        }
    }
    
    
}

extension ViewController: ScanDevicesDelegate {
    func didSelectScanDevice(deviceName: String) {
        print(deviceName)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData!)
        simpleBluetoothIO.didConnect(peripheralName: deviceName)
    }
}

extension ViewController: SwitchTableCellDelegate {
    func switchValueChanged(_ row: Int, isOn: Bool) {
       var value = ""
        
        if row == 0 {
            value = "A"
        }else if row == 1 {
            value = "B"
        }else if row == 2 {
            value = "C"
        }else if row == 3 {
            value = "D"
        }else if row == 4 {
            value = "E"
        }else if row == 5 {
            value = "F"
        }else if row == 6 {
            value = "G"
        }else if row == 7 {
            value = "H"
        }
        
        if isOn {
            simpleBluetoothIO.writeValue(value: value.lowercased())
        }else {
            simpleBluetoothIO.writeValue(value: value)
        }
    }
    
    func didTapTimer(_ row: Int, isTimerOn: Bool) {
        if isTimerOn == true {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let timerController = storyboard.instantiateViewController(withIdentifier: "TimerViewController") as! TimerViewController
            timerController.modalPresentationStyle = .overCurrentContext
            timerController.indexRow = row
            timerController.delegate = self
            self.present(timerController, animated: true, completion: nil)
        }else {
            timerArray[row] = ""
            actionTableView.reloadData()
        }
    }
}

extension ViewController: TimerViewControllerDelegate {
    func didStartTimer(hour: Int, min: Int, row: Int) {
        timerArray[row] = "\(hour):\(min):00"
        actionTableView.reloadData()
    }
    
    func didDismissController(_ row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        if let cell = actionTableView.cellForRow(at: indexPath) as? SwitchTableViewCell {
            cell.timerBtn.tintColor = UIColor(red:0.41, green:0.95, blue:0.61, alpha:1.0)
        }
        
    }
}
