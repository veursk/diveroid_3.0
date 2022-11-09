//
//  CheckingAirplaneModeView.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/08.
//

import SwiftUI


// 글자 간격 조절 필요
// Rectangle CornerRadius 조절 필요
struct CheckingAirplaneModeView: View {
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: 250, height: 255)
                .foregroundColor(.white)
            VStack{
                AirplaneCircleImage()
                BigText(string: "잠깐! 비행기 모드를 켜주세요.")
                ContentText(string: "비행기 모드가 켜져 있어야")
                ContentText(string: "배터리가 급속히 소진되는 것을 방지해")
                ContentText(string: "안전하게 다이빙을 할 수 있어요.")
                StopDivingModeText(string: "다이빙 모드 종료")
            }
        }
    }
}

struct AirplaneCircleImage: View {
    
    var body: some View {
        Image("AirplaneCircle")
            .frame(width: 60, height: 60)
    }
}

struct BigText: View {
    
    var string: String
    
    var body: some View {
        Text(string)
            .foregroundColor(.black)
            .font(.body)
    }
}

struct ContentText: View {
    
    var string: String
    
    var body: some View {
        Text(string)
            .font(.system(size: 14))
            .foregroundColor(.black)
    }
}

struct StopDivingModeText: View {
    
    var string: String
    
    var body: some View {
        Text(string)
            .font(.system(size: 14))
            .foregroundColor(.black)
            .opacity(0.4)
        
    }
}

struct CheckingAirplaneModeView_Previews: PreviewProvider {
    static var previews: some View {
        CheckingAirplaneModeView()
    }
}
