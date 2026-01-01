//
//  SensorCard.swift
//  AirPurifier_app
//
//  Created by วิรัญชนา ประเสริฐวณิช on 12/10/2568 BE.
//

import SwiftUI

struct SensorCard: View {
    @EnvironmentObject var languageManager: LanguageManage
    @EnvironmentObject var sensorStore: SensorStore

    let poleNumber: Int

    private var isOn: Bool {
        poleNumber == 1 ? sensorStore.pole1Online : sensorStore.pole2Online
    }

    private var value: String {
        poleNumber == 1 ? sensorStore.pole1Value : sensorStore.pole2Value
    }

    private var formattedValue: String {
        // แปลงค่า String เป็น Double และจัดรูปแบบทศนิยม 1 ตำแหน่ง
        if let doubleValue = Double(value) {
            return String(format: "%.1f", doubleValue)
        } else {
            return value // ถ้าแปลงไม่ได้ให้ใช้ค่าเดิม
        }
    }

    private var title: String {
        poleNumber == 1 ? "Pole 1".loc : "Pole 2".loc
    }

    var body: some View {
        HStack {
            // Left content
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isOn ?
                              LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.green.opacity(0.7),
                                    Color.teal.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ) :
                              LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.7),
                                    Color.gray.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ))
                        .frame(width: 36, height: 36)

                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(isOn ? "Active".loc : "Inactive".loc)
                        .font(.system(size: 12))
                        .foregroundColor(isOn ? .green : .gray)
                }
            }
            
            Spacer()
            
            // Right content - แบบไม่มีกล่อง
            if isOn {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("PM2.5".loc)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(formattedValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.9, green: 0.85, blue: 0.95), lineWidth: 1)
        )
        .id(languageManager.selectedLanguage)
    }
}
