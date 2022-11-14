//
//  ContentView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct DiveMainView: View {
    
    @StateObject private var model = DiveMainViewModel()
    
    @State var showOptionCells = false
    @State var isWideAngleSelected: Bool = true
    @State var isNormalAngleSelected: Bool = false
    @State var isZoomAngleSelected: Bool = false
    @State var isSelfieAngleSelected: Bool = false
    @State var isEcoModeOn: Bool = false
    @State var isRecording: Bool = false
    @State var isFiltering: Bool = false
    
    
    
    var body: some View {
        ZStack {
            //            if isRecording {
            //                ZStack{
            //                    PreviewController()
            //                    Circle()
            //                        .foregroundColor(.blue)
            //                }
            //            } else {
            //                FrameView(isEcoModeOn: $isEcoModeOn, image: model.frame)
            //                    .edgesIgnoringSafeArea(.all)
            //            }
            if !isFiltering{
                ZStack{
                    FrameView(isEcoModeOn: $isEcoModeOn, image: model.frame)
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                FilteredVideoPreviewView()
            }
            if showOptionCells {
                TopButtonInteractionView(
                    isWideAngleSelected: $isWideAngleSelected,
                    isNormalAngleSelected: $isNormalAngleSelected,
                    isZoomAngleSelected: $isZoomAngleSelected,
                    isSelfieAngleSelected: $isSelfieAngleSelected)
            }
            HStack{
                Spacer()
                ButtonsView(showOptionsCells: $showOptionCells,
                            isWideAngleSelected: $isWideAngleSelected,
                            isNormalAngleSelected: $isNormalAngleSelected,
                            isZoomAngleSelected: $isZoomAngleSelected,
                            isSelfieAngleSelected: $isSelfieAngleSelected,
                            isEcoModeOn: $isEcoModeOn, isRecording: $isRecording, isFiltering: $isFiltering)
            }
            ErrorView(error: model.error)
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiveMainView()
    }
}
