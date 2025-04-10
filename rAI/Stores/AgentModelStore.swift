//
//  AgentModelStore.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftData

@Observable
final class AgentModelStore {
    static let shared = AgentModelStore(swiftDataService: SwiftDataService.shared)
    
    private var swiftDataService: SwiftDataService
    @MainActor var agents: [AgentModelSD] = []
    @MainActor var supportsImages = false
    @MainActor var selectedAgent: AgentModelSD?
    
    init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
    }
    
    @MainActor
    func setAgent(agent: AgentModelSD?) {
        if let agent = agent {
            // check if model still exists
            if agents.contains(agent) {
                selectedAgent = agent
            }
        } else {
            selectedAgent = nil
        }
    }
    
    @MainActor
    func setAgent(agentName: String) {
        for agent in agents {
            if agent.name == agentName {
                setAgent(agent: agent)
                return
            }
        }
        if let lastAgent = agents.last {
            setAgent(agent: lastAgent)
        }
    }
    
    func loadAgents() async throws {
        let remoteAgents = try await rAIService.shared.getAgents()
        try await swiftDataService.saveAgents(agents: remoteAgents.map{AgentModelSD(name: $0.name, type: $0.type, imageSupport: $0.imageSupport, agentProvider: .raiko)})
        
        let storedAgents = (try? await swiftDataService.fetchAgents()) ?? []
        
        DispatchQueue.main.async {
            let remoteAgentNames = remoteAgents.map { $0.name }
            self.agents = storedAgents.filter{remoteAgentNames.contains($0.name)}
        }
    }
    
    func deleteAllAgents() async throws {
        DispatchQueue.main.async {
            self.agents = []
        }
        try await swiftDataService.deleteAgents()
    }
}

