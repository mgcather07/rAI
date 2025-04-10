//
//  AVSpeechSynthesisVoice+Extension.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesisVoice {
    var prettyName: String {
        let name = self.name
        if name.lowercased().contains("default") || name.lowercased().contains("premium") || name.lowercased().contains("enhanced") {
            return name
        }
        
        let qualityString = {
            switch self.quality.rawValue {
            case 1: return "Default"
            case 2: return "Enhanced"
            case 3: return "Premium"
            default: return "Unknown"
            }
        }()
        
        return "\(name) (\(qualityString))"
    }
}
