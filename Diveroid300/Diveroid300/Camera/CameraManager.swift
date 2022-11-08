//
//  CameraManager.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import AVFoundation
import Photos

class CameraManager: NSObject, ObservableObject {
    
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    
    @Published var error: CameraError?
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    /// 공부 필요
    ///
    private let sessionQueue = DispatchQueue(label: "cameraSessionQ")
    let session = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var audioDevice: AVCaptureDevice?
    var audioInput: AVCaptureDeviceInput?
    
    private var status = Status.unconfigured
    static let shared = CameraManager()
    
    // discoverySession도 다시 체크 필요함(기기별)
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                                             .builtInWideAngleCamera],
                                                                               mediaType: .video,
                      
                                                                               
                                                                               position: .unspecified)
    /// Singleton으로 구현
    private override init() {
        super.init()
        configure()
    }
    
    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    ///main Queue 왜 써야하는 지 아직 모름...
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            set(error: .restrictedAuthorization)
        case .denied:
            status = .unauthorized
            set(error: .deniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
            set(error: .unknownAuthorization)
        }
    }
    
    private func configureCaptureSession() {
        guard status == .unconfigured else {return}
        
        session.beginConfiguration()
        
        /// 혹시를 대비해서 defer 사용
        defer {
            session.commitConfiguration()
        }
        
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard let camera = device else {
            set(error: .cameraUnavailable)
            status = .failed
            return
        }
        
        do {
            input = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(input!) {
                session.addInput(input!)
            } else {
                set(error: .cannotAddInput)
                status = .failed
                return
            }
        } catch {
            set(error: .createCaptureInput(error))
            status = .failed
            return
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.videoSettings =
                [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            /// Video Setting 이 부분 필요함
        } else {
            set(error: .cannotAddOutput)
            status = .failed
            return
        }
        
        session.sessionPreset = .hd4K3840x2160
        /// 일단 4K로 설정함 (4K 지원여부 따져봐야함)
        /// 기기별 설정 필요
        status = .configured
    }
    
    private func configure() {
        checkPermission()
        sessionQueue.async {
            self.configureCaptureSession()
            self.session.startRunning()
        }
    }
    
    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
    
    
    /* SetRecording 함수는 SessionQueue에서 뺐음. StateObject 쓰려고 한 이유. + 굳이 세션큐에 안 넣어도 상관 없음? */
    func setRecording() {
        
            print("setRecording 시작1")
            self.session.beginConfiguration()
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {return}
            print("setRecording 시작2")

            do {
                print("setRecording 시작3")

                try self.audioInput = AVCaptureDeviceInput(device: audioDevice)
                
                if self.session.canAddInput(self.audioInput!) {
                    self.session.addInput(self.audioInput!)
                    self.audioDevice = audioDevice
                }
                
                self.session.removeOutput(self.videoOutput)
                
                if self.session.canAddOutput(self.movieOutput) {
                    self.session.addOutput(self.movieOutput)
                }
                
                self.session.commitConfiguration()
                
            } catch {
                print("setRecording 시작4")

                print(error.localizedDescription)
            }

            self.isRecording = true

    }
    
    func startRecording() {
        /// SessinQueue에 안 집어넣으면 에러발생.
        sessionQueue.async {
            print("startRecording 시작1")

            // TEMPORARY URL FOR RECORDING VIDEO
            let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
            self.movieOutput.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
            print("startRecording 시작2")
        }
        

    }
    
    /* stopRecording 함수도 SessionQueue에 집어넣어야 하는 지 체크 필요.*/
    func stopRecording() {
        print("stopRecording 시작1")

        self.movieOutput.stopRecording()
        print("stopRecording 시작2")

        print("stopRecording 시작3")

        print("stopRecording 시작4")

        /// 여기다가 넣으면 error 발생
//        self.session.removeOutput(self.movieOutput)
//
//        if self.session.canAddOutput(self.videoOutput) {
//            print("stopRecording 시작6")
//
//            self.session.addOutput(self.videoOutput)
//            print("stopRecording 시작7")
//
//            }
        
    }
    
    
    func switchCamera() {
        sessionQueue.async {
            let currentVideoDevice = self.input!.device
            var preferredPosition = AVCaptureDevice.Position.unspecified
            
            switch currentVideoDevice.position {
            case .unspecified, .front:
                preferredPosition = .back
                
            case .back:
                preferredPosition = .front
                
            @unknown default:
                fatalError("Unknown video device position.")
            }
            
            let devices = self.videoDeviceDiscoverySession.devices
            
            if let videoDevice = devices.first(where: { $0.position == preferredPosition }) {
                var videoInput: AVCaptureDeviceInput
                do {
                    videoInput = try AVCaptureDeviceInput(device: videoDevice)
                } catch {
                    print("Could not create video device input: \(error)")
                    return
                }
                
                self.session.beginConfiguration()
                self.session.removeInput(self.input!)
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    self.input = videoInput
                } else {
                    print("Could not add video device input to the session")
                    self.session.addInput(self.input!)
                }
                
                if preferredPosition == .front {
                    let videoConnection = self.videoOutput.connection(with: .video)
                    videoConnection?.videoOrientation = .landscapeRight
                    videoConnection?.isVideoMirrored = true
                }
                
                self.session.commitConfiguration()
            }
        }
    }
    
    /// changeCameraOption Method는 Camera Unavailable 발생
    /// switchCamera Method는 문제 없음..
    /// 테스트 실기기인 아이폰 11 (Green)에 .builtindual camera를 지원안함... -> 어쨌든 dual camera 안쓸거지만.. 이유는 찾음
    
    func changCameraOptionModified(CameraOptionName: Constants.CameraOptionName) {
        sessionQueue.async {
            
            defer {
                self.session.commitConfiguration()
            }
            
            switch CameraOptionName {
            case Constants.CameraOptionName.WideCameraOption:
                guard let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else {
                    self.set(error: .cameraUnavailable)
                    self.status = .failed
                    return
                }
                
                var videoInput: AVCaptureDeviceInput
                
                do {
                    videoInput = try AVCaptureDeviceInput(device: device)
                } catch {
                    print("Could not create video device inputL \(error)")
                    return
                }
                
                self.session.beginConfiguration()
                
                self.session.removeInput(self.input!)
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    self.input = videoInput
                } else {
                    print("Could not add video device input to the session")
                    self.session.addInput(self.input!)
                }
                
            case Constants.CameraOptionName.NormalCameraOption:
                guard let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else {
                    self.set(error: .cameraUnavailable)
                    self.status = .failed
                    return
                }
                
                var videoInput: AVCaptureDeviceInput
                
                do {
                    videoInput = try AVCaptureDeviceInput(device: device)
                } catch {
                    print("Could not create video device inputL \(error)")
                    return
                }
                
                self.session.beginConfiguration()
                
                self.session.removeInput(self.input!)
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    self.input = videoInput
                } else {
                    print("Could not add video device input to the session")
                    self.session.addInput(self.input!)
                }
                
            case Constants.CameraOptionName.ZoomCameraOption:
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    self.set(error: .cameraUnavailable)
                    self.status = .failed
                    return
                }
                
                var videoInput: AVCaptureDeviceInput
                
                do {
                    videoInput = try AVCaptureDeviceInput(device: device)
                } catch {
                    print("Could not create video device inputL \(error)")
                    return
                }
                
                self.session.beginConfiguration()
                
                self.session.removeInput(self.input!)
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    self.input = videoInput
                } else {
                    print("Could not add video device input to the session")
                    self.session.addInput(self.input!)
                }
                
                // Zoom 설정 구현 코드
                // Catch문 수정 필요
            
                do {
                    try device.lockForConfiguration()
                    device.videoZoomFactor = 2.0
                    device.unlockForConfiguration()
                } catch {
                    
                }
                
            case Constants.CameraOptionName.SelfieCameraOption:
                // 그냥 여기다가 구현할까..?
                // 아니면 switch method 사용할까..?
                
                let currentVideoDevice = self.input!.device
                var preferredPosition = AVCaptureDevice.Position.unspecified
                
                switch currentVideoDevice.position {
                case .unspecified, .front:
                    preferredPosition = .back
                    
                case .back:
                    preferredPosition = .front
                    
                @unknown default:
                    fatalError("Unknown video device position.")
                }
                
                let devices = self.videoDeviceDiscoverySession.devices
                
                if let videoDevice = devices.first(where: { $0.position == preferredPosition}) {
                    var videoInput: AVCaptureDeviceInput
                    
                    do {
                        videoInput = try AVCaptureDeviceInput(device: videoDevice)
                    } catch {
                        print("Could not create video device input: \(error)")
                        return
                    }
                    
                    self.session.beginConfiguration()
                    self.session.removeInput(self.input!)
                    
                    if self.session.canAddInput(videoInput) {
                        self.session.addInput(videoInput)
                        self.input = videoInput
                    } else {
                        print("Could not add video device input to the session")
                        self.session.addInput(self.input!)
                    }
                    
                    // 전면의 경우 상하좌우 수정해줘야 함.
                    if preferredPosition == .front {
                        let videoConnection = self.videoOutput.connection(with: .video)
                        videoConnection?.videoOrientation = .landscapeRight
                        videoConnection?.isVideoMirrored = true
                    }
                    
                }
                
            }
            
            
            
            
            
