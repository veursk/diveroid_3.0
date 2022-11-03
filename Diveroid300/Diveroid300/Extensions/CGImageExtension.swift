//
//  CGImageExtension.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import CoreGraphics
import VideoToolbox

extension CGImage {
    static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
        guard let pixelBuffer = cvPixelBuffer else {
            return nil
        }
        
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
        return image
    }
}
