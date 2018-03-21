import CoreBluetooth

protocol SimpleBluetoothIODelegate: class {
    func simpleBluetoothIO(simpleBluetoothIO: SimpleBluetoothIO, didReceiveValue value: Int8)
    func getDiscoverPeripheral(items: [String: [String: Any]])
    func didConnectToPeripheral(peripheralName: String)
    func didDisconnectFromPeripheral()
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
    
    init(serviceUUID: String, delegate: SimpleBluetoothIODelegate?) {
        self.serviceUUID = serviceUUID
        self.delegate = delegate

        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
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
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            //centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUUID)], options: nil)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral.state == .disconnected {
            delegate?.didDisconnectFromPeripheral()
            UserDefaults.standard.removeObject(forKey: "DeviceUUID")
        }
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
