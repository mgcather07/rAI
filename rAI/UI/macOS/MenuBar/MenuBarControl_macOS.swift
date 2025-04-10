//
//  MenuBarControl_macOS.swift
//  rAI
//
//  Created by Michael Cather on 4/3/25.
//

#if os(macOS)
import SwiftUI

struct MenuBarControl: View {
    @State private var appStore = AppStore.shared
    var body: some View {
        MenuBarControlView(notifications: appStore.notifications)
    }
}
#endif
