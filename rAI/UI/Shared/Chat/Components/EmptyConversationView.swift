//
//  EmptyConversationView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

struct EmptyConversaitonView: View, KeyboardReadable {
    @Environment(\.openURL) private var openURL
    @State var showPromptsAnimation = false
    @State var prompts: [AgentSamples] = []
    var sendPrompt: (String) -> ()
    @State private var isHovering = false
#if os(iOS)
    @State var isKeyboardVisible = false
#endif
    
#if os(macOS)
    var columns = Array.init(repeating: GridItem(.flexible(), spacing: 15), count: 4)
#else
    var columns = [GridItem(.flexible()), GridItem(.flexible())]
#endif
    @State var visibleItems = Set<Int>()
    
    func onRaiTap() {
        if let url = URL(string: "https://chat.vaatu.co") {
            openURL(url)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 25) {
                
                // ---------- \\
                VStack(alignment: .center) {
                    
                    
                    Text("rAI")
                        .font(Font.system(size: 46, weight: .thin))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4285f4"), Color(hex: "9b72cb"), Color(hex: "d96570"), Color(hex: "#d96570")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
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
                // ---------- \\
                
                // ---------- \\
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    ForEach(0..<prompts.prefix(4).count, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                sendPrompt(prompts[index].agent)
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text(prompts[index].agent)
                                    .font(.system(size: 15))
                                Spacer()
                                
                                // todo: sub text here
                                
                                HStack {
                                    Spacer()
                                    Image(systemName: prompts[index].type.icon)
                                }
                            }
//                            .frame(maxWidth: .infinity)
                            .frame(width: 125, height: 125)
                            .padding(15)
                            .background(Color.gray5Custom)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                        .opacity(visibleItems.contains(index) ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.2 * Double(index)), value: visibleItems)
                        .transition(.slide)
                        .showIf(showPromptsAnimation)
                        .buttonStyle(.plain)
                    }
                }
                .onAppear {
                    for index in 0..<4 {
                        DispatchQueue.main.async {
                            visibleItems.insert(index)
                        }
                    }
                }
                .frame(maxWidth: 700)
                .padding()
                .transition(AnyTransition(.opacity).combined(with: .slide))
#if os(iOS)
                .showIf(!isKeyboardVisible)
#endif
                // ---------- \\
                
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
    EmptyConversaitonView(sendPrompt: {_ in})
}