//            guard let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else {
//                self.set(error: .cameraUnavailable)
//                self.status = .failed
//                return
//            }
//
//            var videoInput: AVCaptureDeviceInput
//
//            do {
//                videoInput = try AVCaptureDeviceInput(device: device)
//            } catch {
//                print("Could not create video device inputL \(error)")
//                return
//            }
//
//            self.session.beginConfiguration()
//
//            self.session.removeInput(self.input!)
//
//            if self.session.canAddInput(videoInput) {
//                self.session.addInput(videoInput)
//                self.input = videoInput
//            } else {
//                print("Could not add video device input to the session")
//                self.session.addInput(self.input!)
//            }
            
        }
    }
    
    
    // Focus 함수, 1. smoothAutoFocus 확인필요 2. subjectAreaChangeMonitoringEnalbe 확인필요 3.CGPoint 작동 확인.
    func focus() {
        guard let videoDevice = self.input?.device else {return}

        do {
            try videoDevice.lockForConfiguration()
            if videoDevice.isFocusPointOfInterestSupported && videoDevice.isFocusModeSupported(.continuousAutoFocus) {
                videoDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                videoDevice.focusMode = .continuousAutoFocus
            }
            /* smoothAutoFocus*/
//            if videoDevice.isSmoothAutoFocusSupported {
//                videoDevice.isSmoothAutoFocusSupported = true
//            }
            
            /* 일단 주석 처리 함*/
//            videoDevice.isSubjectAreaChangeMonitoringEnabled = true

            videoDevice.unlockForConfiguration()

        } catch {
            print("error on setting focus")
        }
    }
    
    // 절전모드 함수, 1. 잔여 프레임이 남는 지 확인 필요 2. 필터 적용 시 확인 필요 3.SessionQueue 이용(Background Thread)
    func ecoMode() {
        sessionQueue.async {
            
            if self.session.isRunning{
                self.session.stopRunning()
            } else {
                self.session.startRunning()
            }
        }
    }
    
    
