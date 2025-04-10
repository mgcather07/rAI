//
//  CompletionsEditor.swift
//  rAI
//
//  Created by Michael Cather on 4/3/25.
//


#if os(macOS)
import Foundation
import SwiftUI

struct CompletionsEditor: View {
    @State private var completionsStore = CompletionsStore.shared
    @State private var accessibilityStatus = true
    @State private var timer: Timer?
    
    private func requestAccessibility() {
        Task {
            print("Requesting accessibility")
            await Accessibility.shared.showAccessibilityInstructionsWindow()
            Accessibility.shared.simulateCopyKeyPress()
        }
    }
    
    var body: some View {
        CompletionsEditorView(
            completions: $completionsStore.completions,
            onSave: completionsStore.save,
            onDelete: completionsStore.delete,
            accessibilityAccess: accessibilityStatus,
            requestAccessibilityAccess: requestAccessibility
        )
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                withAnimation {
                    accessibilityStatus = Accessibility.shared.checkAccessibility()
                    print("accessibility", accessibilityStatus)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}
#endif
