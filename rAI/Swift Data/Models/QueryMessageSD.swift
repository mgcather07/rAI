//
//  QueryMessageSD.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftData

@Model
final class QueryMessageSD: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var content: String
    var role: String
    var done: Bool = false
    var error: Bool = false
    var createdAt: Date = Date.now
    
    var query: String = ""
    var query_expanded: String = ""
    var documents: [RaiLoaderDocument] = []
    var sub_documents: [RaiLoaderDocument] = []
    var formatted: String = ""
    var response: String = ""
    @Attribute(.externalStorage) var image: Data?
    
    @Relationship var conversation: ConversationSD?
        
    
    init(content: String, role: String, done: Bool = false, error: Bool = false, image: Data? = nil) {
        self.content = content
        self.role = role
        self.done = done
        self.error = error
        self.conversation = conversation
        self.image = image
    }

    @Transient var model: String {
        conversation?.model?.name ?? ""
    }
}

extension QueryMessageSD {
    static let sample: [QueryMessageSD] = [
        .init(content: "How many quarks there are in SM?", role: "user"),
        .init(content: "There are 6 quarks in SM, each of them has an antiparticle and colour.", role: "assistant"),
        .init(content: "How elementary particle is defined in mathematics?", role: "user"),
        .init(content: "Elementary particle is defined as an irreducible representation of the poincase group.", role: "assistant")
    ]
}

// MARK: - @unchecked Sendable
extension QueryMessageSD: @unchecked Sendable {
    /// We hide compiler warnings for concurency. We have to make sure to modify the data only via SwiftDataManager to ensure concurrent operations.
}

