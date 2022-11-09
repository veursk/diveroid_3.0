//
//  ComputerArea.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI

struct DivingComputerView: View {
    var body: some View {
        ZStack{
            Color("ComputerAreaBackgroundColor")
            HStack{
                VStack{
                    AscendingGraphView(name: "AscendingSpeed(6)")
                    Spacer()
                }
                centerBodyView()
            }
        }
        .frame(width: 127, height: 234)
    }
}



struct centerBodyView: View {
    
    var body: some View {
        VStack(alignment: .leading){
            Spacer()
            depthTextView(string: "수심, m")
            depthNumberView(depth: 26.5, integer: 26, decimal: 5)
            ndlTextView(string: "NDL")
            ndlNumberView(ndlNumber: 42)
            divingTimeTextView(string: "다이빙 시간")
            divingTimeNumberView(ndlNumber: 42)
            waterTemperatureTextView(string: "수온")
            waterTemperatureNumberView(waterTempNumber: 23)
            Spacer()
        }

    }
}


struct depthTextView: View {
    var string: String
    
    var body: some View {
        Text(string)
            .font(.caption)
            .frame(height: 14)
            .foregroundColor(.white)
            .opacity(0.7)
    }
}

struct depthNumberView: View {
    var depth: Double
    var integer: Int
    var decimal: Int
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0){
            Text(String(integer))
                .font(.largeTitle)
                .foregroundColor(.white)
            Text("." + String(decimal))
                .font(.title2)
                .foregroundColor(.white)
        }
    }
}

struct ndlTextView: View {
    var string: String
    
    var body: some View {
        Text(string)
            .font(.caption)
            .frame(height: 14)
            .foregroundColor(.white)
            .opacity(0.7)
    }
}

struct divingTimeTextView: View {
    var string: String
    
    var body: some View {
        Text(string)
            .font(.caption)
            .frame(height: 14)
            .foregroundColor(.white)
            .opacity(0.7)
    }
}

struct waterTemperatureTextView: View {
    var string: String
    
    var body: some View {
        Text(string)
            .font(.caption)
            .frame(height: 14)
            .foregroundColor(.white)
            .opacity(0.7)
    }
}



struct ndlNumberView: View {
    var ndlNumber: Int
    
    var body: some View {
        Text(String(ndlNumber) + "’")
            .font(.largeTitle)
            .foregroundColor(.white)
    }
}

struct divingTimeNumberView: View {
    var ndlNumber: Int
    
    var body: some View {
        Text(String(ndlNumber) + "’")
            .font(.title2)
            .foregroundColor(.white)
    }
}

struct waterTemperatureNumberView: View {
    var waterTempNumber: Int
    
    var body: some View {
        Text(String(waterTempNumber) + "°C")
            .font(.subheadline)
            .foregroundColor(.white)
    }
}



//20221103 Weight 설정 아직 안함
//20221103 NDL 초로 가져오자 (Int)

struct DivingComputerView_Previews: PreviewProvider {
    static var previews: some View {
        DivingComputerView()
    }
}
