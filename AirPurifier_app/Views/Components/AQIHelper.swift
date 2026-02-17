//
//  AQIHelper.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 15/2/2569 BE.
//

import Foundation

struct AQIHelper {

    static func aqiFromPM25(_ pm: Double) -> Int {
        let table: [(Double, Double, Int, Int)] = [
            (0.0, 12.0, 0, 50),
            (12.1, 35.4, 51, 100),
            (35.5, 55.4, 101, 150),
            (55.5, 150.4, 151, 200),
            (150.5, 250.4, 201, 300),
            (250.5, 350.4, 301, 400),
            (350.5, 500.4, 401, 500)
        ]

        for (bpLo, bpHi, iLo, iHi) in table {
            if pm >= bpLo && pm <= bpHi {
                let aqi = (Double(iHi - iLo)/(bpHi - bpLo)) * (pm - bpLo) + Double(iLo)
                return Int(round(aqi))
            }
        }
        return 500
    }
}
