//
//  ButtonsView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct ButtonsView: View {
    
    @Binding var showOptionsCells: Bool
    
    var body: some View {
        VStack(spacing: 30){
            topButtonView(showOptionCells: $showOptionsCells).position(CGPoint(x: 730, y: 100))
            middleButtonView().position(CGPoint(x: 780, y: 70))
            bottomButtonView().position(CGPoint(x: 730, y: 40))
        }
    }
}

struct topButtonView: View {
    
    @Binding var showOptionCells: Bool
    
    var body: some View {
        ZStack{
          Circle()
            .fill(Color.gray)
            .opacity(0.2)
            .frame(width: 94.0, height: 94.0)
          Button(action: {
              self.showOptionCells.toggle()
          },
                 label: {
            Circle()
              .fill(Color.white)
              .frame(width: 46.0, height: 46.0)
          })
        }
      }
    }

struct middleButtonView: View {
    var body: some View {
        ZStack{
          Circle()
            .fill(Color.gray)
            .opacity(0.2)
            .frame(width: 94.0, height: 94.0)
          Button(action: {
          },
                 label: {
            Circle()
              .fill(Color.white)
              .frame(width: 46.0, height: 46.0)
          })
        }
      }
    }

struct bottomButtonView: View {
    var body: some View {
        ZStack{
          Circle()
            .fill(Color.gray)
            .opacity(0.2)
            .frame(width: 94.0, height: 94.0)
          Button(action: {
          },
                 label: {
            Circle()
              .fill(Color.white)
              .frame(width: 46.0, height: 46.0)
          })
        }
      }
    }


struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView(showOptionsCells: .constant(false))
    }
}
