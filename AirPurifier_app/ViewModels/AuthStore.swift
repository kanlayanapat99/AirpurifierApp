//
//  AuthStore.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 15/9/2568 BE.
//

import Foundation
import Combine

class AuthStore: ObservableObject {
    @Published var allowedEmails: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    let haBaseURL = "https://ob2s2wfi0mp5smcvcbz8rydvzt2hlvwk.ui.nabu.casa"
    let haToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIwNDEzNmRkYTA3ODE0ODY4YmIwMWU4NmJlZWY0MDA2MiIsImlhdCI6MTc0OTcwNDQ0NCwiZXhwIjoyMDY1MDY0NDQ0fQ.XshdadBtHNeAv0_L-X69q_lwTPm6fYKSh-zTsvgymvE"
    
    init() {
        fetchAllowedEmails()
    }
    
    // MARK: - ดึงค่า allowed_emails จาก Home Assistant
    func fetchAllowedEmails() {
        getState(entity: "input_text.allowed_emails") { state, _ in
            DispatchQueue.main.async {
                if let data = state.data(using: .utf8),
                   let emails = try? JSONDecoder().decode([String].self, from: data) {
                    self.allowedEmails = emails.map { $0.lowercased() }
                    print("✅ Allowed emails updated: \(emails)")
                } else {
                    print("❌ Failed to parse allowed_emails")
                    self.allowedEmails = []
                }
            }
        }
    }
    
    // MARK: - GET state
    private func getState(entity: String, completion: @escaping (String, [String: Any]) -> Void) {
        guard let url = URL(string: "\(haBaseURL)/api/states/\(entity)") else {
            print("❌ Invalid getState URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(haToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ getState error: \(error.localizedDescription)")
                completion("", [:])
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                print("❌ Failed to parse state JSON")
                completion("", [:])
                return
            }

            if let state = json["state"] as? String,
               let attr = json["attributes"] as? [String: Any] {
                completion(state, attr)
            } else {
                completion("", [:])
            }
        }.resume()
    }
    
    // MARK: - ตรวจสอบ email
    func isEmailAllowed(_ email: String) -> Bool {
        allowedEmails.contains(email.lowercased())
    }
}
