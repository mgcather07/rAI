//
//  AgentModelSD.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftData

@Model
final class AgentModelSD: Identifiable {
    @Attribute(.unique) var name: String
    var type: String = ""
    var isAvailable: Bool = false
    var imageSupport: Bool = false
    @Attribute var agentProvider: AgentProvider? = AgentProvider.raiko
    
    @Relationship(deleteRule: .cascade, inverse: \ConversationSD.model)
    var conversations: [ConversationSD]? = []
    
    
    init(name: String, type: String="", imageSupport: Bool = false, agentProvider: AgentProvider) {
        self.name = name
        self.type = type
        self.imageSupport = imageSupport
        self.agentProvider = agentProvider
    }
    
    @Transient var isNotAvailable: Bool {
        isAvailable == false
    }
}

// MARK: - Helpers
extension AgentModelSD {
    var prettyName: String {
        return name.capitalized
    }
    
    var prettyVersion: String {
        let components = name.components(separatedBy: ":")
        if components.count >= 2 {
            return components[1]
        }
        return ""
    }
    
    var supportsImages: Bool {
        if imageSupport {
            return true
        }
        

        return false
    }
    
    static let sample: [AgentModelSD] = [
        .init(name: "RAG", type: "base", agentProvider: .raiko),
        .init(name: "Query", type: "base", agentProvider: .raiko)
    ]
}


// MARK: - @unchecked Sendable
extension AgentModelSD: @unchecked Sendable {
    /// We hide compiler warnings for concurency. We have to make sure to modify the data only via SwiftDataManager to ensure concurrent operations.
}
