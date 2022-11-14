//
//  CameraPreviewView.swift
//  Test-Headshot
//
//  Created by Doug on 2019-11-23.
//  Copyright © 2019 Shodu Ltd. All rights reserved.
//
import SwiftUI
import UIKit
import GPUImage
import AVFoundation

class DeviceSetup {
    enum DeviceModelName: String {
        
        case undefined
        case iPodTouch5
        case iPodTouch6
        case iPhone4
        case iPhone4s
        case iPhone5
        case iPhone5c
        case iPhone5s
        case iPhone6
        case iPhone6Plus
        case iPhone6s
        case iPhone6sPlus
        case iPhone7
        case iPhone7Plus
        case iPhoneSE
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhoneXS
        case iPhoneXSMax
        case iPhoneXR
        case iPad2
        case iPad3
        case iPad4
        case iPadAir
        case iPadAir2
        case iPad5
        case iPad6
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadPro97Inch
        case iPadPro129Inch
        case iPadPro129Inch2ndGen
        case iPadPro105Inch
        case iPadPro11Inch
        case iPadPro129Inch3rdGen
        case AppleTV
        case AppleTV4K
        case HomePod
    }
    
    /// pares the deveice name as the standard name
    var modelName: DeviceModelName {
        
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
        
        switch identifier {
        case "iPod5,1":                                 return .iPodTouch5
        case "iPod7,1":                                 return .iPodTouch6
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return .iPhone4
        case "iPhone4,1":                               return .iPhone4s
        case "iPhone5,1", "iPhone5,2":                  return .iPhone5
        case "iPhone5,3", "iPhone5,4":                  return .iPhone5c
        case "iPhone6,1", "iPhone6,2":                  return .iPhone5s
        case "iPhone7,2":                               return .iPhone6
        case "iPhone7,1":                               return .iPhone6Plus
        case "iPhone8,1":                               return .iPhone6s
        case "iPhone8,2":                               return .iPhone6sPlus
        case "iPhone9,1", "iPhone9,3":                  return .iPhone7
        case "iPhone9,2", "iPhone9,4":                  return .iPhone7Plus
        case "iPhone8,4":                               return .iPhoneSE
        case "iPhone10,1", "iPhone10,4":                return .iPhone8
        case "iPhone10,2", "iPhone10,5":                return .iPhone8Plus
        case "iPhone10,3", "iPhone10,6":                return .iPhoneX
        case "iPhone11,2":                              return .iPhoneXS
        case "iPhone11,4", "iPhone11,6":                return .iPhoneXSMax
        case "iPhone11,8":                              return .iPhoneXR
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return .iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3":           return .iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6":           return .iPad4
        case "iPad4,1", "iPad4,2", "iPad4,3":           return .iPadAir
        case "iPad5,3", "iPad5,4":                      return .iPadAir2
        case "iPad6,11", "iPad6,12":                    return .iPad5
        case "iPad7,5", "iPad7,6":                      return .iPad6
        case "iPad2,5", "iPad2,6", "iPad2,7":           return .iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6":           return .iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9":           return .iPadMini3
        case "iPad5,1", "iPad5,2":                      return .iPadMini4
        case "iPad6,3", "iPad6,4":                      return .iPadPro97Inch
        case "iPad6,7", "iPad6,8":                      return .iPadPro129Inch
        case "iPad7,1", "iPad7,2":                      return .iPadPro129Inch2ndGen
        case "iPad7,3", "iPad7,4":                      return .iPadPro105Inch
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return .iPadPro11Inch
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return .iPadPro129Inch3rdGen
        case "AppleTV5,3":                              return .AppleTV
        case "AppleTV6,2":                              return .AppleTV4K
        case "AudioAccessory1,1":                       return .HomePod
            
        default:                                        return .undefined
        }
    }
    
    
    /// pares the deveice name as the standard name
    var maxResolution: (AVCaptureSession.Preset , Int) {
        
        
        
        
        switch modelName {
        case .iPodTouch5 :       return (.hd1280x720, 30)
        case .iPodTouch6 :       return (.hd1280x720, 30)
        case .iPhone4    :       return (.hd1280x720, 30)
        case .iPhone4s   :       return (.hd1280x720, 30)
        case .iPhone5    :       return (.hd1280x720, 30)
        case .iPhone5c   :       return (.hd1280x720, 30)
        case .iPhone5s   :       return (.hd1280x720, 30)
        case .iPhone6    :       return (.hd1920x1080, 60)
        case .iPhone6Plus:       return (.hd1920x1080, 60)
        case .iPhone6s   :       return (.hd1920x1080, 60)
        case .iPhone6sPlus:      return (.hd1920x1080, 60)
        case .iPhone7    :       return (.hd4K3840x2160, 30)
        case .iPhone7Plus:       return (.hd4K3840x2160, 30)
        case .iPhoneSE   :       return (.hd1920x1080, 60)
        case .iPhone8    :       return (.hd4K3840x2160, 60)
        case .iPhone8Plus:       return (.hd4K3840x2160, 60)
        case .iPhoneX    :       return (.hd4K3840x2160, 60)
        case .iPhoneXS   :       return (.hd4K3840x2160, 60)
        case .iPhoneXSMax:       return (.hd4K3840x2160, 60)
        case .iPhoneXR   :       return (.hd4K3840x2160, 60)
        case .iPad2      :       return (.hd1280x720, 30)
        case .iPad3      :       return (.hd1280x720, 30)
        case .iPad4      :       return (.hd1280x720, 30)
        case .iPadAir    :       return (.hd1280x720, 30)
        case .iPadAir2   :       return (.hd1280x720, 30)
        case .iPad5      :       return (.hd1280x720, 30)
        case .iPad6      :       return (.hd1280x720, 30)
        case .iPadMini   :       return (.hd1280x720, 30)
        case .iPadMini2  :       return (.hd1280x720, 30)
        case .iPadMini3  :               return (.hd1280x720, 30)
        case .iPadMini4  :               return (.hd1280x720, 30)
        case .iPadPro97Inch  :           return (.hd1280x720, 30)
        case .iPadPro129Inch :           return (.hd1280x720, 30)
        case .iPadPro129Inch2ndGen  :   return (.hd1280x720, 30)
        case .iPadPro105Inch :           return (.hd1280x720, 30)
        case .iPadPro11Inch  :          return (.hd1280x720, 30)
        case .iPadPro129Inch3rdGen   :return (.hd1280x720, 30)
        case .AppleTV    :           return (.hd1280x720, 30)
        case .AppleTV4K  :           return (.hd1280x720, 30) //
        case  .HomePod   :           return (.hd1280x720, 30)
            
        default:         return (.hd4K3840x2160, 60)
        }
    }
    
    
    public var maxEncodeResolution:   (Int, String)  {
        
        
        
        
        switch modelName {
        case .iPodTouch5 :       return (1920 * 1080, "qhd")
        case .iPodTouch6 :       return (1920 * 1080, "qhd")
        case .iPhone4    :       return (1920 * 1080, "qhd")
        case .iPhone4s   :       return (1920 * 1080, "qhd")
        case .iPhone5    :       return (1920 * 1080, "qhd")
        case .iPhone5c   :       return (1920 * 1080, "qhd")
        case .iPhone5s   :       return (1920 * 1080, "qhd")
        case .iPhone6    :       return (1920 * 1080, "qhd")
        case .iPhone6Plus:       return (1920 * 1080, "qhd")
        case .iPhone6s   :       return (3840 * 2160, "uhd")
        case .iPhone6sPlus:      return (3840 * 2160, "uhd")
        case .iPhone7    :       return (3840 * 2160, "uhd")
        case .iPhone7Plus:       return (3840 * 2160, "uhd")
        case .iPhoneSE   :       return (3840 * 2160, "uhd")
        case .iPhone8    :       return (3840 * 2160, "uhd")
        case .iPhone8Plus:       return (3840 * 2160, "uhd")
        case .iPhoneX    :       return (3840 * 2160, "uhd")
        case .iPhoneXS   :       return (3840 * 2160, "uhd")
        case .iPhoneXSMax:       return (3840 * 2160, "uhd")
        case .iPhoneXR   :       return (3840 * 2160, "uhd")
        case .iPad2      :       return (3840 * 2160, "uhd")
        case .iPad3      :       return (3840 * 2160, "uhd")
        case .iPad4      :       return (3840 * 2160, "uhd")
        case .iPadAir    :       return (3840 * 2160, "uhd")
        case .iPadAir2   :       return (3840 * 2160, "uhd")
        case .iPad5      :       return (3840 * 2160, "uhd")
        case .iPad6      :       return (3840 * 2160, "uhd")
        case .iPadMini   :       return (3840 * 2160, "uhd")
        case .iPadMini2  :       return (3840 * 2160, "uhd")
        case .iPadMini3  :               return (3840 * 2160, "uhd")
        case .iPadMini4  :               return (3840 * 2160, "uhd")
        case .iPadPro97Inch  :           return (3840 * 2160, "uhd")
        case .iPadPro129Inch :           return (3840 * 2160, "uhd")
        case .iPadPro129Inch2ndGen  :   return (3840 * 2160, "uhd")
        case .iPadPro105Inch :           return (3840 * 2160, "uhd")
        case .iPadPro11Inch  :          return (3840 * 2160, "uhd")
        case .iPadPro129Inch3rdGen   :return (3840 * 2160, "uhd")
        case .AppleTV    :           return (3840 * 2160, "uhd")
        case .AppleTV4K  :           return (3840 * 2160, "uhd")
        case  .HomePod   :           return (3840 * 2160, "uhd")
            
        default:         return (3840 * 2160, "uhd")
        }
    }
    
    
    
    
}


