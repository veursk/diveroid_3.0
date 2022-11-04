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


    var body: some View {
        ZStack {
            FrameView(image: model.frame)
                .edgesIgnoringSafeArea(.all)
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
                            isSelfieAngleSelected: $isSelfieAngleSelected)
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
