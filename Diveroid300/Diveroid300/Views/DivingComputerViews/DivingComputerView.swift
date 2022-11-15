//
//  ComputerArea.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/03.
//

import SwiftUI
import Foundation

struct DivingComputerView: View {
    
    @Binding var depth: Float
    @Binding var temperature: Float
    
    var body: some View {
        ZStack{
            Color("ComputerAreaBackgroundColor")
            HStack{
                VStack{
                    AscendingGraphView(name: "AscendingSpeed(6)")
                    Spacer()
                }
                centerBodyView(depth: $depth, temperature: $temperature)
            }
        }
        .frame(width: 127, height: 234)
    }
}



struct centerBodyView: View {
    
    @Binding var depth: Float
    @Binding var temperature: Float
    

    var body: some View {
        VStack(alignment: .leading){
            Spacer()
            depthTextView(string: "수심, m")
            depthNumberView(depth: $depth)
            ndlTextView(string: "NDL")
            ndlNumberView(ndlNumber: 42)
            divingTimeTextView(string: "다이빙 시간")
            divingTimeNumberView(ndlNumber: 42)
            waterTemperatureTextView(string: "수온")
            waterTemperatureNumberView(temperature: $temperature)
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
    
    @Binding var depth: Float

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0){
            Text(String(Int(floor(depth))))
                .font(.largeTitle)
                .foregroundColor(.white)
            Text("." + String(Int((depth - floor(depth)) * 10)))
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
    @Binding var temperature: Float

    var body: some View {
        Text(String(temperature) + "°C")
            .font(.subheadline)
            .foregroundColor(.white)
    }
}



//20221103 Weight 설정 아직 안함
//20221103 NDL 초로 가져오자 (Int)

struct DivingComputerView_Previews: PreviewProvider {
    static var previews: some View {
        DivingComputerView(depth: .constant(42.5), temperature: .constant(25.4))
    }
}