class CameraViewController : UIViewController {
    
    // GPUImage3 returns video output to a RenderView. Have tried different ways of doing this, but setting up as an IBOutlet works
    
   @IBOutlet weak var filterView: RenderView?
    
    var screenRect: CGRect! = nil
    
    var videoCamera: Camera?
    public var subViews : Array<UIViewController> = Array<UIViewController>()
    public static var isFiltering : Bool = true
    var filterOperation: FilterOperationInterface?
    var currentPreFilter : RGBSampleAdjustment!
    var currentFilter : WaterAdjustment!

   
    deinit {
       print("deinit RealtimeViewController");
    }
    
    func loadCamera() {
        
        screenRect = UIScreen.main.bounds
        var finalView: RenderView! = RenderView(frame: CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height))

        do {
            videoCamera = try Camera(sessionPreset: .hd1920x1080, orientation: .portraitUpsideDown)
            guard let videoCamera = videoCamera else {
                return
            }
            if let currentFilterConfiguration = self.filterOperation {
                self.title = currentFilterConfiguration.titleName
                
                // Configure the filter chain, ending with the view
              
                    switch currentFilterConfiguration.filterOperationType {
                    case .singleInput:
                        
                        var filter = RGBSampleAdjustment()
                        videoCamera.addTarget( filter )
                        currentPreFilter = filter;
                        var water  = WaterAdjustment(useYUV : true);
                        currentFilter = water;
                        filter.addTarget(water)
                        water.addTarget(finalView)
                        
                    case .blend:
                        videoCamera.addTarget(currentFilterConfiguration.filter)
                        currentFilterConfiguration.filter.addTarget(finalView)
                    case let .custom(filterSetupFunction:setupFunction):
                        currentFilterConfiguration.configureCustomFilter(setupFunction(videoCamera, currentFilterConfiguration.filter, finalView))
                    }
                    
                    videoCamera.startCapture()
                    view.addSubview(finalView)
                
            }
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        finalView.isReverse = false;
        FilterPreProcessor_setEnabled(1)
        FilterPreProcessor_setStrength(1)

        var filterInList  = FilterOperation(
            filter:{
                
                WaterAdjustment()
                
        },
            
            
            
            listName:"Water",
            titleName:"Water",
            sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
            sliderUpdateCallback: {(filter, sliderValue) in
                filter.inputValueScaleAll = sliderValue
        },
            filterOperationType:.singleInput
        )
        
        // var filterInList  = filterOperations[6];
        filterOperation = filterInList
        
        
        
        self.loadCamera()
        
        
    }
    
    

}


// Testing showing a video preview which is "live filtered" using GPUImage3
// We use a UIViewControllerRepresentable as the bridge between our UIViewController and Swift
struct FilteredVideoPreviewView: UIViewControllerRepresentable  {
   
    func makeUIViewController(context: UIViewControllerRepresentableContext<FilteredVideoPreviewView>) -> UIViewController {
        let controller = CameraViewController()
        return controller
    }
    
    // No values change so no need to return anything
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<FilteredVideoPreviewView>) {
        
    }
}
