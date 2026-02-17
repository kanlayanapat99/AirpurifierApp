//
//  SensorStore.swift
//  AirPurifier_app
//
//  Created by วิรัญชนา ประเสริฐวณิช on 11/10/2568 BE.
//

import Foundation
import Combine

class SensorStore: ObservableObject {
    @Published var pole1Online: Bool
    @Published var pole2Online: Bool
    @Published var pole1Value: String
    @Published var pole2Value: String
    
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

    
    private var timerCancellable: AnyCancellable?

    init() {
        self.pole1Online = true
        self.pole2Online = true
        self.pole1Value = "0.0"
        self.pole2Value = "0.0"
        
        fetchSensors()
        startAutoRefresh()
    }
    
    init(pole1Online: Bool, pole2Online: Bool, pole1Value: String, pole2Value: String) {
            self.pole1Online = pole1Online
            self.pole2Online = pole2Online
            self.pole1Value = pole1Value
            self.pole2Value = pole2Value
        }
    
    func fetchSensors() {
        fetchSensorStatus(entity: "sensor.dust_pole_pm2_5") { state in
            DispatchQueue.main.async {
                self.pole1Online = self.isValidState(state)
                self.pole1Value = state
            }
        }
        
        fetchSensorStatus(entity: "sensor.dust_pole_pm2_5_2") { state in
            DispatchQueue.main.async {
                self.pole2Online = self.isValidState(state)
                self.pole2Value = state
            }
        }
    }
    
    private func isValidState(_ state: String) -> Bool {
        !(state == "unknown" || state == "unavailable" || state.isEmpty)
    }
    
    private func fetchSensorStatus(entity: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(haBaseURL)/api/states/\(entity)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(haToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let state = json["state"] as? String else {
                completion("unavailable")
                return
            }
            completion(state)
        }.resume()
    }
    
    // MARK: - Auto Refresh
    private func startAutoRefresh() {
        timerCancellable = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchSensors()
            }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

