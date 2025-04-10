//
//  AgentSelectionView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

struct AgentSelectorView: View {
    var agentsList: [AgentModelSD]
    var selectedAgent: AgentModelSD?
    var onSelectAgent: @MainActor (_ model: AgentModelSD?) -> ()
    var showChevron = true
    
    var body: some View {
        Menu {
            ForEach(agentsList, id: \.self) { agent in
                Button(action: {
                    withAnimation(.easeOut) {
                        onSelectAgent(agent)
                    }
                }) {
                    Text(agent.name)
                        .font(.body)
                        .tag(agent.name)
                }
            }
        } label: {
            HStack(alignment: .center) {
                if let selectedModel = selectedAgent {
                    HStack(alignment: .bottom, spacing: 5) {
                        
                        #if os(macOS) || os(visionOS)
                        Text(selectedModel.name)
                            .font(.body)
                        #elseif os(iOS)
                        Text(selectedModel.prettyName )
                            .font(.body)
                            .foregroundColor(Color.labelCustom)
                        
                        Text(selectedModel.prettyVersion)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        #endif
                    }
                }
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
            //        .foregroundColor(Color(.label))
                    .showIf(showChevron)
            }
        }
    }
}

#Preview {
    AgentSelectorView(
        agentsList: AgentModelSD.sample,
        selectedAgent: AgentModelSD.sample[0],
        onSelectAgent: {_ in},
        showChevron: false
    )
}

