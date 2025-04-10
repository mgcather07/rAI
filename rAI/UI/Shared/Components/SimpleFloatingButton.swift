//
//  SimpleFloatingButton.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI


/// Submit button on chat
struct SimpleFloatingButton: View {
    var systemImage: String
    var onClick: () -> ()
    
    var body: some View {
        Button(action: onClick) {
            Image(systemName: systemImage)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
          //      .foregroundColor(Color.primary)
                .frame(height: 18)
        }
        .buttonStyle(GrowingButton())
        .contentShape(Rectangle())
    }
}
