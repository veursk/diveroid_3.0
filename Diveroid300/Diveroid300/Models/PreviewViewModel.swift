//
//  PreviewViewModel.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/07.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

struct PreviewViewModel: UIViewRepresentable {
    
    func makeUIView() -> UIView {
        let view = UIView()
        
        CameraManager.shared.videoPreview = AVCaptureVideoPreviewLayer(session: CameraManager.shared.session)
        CameraManager.shared.videoPreview.frame = view.frame
        CameraManager.shared.videoPreview.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(CameraManager.shared.videoPreview)
        
        return view
        
    }
}
