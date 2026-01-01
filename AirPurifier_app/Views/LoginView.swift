//
//  LoginView.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 23/7/2568 BE.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var auth: Auth
    @EnvironmentObject var languageManager: LanguageManage
    @State private var error = ""

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack(spacing: 20) {
                Image("MyAppIcon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Log in".loc)
                    .font(.title.bold())
                    .foregroundColor(.black)
                    .padding(.bottom, 10)

                if !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                // MARK: - Custom Google Sign In Button
                Button(action: {
                    handleGoogleSignIn()
                }) {
                    HStack(spacing: 12) {
                        Image("GoogleLogo")
                            .resizable()
                            .frame(width: 35, height: 35)
                        Text("Sign in with Google".loc)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)


            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 8)
            .padding()
            .id(languageManager.selectedLanguage)
        }
    }

    func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            print("❌ Can't find root view controller")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                self.error = error.localizedDescription
                return
            }

            guard let user = result?.user,
                  let email = user.profile?.email else {
                self.error = "Cannot get email".loc
                return
            }

            if auth.isEmailAllowed(email) {
                auth.login(with: email)
            } else {
                self.error = "Email not allowed".loc
            }
        }
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuth = Auth(authStore: AuthStore())
        let mockLang = LanguageManage()
        LoginView()
            .environmentObject(mockAuth)
            .environmentObject(mockLang)
    }
}
