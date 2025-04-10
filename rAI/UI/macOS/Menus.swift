//
//  Menus.swift
//  rAI
//
//  Created by Michael Cather on 4/3/25.
//

import Foundation
import SwiftUI

#if os(macOS)
struct ShowSettingsKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var showSettings: Binding<Bool>? {
        get { self[ShowSettingsKey.self] }
        set { self[ShowSettingsKey.self] = newValue }
    }
}

struct Menus: Commands {
   @FocusedValue(\.showSettings) var showSettings

   var body: some Commands {
       CommandGroup(replacing: .appSettings) {
           Button("Settings") {
               showSettings?.wrappedValue = true
           }
           .keyboardShortcut(",", modifiers: .command)
       }
  }
}
#endif
