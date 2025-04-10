//
//  Alignments.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI
// Alightments
public struct AlignLeft<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            content()
            Spacer()
        }
    }
}

public struct AlignRight<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            content()
        }
    }
}

public struct AlignCenter<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            content()
            Spacer()
        }
    }
}

