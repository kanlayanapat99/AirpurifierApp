//
//  HomeView.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import SwiftUI
import BottomSheet

enum BottomSheetRelativePosition: CGFloat, CaseIterable {
    case bottom = 0.457
    case middle = 0.458
    case top = 0.650
}

struct HomeView: View {
    @EnvironmentObject var store: DeviceStore
    @State private var sheetPosition: BottomSheetRelativePosition = .bottom

    var filteredDevices: [Device] {
        store.devices.filter { $0.location == "Main Room" }
    }

    var body: some View {
        NavigationView {
            ZStack {
                    
                Group {
                    if sheetPosition == .bottom || sheetPosition == .middle {
                        FullAirQualityCard(airQuality: store.airQuality)
                            .transition(.move(edge: .top))
                    } else {
                        MiniAirQualityCard(airQuality: store.airQuality)
                            .transition(.move(edge: .bottom))
                    }
                } .animation(.interpolatingSpring(stiffness: 20, damping: 30), value: sheetPosition)


                BottomSheetView(
                    position: $sheetPosition,
                    header: {
                        VStack(spacing: 8) {
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 36, height: 6)
                                .padding(.top, 8)
                                .frame(maxWidth: .infinity)
                            Text("Devices".loc)
                                .font(.system(size: 28, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                    },
                    content: {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredDevices) { device in
                                    NavigationLink(destination: DeviceDetailView(device: device)) {
                                        DeviceStack(device: device)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                        .background(Color(.systemBackground).opacity(0.8))
                    }
                )
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RoundedCorner: Shape {
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
