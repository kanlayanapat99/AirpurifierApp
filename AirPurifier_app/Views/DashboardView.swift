//
//  DashboardView.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 8/9/2568 BE.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: DashboardStore
    @EnvironmentObject var languageManager: LanguageManage
    @State private var showInfo = false

    var body: some View {
        NavigationView {
            VStack {
                Stats()
                    .padding(.vertical, 15)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 30) {
                        Text("Dashboard".loc)
                            .font(.largeTitle).bold()
                        Button {
                            showInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .overlay {
                if showInfo {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showInfo = false
                            }

                        // Info card
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("PM2.5 Color Scale".loc)
                                    .font(.subheadline).bold()

                                Text("🟢 0–9.0: Excellent".loc)
                                Text("🟡 9.1–55.4: Moderate".loc)
                                Text("🔴 Above 55.5: Unhealthy for the Elderly".loc)
                            }
                            
                            Divider()

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Temperature Color".loc)
                                    .font(.subheadline).bold()

                                Text("🔵 Blue: Temperature".loc)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground)) // <-- เปลี่ยนตามธีม
                                .shadow(radius: 10)
                        )
                        .frame(maxWidth: 300)
                    }
                }
            }

            } .id(languageManager.selectedLanguage)
        }
    }


#Preview {
    DashboardView()
        .environmentObject(DashboardStore())
}

