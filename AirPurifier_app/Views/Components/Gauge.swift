//
//  Gauge.swift
//  AirPurifier_app
//
//  Created by วิรัญชนา ประเสริฐวณิช on 15/6/2568 BE.
//
import SwiftUI

struct SemiCircleGauge: View {
    let pm25Value: Double
    var maxValue: Double = 150.0
    
    private var gaugeColor: Color {
        switch pm25Value {
        case 0..<0.1: return .clear
        case 0.1..<9.1: return .green
        case 9.1..<55.5: return .yellow
        default: return .red
        }
    }

    private var progress: Double {
        min(max(pm25Value / maxValue, 0), 1)
    }

    var body: some View {
        ZStack {
            // พื้นหลังเกจ
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .rotationEffect(.degrees(180))
            
            // สีเกจ
            Circle()
                .trim(from: 0, to: progress * 0.5)
                .stroke(gaugeColor, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .rotationEffect(.degrees(180))
                .animation(.easeInOut(duration: 0.6), value: progress)

            // ค่า PM ตรงกลาง
            VStack {
                Spacer()
                Text(String(format: "%.1f μg/m³", pm25Value))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(gaugeColor)
                    .padding(.bottom, 24)
            }
            .frame(height: 150)
        }
        .frame(width: 300, height: 150)
    }
}

//struct SemiCircleGauge_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 40) {
//            SemiCircleGauge(value: 0)
//            SemiCircleGauge(value: 20)
//            SemiCircleGauge(value: 40)
//            SemiCircleGauge(value: 70)
//            SemiCircleGauge(value: 155)
//        }
//        .padding()
//    }
//}
