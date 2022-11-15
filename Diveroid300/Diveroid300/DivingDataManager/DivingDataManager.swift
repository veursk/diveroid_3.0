//
//  DivingDataManager.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/15.
//

import Foundation
import UIKit

class DivingDataManager: NSObject, ObservableObject {
    static let shared = DivingDataManager()
    
    //MARK:- 화면에 갱신되어야 되는 데이터들
    public var divingTime: Int = 0
    public var lastActiveTime: Double = 0
    @Published public var depth: Float = 0.0
    public var pressure: Float = 0.0
    @Published public var temperature: Float = 0.0
    public var degree: Float = 0.0
    public var ndl: Int = 0
    public var battery: Int = 0
    public var brightness: CGFloat = UIScreen.main.brightness
    
    //계산용
    public var surfaceHpaPressure: Float = 1013.25
    
    public override init() {
        super.init()
        self.initVariables()
    }
}

extension DivingDataManager {
    public func initVariables() {
        self.depth = 0
        self.pressure = 0
        self.temperature = 0
        self.ndl = 90
    }
    
    public func pressureToDepthMetric(pressure: Float) -> Float {
        let pAir: Float = surfaceHpaPressure // hPa
        let gravAcc: Float = 9.8 // kg/(m * s^2)
        var specGravWater: Float = 1000.0 // kg/m^3
        
        
        let depth: Float = (pressure * 1000.0 - pAir) / (specGravWater * gravAcc / 100.0)
        return depth < 0 ? 0 : depth
    }
}

extension DivingDataManager {
    public func passDataFromBluetooth(pressure: Float, temperature: Float, battery: Int) {
        DispatchQueue.global(qos: .utility).sync {
            self.depth = pressureToDepthMetric(pressure: pressure)
            self.temperature = temperature
            /// 배터리 메서드 필요
            self.battery = battery
        }
    }
}

