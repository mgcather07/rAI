//
//  LanguageModel.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation

struct LanguageModel {
    var name: String
    var provider: ModelProvider
    var imageSupport: Bool
}

enum ModelProvider: Codable {
    case ollama
}

