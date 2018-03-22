import CoreBluetooth
import UIKit

protocol SimpleBluetoothIODelegate: class {
    func simpleBluetoothIO(simpleBluetoothIO: SimpleBluetoothIO, didReceiveValue value: Int8)
    func getDiscoverPeripheral(items: [String: [String: Any]])
    func didConnectToPeripheral(peripheralName: String)
    func didDisconnectFromPeripheral()
    func didDiscoverFailed()
    func didFailToConnect(_ peripheralName: String)
}

class SimpleBluetoothIO: NSObject {
    let serviceUUID: String
    weak var delegate: SimpleBluetoothIODelegate?

    var centralManager: CBCentralManager!
    var discoverPeripheral: [CBPeripheral]? = []
    var connectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?
    var items = [String: [String: Any]]()
    var target:UIViewController?
    var isDisconnect = false
    
    init(serviceUUID: String, delegate: SimpleBluetoothIODelegate?) {
        self.serviceUUID = serviceUUID
        self.delegate = delegate

        super.init()
        let opts = [CBCentralManagerOptionShowPowerAlertKey: true]
        //centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: opts)
    }

    func writeValue(value: String) {
        guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
            return
        }

        let data = Data.dataWithValue(value: value)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    fileprivate func didReadPeripheral(_ peripheral: CBPeripheral, rssi: NSNumber){
        discoverPeripheral?.append(peripheral)
        if let name = peripheral.name{
            items[name] = [
                "name":name,
                "rssi":rssi
            ]
            
            delegate?.getDiscoverPeripheral(items: items)
        }
    }
    
    func didConnect(peripheralName: String) {
        guard discoverPeripheral != nil else {
            return
        }
        
        for peripheral in discoverPeripheral! {
            if peripheral.name == peripheralName {
                connectedPeripheral = peripheral
                if let connectedPeripheral = connectedPeripheral {
                    connectedPeripheral.delegate = self
                    isDisconnect = false
                    centralManager.connect(connectedPeripheral, options: nil)
                }
                centralManager.stopScan()
                break
            }
        }
    }
    
    func disconnectPeripheral() {
        guard let peripheral = connectedPeripheral else {
            return
        }
        isDisconnect = true
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

extension SimpleBluetoothIO: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        print(peripheral.identifier)
        print(peripheral.state)
        if peripheral.state == .connected {
            let uuid: String = String(describing: peripheral.identifier)
            UserDefaults.standard.setValue(uuid, forKey: "DeviceUUID")
            delegate?.didConnectToPeripheral(peripheralName: peripheral.name!)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        didReadPeripheral(peripheral, rssi: RSSI)
        
        if let deviceUUID = UserDefaults.standard.value(forKey: "DeviceUUID") as? String, deviceUUID == "\(peripheral.identifier)" {
            print("UUID : \(deviceUUID)")
            didConnect(peripheralName: peripheral.name!)
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
//            if let deviceUUID = UserDefaults.standard.value(forKey: "DeviceUUID") as? String {
//                centralManager.scanForPeripherals(withServices: [CBUUID(string: deviceUUID)], options: nil)
//            }else {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
//            }
        }else {
            switch central.state {
            case .poweredOff:
                print("powerOff")
                showAlert(with: "No Bluetooth Connection", message: "Bluetooth is currently powered off , powered ON first.")
                
            case .resetting:
                print("resetting")
                showAlert(with: "Update imminent", message: "The connection with the system service was momentarily lost, update imminent.")
            case .unauthorized:
                print("unauthorized")
                showAlert(with: "Weak Bluetooth Connection", message: "The app is not authorized to use Bluetooth Low Energy.")
            case .unsupported:
                print("unsupported")
                showAlert(with: "Unsupported", message: "The platform doesn't support Bluetooth Low Energy.")
            case .unknown:
                print("unknown")
                showAlert(with: "State unknown, update imminent.", message: "Unknown state")
            default:
               break
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral.state == .disconnected {
            if isDisconnect {
                delegate?.didDisconnectFromPeripheral()
                UserDefaults.standard.removeObject(forKey: "DeviceUUID")
            }else {
                didConnect(peripheralName: peripheral.name!)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("FailToConnect: \(error.debugDescription)")
        delegate?.didFailToConnect(peripheral.name!)
    }
    
    func showAlert(with aTitle: String, message: String) {
        delegate?.didDiscoverFailed()
        let alertContoller = UIAlertController(title: aTitle, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            if aTitle == "No Bluetooth Connection" {
                self.openBluetooth()
            }
        }
        
        alertContoller.addAction(okAction)
        
        target?.present(alertContoller, animated: true, completion: nil)
        
    }
    
    func openBluetooth(){
        let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: [:]) { (success) in
            
        }
        //app.openURL(url!)
    }
}

extension SimpleBluetoothIO: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }

        targetService = services.first
        if let service = services.first {
            targetService = service
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writableCharacteristic = characteristic
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, let delegate = delegate else {
            return
        }

        delegate.simpleBluetoothIO(simpleBluetoothIO: self, didReceiveValue: data.int8Value())
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        didReadPeripheral(peripheral, rssi: RSSI)
        
        delay(1.0){
            peripheral.readRSSI()
        }
    }
}
