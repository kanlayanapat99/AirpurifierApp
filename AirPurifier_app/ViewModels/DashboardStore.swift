//
//  DashboardStore.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 15/9/2568 BE.
//

import Foundation
import Combine

class DashboardStore: ObservableObject {
    @Published var pmDate: [PMDataGODate] = []
    @Published var pmDay: [PMDataGODay] = []
    @Published var pmTime: [PMDataGOTime] = []
    @Published var tempDate: [TempDataGODate] = []
    @Published var tempDay: [TempDataGODay] = []
    @Published var tempTime: [TempDataGOTime] = []

    private var refreshTimer: AnyCancellable?

    let headers = ["X-Master-Key": "$2a$10$COVfkQUkHHOSQocqbdFwTuO8/aXZe7lQYCUltOrovXvKtbhXX9h5m"]
    let baseUrl = "https://api.jsonbin.io/v3/b"

    init() {
        fetchAll()
        startAutoRefresh()
    }
    
    // MARK: - Auto Refresh Timer
    private func startAutoRefresh() {
        refreshTimer = Timer
            .publish(every: 1800, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchAll()
            }
    }

    // MARK: - Generic GET function
    private func getData<T: Codable>(id: String, type: T.Type, completion: @escaping ([T]) -> Void) {
        guard let url = URL(string: "\(baseUrl)/\(id)/latest") else {
            print("❌ Invalid URL getData")
            return
        }

        var request = URLRequest(url: url)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Request error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(JSONBinResponse<T>.self, from: data)
                DispatchQueue.main.async {
                    completion(decoded.record)
                }
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }

    func fetchAll() {
        fetchPMDate()
        fetchPMDay()
        fetchPMTime()
        fetchTempDate()
        fetchTempDay()
        fetchTempTime()
    }

    // MARK: - Fetch functions
    func fetchPMDate() {
        getData(id: "68cac8cfd0ea881f40811a8d", type: PMDataGODate.self) { [weak self] result in
            self?.pmDate = result
        }
    }

    func fetchPMDay() {
        getData(id: "68cac914d0ea881f40811aeb", type: PMDataGODay.self) { [weak self] result in
            self?.pmDay = result
        }
    }

    func fetchPMTime() {
        getData(id: "68cac94cae596e708ff1e64f", type: PMDataGOTime.self) { [weak self] result in
            self?.pmTime = result
        }
    }

    func fetchTempDate() {
        getData(id: "68cac8e7d0ea881f40811aa7", type: TempDataGODate.self) { [weak self] result in
            self?.tempDate = result
        }
    }

    func fetchTempDay() {
        getData(id: "68cac932ae596e708ff1e627", type: TempDataGODay.self) { [weak self] result in
            self?.tempDay = result
        }
    }

    func fetchTempTime() {
        getData(id: "68cac97a43b1c97be9462a0d", type: TempDataGOTime.self) { [weak self] result in
            self?.tempTime = result
        }
    }
}