//    func changeCameraOption() {
//        sessionQueue.async {
//            self.session.beginConfiguration()
//
//            defer {
//                self.session.commitConfiguration()
//            }
//
//            self.device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
//
//            guard let camera = self.device else {
//                self.set(error: .cameraUnavailable)
//                self.status = .failed
//                return
//            }
//
//            do {
//                self.input = try AVCaptureDeviceInput(device: camera)
//
//                if self.session.canAddInput(self.input!) {
//                    self.session.addInput(self.input!)
//                } else {
//                    self.set(error: .cannotAddInput)
//                    self.status = .failed
//                    return
//                }
//            } catch {
//                self.set(error: .createCaptureInput(error))
//                self.status = .failed
//                return
//            }
//
//            self.session.sessionPreset = .hd4K3840x2160
//            self.status = .configured
//
//        }
//    }
    
    
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        // 왜 여기다가 넣으면 될까..?
        self.session.removeOutput(self.movieOutput)
        
        if self.session.canAddOutput(self.videoOutput) {
            print("stopRecording 시작6")

            self.session.addOutput(self.videoOutput)
            print("stopRecording 시작7")
            self.isRecording = false
            }
        //
        
        if let error = error {
            print("에러인가")

            print(error.localizedDescription)
            return
        }
        print("무비파일아웃")

        // CREATED SUCCESFULLY
        print(outputFileURL)
        self.recordedURLs.append(outputFileURL)

        // CONVERTING URLs TO ASSETS
        let assets = recordedURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }

        // MERGING VIDEOS
        mergeVideos(assets: assets) { exporter in
            exporter.exportAsynchronously {
                if exporter.status == .failed {
                    // HANDLE ERROR
                    print("에러3")
                    print(exporter.error!)
                    print("에러4")
                } else {
                    if let finalURL = exporter.outputURL{
                        print(finalURL)
                        PHPhotoLibrary.requestAuthorization { status in
                            if status == .authorized {
                                PHPhotoLibrary.shared().performChanges {
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: finalURL)
                                } completionHandler: { errSecSuccess, eroor in
                                    print("아직 개발 안함")
                                }
                            }
                        }
                    }
                }
            }
        }
        
//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                PHPhotoLibrary.shared().performChanges {
//                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: finalUR)
//                    PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
//                } completionHandler: { errSecSuccess, eroor in
//                    print("아직 개발 안함")
//                }
//            }
//        }

    }
    
    func mergeVideos(assets: [AVURLAsset], completion: @escaping (_ exporter: AVAssetExportSession) -> ()) {

        let composition = AVMutableComposition()
        var lastTime: CMTime = .zero

        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}

        for asset in assets {
            // LINKING AUDIO AND VIDEO
            do {
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: asset.tracks(withMediaType: .video)[0], at: lastTime)
                // SAFE CHECK IF VIDEO HAS AUDIO
                if !asset.tracks(withMediaType: .audio).isEmpty {
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: lastTime)
                }
                
            } catch {
                // HANDLE ERROR
                print("에러1")
                print(error.localizedDescription)
                print("에러2")

            }
            
            // UPDATING LAST TIME
            lastTime = CMTimeAdd(lastTime, asset.duration)
        }

        // TEMP OUTPUT URL
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "Diveroid-\(Date()).mp4")

        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {return}
        exporter.outputFileType = .mp4
        exporter.outputURL = tempURL
        completion(exporter)

    }
}
