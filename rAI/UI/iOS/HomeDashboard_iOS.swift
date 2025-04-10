//
//  HomeDashboard_iOS.swift
//  rAI
//
//  Created by Michael Cather on 4/9/25.
//

import Foundation
import SwiftUI

struct HomeDashboard_iOS: View {
    @State private var isHovering: Bool = false

    // Gradient for the title.
    private var titleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "4285f4"),
                Color(hex: "9b72cb"),
                Color(hex: "d96570"),
                Color(hex: "#d96570")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // Extracted header view.
    var headerView: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("rAI")
                .font(.system(size: 46, weight: .thin))
                .multilineTextAlignment(.center)
                .foregroundStyle(titleGradient)
            
            Button(action: onRaiTap) {
                Text("Information Assistant")
                    .font(.system(size: isHovering ? 19 : 17, weight: .light))
                    .scaleEffect(isHovering ? 1.05 : 1.0)
                    .opacity(isHovering ? 0.8 : 1.0)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovering = hovering
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
    }
    
    // Action for header button tap.
    func onRaiTap() {
        // Insert your desired functionality here.
        print("Information Assistant tapped")
    }
    
    // Custom square button view.
    func customSquareButton(text: String, gradient: LinearGradient) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 80, height: 80)
            .background(gradient)
            .cornerRadius(10)
    }
    
    // Main view body.
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                headerView
                
                // HStack for the square buttons.
                HStack(spacing: 20) {
                    // Wrap the Tools button in a NavigationLink to ToolsView.
                    NavigationLink(destination: ToolsView()) {
                        customSquareButton(
                            text: "Tools",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    
                    // The other buttons remain as before.
                    NavigationLink(destination: AgentView()) {
                        customSquareButton(
                            text: "Agent",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    
                    Button(action: {
                        print("Assistant button tapped")
                    }) {
                        customSquareButton(
                            text: "Assistant",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
