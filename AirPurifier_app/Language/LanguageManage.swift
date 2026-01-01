//
//  LanguageManage.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 29/7/2568 BE.
//

import SwiftUI

class LanguageManage: ObservableObject {
    @Published var selectedLanguage: String {
        didSet {
            setLanguage(selectedLanguage)
        }
    }

    init() {
        selectedLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first ?? "en"
    }

    private func setLanguage(_ lang: String) {
        UserDefaults.standard.set([lang], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        Bundle.setLanguage(lang)
    }
}


