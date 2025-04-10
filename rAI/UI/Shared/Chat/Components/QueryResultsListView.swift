//
//  QueryResultsListView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftUI

#if os(macOS)
import AppKit
#endif

struct QueryResultListView: View {
    var messages: [MessageSD]
    var conversationState: ConversationState
    var userInitials: String
    @Binding var editMessage: MessageSD?
    @State private var messageSelected: MessageSD?
    @StateObject private var speechSynthesizer = SpeechSynthesizer.shared
    
    func onEditMessageTap() -> (MessageSD) -> Void {
        return { message in
            editMessage = message
        }
    }
    
    func onReadAloud(_ message: String) {
        Task {
            await speechSynthesizer.speak(text: message)
        }
    }
    
    func stopReadingAloud() {
        Task {
            await speechSynthesizer.stopSpeaking()
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack {
                        ForEach(messages) { message in
                            let contextMenu = ContextMenu(menuItems: {
                                Button(action: {Clipboard.shared.setString(message.content)}) {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                
#if os(iOS) || os(visionOS)
                                Button(action: { messageSelected = message }) {
                                    Label("Select Text", systemImage: "selection.pin.in.out")
                                }
                                
                                Button(action: {
                                    onReadAloud(message.content)
                                }) {
                                    Label("Read Aloud", systemImage: "speaker.wave.3.fill")
                                }
#endif
                                
                                if message.role == "user" {
                                    Button(action: {
                                        withAnimation { editMessage = message }
                                    }) {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                }
                                
                                if editMessage?.id == message.id {
                                    Button(action: {
                                        withAnimation { editMessage = nil }
                                    }) {
                                        Label("Unselect", systemImage: "pencil")
                                    }
                                }
                            })
                            
                            ChatMessageView(
                                message: message,
                                showLoader: conversationState == .loading && messages.last == message,
                                userInitials: userInitials,
                                editMessage: $editMessage
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .contentShape(Rectangle())
                            .contextMenu(contextMenu)
                            .runningBorder(animated: message.id == editMessage?.id)
                            .id(message)
                        }
                    }
                }
                .onAppear {
                    scrollViewProxy.scrollTo(messages.last, anchor: .bottom)
                }
                .onChange(of: messages) { oldMessages, newMessages in
                    scrollViewProxy.scrollTo(messages.last, anchor: .bottom)
                }
                .onChange(of: messages.last?.content) {
                    scrollViewProxy.scrollTo(messages.last, anchor: .bottom)
                }
#if os(iOS) || os(visionOS)
                .sheet(item: $messageSelected) { message in
                    SelectTextSheet(message: message)
                }
#endif
            }
            
            ReadingAloudView(onStopTap: stopReadingAloud)
                .frame(maxWidth: 400)
                .showIf(speechSynthesizer.isSpeaking)
                .transition(.asymmetric(
                    insertion: AnyTransition.opacity.combined(with: .scale(scale: 0.7, anchor: .top)),
                    removal: AnyTransition.opacity.combined(with: .scale(scale: 0.7, anchor: .top)))
                )
        }
    }
}


/// A container view that organizes the chat messages in the center with two side columns reserved for RAG query results.
struct TripleColumnChatView: View {
    var messages: [MessageSD]
    var conversationState: ConversationState
    var userInitials: String
    @Binding var editMessage: MessageSD?
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // MARK: - Center Column (Chat Messages)
            QueryResultListView(
                messages: messages,
                conversationState: conversationState,
                userInitials: userInitials,
                editMessage: $editMessage
            )
//            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // MARK: - Right Column (Additional RAG Enhancements)
            VStack {
                RAGStaggeredGridView(title: "Knowledge Base Documents", messages: messages)
            }
            
        }
        .padding()
        .padding(.top)
        .edgesIgnoringSafeArea(.all)
    }
}

struct RAGStaggeredGridView: View {
    let title: String
    var messages: [MessageSD]

    @State private var selectedDocument: RaiLoaderDocument? = nil
    
    @State private var presentingDocument: Bool = false


    private var documents: [RaiLoaderDocument] {
        messages.last?.documents ?? []
    }

    private var leftColumnDocuments: [RaiLoaderDocument] {
        documents.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
    }

