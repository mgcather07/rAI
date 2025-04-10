//
//  AgentView_iOS.swift
//  rAI
//
//  Created by Michael Cather on 4/9/25.
//

import Foundation
import SwiftUI

// MARK: - Assistant View (Main Chat Screen)

struct AssistantView: View {
    // Dummy list of soccer team names as document options.
    private let documentOptions = [
        "BUSA United",
        "Bama Strikers",
        "Mobile Mariners",
        "Montgomery Monarchs",
        "Tuscaloosa Titans",
        "Gulf Coast Rovers",
        "Alabama Aces",
        "BUSA Thunder",
        "Capitol Crushers",
        "Heart of Dixie FC"
    ]
    
    // Chat-like message states.
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    
    // Controls navigation to the document list.
    @State private var navigateToDocuments: Bool = false

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
                    // Auto-scroll to the last message when one is added.
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
                        
                        // Append the user's message.
                        let userMessage = ChatMessage(text: inputText, isUser: true)
                        messages.append(userMessage)
                        
                        // Append a dummy response.
                        let dummyResponse = ChatMessage(text: "This is a dummy response.", isUser: false)
                        messages.append(dummyResponse)
                        
                        // Clear the input.
                        inputText = ""
                    }
                    .padding(.horizontal, 5)
                }
                .padding()
                
                // A hidden NavigationLink that activates when navigateToDocuments is true.
                NavigationLink(
                    destination: SelectDocumentsView(documentOptions: documentOptions),
                    isActive: $navigateToDocuments,
                    label: { EmptyView() }
                )
            } // End of VStack
            .navigationTitle("Assistant")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // The Documents button is enabled only after at least one user message.
                    Button(action: {
                        navigateToDocuments = true
                    }) {
                        Text("Documents")
                            .underline()
                    }
                    .disabled(messages.filter { $0.isUser }.isEmpty)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - ChatMessage Model

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// MARK: - SelectDocumentsView

struct SelectDocumentsView: View {
    let documentOptions: [String]
    @State private var searchText = ""
    
    // Computed property: sort and filter the document options.
    var filteredDocuments: [String] {
        let sortedDocs = documentOptions.sorted()
        if searchText.isEmpty {
            return sortedDocs
        } else {
            return sortedDocs.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List(filteredDocuments, id: \.self) { document in
            // Each document navigates to its detail view.
            NavigationLink(destination: DocumentDetailView(document: document)) {
                Text(document)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Select Document")
    }
}

// MARK: - DocumentDetailView

struct DocumentDetailView: View {
    let document: String
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header image or team logo – replace with your actual asset name
                    Image("BUSA")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    
                    // Team name and tagline
                    VStack(spacing: 6) {
                        Text(document)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Professional Soccer Club")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quick stats section
                    HStack(spacing: 40) {
                        VStack {
                            Text("Founded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("2006")
                                .font(.headline)
                        }
                        Divider()
                        VStack {
                            Text("State")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Alabama")
                                .font(.headline)
                        }
                        Divider()
                        VStack {
                            Text("Stadium")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Regions")
                                .font(.headline)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // A brief description or history
                    Text("""
                    \(document) is one of the most renowned soccer clubs in the league. 
                    With a rich history dating back to the late 21st century, they have 
                    won numerous championships and remain a powerhouse in today’s modern game.
                    """)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    
                    // Some highlights or achievements
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Achievements")
                            .font(.headline)
                        Text("• 10x League Champions")
                        Text("• 5x National Cup Winners")
                        Text("• 2x Continental Cup Winners")
                    }
                    .padding(.horizontal)
                    
                    // Spacing at the bottom
                    Spacer(minLength: 30)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle(document)
            .navigationBarTitleDisplayMode(.inline)
        }
}
