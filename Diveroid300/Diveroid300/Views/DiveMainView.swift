//
//  ContentView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct DiveMainView: View {
    
    @StateObject private var model = DiveMainViewModel()
    
    
    var body: some View {
        ZStack {
            FrameView(image: model.frame)
                .edgesIgnoringSafeArea(.all)
            HStack{
                Spacer()
                ButtonsView()
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
