//
//  ToolsView_iOS.swift
//  rAI
//
//  Created by Michael Cather on 4/9/25.
//

import Foundation
import SwiftUI

struct ToolsView: View {
    // Updated list of AI dummy tool names.
    @State private var selectedTool: String = "Select Tool"
    private let toolOptions = [
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
    
    // State to control whether the tool selection sheet is presented.
    @State private var showToolSheet: Bool = false

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
                    TextField("rAI is here to help...", text: $inputText)
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
            .navigationBarTitle("Tools")
            .navigationBarTitleDisplayMode(.large)
            // MARK: - Toolbar with Underlined Select Tool Button
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showToolSheet = true
                    }) {
                        Text(selectedTool)
                            .underline()
                    }
                }
            }
            // Present the SelectTools sheet.
            .sheet(isPresented: $showToolSheet) {
                SelectTools(toolOptions: toolOptions) { tool in
                    selectedTool = tool
                    showToolSheet = false
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct SelectTools: View {
    let toolOptions: [String]
    let onToolSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredToolOptions: [String] {
        // First, sort the tools alphabetically.
        let sortedTools = toolOptions.sorted()
        // Then filter based on the search text.
        if searchText.isEmpty {
            return sortedTools
        } else {
            return sortedTools.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredToolOptions, id: \.self) { tool in
                Button(action: {
                    onToolSelected(tool)
                }) {
                    Text(tool)
                }
            }
            // Add a search bar in the navigation bar drawer
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Select Tool")
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
