import CoreBluetooth
import Foundation

class BluetoothManager: NSObject {
    
    static let shared = BluetoothManager()
    
    var centralManager: CBCentralManager!
    var miniPeripheral: CBPeripheral!
    
    fileprivate let serviceUUID        = "0000180a-0000-1000-8000-00805f9b34fb"
    fileprivate let descriptorUUID     = "00002902-0000-1000-8000-00805f9b34fb"
    fileprivate let customServiceUUID  = "0000ffff-1212-efde-1523-785fef13d123"
    fileprivate let characteristicUUID = "00000001-1212-efde-1523-785fef13d123"
    private lazy var detectUUID = [customServiceUUID] //, serviceUUID, descriptorUUID, characteristicUUID]

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            ///withService : [CBUUID] 미니 특정할 때 사용
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is .unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        
        if peripheral.name != nil {
            if peripheral.name!.contains("DVMINI6") {
                print(peripheral)
                miniPeripheral = peripheral
                miniPeripheral.delegate = self
                centralManager.stopScan()
                centralManager.connect(miniPeripheral)
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected \(peripheral.name!)")
        miniPeripheral.discoverServices(nil)
    }
    
    
    
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        
        for service in services {
            print(service)
            if detectUUID.contains(service.uuid.uuidString.lowercased()) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        /// global, sync 동시성 잡은 이유...?
        DispatchQueue.global(qos: .utility).sync {
            if let deviceData = characteristic.value {
                
                var pressure = Float((UInt16(deviceData[0]) << 8) | UInt16(deviceData[1])) / 1000.0
                pressure = pressure < 0 ? 1.013 + pressure : pressure
                
                let temperature = Float((UInt16(deviceData[2]) << 8) | UInt16(deviceData[3])) / 10.0
                let battery = Int((UInt16(deviceData[4]) << 8) | UInt16(deviceData[5]))
                
                /// batterty가 1000 (전압) 이넘으면 새로운 DVMINI5, DVMINI6임.
                print("Bluetooth: pressure3:\(pressure)  temperature: \(temperature) battery: \(battery)")
//                SharedDivingSession.shared.passDivingHardwareInput(pressure: pressure, temperature: temperature, battery: battery)
                
                
                DivingDataManager.shared.passDataFromBluetooth(pressure: pressure, temperature: temperature, battery: battery)
                print(DivingDataManager.shared.depth)
                print(DivingDataManager.shared.temperature)
            }
        }
    }
}
