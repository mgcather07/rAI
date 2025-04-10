//
//  DeallocPrinter.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation

class DeallocPrinter {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    deinit {
        print("deallocated \(message)")
    }
}

