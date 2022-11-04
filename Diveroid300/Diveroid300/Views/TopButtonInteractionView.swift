//
//  ListTestView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/04.
//

import SwiftUI

struct TopButtonInteractionView: View {
    
    @Binding var isWideAngleSelected: Bool
    @Binding var isNormalAngleSelected: Bool
    @Binding var isZoomAngleSelected: Bool
    @Binding var isSelfieAngleSelected: Bool

    
    var body: some View {
        ZStack{
            VStack{
                HStack(spacing: 0.5){
                    optionCellView(isSelected: $isWideAngleSelected, optionName: "광각", optionImageName: "wideAngleOption")
                    optionCellView(isSelected: $isNormalAngleSelected, optionName: "일반", optionImageName: "normalAngleOption")
                    optionCellView(isSelected: $isZoomAngleSelected, optionName: "줌", optionImageName: "zoomAngleOption")
                    optionCellView(isSelected: $isSelfieAngleSelected, optionName: "셀피", optionImageName: "selfieAngleOption")
                }
                HStack{
                    otherOptionCellView(optionName: "에어/나이트록스", currentValue: "EAN 21 [Air]")
                    otherOptionCellView(optionName: "최근 찍은 사진", currentValue: "24")
                }
            }
        }
    }
}


struct TopButtonInteractionView_Previews: PreviewProvider {
    static var previews: some View {
        TopButtonInteractionView(
            isWideAngleSelected: .constant(true),
            isNormalAngleSelected: .constant(false),
            isZoomAngleSelected: .constant(false),
            isSelfieAngleSelected: .constant(false))
    }
}

struct optionCellView: View {
    
    @Binding var isSelected: Bool
    
    let optionName: String
    let optionImageName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color("optionCellViewBackgroundColor"))
                .frame(width: 106, height: 138)
            if isSelected {
                RoundedRectangle(cornerRadius: 9)
                    .foregroundColor(Color.white)
                    .border(.blue, width: 2)
                    .frame(width: 98, height: 130)
            }
            VStack(spacing: 30){
                Image(optionImageName)
                    .frame(width: 73.32, height: 47)
                Text(optionName)
                    .font(.body)
                    .foregroundColor(Color.black)
            }
        }
    }
}

struct otherOptionCellView: View {
    
    let optionName: String
    let currentValue: String
    let endingBracket: String = ">"
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color("optionCellViewBackgroundColor"))
                .frame(width: 214, height: 44)
            HStack{
                Text(optionName)
                    .font(.system(size: 12))
                Text(currentValue)
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                Text(endingBracket)
                    .font(.system(size: 16))
            }

        }
    }
}


// 고화질 이미지로 다시 처리 필요 일단은 간단하게 UI 만들려고 진행함, 폰트크기도
// currentValue 폰트 종류 처리 필요
// otherOptionCellView는 물밖에서만 나옴.
// CornerRadius 먹어야함.
