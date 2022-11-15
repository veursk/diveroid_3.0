//
//  ContentView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct DiveMainView: View {
    
    @StateObject private var model = DiveMainViewModel()
    @ObservedObject var divingDataManager = DivingDataManager.shared
    
    @State var showOptionCells = false
    @State var isWideAngleSelected: Bool = true
    @State var isNormalAngleSelected: Bool = false
    @State var isZoomAngleSelected: Bool = false
    @State var isSelfieAngleSelected: Bool = false
    @State var isEcoModeOn: Bool = false
    @State var isRecording: Bool = false
    @State var isFiltering: Bool = false
    
//    var manager = BluetoothManager.shared
    var airplaneModeModel = AirplaneModeModel.shared

    
    var body: some View {
        ZStack {
            if !isFiltering{
                ZStack{
                    FrameView(isEcoModeOn: $isEcoModeOn, image: model.frame)
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                FilteredVideoPreviewView()
            }
            if !airplaneModeModel.isAirplaneModeOn {
                CheckingAirplaneModeView()
            }
            if showOptionCells {
                TopButtonInteractionView(
                    isWideAngleSelected: $isWideAngleSelected,
                    isNormalAngleSelected: $isNormalAngleSelected,
                    isZoomAngleSelected: $isZoomAngleSelected,
                    isSelfieAngleSelected: $isSelfieAngleSelected)
            }
            HStack{
                DivingComputerView(depth: $divingDataManager.depth, temperature: $divingDataManager.temperature, velocity: $divingDataManager.velocity)
                Spacer()
            }
                ButtonsView(showOptionsCells: $showOptionCells,
                            isWideAngleSelected: $isWideAngleSelected,
                            isNormalAngleSelected: $isNormalAngleSelected,
                            isZoomAngleSelected: $isZoomAngleSelected,
                            isSelfieAngleSelected: $isSelfieAngleSelected,
                            isEcoModeOn: $isEcoModeOn, isRecording: $isRecording, isFiltering: $isFiltering)
            ErrorView(error: model.error)
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiveMainView()
    }
}
