//
//  SharedDivingSession.swift
//  DiveroidRenewal-iOS
//
//  Created by YoungWoon Lee on 30/10/2019.
//  Copyright © 2019 Artisan&Ocean co.,ltd. All rights reserved.
//

import UIKit

enum StopStatus: String {
    case NONE = "NONE"
    case ALLOW = "ALLOW"
    case DOWN_RECOMMEND = "DOWN_RECOMMEND"
    case DOWN_FORCE = "DOWN_FORCE"
    case UP_RECOMMEND = "UP_RECOMMEND"
    case UP_FORCE = "UP_FORCE"
}

enum Level {
    case Hard
    case Middle
    case Deco//leess 20220613 데코모드진입 경고 추가
    case Depth//수심알람
    case Time//시간알람
}

protocol DivingWarningDelegate: NSObjectProtocol {
    func alertWarning( level : Level )
    func updateVelocity( velocity : Float ) // 0~1
    func updateUI(divingStarted: Bool)
    func divingStarted()
    func dismissDiveComputer()
}

extension SharedDivingSession {

    //다이빙화면 나가기 버튼 눌렀을때 동작
    public func finishSession() {
        if isRecording {
            isFinishAfterVideoSaved = true
            //TODO: 다이빙 컴퓨터에서 처리
            //[[DiveComputerWrapperVC shared] actionFullPressed];
            return
        }
        
        BluetoothManager.shared.disconnectDevice(isReConnect: true)

        if Utility.develop.isDivingMan30 {
            if let divingMan30 = self.getDivingMan30() {
                divingMan30.addSensorData(pressure: 1.013, depth: 0, temp: divingMan30.temperature, elapsedTime: divingMan30.elapsedTime)
                
                //isDivingStart 값에 따른 분기
                if divingMan30.isDivingStart {
                    divingMan30.finishDiving()
                } else {
                    divingMan30.saveMediaOnly()
                }
            }
        } else {
            if let divingManager = self.getDivingManager() {
                divingManager.addSensorData(pressure: 1.013, depth: 0, temp: divingManager.temperature, elapsedTime: divingManager.elapsedTime, index: nil)
                
                //isDivingStart 값에 따른 분기
                if divingManager.getDivingStartStatus() {
                    divingManager.finishDiving()
                } else {
                    divingManager.saveMediaOnly()
                }
            }
        }

        LogbookMainController.updateData = true
        initSessionVariables()
        //TODO: 화면 처리
    }
    
    public func passDivingHardwareInput(pressure: Float, temperature: Float, battery: Int) {
        
        DispatchQueue.global(qos: .utility).sync {
            if !self.reconnetBleOnDisconnect {
                UserManager.realm.updateMiniBattery(battery)
            }
            
            if Utility.develop.isDivingMan30 {
                if let divingMan30 = self.getDivingMan30() {
                    if !DivingDataManager.debug {
                        self.pressure = pressure
                    }
                    self.depth = divingMan30.pressureToDepthMetric(pressure: self.pressure, temperature: temperature)
                    self.temperature = temperature
                    self.battery = Int(self.getAverageBattery(battery: Float(battery)))
                    divingMan30.initDivingManager(barPress: self.pressure, temp: self.temperature)
                }
            } else {
                if let divingManager = self.getDivingManager() {
                    if divingManager.isDivingEndingProcess { return }
                    
                    if !DivingDataManager.debug {
                        self.pressure = pressure
                    }
                    self.depth = divingManager.pressureToDepthMetric(pressure: self.pressure, temperature: temperature)
                    self.temperature = temperature
                    self.battery = Int(self.getAverageBattery(battery: Float(battery)))
                    divingManager.initDivingManager(barPress: self.pressure, temp: self.temperature)
                }
            }
        }
    }
    
    public func getTargetBrightness() -> Float {
        return Float(UIScreen.main.brightness)
    }
    
    public func setTargetBrightness(brightness: Float) {
        DispatchQueue.main.async {
            UIScreen.main.brightness = CGFloat(brightness)
        }
    }
    
