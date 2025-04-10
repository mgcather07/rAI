//
//  ChatView_macOS.swift
//  rAI
//
//  Created by Michael Cather on 4/3/25.
//


#if os(macOS) || os(visionOS)
import Foundation
import SwiftUI

struct ChatView: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    var selectedConversation: ConversationSD?
    var conversations: [ConversationSD]
    var messages: [MessageSD]
    var modelsList: [LanguageModelSD]
    var onMenuTap: () -> ()
    var onNewConversationTap: () -> ()
    var onSendMessageTap: @MainActor (_ prompt: String, _ model: LanguageModelSD, _ image: Image?, _ trimmingMessageId: String?) -> ()
    var onConversationTap: (_ conversation: ConversationSD) -> ()
    var conversationState: ConversationState
    var onStopGenerateTap: @MainActor () -> ()
    var reachable: Bool
    var modelSupportsImages: Bool
    var selectedModel: LanguageModelSD?
    var onSelectModel: @MainActor (_ model: LanguageModelSD?) -> ()
    var onConversationDelete: (_ conversation: ConversationSD) -> ()
    var onDeleteDailyConversations: (_ date: Date) -> ()
    var userInitials: String
    var copyChat: (_ json: Bool) -> ()
    
    @State private var message = ""
    @State private var editMessage: MessageSD?
    @State var isRecording = false
    @FocusState private var isFocusedInput: Bool
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(
                selectedConversation: selectedConversation,
                conversations: conversations,
                onConversationTap: onConversationTap,
                onConversationDelete: onConversationDelete,
                onDeleteDailyConversations: onDeleteDailyConversations
            )
            .toolbar {
#if os(visionOS)
                ToolbarItemGroup(placement:.navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeIn(duration: 0.3)) {
                            columnVisibility = .detailOnly
                        }
                    }) {
                        Image(systemName: "sidebar.left")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .showIf(columnVisibility != .detailOnly)
                }
                
#endif
            }
        } detail: {
            VStack(alignment: .center) {
                
                InputFieldsView(
                    message: $message,
                    conversationState: conversationState,
                    onStopGenerateTap: onStopGenerateTap,
                    selectedModel: selectedModel,
                    onSendMessageTap: onSendMessageTap,
                    editMessage: $editMessage
                )
                .padding()
                .frame(maxWidth: 800)
                
                if selectedConversation != nil {
                    TripleColumnChatView(
                        messages: messages,
                        conversationState: conversationState,
                        userInitials: userInitials,
                        editMessage: $editMessage
                    )
                } else {
                    EmptyConversaitonView(sendPrompt: {selectedMessage in
                        if let selectedModel = selectedModel {
                            onSendMessageTap(selectedMessage, selectedModel, nil, nil)
                        }
                    })
                }
                
                if !reachable {
                    UnreachableAPIView()
                }
                
                
            }
            .toolbar {
                #if os(visionOS)
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {
                        withAnimation {
                            columnVisibility = .automatic
                        }
                    }) {
                        Image(systemName: "sidebar.left")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .showIf(columnVisibility == .detailOnly)
                    
                    Text("rAI")
                }
                #else
                ToolbarItem(placement: .navigation) {
                    Text("rAI")
                }
                #endif

                
                ToolbarItemGroup(placement: .automatic) {
                    ToolbarView(
                        modelsList: modelsList,
                        selectedModel: selectedModel,
                        onSelectModel: onSelectModel,
                        onNewConversationTap: onNewConversationTap,
                        copyChat: copyChat
                    )
                }
            }
        }
        .navigationTitle("")
        .onChange(of: editMessage, initial: false) { _, newMessage in
            if let newMessage = newMessage {
                message = newMessage.content
                isFocusedInput = true
            }
        }
    }
}

#Preview {
    ChatView(
        selectedConversation: ConversationSD.sample[0],
        conversations: ConversationSD.sample,
        messages: MessageSD.sample,
        modelsList: LanguageModelSD.sample,
        onMenuTap: {},
        onNewConversationTap: { },
        onSendMessageTap: {_,_,_,_    in},
        onConversationTap: {_ in},
        conversationState: .completed,
        onStopGenerateTap: {},
        reachable: true,
        modelSupportsImages: true,
        selectedModel: LanguageModelSD.sample[0], onSelectModel: {_ in},
        onConversationDelete: {_ in},
        onDeleteDailyConversations: {_ in},
        userInitials: "AM",
        copyChat: {_ in}
    )
}
#endif
