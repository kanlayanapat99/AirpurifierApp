//
//  Stats.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 8/9/2568 BE.
//

import SwiftUI
import Charts

struct Stats: View {
    
    enum DisplayType: String, CaseIterable, Identifiable {
        case days = "Days"
        case dates = "Dates"
        case times = "Times"
        
        var id: String { rawValue }
        
        var localized: String {
            rawValue.loc
        }
    }
    
    @State private var selectedType: DisplayType = .days
    @EnvironmentObject var dashboardStore: DashboardStore
    @EnvironmentObject var languageManager: LanguageManage // เพิ่มเพื่อเปลี่ยน Locale
    
    // MARK: - Dynamic Formatters
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: languageManager.selectedLanguage == "th" ? "th_TH" : "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }
    
    private var dateLabelFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        f.locale = Locale(identifier: languageManager.selectedLanguage == "th" ? "th_TH" : "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }
    
    private var dateTableFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        f.locale = Locale(identifier: languageManager.selectedLanguage == "th" ? "th_TH" : "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Segmented Picker
            HStack(spacing: 0) {
                ForEach(DisplayType.allCases) { type in
                    Button(action: {
                        withAnimation {
                            selectedType = type
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(type.localized)
                                .font(.headline)
                                .foregroundColor(selectedType == type ? .primary : .gray)
                            
                            Rectangle()
                                .frame(height: 3)
                                .foregroundColor(selectedType == type ? .cyan : .clear)
                                .cornerRadius(1.5)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            
            ScrollView {
                VStack(spacing: 30) {
                    // MARK: - Charts Section
                    VStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("PM2.5 (µg/m³)".loc).font(.headline).padding(.horizontal)
                            pm25Chart()
                        }
                        VStack(alignment: .leading) {
                            Text("Temperature (°C)".loc).font(.headline).padding(.horizontal)
                            tempChart()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // MARK: - Table Section
                    summaryTable()
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }

        }
        .id(languageManager.selectedLanguage) // รีเฟรช view เมื่อเปลี่ยนภาษา
    }
    
    // MARK: - PM2.5 Chart
    @ViewBuilder
    func pm25Chart() -> some View {
        Chart {
            switch selectedType {
            case .days:
                ForEach(dashboardStore.pmDay.filter { $0.AveragePM25 != nil }) { data in
                    let abbr = String(data.DayOfWeek.prefix(3))
                    BarMark(
                        x: .value("Day", abbr.loc),
                        y: .value("PM2.5", data.AveragePM25!)
                    )
                    .foregroundStyle(colorForPM(value: data.AveragePM25!))
                    .annotation(position: .top) {
                        Text(String(format: "%.1f", data.AveragePM25!))
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }
                }

            case .dates:
                ForEach(dashboardStore.pmDate.filter { $0.AveragePM25 != nil }) { data in
                    if let date = data.dateValue {
                        LineMark(
                            x: .value("Date", date),
                            y: .value("PM2.5", data.AveragePM25!)
                        )
                        .foregroundStyle(.gray)

                        PointMark(
                            x: .value("Date", date),
                            y: .value("PM2.5", data.AveragePM25!)
                        )
                        .foregroundStyle(colorForPM(value: data.AveragePM25!))
                    }
                }

            case .times:
                ForEach(dashboardStore.pmTime.filter { $0.AveragePM25 != nil }) { data in
                    if let date = timeFormatter.date(from: data.TimeSlot) {
                        LineMark(
                            x: .value("Time", date),
                            y: .value("PM2.5", data.AveragePM25!)
                        )
                        .foregroundStyle(.gray)

                        PointMark(
                            x: .value("Time", date),
                            y: .value("PM2.5", data.AveragePM25!)
                        )
                        .foregroundStyle(colorForPM(value: data.AveragePM25!))
                    }
                }
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            switch selectedType {
            case .days:
                AxisMarks()
            case .dates:
                let validDates = dashboardStore.pmDate
                    .compactMap { $0.AveragePM25 != nil ? $0.dateValue : nil }
                    .sorted()
                let stepDates = stride(from: 0, to: validDates.count, by: 5).map { validDates[$0] }

                AxisMarks(values: stepDates) { value in
                    if let date = value.as(Date.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(dateLabelFormatter.string(from: date))
                    }
                }
            case .times:
                let validTimes = dashboardStore.pmTime
                    .compactMap { $0.AveragePM25 != nil ? timeFormatter.date(from: $0.TimeSlot) : nil }
                    .sorted()
                let stepTimes = validTimes.filter { Calendar.current.component(.hour, from: $0) % 4 == 0 }

                AxisMarks(values: stepTimes) { value in
                    if let date = value.as(Date.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(timeFormatter.string(from: date))
                    }
                }
            }
        }

    }
    
    // MARK: - Temperature Chart
    @ViewBuilder
    func tempChart() -> some View {
        Chart {
            switch selectedType {
            case .days:
                ForEach(dashboardStore.tempDay.filter { $0.AverageCelsius != nil }) { data in
                    let abbr = String(data.DayOfWeek.prefix(3))
                    BarMark(
                        x: .value("Day", abbr.loc),
                        y: .value("Temp", data.AverageCelsius!)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top) {
                        Text(String(format: "%.1f", data.AverageCelsius!))
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }
                }

            case .dates:
                ForEach(dashboardStore.tempDate.filter { $0.AverageCelsius != nil }) { data in
                    if let date = data.dateValue {
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Temp", data.AverageCelsius!)
                        )
                        .foregroundStyle(.gray)
                        
                        PointMark(
                            x: .value("Date", date),
                            y: .value("Temp", data.AverageCelsius!)
                        )
                        .foregroundStyle(.blue)
                    }
                }
            case .times:
                ForEach(dashboardStore.tempTime.filter { $0.AverageCelsius != nil }) { data in
                    if let date = timeFormatter.date(from: data.TimeSlot) {
                        LineMark(
                            x: .value("Time", date),
                            y: .value("Temp", data.AverageCelsius!)
                        )
                        .foregroundStyle(.gray)
                        
                        PointMark(
                            x: .value("Time", date),
                            y: .value("Temp", data.AverageCelsius!)
                        )
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            switch selectedType {
            case .days:
                AxisMarks()
            case .dates:
                let validDates = dashboardStore.tempDate
                    .compactMap { $0.AverageCelsius != nil ? $0.dateValue : nil }
                    .sorted()
                
                let stepDates = stride(from: 0, to: validDates.count, by: 5).map { validDates[$0] }
                
                AxisMarks(values: stepDates) { value in
                    if let date = value.as(Date.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(dateLabelFormatter.string(from: date))
                    }
                }
                
            case .times:
                let validTimes = dashboardStore.tempTime
                    .compactMap { $0.AverageCelsius != nil ? timeFormatter.date(from: $0.TimeSlot) : nil }
                    .sorted()
                
                let stepTimes = validTimes.filter { Calendar.current.component(.hour, from: $0) % 4 == 0 }
                
                AxisMarks(values: stepTimes) { value in
                    if let date = value.as(Date.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(timeFormatter.string(from: date))
                    }
                }
            }
        }

    }
    
    // MARK: - Summary Table
    @ViewBuilder
    func summaryTable() -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                switch selectedType {
                case .days:
                    Text("Day".loc).bold().frame(maxWidth: .infinity)
                    Text("PM2.5".loc).bold().frame(maxWidth: .infinity)
                    Text("Temp".loc).bold().frame(maxWidth: .infinity)
                case .dates:
                    Text("Date".loc).bold().frame(maxWidth: .infinity)
                    Text("PM2.5".loc).bold().frame(maxWidth: .infinity)
                    Text("Temp".loc).bold().frame(maxWidth: .infinity)
                case .times:
                    Text("Time".loc).bold().frame(maxWidth: .infinity)
                    Text("PM2.5".loc).bold().frame(maxWidth: .infinity)
                    Text("Temp".loc).bold().frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.cyan.opacity(0.2))
            .cornerRadius(10, corners: [.topLeft, .topRight])
            
            // Rows
            VStack(spacing: 0) {
                switch selectedType {
                case .days:
                    ForEach(Array(zip(dashboardStore.pmDay.filter { $0.AveragePM25 != nil }, dashboardStore.tempDay.filter { $0.AverageCelsius != nil })), id: \.0.id) { pm, temp in
                        HStack {
                            Text(pm.DayOfWeek.loc).frame(maxWidth: .infinity)
                            Text(String(format: "%.1f", pm.AveragePM25!)).frame(maxWidth: .infinity)
                            Text(String(format: "%.1f", temp.AverageCelsius!)).frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 10)
                    }
                case .dates:
                    ForEach(Array(zip(dashboardStore.pmDate.filter { $0.AveragePM25 != nil }, dashboardStore.tempDate.filter { $0.AverageCelsius != nil })), id: \.0.id) { pm, temp in
                        HStack {
                            if let date = pm.dateValue {
                                Text(dateTableFormatter.string(from: date))
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("-").frame(maxWidth: .infinity)
                            }
                            Text(String(format: "%.1f", pm.AveragePM25!)).frame(maxWidth: .infinity)
                            Text(String(format: "%.1f", temp.AverageCelsius!)).frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 10)
                    }
                case .times:
                    ForEach(Array(zip(dashboardStore.pmTime.filter { $0.AveragePM25 != nil }, dashboardStore.tempTime.filter { $0.AverageCelsius != nil })), id: \.0.id) { pm, temp in
                        HStack {
                            Text(pm.TimeSlot.loc).frame(maxWidth: .infinity)
                            Text(String(format: "%.1f", pm.AveragePM25!)).frame(maxWidth: .infinity)
                            Text(String(format: "%.1f", temp.AverageCelsius!)).frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.vertical)
    }
    
    // MARK: - PM2.5 Color
    func colorForPM(value: Double) -> Color {
        switch value {
        case 0..<9.1: return .green
        case 9.1..<55.5: return .yellow
        default: return .red
        }
    }
}

// MARK: - Rounded Corner Shape
struct RoundedCornerShape: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
