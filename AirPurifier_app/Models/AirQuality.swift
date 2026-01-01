//
//  AirQuality.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import Foundation

struct AirQuality: Codable {
    let location: String
    let city: String
    let pm25: Double
    let temperature: Double
    let lastUpdated: Date
}
