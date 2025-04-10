//
//  ConversationStore.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftData
import OllamaKit
import Combine
import SwiftUI

@Observable
final class ConversationStore: Sendable {
    static let shared = ConversationStore(swiftDataService: SwiftDataService.shared)
    
    private var swiftDataService: SwiftDataService
    private var generation: AnyCancellable?
    
    /// For some reason (SwiftUI bug / too frequent UI updates) updating UI for each stream message sometimes freezes the UI.
    /// Throttling UI updates seem to fix the issue.
    private var currentMessageBuffer: String = ""
#if os(macOS)
    private let throttler = Throttler(delay: 0.1)
#else
    private let throttler = Throttler(delay: 0.1)
#endif
    
    @MainActor var conversationState: ConversationState = .completed
    @MainActor var conversations: [ConversationSD] = []
    @MainActor var selectedConversation: ConversationSD?
    @MainActor var messages: [MessageSD] = []
    
    init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
    }
    
    func loadConversations() async throws {
        print("loading conversations")
        let fetchedConversations = try await swiftDataService.fetchConversations()
        DispatchQueue.main.async {
            self.conversations = fetchedConversations
        }
        print("loaded conversations")
    }
    
    func deleteAllConversations() {
        Task {
            DispatchQueue.main.async { [weak self] in
                self?.messages = []
                self?.selectedConversation = nil
            }
            try? await swiftDataService.deleteConversations()
            try? await swiftDataService.deleteMessages()
            try? await loadConversations()
        }
    }
    
    func deleteDailyConversations(_ date: Date) {
        Task {
            DispatchQueue.main.async { [self] in
                selectedConversation = nil
                messages = []
            }
            try? await swiftDataService.deleteConversations()
            try? await loadConversations()
        }
    }
    
    
    func create(_ conversation: ConversationSD) async throws {
        try await swiftDataService.createConversation(conversation)
    }
    
    func reloadConversation(_ conversation: ConversationSD) async throws {
        let (messages, selectedConversation) = try await (
            swiftDataService.fetchMessages(conversation.id),
            swiftDataService.getConversation(conversation.id)
        )
        
        DispatchQueue.main.async {
                self.messages = messages
                self.selectedConversation = selectedConversation
        }
    }
    
    func selectConversation(_ conversation: ConversationSD) async throws {
        try await reloadConversation(conversation)
    }
    
    func delete(_ conversation: ConversationSD) async throws {
        try await swiftDataService.deleteConversation(conversation)
        let fetchedConversations = try await swiftDataService.fetchConversations()
        DispatchQueue.main.async {
            self.selectedConversation = nil
            self.conversations = fetchedConversations
        }
    }
    
    @MainActor func stopGenerate() {
        generation?.cancel()
        handleComplete()
        withAnimation {
            conversationState = .completed
        }
    }

    
    @MainActor
    func sendPrompt(userPrompt: String, model: LanguageModelSD, image: Image? = nil, systemPrompt: String = "", trimmingMessageId: String? = nil) {
        // Ensure the prompt is not empty.
        guard userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else { return }
        
        // Select an existing conversation or create a new one.
        let conversation = selectedConversation ?? ConversationSD(name: userPrompt)
        conversation.updatedAt = Date.now
        conversation.model = model
        
        print("model", model.name)
        print("conversation", conversation.name)
        
        // If in edit mode, trim conversation messages.
        if let trimmingMessageId = trimmingMessageId {
            conversation.messages = conversation.messages
                .sorted { $0.createdAt < $1.createdAt }
                .prefix(while: { $0.id.uuidString != trimmingMessageId })
                .map { $0 }
        }
        
        // Add a system prompt as the first message if needed.
        if !systemPrompt.isEmpty && conversation.messages.isEmpty {
            let systemMessage = MessageSD(content: systemPrompt, role: "system")
            systemMessage.conversation = conversation
            conversation.messages.append(systemMessage)
        }
        
        // Construct the user's message.
        let userMessage = MessageSD(content: userPrompt, role: "user", image: image?.render()?.compressImageData())
        userMessage.conversation = conversation
        
        // Create a placeholder for the assistant's response.
        let assistantMessage = MessageSD(content: "", role: "assistant")
        assistantMessage.conversation = conversation
        
        conversationState = .loading
        
        Task {
            do {
                // Persist the conversation and messages.
                try await swiftDataService.updateConversation(conversation)
                try await swiftDataService.createMessage(userMessage)
                try await swiftDataService.createMessage(assistantMessage)
                try await reloadConversation(conversation)
                try? await loadConversations()
                // Send the prompt using the new ChatService API.
//                let apiResponse = try await rAIService.shared.query(queryText: userPrompt, modelName: model.name)
                let apiResponse = try await rAIService.shared.queryKnowledge(queryText: userPrompt, modelName: model.name)
                
                // Update your assistant message (or entire conversation state) based on apiResponse.
                self.handleReceiveKnowledge(apiResponse)
                self.handleCompleteKnowledge()

            } catch {
                self.handleErrorKnowledge(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    private func handleReceiveKnowledge(_ response: KnowledgeResponse) {
        // Ensure we have at least one message to update.
        guard !messages.isEmpty else { return }
        
        // Update the last (assistant) message with the complete response.
        // Using 'answer' for the main text and 'data' for the documents.
        messages[messages.count - 1].content = response.answer
        messages[messages.count - 1].response = response.answer
        messages[messages.count - 1].documents = response.data
        // If you need to clear out any previous formatted text or query, you can do so:
        messages[messages.count - 1].formatted = "nil"
        messages[messages.count - 1].query = "nil"
    }

    @MainActor
    private func handleErrorKnowledge(_ errorMessage: String) {
        // Update the last message to mark it as errored.
        guard let lastMessage = messages.last else { return }
        lastMessage.error = true
        lastMessage.done = false
        
        // Persist the updated error state.
        Task(priority: .background) {
            try? await swiftDataService.updateMessage(lastMessage)
        }
        
        // Update UI state.
        withAnimation {
            conversationState = .error(message: errorMessage)
        }
    }

    @MainActor
    private func handleCompleteKnowledge() {
        // Update the last message to mark it as successfully completed.
        guard let lastMessage = messages.last else { return }
        lastMessage.error = false
        lastMessage.done = true
        
        // Persist the updated message state.
        Task(priority: .background) {
            try await swiftDataService.updateMessage(lastMessage)
        }
        
        // Update UI state.
        withAnimation {
            conversationState = .completed
        }
    }


    @MainActor
    private func handleReceiveRai(_ response: RaiQueryAgentResults) {
        // Ensure we have at least one message to update.
        guard !messages.isEmpty else { return }
        
        // Update the last (assistant) message with the complete response.
        messages[messages.count - 1].content = response.response
        messages[messages.count - 1].response = response.response
        messages[messages.count - 1].documents = response.documents
        messages[messages.count - 1].formatted = response.formatted
        messages[messages.count - 1].query = response.query
        
    }

    @MainActor
    private func handleErrorRai(_ errorMessage: String) {
        // Update the last message to mark it as errored.
        guard let lastMessage = messages.last else { return }
        lastMessage.error = true
        lastMessage.done = false
        
        // Persist the updated error state.
        Task(priority: .background) {
            try? await swiftDataService.updateMessage(lastMessage)
        }
        
        // Update UI state.
        withAnimation {
            conversationState = .error(message: errorMessage)
        }
    }

    @MainActor
    private func handleCompleteRai() {
        // Update the last message to mark it as successfully completed.
        guard let lastMessage = messages.last else { return }
        lastMessage.error = false
        lastMessage.done = true
        
        // Persist the updated message state.
        Task(priority: .background) {
            try await self.swiftDataService.updateMessage(lastMessage)
        }
        
        // Update UI state.
        withAnimation {
            conversationState = .completed
        }
    }

    
    @MainActor
    private func handleReceive(_ response: OKChatResponse)  {
        if messages.isEmpty { return }
        
        if let responseContent = response.message?.content {
            currentMessageBuffer = currentMessageBuffer + responseContent
            
            throttler.throttle { [weak self] in
                guard let self = self else { return }
                let lastIndex = self.messages.count - 1
                self.messages[lastIndex].content.append(currentMessageBuffer)
                currentMessageBuffer = ""
            }
        }
    }
    
    @MainActor
    private func handleError(_ errorMessage: String) {
        guard let lastMesasge = messages.last else { return }
        lastMesasge.error = true
        lastMesasge.done = false
        
        Task(priority: .background) {
            try? await swiftDataService.updateMessage(lastMesasge)
        }
        
        withAnimation {
            conversationState = .error(message: errorMessage)
        }
    }
    
    @MainActor
    private func handleComplete() {
        guard let lastMesasge = messages.last else { return }
        lastMesasge.error = false
        lastMesasge.done = true
        
        Task(priority: .background) {
            try await self.swiftDataService.updateMessage(lastMesasge)
        }
        
        withAnimation {
            conversationState = .completed
        }
    }
}

