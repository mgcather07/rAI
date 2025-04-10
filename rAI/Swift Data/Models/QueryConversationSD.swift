//
//  QueryConversationSD.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftData

@Model
final class QueryConversationSD: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var name: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify)
    var model: LanguageModelSD?

    @Relationship(deleteRule: .cascade, inverse: \QueryMessageSD.conversation)
    var messages: [QueryMessageSD] = []
    
    init(name: String, updatedAt: Date = Date.now) {
        self.name = name
        self.updatedAt = updatedAt
        self.createdAt = updatedAt
    }
}

// MARK: - Sample data
extension QueryConversationSD {
    static let sample = [
        QueryConversationSD(name: "New Chat", updatedAt: Date.now),
        QueryConversationSD(name: "Presidential", updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!),
        QueryConversationSD(name: "What is QFT?", updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!)
    ]
}

// MARK: - @unchecked Sendable
extension QueryConversationSD: @unchecked Sendable {
    /// We hide compiler warnings for concurency. We have to make sure to modify the data only via SwiftDataManager to ensure concurrent operations.
}

