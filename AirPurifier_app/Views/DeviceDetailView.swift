//
//  DeviceDetailView.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import SwiftUI

struct DeviceDetailView: View {
    @EnvironmentObject var store: DeviceStore
    @ObservedObject var device: Device
    
    // MARK: - Note popup states
    @State private var showEditNotePopup = false
    @State private var tempNote = ""

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    airQualityGaugeSection
                    filterLifetimeSection
                    modeAndFanStatusCard
                    Spacer()
                }
                .padding()
            }
            .background(backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.refreshDeviceState(device)
                store.getFilterLife(for: device)
                store.getNote(for: device)
            }
            
            // MARK: - Edit Note Popup
            if showEditNotePopup {
                Color.gray.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showEditNotePopup = false
                    }
                
                VStack(spacing: 16) {
                    Text("Device Note")
                        .font(.headline)
                    
                    TextField("Add a note...", text: $tempNote)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Cancel") {
                            showEditNotePopup = false
                        }
                        Spacer()
                        Button("Save") {
                            device.notes = tempNote.isEmpty ? nil : tempNote
                            store.updateNote(for: device)
                            showEditNotePopup = false
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: 300)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(device.model)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        tempNote = device.notes ?? ""
                        showEditNotePopup = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(device.location.loc)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    if let note = device.notes, !note.isEmpty {
                        Divider()
                            .frame(width: 2,height: 18)
                            .background(Color.gray)
                        
                        Text(note)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            Button(action: {
                store.toggleDevicePower(device)
                
                if !device.isOn {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        device.mode = "Auto"
                        store.setAutoMode(enabled: true)
                    }
                }
            }) {
                Image(systemName: device.isOn ? "power.circle.fill" : "power.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(device.isOn ? .green : .red)
                    .padding(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }


    // MARK: - Air Quality
    private var airQualityGaugeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("AIR QUALITY".loc)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(airQualityStatus.loc)
                    .font(.headline)
                    .foregroundColor(airQualityColor)
                    .padding(6)
                    .background(airQualityColor.opacity(0.2))
                    .cornerRadius(10)
            }
            SemiCircleGauge(pm25Value: device.pm25Value)

            HStack {
                Spacer()
                Text("AQI: ")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.secondary)
                Text("\(device.aqiValue)")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(airQualityColor)
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Filter
    private var filterLifetimeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("FILTER LIFETIME".loc)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(device.filterLife)%")
                    .font(.headline)
                    .foregroundColor(filterColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(Color(.systemGray5))

                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: max(CGFloat(device.filterLife) / 100 * geometry.size.width, 4))
                        .foregroundColor(filterColor)
                }
            }
            .frame(height: 20)

        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Mode & Fan Speed Card
    private var modeAndFanStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\("MODE".loc):")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(localizedMode(device.mode))
                    .font(.headline)
                    .foregroundColor(device.isOn ? .blue : .gray)
            }
            
            HStack {
                Text("\("FAN LEVEL".loc):")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(device.fanLevel.rawValue.capitalized.loc)")
                    .font(.headline)
                    .foregroundColor(device.isOn ? .blue : .gray)
            }

            HStack {
                Text("\("FAN SPEED".loc):")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(device.percentage)%")
                    .font(.headline)
                    .foregroundColor(device.isOn ? .blue : .gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Colors range
    private var airQualityStatus: String {
        switch device.pm25Value {
        case 0..<0.1: return "No sensor"
        case 0.1..<9.1: return "EXCELLENT"
        case 9.1..<55.5: return "MODERATE"
        default: return "UNHEALTHY"
        }
    }

    private var airQualityColor: Color {
        switch device.pm25Value {
        case 0..<0.1: return .gray
        case 0.1..<9.1: return .green
        case 9.1..<55.5: return .yellow
        default: return .red
        }
    }

    private var filterColor: Color {
        switch device.filterLife {
        case 70...100: return .green
        case 40..<70: return .yellow
        case 10..<40: return .orange
        default: return .red
        }
    }
    
    // MARK: - Background color Based on PM2.5
    private var backgroundGradient: LinearGradient {
        let pm = device.pm25Value
        let colors: [Color]

        switch pm {
        case 0..<9.1:
            colors = [Color.green.opacity(0.3), Color.mint.opacity(0.2)]
        case 9.1..<55.5:
            colors = [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)]
        default:
            colors = [
                Color.orange.opacity(0.3), Color.red.opacity(0.2)
            ]
        }

        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview
struct DeviceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // สร้าง mock device สำหรับพรีวิว
        let mockDevice = Device(
            model: "Core 600s",
            location: "Main Room",
            entityId: "fan.core_600s",
            filterEntityId: "sensor.core_600s_filter_lifetime",
            aqiEntityId: "sensor.core_600s_air_quality",
            pm25EntityId: "sensor.core_600s_pm2_5",
            notesEntityId: "input_text.core_600s_note",
            notes: "Test note"
        )

        // สร้าง DeviceStore mock
        let store = DeviceStore()
        store.devices = [mockDevice]

        return DeviceDetailView(device: mockDevice)
            .environmentObject(store)
            .previewDevice("iPhone 14")
            .previewDisplayName("Device Detail Preview")
    }
}
