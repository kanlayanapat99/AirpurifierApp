//
//  AirPurifier_appApp.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 14/6/2568 BE.
//

import SwiftUI

@main
struct AirControlApp: App {
    @StateObject private var authStore: AuthStore
    @StateObject private var auth: Auth
    @StateObject private var store = DeviceStore()
    @StateObject private var languageManager = LanguageManage()
    @StateObject private var dashboard = DashboardStore()
    @StateObject private var sensor = SensorStore()
    
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"

    init() {
        // ✅ สร้าง instance ก่อน
        let authStoreInstance = AuthStore()
        let authInstance = Auth(authStore: authStoreInstance)

        // ✅ กำหนดให้ StateObject โดยใช้ wrappedValue
        _authStore = StateObject(wrappedValue: authStoreInstance)
        _auth = StateObject(wrappedValue: authInstance)

        // tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemCyan
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemCyan]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    var body: some Scene {
        WindowGroup {
            if auth.isAuthenticated {
                TabView {
                    HomeView()
                        .tabItem { Image(systemName: "house"); Text("Home".loc) }
                    DevicesView()
                        .tabItem { Image(systemName: "fanblades.fill"); Text("Devices".loc) }
                    DashboardView()
                        .tabItem { Image(systemName: "chart.bar.fill"); Text("Dashboard".loc) }
                    AccountView()
                        .tabItem { Image(systemName: "person.circle"); Text("Account".loc) }
                }
                .environmentObject(store)
                .environmentObject(auth)
                .environmentObject(authStore)
                .environmentObject(languageManager)
                .environmentObject(dashboard)
                .environmentObject(sensor)
                .accentColor(.blue)
                .preferredColorScheme(colorSchemeFromSelection())
            } else {
                LoginView()
                    .environmentObject(auth)
                    .environmentObject(authStore)
                    .environmentObject(languageManager)
                    .id(languageManager.selectedLanguage)
            }
        }
    }

    private func colorSchemeFromSelection() -> ColorScheme? {
        switch selectedAppearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
