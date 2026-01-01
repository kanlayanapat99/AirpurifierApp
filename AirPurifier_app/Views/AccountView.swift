//
//  AccountView.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 25/7/2568 BE.
//

import SwiftUI
import BottomSheet

enum SheetPosition: CGFloat, CaseIterable {
    case hidden = 0.0
    case show = 0.45
}

struct AccountView: View {
    @EnvironmentObject var auth: Auth
    @EnvironmentObject var languageManager: LanguageManage
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    
    @State private var SheetPosition: SheetPosition = .hidden
    @State private var appearanceSheetPosition: SheetPosition = .hidden
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Your Account".loc)) {
                        HStack {
                            Text("Email".loc)
                            Spacer()
                            Text(auth.email)
                                .foregroundColor(.gray)
                        }
                    }
 
                    Section {
                        // Language button
                        Button {
                            withAnimation {
                                SheetPosition = .show
                            }
                        } label: {
                            HStack {
                                Text("Language".loc)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(languageManager.selectedLanguage == "en" ? "English" : "ไทย")
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Appearance button
                        Button {
                            withAnimation {
                                appearanceSheetPosition = .show
                            }
                        } label: {
                            HStack {
                                Text("Appearance".loc)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(appearanceLabel(for: selectedAppearance))
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showLogoutAlert = true   // <- กดแล้วเปิด Alert
                        } label: {
                            Text("Log out".loc)
                        }
                    }
                }
                .navigationTitle("Account Settings".loc)
                .id(languageManager.selectedLanguage)
                .alert(isPresented: $showLogoutAlert) {  // <- แสดง Alert
                    Alert(
                        title: Text("Confirm Logout".loc),
                        message: Text("Are you sure you want to log out?".loc),
                        primaryButton: .destructive(Text("Log out".loc)) {
                            auth.logout()
                        },
                        secondaryButton: .cancel(Text("Cancel".loc))
                    )
                }
                
                if SheetPosition == .show || appearanceSheetPosition == .show {
                    Color.gray.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                SheetPosition = .hidden
                                appearanceSheetPosition = .hidden
                            }
                        }
                        .transition(.opacity)
                }
                
                // Bottom Sheet เลือกภาษา
                BottomSheetView(
                    position: $SheetPosition,
                    header: {
                        headerView(title: "Select Language".loc)
                    },
                    content: {
                        VStack(spacing: 16) {
                            ForEach(["en", "th"], id: \.self) { lang in
                                languageRow(lang: lang)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                )
                
                // Bottom Sheet เลือก appearance
                BottomSheetView(
                    position: $appearanceSheetPosition,
                    header: {
                        headerView(title: "Select Appearance".loc)
                    },
                    content: {
                        VStack(spacing: 16) {
                            ForEach(["system", "light", "dark"], id: \.self) { mode in
                                appearanceRow(mode: mode)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func headerView(title: String) -> some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 6)
                .padding(.top, 8)
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    private func languageRow(lang: String) -> some View {
        HStack {
            Text(lang == "en" ? "English" : "ไทย")
                .foregroundColor(.primary)
            Spacer()
            Button {
                languageManager.selectedLanguage = lang
                withAnimation { SheetPosition = .hidden }
            } label: {
                selectionIndicator(isSelected: languageManager.selectedLanguage == lang)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func appearanceRow(mode: String) -> some View {
        HStack {
            Text(appearanceLabel(for: mode))
                .foregroundColor(.primary)
            Spacer()
            Button {
                selectedAppearance = mode
                withAnimation { appearanceSheetPosition = .hidden }
            } label: {
                selectionIndicator(isSelected: selectedAppearance == mode)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func appearanceLabel(for mode: String) -> String {
        switch mode {
        case "light": return "Light".loc
        case "dark": return "Dark".loc
        default: return "Use device settings".loc
        }
    }
    
    private func selectionIndicator(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                Text("✓")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 28, height: 28)
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            } else {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .frame(width: 28, height: 28)
            }
        }
    }
}