    public func setPowerSaveMode(powerSaveMode: Bool) {
        if !isViewDidLoad { return }
        if isPowerSaveMode == powerSaveMode { return }
        if !isPowerSaveMode && isRecording { return }
        
        if !powerSaveMode { self.lastActiveTime = Double(Date().toMs) }
        
        self.isPowerSaveMode = powerSaveMode
        
        if isPowerSaveMode && !isRecording {
            brightness = UIScreen.main.brightness
            setTargetBrightness(brightness: 0.1)
        } else {
            setTargetBrightness(brightness: Float(brightness))
        }
        
        //TODO: PowerSaveMode 켜는 동작
    }
    
    public func getAverageBattery(battery: Float) -> Float {
        if isDebugMode && !isBatterySamplingCompleted && battery != 0 {
            batterySamples[batterySamplingCount] = battery
            batterySamplingCount += 1
            
            if batterySamplingCount >= BATTERY_SAMPLING_NUM {
                isBatterySamplingCompleted = true
                var total: Float = 0
                
                for index in (0..<BATTERY_SAMPLING_NUM) {
                    total += batterySamples[index]
                }
                
                avgBattery = total / Float(BATTERY_SAMPLING_NUM)
            }
        }
        
        return avgBattery
    }
    
    public func addMediaData(fileName: String, imageStringData: String, type: RealmDivingDataType = .PHOTO) {
        if Utility.develop.isDivingMan30 {
            if let divingMan30 = self.getDivingMan30() {
                divingMan30.addMediaData(fileName: fileName, minimumMediaFileString: imageStringData, type: type)
            }
        } else {
            if let manager = getDivingManager() {
                manager.addMediaData(fileName: fileName, minimumMediaFileString: imageStringData, type: type)
            }
        }
    }
    
    public func updateWarning() {
        //TODO: 화면 처리
    }
    
    //DivingManager initUI()에서 호출함
    public func clearUI() {
        self.isCriticalDepth = false
        self.isFastUp = false
        self.isDeco = false
        self.isDeepStop = false
        self.isSafetyStop = false
        self.isSafetyStopStarted = false
        self.isDecoStarted = false
        self.isDeepStopStarted = false
        self.isBackToStop = false
        self.isOxygenToxicity = false
        self.isRemainTimeWarning = false
        
        self.safetyStopTime = 0
        self.deepStopTime = 0
        self.decoTime = 0
        self.backToStopTime = 0
        self.backToStopDepth = 0
        self.safetyStopDepth = 0
        self.deepStopDepth = 0
        self.decoDepth = 0
        self.curStopStatus = .NONE
        self.oxygenToxicityLimitDepth = 0
        
        self.divingTime = 0
    }
    
    public func showFinishDivingView() {
        //TODO: 화면 처리
    }
    
    public func removeFinishDivingView() {
        //TODO: 화면 처리
    }
    
    public func interruptDivingFinish() {
//        finishSession()
//        divingManager?.finishDiving()
        delegate?.dismissDiveComputer()
    }
    
    public func getElapsedTime() -> Int {
        if Utility.develop.isDivingMan30 {
            if let divingMan30 = self.getDivingMan30() {
                return Int(divingMan30.getElapsedTime())
            } else {
                return -1
            }
        } else {
            guard let manager = getDivingManager() else { return -1 }
            
            //leess : 계산된 값 말고 지금 계산해서 가져오는 걸로 변경(계산된값은 3초간격..)
            //return Int(manager.getDivingTime())
            return Int(manager.getElapsedTime())
        }
    }
    
    public func getAscTime() -> Float {
        if Utility.develop.isDivingMan30 {
            guard let divingMan30 = getDivingMan30() else { return -1 }
            return divingMan30.getAscTime()
        } else {
            guard let manager = getDivingManager() else { return -1 }
            return manager.getAscTime()
        }
    }

    //DiveComputerMainViewController viewDidLoad() 에서 호출
    public func resetDiving() {
        if Utility.develop.isDivingMan30 {
            guard let divingMan30 = getDivingMan30() else { return }
            var saltWater = !RealmWaterType(rawValue: config.seaType)!.asInt().boolValue
            divingMan30.initDiving(saltWater: saltWater)
        } else {
            guard let manager = getDivingManager() else { return }
            manager.initDiving()
        }
    }
    
