//
//  CompletionButtonView.swift
//  rAI
//
//  Created by Michael Cather on 4/3/25.
//

import Foundation
import SwiftUI

struct CompletionButtonView: View {
    var name: String
    var keyboardCharacter: Character
    var action: () -> ()
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(keyboardCharacter.lowercased())
                    .textCase(.uppercase)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .font(.system(size: 10, weight: .medium, design: .default))
                
                Text(name)
                    .font(.system(size: 12))
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundStyle(.primary)
            .background(RoundedRectangle(cornerRadius: 5).fill(.primary)
        )}
        .buttonStyle(GrowingButton())
    }
}

#Preview {
    CompletionButtonView(name: "Fix Grammar", keyboardCharacter: "f", action: {})
}
