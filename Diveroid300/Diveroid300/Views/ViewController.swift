//
//  ViewController.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/07.
//

import UIKit
import SwiftUI
import AVFoundation

class ViewController: UIViewController {
    
    var screenRect: CGRect! = nil
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    
    override func viewDidLoad() {
        screenRect = UIScreen.main.bounds
        previewLayer = AVCaptureVideoPreviewLayer(session: CameraManager.shared.session)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .landscapeRight
        
        DispatchQueue.main.async {
            [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
}

struct PreviewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
