//
//  HomeDashboardView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftUI

struct HomeDashboardView: View, KeyboardReadable {
    @Environment(\.openURL) private var openURL
    @State var showPromptsAnimation = false
    @State var prompts: [AgentSamples] = []
    var sendPrompt: (String) -> ()
    @State private var isHovering = false
#if os(iOS)
    @State var isKeyboardVisible = false
#endif
    
#if os(macOS)
    var columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 4)
#else
    var columns = [GridItem(.flexible()), GridItem(.flexible())]
#endif
    @State var visibleItems = Set<Int>()
    
    // Compute only the first 4 prompts
    private var limitedPrompts: [AgentSamples] {
        Array(prompts.prefix(4))
    }
    
    // Title gradient for the "rAI" text
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
    
    // Extracted header view containing the title and button.
    var headerView: some View {
        VStack(alignment: .center) {
            Text("rAI")
                .font(.system(size: 46, weight: .thin))
                .multilineTextAlignment(.center)
                .foregroundStyle(titleGradient)
            
            Button(action: onRaiTap) {
                Text("Information Assistant")
                    .font(.system(size: isHovering ? 19 : 17, weight: .light))
                    .scaleEffect(isHovering ? 1.05 : 1.0)
                    .opacity(isHovering ? 0.8 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovering = hovering
            }
        }
    }
    
    // A dedicated view for each prompt button.
    struct HomePromptButtonView: View {
        let prompt: AgentSamples
        let index: Int
        let visibleItems: Set<Int>
        let showPromptsAnimation: Bool
        let sendPrompt: (String) -> ()
        
        var body: some View {
            Button(action: {
                withAnimation {
                    sendPrompt(prompt.agent)
                }
            }) {
                VStack(alignment: .leading) {
                    Text(prompt.agent)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: prompt.type.icon)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .opacity(visibleItems.contains(index) ? 1 : 0)
            .animation(.easeIn(duration: 0.3).delay(0.2 * Double(index)), value: visibleItems)
            .transition(.slide)
            .showIf(showPromptsAnimation)
            .buttonStyle(.plain)
        }
    }
    
    // Extracted grid view for the prompts.
    // Extracted grid view for the prompts.
    var promptGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
            ForEach(limitedPrompts.indices, id: \.self) { index in
                HomePromptButtonView(
                    prompt: limitedPrompts[index],
                    index: index,
                    visibleItems: visibleItems,
                    showPromptsAnimation: showPromptsAnimation,
                    sendPrompt: sendPrompt
                )
            }
        }
        .onAppear {
            for index in 0..<limitedPrompts.count {
                DispatchQueue.main.async {
                    visibleItems.insert(index)
                }
            }
        }
        .frame(maxWidth: 700)
        .background(Color.pink)
        .padding()
        .transition(AnyTransition.opacity.combined(with: .slide))
    }

    
    func onRaiTap() {
        if let url = URL(string: "https://chat.vaatu.co") {
            openURL(url)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 25) {
                headerView
                promptGrid
            }
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation {
                    prompts = AgentSamples.samples.shuffled()
                    showPromptsAnimation = true
                }
            }
        }
#if os(iOS)
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            DispatchQueue.main.async {
                withAnimation {
                    isKeyboardVisible = newIsKeyboardVisible
                }
            }
        }
#endif
    }
}

//#Preview {
//    HomeDashboardView(sendPrompt: { _ in })
//}

