//
//  CameraManager.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import AVFoundation

class CameraManager: ObservableObject {
    
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    @Published var error: CameraError?
    /// 공부 필요
    ///
    private let sessionQueue = DispatchQueue(label: "cameraSessionQ")
    let session = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    private var status = Status.unconfigured
    static let shared = CameraManager()
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                                             .builtInWideAngleCamera],
                                                                               mediaType: .video,
                      
                                                                               
                                                                               position: .unspecified)
    /// Singleton으로 구현
    private init() {
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
    
    func changeCameraOption() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            defer {
                self.session.commitConfiguration()
            }
            
            self.device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            
            guard let camera = self.device else {
                self.set(error: .cameraUnavailable)
                self.status = .failed
                return
            }
            
            do {
                self.input = try AVCaptureDeviceInput(device: camera)
                
                if self.session.canAddInput(self.input!) {
                    self.session.addInput(self.input!)
                } else {
                    self.set(error: .cannotAddInput)
                    self.status = .failed
                    return
                }
            } catch {
                self.set(error: .createCaptureInput(error))
                self.status = .failed
                return
            }
            
            self.session.sessionPreset = .hd4K3840x2160
            self.status = .configured
              
        }
    }
    
    
}
