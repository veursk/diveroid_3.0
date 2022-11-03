//
//  FrameManager.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import AVFoundation
import Photos
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class FrameManager: NSObject, ObservableObject {
    
    static let shared = FrameManager()
    var isSavingFrame = false
    
    @Published var current: CVPixelBuffer?
    
    let videoOutputQueue = DispatchQueue(label: "videoOutputQ", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    let processingQueue = DispatchQueue(label: "photoProcessingQueue", attributes: [], autoreleaseFrequency: .workItem)
    /// 공부 필요
    
    private override init() {
        super.init()
        CameraManager.shared.set(self, queue: videoOutputQueue)
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /// Frame Capture하는 함수
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let buffer = sampleBuffer.imageBuffer {
            DispatchQueue.main.async {
                self.current = buffer
            }
            
            if isSavingFrame == true {
                saveFrame(sampleBuffer: buffer)
                isSavingFrame = false
            }
        }
    }
    
    
    /// 사진찍기전에 처음 가입 시 권한 받아야함
    func saveFrame(sampleBuffer: CVImageBuffer) {
        let videoPixelBuffer = sampleBuffer
        let cameraImage = CIImage(cvImageBuffer: videoPixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(cameraImage, from: cameraImage.extent) else {return}
        
        let finalImage = UIImage(cgImage: cgImage)
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
                } completionHandler: { errSecSuccess, eroor in
                    print("아직 개발 안함")
                }
            }
        }
    }
}
