//
//  AgentView.swift
//  rAI
//
//  Created by Michael Cather on 4/9/25.
//

import Foundation
import SwiftUI

struct AgentView: View {
    // Updated list of AI dummy agent names.
    @State private var selectedAgent: String = "Agents"
    private let agentOptions = [
        "How Smart",
        "NeuralNet Analyzer",
        "Data Whisperer",
        "Cognitive Assistant",
        "Visionary AI",
        "Predictive Modeler",
        "Deep Learning Lab",
        "Mind Meld",
        "Sentiment Synthesizer",
        "Robo Advisor"
    ]
    
    // Chat-like message states.
    @State private var inputText: String = ""
    @State private var messages: [Message] = []
    
    // State to control whether the agent selection sheet is presented.
    @State private var showAgentSheet: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Message Conversation Area
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages) { message in
                                HStack {
                                    if message.isUser {
                                        Spacer()
                                        Text(message.text)
                                            .padding(10)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text(message.text)
                                            .padding(10)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                }
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    // Auto scroll to the bottom when a new message is added.
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // MARK: - Input Field and Send Button
                HStack {
                    TextField("Message rAI", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Send") {
                        guard !inputText.isEmpty else { return }
                        
                        // Append user's message as one bubble.
                        let userMessage = Message(text: inputText, isUser: true)
                        messages.append(userMessage)
                        
                        // Append dummy response as another bubble.
                        let dummyResponse = Message(text: "No, he is a complete idiot", isUser: false)
                        messages.append(dummyResponse)
                        
                        // Clear the input text after sending.
                        inputText = ""
                    }
                    .padding(.horizontal, 5)
                }
                .padding()
            }
            .navigationBarTitle("Agent")
            .navigationBarTitleDisplayMode(.large)
            // MARK: - Toolbar with Underlined Agent Button
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAgentSheet = true
                    }) {
                        Text(selectedAgent)
                            .underline()
                    }
                }
            }
            // Present the SelectAgent sheet.
            .sheet(isPresented: $showAgentSheet) {
                SelectAgent(agentOptions: agentOptions) { agent in
                    selectedAgent = agent
                    showAgentSheet = false
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct SelectAgent: View {
    let agentOptions: [String]
    let onAgentSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredAgentOptions: [String] {
        // First, sort the agents alphabetically.
        let sortedAgents = agentOptions.sorted()
        // Then filter based on the search text.
        if searchText.isEmpty {
            return sortedAgents
        } else {
            return sortedAgents.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredAgentOptions, id: \.self) { agent in
                Button(action: {
                    onAgentSelected(agent)
                }) {
                    Text(agent)
                }
            }
            // Add a search bar in the navigation bar drawer
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Agent")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()  // Dismiss the sheet.
                    }
                }
            }
        }
    }
}

