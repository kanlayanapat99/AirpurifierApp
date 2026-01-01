//
//  DeviceStack.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import SwiftUI

struct DeviceStack: View {
    @ObservedObject var device: Device
    @EnvironmentObject var languageManager: LanguageManage

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .frame(height: 150)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.9, green: 0.85, blue: 0.95), lineWidth: 1)
                    )

                VStack(spacing: 10) {
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

                    Text(device.model)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    Text(device.location.loc)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(device.isOn ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)

                        Text(device.isOn ? "On".loc : "Off".loc)
                            .font(.system(size: 12))
                            .foregroundColor(device.isOn ? .green : .gray)
                    }
                }
                .padding()
            }
        }
        .id(languageManager.selectedLanguage)
    }
}
