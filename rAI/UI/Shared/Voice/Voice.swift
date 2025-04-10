//
//  Voice.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

struct Voice: View {
    @State var languageModelStore: LanguageModelStore
    @State var conversationStore: ConversationStore
    @State var appStore: AppStore
    
    var body: some View {
        VoiceView()
    }
}
