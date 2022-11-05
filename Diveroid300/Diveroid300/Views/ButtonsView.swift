//
//  ButtonsView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct ButtonsView: View {
    
    @Binding var showOptionsCells: Bool
    @Binding var isWideAngleSelected: Bool
    @Binding var isNormalAngleSelected: Bool
    @Binding var isZoomAngleSelected: Bool
    @Binding var isSelfieAngleSelected: Bool

    var body: some View {
        VStack(spacing: 30){
            topButtonView(showOptionsCells: $showOptionsCells, isWideAngleSelected: $isWideAngleSelected, isNormalAngleSelected: $isNormalAngleSelected, isZoomAngleSelected: $isZoomAngleSelected, isSelfieAngleSelected: $isSelfieAngleSelected)
                .position(CGPoint(x: 730, y: 100))
            middleButtonView()
                .position(CGPoint(x: 780, y: 70))
            bottomButtonView()
                .position(CGPoint(x: 730, y: 40))
        }
    }
}

struct topButtonView: View {
    
    @Binding var showOptionsCells: Bool
    @Binding var isWideAngleSelected: Bool
    @Binding var isNormalAngleSelected: Bool
    @Binding var isZoomAngleSelected: Bool
    @Binding var isSelfieAngleSelected: Bool
    
    var body: some View {
        ZStack{
          Circle()
            .fill(Color.gray)
            .opacity(0.2)
            .frame(width: 94.0, height: 94.0)
          Button(action: {
              if !showOptionsCells {
                  showOptionsCells.toggle()
              }
              else {
                  if isWideAngleSelected {
                      isNormalAngleSelected.toggle()
                      isWideAngleSelected.toggle()
                      CameraManager.shared.changCameraOptionModified(CameraOptionName: Constants.CameraOptionName.NormalCameraOption)
                  } else if isNormalAngleSelected {
                      isZoomAngleSelected.toggle()
                      isNormalAngleSelected.toggle()
                      CameraManager.shared.changCameraOptionModified(CameraOptionName: Constants.CameraOptionName.ZoomCameraOption)
                  } else if isZoomAngleSelected {
                      isSelfieAngleSelected.toggle()
                      isZoomAngleSelected.toggle()
                      CameraManager.shared.changCameraOptionModified(CameraOptionName: Constants.CameraOptionName.SelfieCameraOption)
                  } else if isSelfieAngleSelected {
                      isWideAngleSelected.toggle()
                      isSelfieAngleSelected.toggle()
                      CameraManager.shared.changCameraOptionModified(CameraOptionName: Constants.CameraOptionName.WideCameraOption)
                  }
              }
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
        ButtonsView(showOptionsCells: .constant(false),
                    isWideAngleSelected: .constant(true),
                    isNormalAngleSelected: .constant(false),
                    isZoomAngleSelected: .constant(false),
                    isSelfieAngleSelected: .constant(false))
    }
}
