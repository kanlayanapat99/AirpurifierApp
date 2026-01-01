//
//  ControlPanel.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 20/6/2568 BE.
//

import SwiftUI

struct ControlPanelView: View {
    @EnvironmentObject var store: DeviceStore
    @EnvironmentObject var languageManager: LanguageManage  // เพิ่มตรงนี้

    let modes = ["Auto", "Manual"]
    let levels = ["OFF","LOW", "MID", "HIGH","TURBO"]

    @State private var isExpanded: Bool = false
    @State private var selectedMode: String = "auto"
    @State private var selectedLevel: DeviceLevel = .off

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Control Panel".loc)
                    .font(.headline)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(.ultraThinMaterial)
            .background(Color(.systemBackground))
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                VStack(spacing: 20) {
                    // MODE SELECTION
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MODE".loc)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 15) {
                            ForEach(modes, id: \.self) { mode in
                                let isSelected = selectedMode.caseInsensitiveCompare(mode) == .orderedSame

                                Button(action: {
                                    selectedMode = mode.lowercased()

                                    for device in store.devices {
                                        device.mode = selectedMode

                                        if selectedMode == "manual" {
                                            device.fanLevel = .off
                                            device.percentage = 0
                                            device.isOn = false
                                        }

                                        store.setAutoMode(enabled: selectedMode == "auto")
                                    }
                                }) {
                                    Text(mode.loc)
                                        .font(.system(size: 18, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(isSelected ? .cyan : Color(.systemGray5))
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    if selectedMode == "manual" {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("FAN LEVEL".loc)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 10) {
                                ForEach(levels, id: \.self) { level in
                                    let levelEnum = DeviceLevel(rawValue: level.lowercased()) ?? .off
                                    let isSelected = selectedLevel == levelEnum

                                    Button(action: {
                                        selectedLevel = levelEnum

                                        for device in store.devices {
                                            device.fanLevel = levelEnum
                                            device.percentage = levelEnum.percentage
                                            device.isOn = (levelEnum != .off)

                                            store.setFanLevel(for: device, to: levelEnum)
                                        }
                                    }) {
                                        Text(level.loc)
                                            .font(.system(size: 16, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(isSelected ? .cyan : Color(.systemGray5))
                                            .foregroundColor(isSelected ? .white : .gray)
                                            .cornerRadius(8)
                                    }
                                    .disabled(selectedMode != "manual")
                                }
                            }
                        }
                    }
                }
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .padding()
        .id(languageManager.selectedLanguage)
    }
}
