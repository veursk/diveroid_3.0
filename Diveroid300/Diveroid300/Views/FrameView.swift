//
//  FrameView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct FrameView: View {
    
    @Binding var isEcoModeOn: Bool

    var image: CGImage?
    private let label = Text("Camera Feed")
    
    var body: some View {
        ZStack{
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
                Circle()
                    .foregroundColor(.red)

            } else {
                Color.black
            }
        }
        if isEcoModeOn {
            Color.black
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView(isEcoModeOn: .constant(true))
    }
}
