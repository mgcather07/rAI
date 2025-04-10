//
//  LoginView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    var onLogin: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                // Title section with adjusted font sizes per platform.
                Text("Welcome to ")
                    .font(titleFont())
                    .foregroundColor(.primary)
                
                Text("rAI")
                    .font(logoFont())
                    .foregroundColor(.red)
                    .italic()
                
                // Form fields for username and password.
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .textFieldStyle(commonTextFieldStyle())
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(commonTextFieldStyle())
                        .padding(.horizontal)
                }
                
                // Login button with platform-specific styling.
                Button(action: {
                    // Dummy login: triggers the onLogin callback.
                    onLogin()
                }) {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                #if os(macOS)
                .buttonStyle(PlainButtonStyle())
                #endif
                .padding(.horizontal)
            }
            .frame(maxWidth: 500)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Extra padding might be useful on macOS.
        #if os(macOS)
        .padding()
        #endif
    }
    
    // Helper method to adjust title font based on platform.
    private func titleFont() -> Font {
        #if os(iOS)
        return .system(size: 60, weight: .semibold)
        #elseif os(macOS)
        return .system(size: 48, weight: .semibold)
        #else
        return .headline
        #endif
    }
    
    // Helper method to adjust logo font based on platform.
    private func logoFont() -> Font {
        #if os(iOS)
        return .system(size: 100, weight: .semibold)
        #elseif os(macOS)
        return .system(size: 80, weight: .semibold)
        #else
        return .largeTitle
        #endif
    }
    
    // Adjust text field style for each platform.
    private func commonTextFieldStyle() -> some TextFieldStyle {
        #if os(iOS)
        return RoundedBorderTextFieldStyle()
        #elseif os(macOS)
        return PlainTextFieldStyle()
        #else
        return DefaultTextFieldStyle()
        #endif
    }
}
