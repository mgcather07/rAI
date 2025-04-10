//
//  AgentSamples.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation

struct AgentSamples: Identifiable, Hashable {
    enum AgentSamplesType {
        case tool
        case flow
        case agent
        
        var icon: String {
            switch self {
            case .tool:
                return "hammer.circle"
            case .flow:
                return "wave.circle"
            case .agent:
                return "robot.circle"
            }
        }
    }
    
    var agent: String
    var type: AgentSamplesType
    
    var id: String {
        agent
    }
}

// MARK: - Sample Data
extension AgentSamples {
    static let samples: [AgentSamples] = [
        .init(agent: "Referral Intake", type: .flow),
        .init(agent: "nORA", type: .flow),
        .init(agent: "Text Analysis", type: .flow),
        .init(agent: "Text Summary", type: .flow),
        .init(agent: "Text Extraction", type: .tool),
        .init(agent: "RAG", type: .tool),
        .init(agent: "Query", type: .flow),
    ]
    
    static var shuffled: [AgentSamples] {
        return samples.shuffled()
    }
}

