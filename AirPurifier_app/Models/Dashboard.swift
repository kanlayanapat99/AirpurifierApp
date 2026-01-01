//
//  Dashboard.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 16/9/2568 BE.
//

import Foundation

//PM2.5 Group of Date
struct PMDataGODate: Codable, Identifiable {
    let id = UUID()
    let ReportDate: String
    let AveragePM25: Double?
    
    var dateValue: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: ReportDate)
    }

    
    enum CodingKeys: String, CodingKey {
        case ReportDate, AveragePM25
    }
}

//PM2.5 Group of Day
struct PMDataGODay: Codable, Identifiable {
    var id = UUID()
    let DayOfWeek: String
    let AveragePM25: Double?
    
    enum CodingKeys: String, CodingKey {
        case DayOfWeek, AveragePM25
    }
}

//PM2.5 Group of Time
struct PMDataGOTime: Codable, Identifiable {
    var id = UUID()
    let TimeSlot: String
    let AveragePM25: Double?
    
    enum CodingKeys: String, CodingKey {
        case TimeSlot, AveragePM25
    }
}

//Temperature Group of Date
struct TempDataGODate: Codable, Identifiable {
    var id = UUID()
    let ReportDate: String
    let AverageCelsius: Double?
    
    var dateValue: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: ReportDate)
    }

    
    enum CodingKeys: String, CodingKey {
        case ReportDate, AverageCelsius
    }
}


//Temperature Group of Day
struct TempDataGODay: Codable, Identifiable {
    var id = UUID()
    let DayOfWeek: String
    let AverageCelsius: Double?
    
    enum CodingKeys: String, CodingKey {
        case DayOfWeek, AverageCelsius
    }
}

//Temperature Group of Time
struct TempDataGOTime: Codable, Identifiable {
    var id = UUID()
    let TimeSlot: String
    let AverageCelsius: Double?
    
    enum CodingKeys: String, CodingKey {
        case TimeSlot, AverageCelsius
    }
}

// JSONBin Response Wrapper
struct JSONBinResponse<T: Codable>: Codable {
    let record: [T]
    let metadata: Metadata?
    
    struct Metadata: Codable {
        let id: String?
        let createdAt: String?
    }
}


