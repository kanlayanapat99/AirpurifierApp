//
//  DevicesView.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import SwiftUI

struct DevicesView: View {
    @EnvironmentObject var store: DeviceStore
    @EnvironmentObject var languageManager: LanguageManage
    @EnvironmentObject var sensorStore: SensorStore
    
    let devicesList = ["Main Room"]
    
    var filteredDevices: [Device] {
        store.devices.filter { devicesList.contains($0.location) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    ControlPanelView()

                    // รายการอุปกรณ์
                    List {
                        Section {
                            HStack(spacing: 14) {
                                SensorCard(poleNumber: 1)
                                    .frame(maxWidth: .infinity)
                                SensorCard(poleNumber: 2)
                                    .frame(maxWidth: .infinity)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                        }
                        .listSectionSeparator(.hidden)

                        // DeviceRow Section ตามปกติ
                        Section {
                            ForEach(filteredDevices) { device in
                                ZStack {
                                    DeviceRow(device: device)
                                    NavigationLink(destination: DeviceDetailView(device: device)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                        }
                        .listSectionSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Devices".loc)
            .id(languageManager.selectedLanguage)
            // ลบ .environmentObject(sensorStore) ออก เพราะเราใช้ @EnvironmentObject แล้ว
        }
    }
    
    // MARK: - Dynamic Gradient
    private var backgroundGradient: LinearGradient {
        let pm = store.airQuality.pm25
        let colors: [Color]

        switch pm {
        case 0..<9.1:
            colors = [Color.green.opacity(0.3), Color.mint.opacity(0.2)]
        case 9.1..<55.5:
            colors = [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)]
        default:
            colors = [Color.orange.opacity(0.3), Color.red.opacity(0.2)]
        }

        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
