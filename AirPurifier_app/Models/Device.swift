//
//  Device.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import Foundation
import Combine

class Device: ObservableObject, Identifiable {
    let id: UUID = UUID()
    let entityId: String
    let filterEntityId: String
    let aqiEntityId: String
    let pm25EntityId: String
    let notesEntityId: String

    @Published var model: String
    @Published var location: String
    @Published var isOn: Bool
    @Published var mode: String
    @Published var percentage: Int
    @Published var filterLife: Int
    @Published var pm25Value: Double
    @Published var aqiValue: Int
    @Published var fanLevel: DeviceLevel = .off
    @Published var isLoading: Bool = false
    @Published var notes: String?

    init(
        model: String,
        location: String,
        entityId: String,
        filterEntityId: String,
        aqiEntityId: String,
        pm25EntityId: String,
        notesEntityId: String,
        isOn: Bool = false,
        mode: String = "auto",
        percentage: Int = 0,
        filterLife: Int = 0,
        pm25Value: Double = 0.0,
        aqiValue: Int = 0,
        notes: String? = nil
    ) {
        self.model = model
        self.location = location
        self.entityId = entityId
        self.filterEntityId = filterEntityId
        self.aqiEntityId = aqiEntityId
        self.pm25EntityId = pm25EntityId
        self.notesEntityId = notesEntityId
        self.isOn = isOn
        self.mode = mode
        self.percentage = percentage
        self.filterLife = filterLife
        self.pm25Value = pm25Value
        self.aqiValue = aqiValue
        self.notes = notes
    }
}

enum DeviceLevel: String, CaseIterable, Identifiable {
    case off, low, mid, high, turbo

    var id: String { self.rawValue }
    var percentage: Int {
        switch self {
        case .off: return 0
        case .low: return 25
        case .mid: return 50
        case .high: return 75
        case .turbo: return 100
        }
    }
}