    public func getDivePlanValue(ean: Int) -> [Int] {
        if Utility.develop.isDivingMan30 {
            return DivingMan30.getDivePlanValue(isMetric: config.isMeter, isSaltWater: !RealmWaterType(rawValue: config.seaType)!.asInt().boolValue, divingStatusObject: DivingDataManager.shared.status, ean: ean, healhCondition: RealmHealthCondition(rawValue: config.healthCondition)!)
        } else {
            return DivingManager.getDivePlanValue(isMetric: config.isMeter, isSaltWater: !RealmWaterType(rawValue: config.seaType)!.asInt().boolValue, divingStatusObject: DivingDataManager.shared.status, ean: ean, healhCondition: RealmHealthCondition(rawValue: config.healthCondition)!)
        }
    }
    
    public func hasUnsavedImage() -> Bool {
        if Utility.develop.isDivingMan30 {
            guard let divingMan30 = getDivingMan30() else { return false }
            if divingMan30.tmpMediaList.count > 0 { return true }
            return false
        } else {
            guard let manager = getDivingManager() else { return false }
            if manager.tmpMediaList.count > 0 { return true }
            return false
        }
    }
}


//MARK:- SharedDivingSession Value Init function
extension SharedDivingSession {
    public func initSessionVariables() {
        self.config = UserManager.shared.config
        //TODO config로 아래 내용 업뎃
        self.unitSystem = RealmUnitySystem(rawValue: config.unitSystem) ?? RealmUnitySystem.METRIC
        self.housingMode = RealmHousingMode(rawValue: config.housingMode) ?? RealmHousingMode.UNIVERSAL
        self.healthCondition = RealmHealthCondition(rawValue: config.healthCondition)!.asInt()
        self.isSeaWater = config.seaType == RealmWaterType.SEA.rawValue
        self.ean = Int32(config.nitrox)
        
        self.lastActiveTime = 0
        self.depth = 0
        self.pressure = 0
        self.temperature = 0
        self.degree = 0
        self.ndl = 90
        self.battery = -1
        self.latitude = 0
        self.longitude = 0
        self.brightness = UIScreen.main.brightness
        
        self.isDivingFinishView = false
        self.isFinishAfterVideoSaved = false
        self.isFinishAndContinueAfterVideoSaved = false//leess 의미없는걸로 보여지는데...
        self.isMiniHasProblem = false
        self.isAlertMiniProblem = false
        
        self.isSimulationMode = false
        self.isDebugMode = false
        self.isDebugControlMode = false

        self.isPowerSaveMode = false
        self.isPreviewMode = false
        self.isSummaryShown = false
        

        self.connectionType = 0
        
        self.isSelfieMode = false
        self.isSuperWideMode = false
        self.isRecording = false
        self.modeSelectPopupItemNum = 3
        self.modeSelectPopupPosition = 0
        
        self.summaryShownTime = 0

        
        self.isAutoPowerSave = true
        self.isViewDidLoad = false
        self.isBatterySamplingCompleted = false
        self.batterySamplingCount = 0
        self.avgBattery = -1
        
        self.batterySamples = [Float]()
        
        if DiveMainController.selectedDiving == .freeDiving {
             self.freeDivingManager = FreeDivingManager()
        } else {
             if Utility.develop.isDivingMan30 {
                 self.divingMan30 = DivingMan30()
             } else {
                 self.divingManager = DivingManager()
             }
        }
        
        if Utility.develop.isDivingMan30 {
            getDivingMan30()?.initDiving()
        } else {
            getDivingManager()?.initDiving()
        }
    }
    
    //leess : private -> public
    public func getDivingManager() -> DivingManager? {
        if DiveMainController.selectedDiving == .scubaDiving {
            if divingManager == nil {
                divingManager = DivingManager()
            }
            return divingManager
        } else {
            if freeDivingManager == nil {
                freeDivingManager = FreeDivingManager()
            }
            return freeDivingManager
        }
    }
    
