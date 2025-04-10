//
//  Helpers.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

#if os(iOS) || os(visionOS)
typealias PlatformImage = UIImage
#else
typealias PlatformImage = NSImage
#endif

//Image(nsImage: nsImage)

