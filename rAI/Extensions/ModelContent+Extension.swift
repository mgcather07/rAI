//
//  ModelContent+Extension.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import SwiftData

extension ModelContext {
    func saveChanges() throws {
        if self.hasChanges {
            try self.save()
        }
    }
}

