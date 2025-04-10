//
//  SettingsView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var ollamaUri: String
    @Binding var systemPrompt: String
    @Binding var vibrations: Bool
    @Binding var colorScheme: AppColorScheme
    @Binding var defaultOllamModel: String
    @Binding var ollamaBearerToken: String
    @Binding var appUserInitials: String
    @Binding var pingInterval: String
    @Binding var voiceIdentifier: String
    @State var ollamaStatus: Bool?
    var save: () -> ()
    var checkServer: () -> ()
    var deleteAll: () -> ()
    var ollamaLangugeModels: [LanguageModelSD]
    var voices: [AVSpeechSynthesisVoice]
    
    @State private var deleteConversationsDialog = false
    
    var body: some View {
        VStack {
            // Top bar
            ZStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16))
                    }
                    
                    Spacer()
                    
                    Button(action: save) {
                        Text("Save")
                            .font(.system(size: 16))
                    }
                }
                
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    Spacer()
                }
            }
            .padding()
            
            // Main form
            Form {
                // rAI Section
                Section {
                    TextField("rAI Server", text: $ollamaUri, onCommit: checkServer)
                        .textContentType(.URL)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
#if !os(macOS)
                        .padding(.top, 8)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
#endif
                    
                    VStack(alignment: .leading) {
                        Text("System prompt")
                        TextEditor(text: $systemPrompt)
                            .font(.system(size: 13))
                            .cornerRadius(4)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 100)
                    }
                    
                    Picker(selection: $voiceIdentifier) {
                        ForEach(voices, id: \.self.identifier) { voice in
                            Text(voice.prettyName).tag(voice.identifier)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Voice", systemImage: "waveform")
                                .foregroundStyle(Color.primary)
                            
                    #if os(macOS)
                            Text("Download voices by going to Settings > Accessibility > Spoken Content > System Voice > Manage Voices.")
                    #else
                            Text("Download voices by going to Settings > Accessibility > Spoken Content > Voices.")
                    #endif
                            
                            Button(action: {
                    #if os(macOS)
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.universalaccess?SpeakableItems") {
                                    NSWorkspace.shared.open(url)
                                }
                    #else
                                if let url = URL(string: "App-Prefs:root=General&path=ACCESSIBILITY"),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                    #endif
                            }) {
                                Text("Open Settings")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    
                    TextField("Initials", text: $appUserInitials)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
#if os(iOS)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
#endif
                    
                    Button(action: { deleteConversationsDialog.toggle() }) {
                        HStack {
                            Spacer()
                            Text("Clear All Data")
                                .foregroundStyle(Color(.systemRed))
                                .padding(.vertical, 6)
                            Spacer()
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .preferredColorScheme(colorScheme.toiOSFormat)
        .confirmationDialog("Delete All Conversations?", isPresented: $deleteConversationsDialog) {
            Button("Delete", role: .destructive) { deleteAll() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Delete All Conversations?")
        }
    }
}

#Preview {
    SettingsView(
        ollamaUri: .constant(""),
        systemPrompt: .constant("You are an intelligent assistant solving complex problems. You are an intelligent assistant solving complex problems. You are an intelligent assistant solving complex problems."),
        vibrations: .constant(true),
        colorScheme: .constant(.light),
        defaultOllamModel: .constant("llama2"),
        ollamaBearerToken: .constant("x"),
        appUserInitials: .constant("AM"),
        pingInterval: .constant("5"),
        voiceIdentifier: .constant("sample"),
        save: {},
        checkServer: {},
        deleteAll: {},
        ollamaLangugeModels: LanguageModelSD.sample,
        voices: []
    )
}

