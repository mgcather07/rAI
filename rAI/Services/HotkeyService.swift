
//  HotkeyService.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.


#if os(macOS)
import Foundation
import SwiftUI
import Carbon // For RegisterEventHotKey, etc.

// MARK: - Global HotKey Event Handler

/// Global event handler that Carbon calls when a registered hotkey is pressed.
private func hotKeyEventHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        UInt32(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),  // Now passing the correct UInt32.
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )
    if status == noErr {
        HotKeyManager.shared.handleHotKey(with: hotKeyID.id)
    }
    return noErr
}

// MARK: - HotKey Wrapper

/// A wrapper around a Carbon-registered hot key.
final class HotKey {
    var hotKeyRef: EventHotKeyRef?
    let id: UInt32
    let keyCode: UInt32
    let modifiers: UInt32
    let handler: () -> Void

    init(id: UInt32, keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        self.id = id
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.handler = handler
    }
    
    /// Registers the hot key using Carbon.
    func register() {
        var eventHotKeyID = EventHotKeyID(
            signature: OSType("HTK1".fourCharCode), // A 4-char signature identifier
            id: id
        )
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            eventHotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        if status != noErr {
            print("Error registering hot key: \(status)")
        }
    }
    
    /// Unregisters the hot key.
    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
        hotKeyRef = nil
    }
}

// Helper to convert a 4-character string into a FourCharCode.
extension String {
    var fourCharCode: FourCharCode {
        var result: FourCharCode = 0
        for char in self.utf8 {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}

// MARK: - HotKey Manager

/// A singleton manager that keeps track of hot keys and dispatches events.
final class HotKeyManager {
    static let shared = HotKeyManager()
    
    private var hotKeys: [UInt32: HotKey] = [:]
    private var nextId: UInt32 = 1
    
    private init() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetEventDispatcherTarget(),
            hotKeyEventHandler,
            1,
            &eventType,
            nil,
            nil
        )
    }
    
    /// Registers a hot key and returns its instance.
    func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) -> HotKey {
        let id = nextId
        nextId += 1
        let hotKey = HotKey(id: id, keyCode: keyCode, modifiers: modifiers, handler: handler)
        hotKeys[id] = hotKey
        hotKey.register()
        return hotKey
    }
    
    /// Unregisters a given hot key.
    func unregister(hotKey: HotKey) {
        hotKey.unregister()
        hotKeys.removeValue(forKey: hotKey.id)
    }
    
    /// Called by the global event handler when a hot key is pressed.
    /// It invokes the hot key’s callback and then unregisters it for single-use behavior.
    func handleHotKey(with id: UInt32) {
        if let hotKey = hotKeys[id] {
            hotKey.handler()
            unregister(hotKey: hotKey)
        }
    }
}

// MARK: - HotkeyService Implementation

/// A service to register single-use global hot keys.
final class HotkeyService {
    static let shared = HotkeyService()
    
    /// Registers a single-use Space key hot key.
    func registerSingleUseSpace(modifiers: NSEvent.ModifierFlags, completion: @escaping () -> Void) {
        let carbonModifiers = self.carbonModifierFlags(from: modifiers)
        let spaceKeyCode: UInt32 = 49 // Space key code in macOS
        _ = HotKeyManager.shared.register(keyCode: spaceKeyCode, modifiers: carbonModifiers, handler: completion)
    }
    
    /// Registers a single-use Escape key hot key.
    func registerSingleUseEscape(modifiers: NSEvent.ModifierFlags, completion: @escaping () -> Void) {
        let carbonModifiers = self.carbonModifierFlags(from: modifiers)
        let escapeKeyCode: UInt32 = 53 // Escape key code in macOS
        _ = HotKeyManager.shared.register(keyCode: escapeKeyCode, modifiers: carbonModifiers, handler: completion)
    }
    
    /// Converts NSEvent modifier flags to Carbon modifier flags.
    private func carbonModifierFlags(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbonFlags: UInt32 = 0
        // The Carbon modifier constants are defined as:
        //   cmdKey    = 256, shiftKey = 512, optionKey = 2048, controlKey = 4096.
        if flags.contains(.control) { carbonFlags |= 4096 }
        if flags.contains(.option)  { carbonFlags |= 2048 }
        if flags.contains(.shift)   { carbonFlags |= 512 }
        if flags.contains(.command) { carbonFlags |= 256 }
        return carbonFlags
    }
}

#endif
