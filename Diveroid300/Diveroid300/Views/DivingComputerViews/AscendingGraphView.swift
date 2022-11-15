//
//  AscendingGraphView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/08.
//

import SwiftUI

struct AscendingGraphView: View {
    @Binding var velocity: Float
    
    var body: some View {
        if 0 < velocity && velocity <= 2 {
            Image("AscendingSpeed(1)")
                .frame(width: 20, height: 100)
        } else if 2 < velocity && velocity <= 4 {
            Image("AscendingSpeed(2)")
                .frame(width: 20, height: 100)
        } else if 4 < velocity && velocity <= 6 {
            Image("AscendingSpeed(3)")
                .frame(width: 20, height: 100)
        } else if 6 < velocity && velocity <= 8 {
            Image("AscendingSpeed(4)")
                .frame(width: 20, height: 100)
        } else if 8 < velocity && velocity <= 10 {
            Image("AscendingSpeed(5)")
                .frame(width: 20, height: 100)
        } else if 10 < velocity && velocity <= 18 {
            Image("AscendingSpeed(6)")
                .frame(width: 20, height: 100)
        } else if 18 < velocity {
            Image("AscendingSpeed(7)")
                .frame(width: 20, height: 100)
        }
    }
}


struct AscendingGraphView_Previews: PreviewProvider {
    static var previews: some View {
        AscendingGraphView(velocity: .constant(5))
    }
}
