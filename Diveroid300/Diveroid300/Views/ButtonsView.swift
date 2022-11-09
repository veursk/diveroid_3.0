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
    @Binding var isEcoModeOn: Bool
    @Binding var isRecording: Bool

    var body: some View {
        VStack(spacing: 30){
            topButtonView(showOptionsCells: $showOptionsCells, isWideAngleSelected: $isWideAngleSelected, isNormalAngleSelected: $isNormalAngleSelected, isZoomAngleSelected: $isZoomAngleSelected, isSelfieAngleSelected: $isSelfieAngleSelected, isEcoModeOn: $isEcoModeOn)
                .position(CGPoint(x: 730, y: 100))
            middleButtonView(showOptionsCells: $showOptionsCells, isEcoModeOn: $isEcoModeOn, isRecording: $isRecording)
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
    @Binding var isEcoModeOn: Bool

    
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
            .simultaneousGesture(LongPressGesture(minimumDuration: 1).onEnded({_ in
                CameraManager.shared.ecoMode()
                isEcoModeOn.toggle()

            }))
            .simultaneousGesture(TapGesture().onEnded({
               
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
            }))
        }
      }
    }

struct middleButtonView: View {
    
    @Binding var showOptionsCells: Bool
    @Binding var isEcoModeOn: Bool
    @Binding var isRecording: Bool

    
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
            .simultaneousGesture(LongPressGesture(minimumDuration: 1)
                .onEnded({ _ in
                    if isEcoModeOn {
                        CameraManager.shared.ecoMode()
                        isEcoModeOn.toggle()
                    } else {
                        if !CameraManager.shared.isRecording {
                            CameraManager.shared.setRecording()
                            isRecording = true
                            CameraManager.shared.startRecording()
                        } else {
                            CameraManager.shared.stopRecording()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                       isRecording = false
                                   })
                            }
                        }
                    }
                ))
            .simultaneousGesture(TapGesture().onEnded({
                if isEcoModeOn {
                    CameraManager.shared.ecoMode()
                    isEcoModeOn.toggle()
                } else {
                    if showOptionsCells {
                        showOptionsCells.toggle()
                    } else {
                        FrameManager.shared.isSavingFrame = true
                    }
                }
            }))
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
              CameraManager.shared.focus()
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
                    isSelfieAngleSelected: .constant(false),
                    isEcoModeOn: .constant(false)
                    , isRecording: .constant(false))
    }
}


/* 카메라 옵션 클로저

 {
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
 }
 
 프레임 촬영 클로저
 
 {
     if showOptionsCells {
         showOptionsCells.toggle()
     } else {
         FrameManager.shared.isSavingFrame = true
     }
     
     
 }
 */