    //leess DivingMan30
    public func getDivingMan30() -> DivingMan30? {
        if divingMan30 == nil {
            divingMan30 = DivingMan30()
        }
        return divingMan30
    }
}


class SharedDivingSession: NSObject {
    static let shared = SharedDivingSession()
    static let freeShared = FreeDivingSession()
    public var divingManager: DivingManager?
    public var freeDivingManager: DivingManager?
    
    //leess DivingMan30
    public var divingMan30: DivingMan30?
    
    fileprivate let BATTERY_SAMPLING_NUM = 5
    
    public var config = UserManager.shared.config
    
    //SessionVariable
    public var reconnetBleOnDisconnect = false
    public var housingMode: RealmHousingMode = .UNIVERSAL
    public var unitSystem: RealmUnitySystem = .METRIC
    public var isSeaWater: Bool = true
    public var ean: Int32 = 0
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    
    //MARK:- 화면에 갱신되어야 되는 데이터들
    public var divingTime: Int = 0
    public var lastActiveTime: Double = 0
    public var depth: Float = 0.0
    public var pressure: Float = 0.0
    public var temperature: Float = 0.0
    public var degree: Float = 0.0
    public var ndl: Int = 0
    public var battery: Int = 0
    public var brightness: CGFloat = UIScreen.main.brightness
    
    //MARK:- 상태 저장
    public var isDivingFinishView: Bool = false
    public var isFinishAfterVideoSaved: Bool = false
    public var isFinishAndContinueAfterVideoSaved: Bool = false
    public var isMiniHasProblem: Bool = false
    public var isAlertMiniProblem: Bool = false
    
    /* Current Diving Status */
    public var isSimulationMode: Bool = false
    public var isDebugMode: Bool = false
    public var isDebugControlMode: Bool = false
    
    public var isPowerSaveMode: Bool = false
    public var isPreviewMode: Bool = false
    public var isSummaryShown: Bool = false
    public var isDivingStarted: Bool {
        get { return getDivingManager()?.getDivingStartStatus() ?? false }
    }
    
    public var isMetric: Bool {
        get { return unitSystem == .METRIC }
    }
    
    /* Warning */
    public var isCriticalDepth: Bool = false
    public var isFastUp: Bool = false
    public var isDeco: Bool = false
    public var isDeepStop: Bool = false
    public var isSafetyStop: Bool = false
    public var isDecoStarted: Bool = false
    public var isDeepStopStarted: Bool = false
    public var isSafetyStopStarted: Bool = false
    public var isBackToStop: Bool = false
    public var isOxygenToxicity: Bool = false
    public var isRemainTimeWarning: Bool = false
    
    public var healthCondition: Int = 1
    public var safetyStopTime: Float = 0
    public var deepStopTime: Float = 0
    public var decoTime: Float = 0
    public var backToStopTime: Float = 0
    public var backToStopDepth: Float = 0
    public var safetyStopDepth: Float  = 0//leess Int->Float변경(통일성 위해)
    public var deepStopDepth: Float  = 0
    public var decoDepth: Float  = 0
    public var connectionType: Int = 0
    
    public var isSelfieMode: Bool = false
    public var isSuperWideMode: Bool = false
    public var isRecording: Bool = false
    public var modeSelectPopupItemNum: Int = 3
    public var modeSelectPopupPosition: Int = 0
    
    public var curStopStatus : StopStatus = .NONE
    
    /* Time Variables */
    public var summaryShownTime: Float = 0.0
    
    public var oxygenToxicityLimitDepth: Int = 0
    public var isAutoPowerSave: Bool = false
    public var isViewDidLoad: Bool = false
    public var isBatterySamplingCompleted: Bool = false
    public var batterySamplingCount: Int = 0
    public var avgBattery: Float = -1
    
    public var batterySamples: [Float] = [Float]()
    public weak var delegate : DivingWarningDelegate?
    
    public override init() {
        super.init()
        
        self.initSessionVariables()
    }
}
