//
//  OptionsMenuView.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

struct MoreOptionsMenuView: View {
    var copyChat: (_ json: Bool) -> ()
    var body: some View {
        Menu {
            Button(action: {copyChat(false)}) {
                Text("Copy Chat")
            }
            Button(action: {copyChat(true)}) {
                Text("Copy Chat as JSON")
            }
        } label: {
            Image(systemName: "ellipsis")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }
}

#Preview {
    MoreOptionsMenuView(copyChat: {_ in})
}

