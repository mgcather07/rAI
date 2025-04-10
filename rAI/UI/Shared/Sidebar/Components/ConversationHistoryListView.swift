//
//  ConversationHistoryListView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

struct ConversationGroup: Hashable {
    let date: Date
    var conversations: [ConversationSD]
    
    // Implementing the Hashable protocol
    static func == (lhs: ConversationGroup, rhs: ConversationGroup) -> Bool {
        lhs.date == rhs.date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}

struct ConversationHistoryList: View {
    var selectedConversation: ConversationSD?
    var conversations: [ConversationSD]
    var onTap: (_ conversation: ConversationSD) -> ()
    var onDelete: (_ conversation: ConversationSD) -> ()
    var onDeleteDailyConversations: (_ date: Date) -> ()
    
    // Grouping function and computed property remain unchanged.
    func groupConversationsByDay(conversations: [ConversationSD]) -> [ConversationGroup] {
        let groupedDictionary = Dictionary(grouping: conversations) {
            Calendar.current.startOfDay(for: $0.updatedAt)
        }
        
        return groupedDictionary.map { (key, value) in
            ConversationGroup(date: key, conversations: value)
        }
        .sorted(by: { $0.date > $1.date })
    }
    
    var conversationGroups: [ConversationGroup] {
        groupConversationsByDay(conversations: conversations)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            ForEach(conversationGroups, id: \.self) { conversationGroup in
                HStack {
                    Text(conversationGroup.date.daysAgoString())
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                    
                    Spacer()
                }
                .contextMenu {
                    Button(role: .destructive, action: {
                        onDeleteDailyConversations(conversationGroup.date)
                    }) {
                        Label("Delete daily conversations", systemImage: "trash")
                    }
                }
                
                ForEach(conversationGroup.conversations, id: \.self) { dailyConversation in
                    ConversationRow(conversation: dailyConversation,
                                    isSelected: selectedConversation == dailyConversation,
                                    onTap: onTap,
                                    onDelete: onDelete)
                }
                
                Divider()
            }
        }
    }
}


struct ConversationRow: View {
    let conversation: ConversationSD
    let isSelected: Bool
    var onTap: (ConversationSD) -> ()
    var onDelete: (ConversationSD) -> ()
    
    var body: some View {
        Button(action: { onTap(conversation) }) {
            HStack {
                if isSelected {
                    // Only show the circle if it's selected.
                    Circle()
                        .frame(width: 6, height: 6)
                        .animation(.easeOut(duration: 0.15), value: isSelected)
                        .transition(.opacity)
                }
                
                Text(conversation.name)
                    .lineLimit(1)
                    .font(.system(size: 16))
                //    .foregroundColor(Color(.label))
                    .animation(.easeOut(duration: 0.15), value: isSelected)
                    .transition(.opacity)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                onDelete(conversation)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
