//
//  AirQualityCard.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//


import SwiftUI

struct FullAirQualityCard: View {
    let airQuality: AirQuality
    @State private var currentTime = Date()
    @State private var animateGradient = false
    private var aqi: Int {
        AQIHelper.aqiFromPM25(airQuality.pm25)
    }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var gradient: LinearGradient {
        let colors: [Color]
        switch airQuality.pm25 {
        case 0..<9.1: colors = [.green, .mint]
        case 9.1..<55.5: colors = [.yellow, .orange]
        default: colors = [.orange, .red]
        }

        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
    }

    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM, HH:mm:ss"
        return formatter.string(from: currentTime)
    }

    var body: some View {
        ZStack {
            gradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Location
                VStack(alignment: .leading, spacing: 4) {
                    Text(airQuality.location.loc)
                        .font(.system(size: 36, weight: .bold))
                    Text(airQuality.city.loc)
                        .font(.system(size: 24, weight: .regular))
                        .opacity(0.8)
                }

                // MARK: - Date & Time
                HStack {
                    Text(formattedDateTime)
                        .font(.headline)
                        .opacity(0.9)
                    Spacer()
                }
                .padding(.vertical, 5)

                // MARK: - PM2.5 Section
                VStack(spacing: 10) {
                    VStack(alignment: .center, spacing: 4) {

                        Text("PM2.5")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.top, 6)

                        Text(String(format: "%.1f", airQuality.pm25))
                            .font(.system(size: 80, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)

                        HStack {
                            Spacer()
                            Text("µg/m³".loc)
                                .font(.system(size: 20, weight: .regular))
                                .opacity(0.8)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }

                    HStack(spacing: 12) {

                        Text("Temp : \(Int(airQuality.temperature))°C")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)

                        Text("AQI : \(aqi)")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .cornerRadius(20)

                }

                Spacer()
            }
            .padding(32)
            .foregroundColor(.white)
        }
        .onReceive(timer) { currentTime = $0 }
        .onAppear {
            // แค่ animate gradient
            DispatchQueue.main.async {
                withAnimation(
                    Animation.easeInOut(duration: 5)
                        .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }
        }

    }
}



// MARK: - MiniCard Scroll up .top
struct MiniAirQualityCard: View {
    let airQuality: AirQuality
    @State private var currentTime = Date()
    @State private var animateGradient = false
    private var aqi: Int {
        AQIHelper.aqiFromPM25(airQuality.pm25)
    }

    private var gradient: LinearGradient {
        let colors: [Color]
        switch airQuality.pm25 {
        case 0..<9.1: colors = [.green, .mint]
        case 9.1..<55.5: colors = [.yellow, .orange]
        default: colors = [.orange, .red]
        }

        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM HH:mm:ss"
        return formatter.string(from: currentTime)
    }

    var body: some View {
        ZStack {
            gradient
                .ignoresSafeArea()
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    // Location
                    VStack(alignment: .leading, spacing: 4) {
                        Text(airQuality.location.loc)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text(airQuality.city.loc)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    // Data
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PM2.5")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text("Temp : \(Int(airQuality.temperature))°C")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 10) {
                            Text("\(String(format: "%.2f", airQuality.pm25)) " + "µg/m³".loc)
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.white)
                            Text("AQI : \(aqi)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(20)
                .background(gradient)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 4, y: 3)
                .padding(.horizontal)
                .padding(.top, 32)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}

