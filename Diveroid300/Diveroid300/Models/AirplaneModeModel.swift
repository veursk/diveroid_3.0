//
//  AirplaneModeModel.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/15.
//

import Network

class AirplaneModeModel {
    
    static let shared = AirplaneModeModel()

    let monitor: NWPathMonitor
    
    var isAirplaneModeOn: Bool = false
    
    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {path in
            if path.availableInterfaces.count == 0 {
                print("Flight Mode")
                self.isAirplaneModeOn = true
            }
            print(path.availableInterfaces)
        }
        
        let airplaneModeCheckqueue = DispatchQueue.global(qos: .background)
        monitor.start(queue: airplaneModeCheckqueue)
    }
    
}
