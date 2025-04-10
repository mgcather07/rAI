//
//  ConversationState.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation

enum ConversationState: Equatable {
    case loading
    case completed
    case error(message: String)
}

