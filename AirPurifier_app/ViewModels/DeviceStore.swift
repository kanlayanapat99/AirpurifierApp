//
//  DeviceStore.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import Foundation
import Combine

class DeviceStore: ObservableObject {
    @Published var airQuality: AirQuality
    @Published var devices: [Device]
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: AnyCancellable?

    private let haBaseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "HA_BASE_URL") as? String else {
            fatalError("❌ HA_BASE_URL not found in Info.plist")
        }
        return url
    }()

    private let haToken: String = {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "HA_TOKEN") as? String else {
            fatalError("❌ HA_TOKEN not found in Info.plist")
        }
        return token
    }()


    init() {
            self.airQuality = AirQuality(
                    location: "Ban Bang Khae 2",
                    city: "Bangkok, Bangkhae",
                    pm25: 0,
                    temperature: 0,
                    lastUpdated: Date()
                )
        

        self.devices = [
            Device(model: "Core 600s", location: "Main Room",entityId: "fan.core_600s", filterEntityId: "sensor.core_600s_filter_lifetime",aqiEntityId: "sensor.core_600s_air_quality",pm25EntityId: "sensor.core_600s_pm2_5",notesEntityId: "input_text.core_600s_note"),
            
            Device(model: "Core 600s (2)", location: "Main Room",entityId: "fan.core_600s_2", filterEntityId: "sensor.core_600s_2_filter_lifetime",aqiEntityId: "sensor.core_600s_2_air_quality",pm25EntityId: "sensor.core_600s_2_pm2_5", notesEntityId: "input_text.core_600s_2_note"),
            
            Device(model: "Core 600s (3)", location: "Main Room",entityId: "fan.core_600s_3", filterEntityId: "sensor.core_600s_3_filter_lifetime",aqiEntityId: "sensor.core_600s_3_air_quality",pm25EntityId: "sensor.core_600s_3_pm2_5", notesEntityId: "input_text.core_600s_3_note"),
            
            Device(model: "Core 400s", location: "Main Room", entityId: "fan.core_400s", filterEntityId: "sensor.core_400s_filter_lifetime",aqiEntityId: "sensor.core_400s_air_quality",pm25EntityId: "sensor.core_400s_pm2_5", notesEntityId: "input_text.core_400s_note"),
        ]

        refreshAllDevices()
        startAutoRefresh()
        fetchAirQuality()
    }
    
    // MARK: - Auto Refresh Timer
        private func startAutoRefresh() {
            refreshTimer = Timer
                .publish(every: 30.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    print("🔁 Auto-refresh triggered")
                    self?.fetchAirQuality()
                    self?.refreshAllDevices()
                }
        }
    
    // MARK: - GET state
    func getState(entity: String, completion: @escaping (String, [String: Any]) -> Void) {
        guard let url = URL(string: "\(haBaseURL)/api/states/\(entity)") else {
            print("❌ Invalid getState URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(haToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ getState error: \(error.localizedDescription)")
                completion("", [:])
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                print("❌ Failed to parse state JSON")
                completion("", [:])
                return
            }

            if let state = json["state"] as? String,
               let attr = json["attributes"] as? [String: Any] {
                completion(state, attr)
            } else {
                print("❌ JSON missing expected keys")
                completion("", [:])
            }
        }.resume()
    }

    // MARK: - ดึงค่า AVG Temperature / PM2.5 จาก เสาเซนเซอร์
    func fetchAirQuality() {
        // --- ดึงค่าจากเสา 1 และเสา 2 ---
        getState(entity: "sensor.dust_pole_pm2_5") { pm1, _ in
            self.getState(entity: "sensor.dust_pole_pm2_5_2") { pm2, _ in
                self.getState(entity: "sensor.dust_pole_temperature") { temp1, _ in
                    self.getState(entity: "sensor.dust_pole_temperature_2") { temp2, _ in
          
                        let validPM1 = self.isValidState(pm1)
                        let validPM2 = self.isValidState(pm2)
                        let validTemp1 = self.isValidState(temp1)
                        let validTemp2 = self.isValidState(temp2)
                        
                        func useMeanIfAvailable(_ completion: @escaping (String, String) -> Void) {
                            self.getState(entity: "sensor.dust_pole_pm2_5_mean") { pmMean, _ in
                                self.getState(entity: "sensor.dust_pole_temperature_mean") { tempMean, _ in
                                    completion(pmMean, tempMean)
                                }
                            }
                        }
                        
                        // Check sensor pole
                        if validPM1 && validPM2 && validTemp1 && validTemp2 {
                            // Both Pole Active get data from avg
                            useMeanIfAvailable { pmState, tempState in
                                self.updateAirQuality(pmState: pmState, tempState: tempState)
                            }
                        } else if validPM1 && validTemp1 {
                            // pole1 active
                            self.updateAirQuality(pmState: pm1, tempState: temp1)
                        } else if validPM2 && validTemp2 {
                            // pole2 active
                            self.updateAirQuality(pmState: pm2, tempState: temp2)
                        } else {
                            // Both pole inactive
                            DispatchQueue.main.async {
                                self.airQuality = AirQuality(
                                    location: "Ban Bang Khae 2",
                                    city: "Bangkok, Bang Khae",
                                    pm25: 0,
                                    temperature: 0,
                                    lastUpdated: Date()
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateAirQuality(pmState: String, tempState: String) {
        DispatchQueue.main.async {
            let pmValue = Double(pmState) ?? 0
            let tempF = Double(tempState) ?? 0
            let tempC = (tempF - 32) * 5 / 9
            
            self.airQuality = AirQuality(
                location: "Ban Bang Khae 2",
                city: "Bangkok, Bang Khae",
                pm25: pmValue,
                temperature: tempC,
                lastUpdated: Date()
            )
        }
    }

    private func isValidState(_ state: String) -> Bool {
        !(state == "unknown" || state == "unavailable" || state.isEmpty)
    }


    // MARK: - เปิด/ปิดอุปกรณ์
    func toggleDevicePower(_ device: Device) {
        let domain = "fan"
        let service = device.isOn ? "turn_off" : "turn_on"
        let urlStr = "\(haBaseURL)/api/services/\(domain)/\(service)"
        device.isLoading = true

        guard let url = URL(string: urlStr) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(haToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["entity_id": device.entityId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Power toggle failed: \(error.localizedDescription)")
                } else {
                    device.isOn.toggle()
                    print("✅ Power toggled: \(device.isOn ? "ON" : "OFF")")
                }
                device.isLoading = false
            }
        }.resume()
    }

    // MARK: - ดึงสถานะของอุปกรณ์
    func refreshDeviceState(_ device: Device) {
        device.isLoading = true
        getState(entity: device.entityId) { state, attr in
            DispatchQueue.main.async {
                device.isOn = (state == "on")
                device.percentage = attr["percentage"] as? Int ?? 0

                switch device.percentage {
                case 0:
                    device.fanLevel = .off
                case 0..<26:
                    device.fanLevel = .low
                case 26..<51:
                    device.fanLevel = .mid
                case 51..<76:
                    device.fanLevel = .high
                default:
                    device.fanLevel = .turbo
                }
            }
        }

        getState(entity: "input_boolean.auto_air_purifier") { state, _ in
            DispatchQueue.main.async {
                device.mode = (state == "on") ? "auto" : "manual"
                device.isLoading = false
            }
        }
    }

    func refreshAllDevices() {
        for device in devices {
            refreshDeviceState(device)
            getFilterLife(for: device)
            getAQI(for: device)
            getPM25(for: device)
            getNote(for: device)
        }
    }
    
    // MARK: - GET Devices sensor pm2.5, AQI, FilterLifetime

    func getFilterLife(for device: Device) {
        let sensorEntityId = device.filterEntityId
        
        getState(entity: sensorEntityId) { state, _ in
            DispatchQueue.main.async {
                if let filterValue = Int(state) {
                    device.filterLife = filterValue
//               print("🔧 Filter life updated: \(filterValue)% for \(device.model)")
                } else {
                    //print("❌ Cannot parse filter life from sensor \(sensorEntityId)")
                }
            }
        }
    }
    
        func getAQI(for device: Device) {
            let sensorEntityId = device.aqiEntityId
    
            getState(entity: sensorEntityId) { state, _ in
                DispatchQueue.main.async {
                    if let aqiValue = Int(state) {
                        device.aqiValue = aqiValue
                        print("\(sensorEntityId): \(aqiValue)")
                    } else {
                     //   print("❌ Cannot parse aqi from sensor \(sensorEntityId)")
                    }
                }
            }
        }
        
        func getPM25(for device: Device) {
            let sensorEntityId = device.pm25EntityId
    
            getState(entity: sensorEntityId) { state, _ in
                DispatchQueue.main.async {
                    if let pmValue = Double(state) {
                        device.pm25Value = pmValue
                     //   print("\(sensorEntityId): \(pmValue)")
                    } else {
                        print("❌ Cannot parse pm2.5 from sensor \(sensorEntityId)")
                    }
                }
            }
        }

    // MARK: - Settings Automode
    func setAutoMode(enabled: Bool) {
        let service = enabled ? "turn_on" : "turn_off"
        guard let url = URL(string: "\(haBaseURL)/api/services/input_boolean/\(service)") else {
            print("❌ Invalid URL for auto mode toggle")
            return
        }

        let payload: [String: Any] = [
            "entity_id": "input_boolean.auto_air_purifier"
        ]

        sendRequest(url: url, payload: payload) {
            print("✅ Auto mode set to \(enabled ? "ON" : "OFF")")

            let automationID = enabled ? "auto_on_all_devices" : "auto_off_all_devices"
            self.triggerAutomation(named: automationID)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.refreshAllDevices()
            }
        }
    }


    // MARK: - Set fanspeed
        func setFanLevel(for device: Device, to level: DeviceLevel) {
            device.isLoading = true
                let url = URL(string: "\(haBaseURL)/api/services/input_select/select_option")!

                let option: String
                switch level {
                case .off:
                    option = "OFF"
                case .low:
                    option = "LOW"
                case .mid:
                    option = "MID"
                case .high:
                    option = "HIGH"
                case .turbo:
                    option = "TURBO"
                }

                let payload: [String: Any] = [
                    "entity_id": "input_select.air_purifier_manual_control",
                    "option": option
                ]

                sendRequest(url: url, payload: payload) {
                    DispatchQueue.main.async {
                        device.fanLevel = level
                        device.percentage = level.percentage
                        device.isLoading = false
                        print("Set fan level to \(option)")
                    }
                }
            }

        // MARK: - send request
        private func sendRequest(url: URL, payload: [String: Any], completion: @escaping () -> Void) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(haToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            } catch {
                print("Failed to encode payload: \(error)")
                return
            }
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Request failed: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("Request succeeded")
                    completion()
                } else {
                    print("Request failed: \(httpResponse.statusCode)")
                }
            }.resume()
        }
    
    // MARK: - Trigger automation
    func triggerAutomation(named automationID: String) {
        guard let url = URL(string: "\(haBaseURL)/api/services/automation/trigger") else {
            print("❌ Invalid URL for automation trigger")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(haToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "entity_id": "automation.\(automationID)" ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Automation trigger failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ Triggered automation: \(automationID)")
                } else {
                    print("❌ Automation trigger failed with status: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    // MARK: - GET Note
    func getNote(for device: Device) {
        getState(entity: device.notesEntityId) { state, _ in
            DispatchQueue.main.async {
                device.notes = (state == "unknown" || state.isEmpty) ? nil : state
                //print("📝 Note fetched for \(device.model): \(device.notes ?? "nil")")
            }
        }
    }
    
    // MARK: - UPDATE Note
    func updateNote(for device: Device) {
        guard let url = URL(string: "\(haBaseURL)/api/services/input_text/set_value") else {
            print("❌ Invalid URL for note update")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(haToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let noteValue = device.notes ?? ""
        
        let payload: [String: Any] = [
            "entity_id": device.notesEntityId,
            "value": noteValue
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("❌ Failed to encode note payload: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Note update failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ Note updated successfully for \(device.model)")
                } else {
                    print("❌ Note update failed with status: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

