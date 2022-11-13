//
//  DiveMainViewModel.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import CoreImage
import GPUImage
import UIKit

/// 여기 전반적으로 다시 체크 필요함.
class DiveMainViewModel: ObservableObject {
    
    @Published var error: Error?
    private let cameraManager = CameraManager.shared
    
    @Published var frame: CGImage?
    private let frameManager = FrameManager.shared
    
    var isFiltering: Bool = true
    
    /// 메탈필터
    let filter = BasicOperation(fragmentFunctionName: "colorInversionFragment")
    
    /// CIImage -> CGImage 변환 시 Context 이용해야 함.
    let context = CIContext()
    
    ///
    var picture: PictureInput!
    
    ///
    var pictureOutput = PictureOutput()
    
    
    init() {
        setupSubscriptions()
    }
    
    func setupSubscriptions() {
        cameraManager.$error
            .receive(on: RunLoop.main)
            .map{$0}
            .assign(to: &$error)
        
        frameManager.$current
            .receive(on: RunLoop.main)
            .compactMap{
                buffer in
                return CGImage.create(from: buffer)
            }
            .assign(to: &$frame)
    }
}