    private var rightColumnDocuments: [RaiLoaderDocument] {
        documents.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }
    }
    

    private let gridLayout = [
        GridItem(.adaptive(minimum: 200), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    

                    LazyVGrid(columns: gridLayout, spacing: 8) {
                        ForEach(documents) { document in
                            DocumentCardView(document: document)
                               .onTapGesture {
                                   selectedDocument = document
                                   presentingDocument.toggle()
                               }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .sheet(isPresented: $presentingDocument, content: {  RaiLoaderDocumentPopupView(documentItem: selectedDocument ?? RaiLoaderDocument(id: "", distance: 0.0, document: "", metadata: ["":""], formatted: "")) })
            
        }
    }
}

struct DocumentCardView: View {
    var document: RaiLoaderDocument

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Image(systemName: "doc.text")
                .resizable()
                .frame(width: 50, height: 50)
                .padding()
            
            Text(document.metadata["title"] ?? document.id)
                .font(.headline)
                .foregroundStyle(.primary)
            
            if let summary = document.metadata["description"] {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack {
                Spacer()
                Text(document.metadata["date_created"] ?? "Unknown Date")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding()
        .padding(.leading)
        .padding(.trailing)
    }
}

struct RaiLoaderDocumentRow: View {
    let documentItem: RaiLoaderDocument
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon representing the document
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.accentColor)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                // Primary title using the formatted string
                Text("documentItem?.formatted")
                    .font(.headline)
                    .lineLimit(1)
                
                // Secondary text for document identifier or description
                Text(documentItem.document)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Optionally display a single metadata key-value pair if available
                if let firstMeta = documentItem.metadata.first {
                    Text("\(firstMeta.key): \(firstMeta.value)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Display the distance on the right, formatted to one decimal place
            Text(String(format: "%.1f km", "documentItem.distance"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8).fill(.ultraThickMaterial)
        }
        .frame(minWidth: 200, maxWidth: 250)
    }
}



struct RaiLoaderDocumentPopupView: View {
    let documentItem: RaiLoaderDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Top bar with dismiss button
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Document Title
            Text(documentItem.metadata["title"] ?? "Unknown Title")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
            
            // Scrollable content for the document details
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Document content
                    Text("Document")
                        .font(.headline)
//                    Text(documentItem.document)
//                        .font(.body)
//                        .multilineTextAlignment(.leading)
                    
                    InputTextMultiLine("Document Body", text: .constant(documentItem.document), isEdit: .constant(false))
                    
                    // Metadata display if available
                    if !documentItem.metadata.isEmpty {
                        Text("Metadata")
                            .font(.headline)
                            .padding(.top)
                        ForEach(documentItem.metadata.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack {
                                CoreInputText(label: key, text: .constant(value), isEdit: .constant(false))
//                                Text("\(key):")
//                                    .fontWeight(.semibold)
//                                Text(value)
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    // Distance info
                    Text(String(format: "Distance: %.1f km", "documentItem.distance"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(minWidth: 1000, idealWidth: 1000, maxWidth: 1000, minHeight: 500, idealHeight: 500, maxHeight: 500)
        .padding(.vertical)
        .padding()
    }
}

struct RaiLoaderDocumentPopupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RaiLoaderDocumentPopupView(documentItem: RaiLoaderDocument(
                id: "1",
                distance: 3.7,
                document: "This is an example content of a RaiLoaderDocument, providing detailed information in a clean and readable format. It’s designed to handle longer text gracefully.",
                metadata: ["Author": "Jane Doe", "Version": "1.0"],
                formatted: "Detailed Document View"
            ))
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            RaiLoaderDocumentPopupView(documentItem: RaiLoaderDocument(
                id: "2",
                distance: 3.7,
                document: "This is an example content of a RaiLoaderDocument, providing detailed information in a clean and readable format. It’s designed to handle longer text gracefully.",
                metadata: ["Author": "Jane Doe", "Version": "1.0"],
                formatted: "Detailed Document View"
            ))
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}

//#Preview {
//    TripleColumnChatView(
//        messages: MessageSD.sample,
//        conversationState: .loading,
//        userInitials: "AM",
//        editMessage: .constant(MessageSD.sample[0])
//    )
//}


//#Preview {
//    QueryResultListView(
//        messages: MessageSD.sample,
//        conversationState: .loading,
//        userInitials: "AM",
//        editMessage: .constant(MessageSD.sample[0])
//    )
//}

