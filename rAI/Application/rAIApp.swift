//
//  rAIApp.swift
//  rAI
//
//  Created by Michael Cather on 4/3/25.
//

import SwiftUI
import SwiftData

#if os(macOS)
import KeyboardShortcuts
extension KeyboardShortcuts.Name {
    static let togglePanelMode = Self("togglePanelMode1", default: .init(.k, modifiers: [.command, .option]))
}
#endif

@main
struct rAIApp: App {
    @State private var appStore = AppStore.shared
    @State private var isLoggedIn = false
    
    #if os(macOS)
        @NSApplicationDelegateAdaptor(PanelManager.self) var panelManager
    #endif
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    HomeDashboard_iOS()
                } else {
                    LoginView {
                        // Login action
                        withAnimation {
                            isLoggedIn = true
                        }
                    }
                }
            }
        #if os(macOS)
            .onKeyboardShortcut(KeyboardShortcuts.Name.togglePanelMode, type: .keyDown) {
                print("heya")
                panelManager.togglePanel()
            }
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
            }
        #endif
        }
#if os(macOS)
        .commands {
            Menus()
        }
#endif
#if os(macOS)
        Window("Keyboard Shortcuts", id: "keyboard-shortcuts") {
            KeyboardShortcutsDemo()
        }
#endif
    }
}

