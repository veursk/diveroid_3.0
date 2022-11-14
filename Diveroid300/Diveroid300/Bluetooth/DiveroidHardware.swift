//
//  DiveroidHardware.swift
//  DiveroidRenewal-iOS
//
//  Created by YoungWoon Lee on 29/10/2019.
//  Copyright © 2019 Artisan&Ocean co.,ltd. All rights reserved.
//

import Foundation
import CoreBluetooth

enum MINIState {
    case NONE, VER1, START, COMPLETE, WaitForFirmware, REUPDATE
}

class DiveroidHardware {
    
    let peripheral: CBPeripheral
    var advertisementData: [String: Any]
    var startTime: TimeInterval
    
    let identifier: String?
    let periperalName: String?
    var over60Sec: Bool!

    ///Serial
    fileprivate var serial: String? = nil
    
    ///kCBAdvDataManufacturerData
    fileprivate var manufacturerData: Data?
    
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], startTime: TimeInterval, overTime: Bool = false) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.startTime = startTime
        self.over60Sec = overTime
        
        self.identifier = peripheral.identifier.uuidString
        self.periperalName = advertisementData["kCBAdvDataLocalName"] as? String ?? peripheral.name
        
        if let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            self.manufacturerData = kCBAdvDataManufacturerData
        }
    }
    
    public func getSerial() -> String? {
        if let data = manufacturerData {
            print("manufacturerData: \(data.hexString)")
            
            if let miniName1 = peripheral.name, let miniName2 = advertisementData["kCBAdvDataLocalName"] as? String {
                
                let dvMini = "DVMINI"
                // Diveroid Leo

                if miniName1.contains(dvMini) || miniName2.contains(dvMini) || miniName1.contains("Magicsee") {
                    if data.count != 8 {
                        serial = peripheral.identifier.uuidString.components(separatedBy: "-")[4]
                    } else {
                        serial = [ data.subdata(in: 7..<8).hexString.uppercased(),
                                   data.subdata(in: 6..<7).hexString.uppercased(),
                                   data.subdata(in: 5..<6).hexString.uppercased(),
                                   data.subdata(in: 4..<5).hexString.uppercased(),
                                   data.subdata(in: 0..<1).hexString.uppercased(),
                                   data.subdata(in: 1..<2).hexString.uppercased() ].joined()
                    }
                } else {
                    serial = peripheral.identifier.uuidString.components(separatedBy: "-")[4]
                }
            }
        }
        
        return serial
    }
    
    public func isInTargetMini() -> Bool {
        guard let name = periperalName else { return false }
        
        return name.contains("AO_DIVING") ||
               name.contains("DIVING_BLE") ||
               name.contains("DV_MINI") ||
               name.contains("DVMINI") ||
               name.contains("AO-DFU")
                // Diveroid Leo
    }
    
    public func updateAdvertisementData(advertisementData: [String: Any]) {
        self.advertisementData = advertisementData
        
        if let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            self.manufacturerData = kCBAdvDataManufacturerData
        }
    }
    
    public func updateScannedTimeStamp(timeStamp: TimeInterval) {
        
        self.startTime = timeStamp
        
    }
    
    public func blinkRedLight() -> Bool {
        guard let data = advertisementData["kCBAdvDataManufacturerData"] as? NSData else { return false }
        var bytes = [Any]()
        for i in 0..<data.count {
            var byte: UInt8 = 0
            data.getBytes(UnsafeMutableRawPointer(mutating: &byte), range: NSRange(location: i, length: 1))
            bytes.append(String.init(format: "0x%x", byte))
        }
        
        var patternSlot: UInt32 = 0
        var curSlot: UInt32 = 0
        
        if bytes.count == 0 { return false }
        var scanner = Scanner(string: bytes[2] as? String ?? "")
        scanner.scanHexInt32(&patternSlot)
        scanner = Scanner(string: bytes[3] as? String ?? "")
        scanner.scanHexInt32(&curSlot)
        
        let curFlag = Int(patternSlot & (0x0001 << curSlot))
        if curFlag == 0 {
            return false
        } else {
            return true
        }
    }
}
