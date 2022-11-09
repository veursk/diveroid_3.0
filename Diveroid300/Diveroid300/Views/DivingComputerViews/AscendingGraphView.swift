//
//  AscendingGraphView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/08.
//

import SwiftUI

struct AscendingGraphView: View {
    var name: String
    var body: some View {
        Image(name)
            .frame(width: 20, height: 100)
    }
}


struct AscendingGraphView_Previews: PreviewProvider {
    static var previews: some View {
        AscendingGraphView(name: "AscendingSpeed(7)")
    }
}
