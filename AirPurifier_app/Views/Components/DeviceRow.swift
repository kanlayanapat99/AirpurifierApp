//
//  DeviceRow.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import SwiftUI

struct DeviceRow: View {
    @ObservedObject var device: Device
    @EnvironmentObject var languageManager: LanguageManage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(device.isOn ?
                              LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.1, green: 0.7, blue: 0.9),
                                    Color(red: 0.2, green: 0.8, blue: 0.7)
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
                                )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "wind")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                .padding(.leading, 5)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.model)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    // location + note ต่อท้ายในบรรทัดเดียวกัน
                    HStack(spacing: 10) {
                        Text(device.location.loc)
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
                        if let note = device.notes, !note.isEmpty {
                            Divider()
                                .frame(width: 2,height: 16)
                                .background(Color.gray)
                            
                            Text("\(note)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            
            Spacer().frame(height: 10)
            
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 15) {
                    Label(device.isOn ? "Status: On".loc : "Status: Off".loc,
                          systemImage: device.isOn ? "power.circle.fill" : "power.circle")
                        .foregroundColor(device.isOn ? .green : .gray)
                        .font(.system(size: 14))
                    
                    Label("\("Mode".loc): \(localizedMode(device.mode))", systemImage: "gearshape")
                        .foregroundColor(device.isOn ? .blue : .gray)
                        .font(.system(size: 14))
                }
                Spacer().frame(width: 30)
                
                VStack(alignment: .leading, spacing: 15) {
                    Label("\("Filter".loc): \(device.filterLife)%".loc, systemImage: "drop.fill")
                        .foregroundColor(device.isOn ? (device.filterLife > 20 ? .purple : .red) : .gray)
                        .font(.system(size: 14))
                    
                    Label("\("Fan".loc): \(device.fanLevel.rawValue.capitalized.loc)", systemImage: "fanblades.fill")
                        .foregroundColor(device.isOn ? .orange : .gray)
                        .font(.system(size: 14))
                }
            }
            .padding(.top, 2)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.9, green: 0.85, blue: 0.95), lineWidth: 1)
        )
        .id(languageManager.selectedLanguage)
    }
}
