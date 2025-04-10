//
//  EmptyConversationView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

// A separate view for each prompt button.
struct PromptButtonView: View {
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
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: prompt.type.icon)
                }
            }
            .frame(width: 125, height: 125)
            .padding(15)
            .background(Color.pink)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .opacity(visibleItems.contains(index) ? 1 : 0)
        .animation(.easeIn(duration: 0.3).delay(0.2 * Double(index)), value: visibleItems)
        .transition(.slide)
        .showIf(showPromptsAnimation)
        .buttonStyle(.plain)
    }
}

struct EmptyConversaitonView: View, KeyboardReadable {
    @Environment(\.openURL) private var openURL
    @State var showPromptsAnimation = false
    @State var prompts: [AgentSamples] = []
    var sendPrompt: (String) -> ()
    @State private var isHovering = false
#if os(iOS)
    @State var isKeyboardVisible = true
#endif
    
#if os(macOS)
    var columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 4)
#else
    var columns = [GridItem(.flexible()), GridItem(.flexible())]
#endif
    @State var visibleItems = Set<Int>()
    
    // Computed property for the limited prompts.
    private var limitedPrompts: [AgentSamples] {
        Array(prompts.prefix(4))
    }
    
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
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovering = hovering
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
    }
    
    // Extracted prompt grid view.
    var promptGrid: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 15) {
            ForEach(limitedPrompts.indices, id: \.self) { index in
                PromptButtonView(
                    prompt: limitedPrompts[index],
                    index: index,
                    visibleItems: visibleItems,
                    showPromptsAnimation: showPromptsAnimation,
                    sendPrompt: sendPrompt
                )
            }
        }
        .frame(maxWidth: .infinity) // Makes the grid take full available width
        .padding()
        .transition(AnyTransition.opacity.combined(with: .slide))
    #if os(iOS)
        .showIf(!isKeyboardVisible)
    #endif
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

#Preview {
    EmptyConversaitonView(sendPrompt: { _ in })
}

