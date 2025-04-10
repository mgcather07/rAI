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
                Text("Welcome to ")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(.primary)
                    
                Text("rAI")
                    .font(.system(size: 100, weight: .semibold))
                    .foregroundColor(.red)
                    .italic()
                
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                Button(action: {
                    // Dummy login: simply trigger the onLogin callback.
                    onLogin()
                }) {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: 500)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
