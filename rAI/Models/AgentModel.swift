//
//  AgentModel.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation

struct AgentModel: Decodable {
    var name: String
    var type: String
    var details: String
    var imageSupport: Bool
    var provider: AgentProvider? = .raiko
}

enum AgentProvider: Codable {
    case raiko
}

