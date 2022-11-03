//
//  FrameView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct FrameView: View {
    
    var image: CGImage?
    private let label = Text("Camera Feed")
    
    var body: some View {
        if let image = image {
            GeometryReader { geometry in
                Image(image,
                      scale: 1.0,
                      orientation: .up,
                label: label)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width,
                       height: geometry.size.height,
                       alignment: .center)
                .clipped()
            }
        } else {
            Color.black
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView()
    }
}
