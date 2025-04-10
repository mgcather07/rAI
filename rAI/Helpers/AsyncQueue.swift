//
//  AsyncQueue.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation

actor AsyncQueue<T> {
    private var items: [T] = []

    func enqueue(_ item: T) {
        items.append(item)
    }

    func dequeueAll() -> [T] {
        defer { items.removeAll() }
        return items
    }
}

