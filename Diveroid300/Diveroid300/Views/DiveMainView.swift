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
    
    var body: some View {
        ZStack {
            FrameView(image: model.frame)
                .edgesIgnoringSafeArea(.all)
            if showOptionCells {
                TopButtonInteractionView()
            }
            HStack{
                Spacer()
                ButtonsView(showOptionsCells: $showOptionCells)
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
