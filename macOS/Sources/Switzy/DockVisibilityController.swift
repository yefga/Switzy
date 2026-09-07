//
//  DockVisibilityController.swift
//  Switzy
//
//  Created by Yefga on 07/09/26.
//

import Cocoa

/// Flips the app between `.accessory` (menu bar only, the `LSUIElement` default)
/// and `.regular` (Dock icon plus app menu) for as long as a tracked window is
/// open. The status bar item lives on `NSStatusBar` and is unaffected by the
/// activation policy, so it stays put through every transition.
@MainActor
final class DockVisibilityController: NSObject {

    static let shared = DockVisibilityController()

    private let openWindows = NSHashTable<NSWindow>.weakObjects()

    private override init() {
        super.init()
    }

    /// Reveal the Dock icon and keep it visible until `window` — and every other
    /// tracked window — has closed.
    func track(_ window: NSWindow) {
        window.delegate = self
        openWindows.add(window)
        apply(.regular)
    }
}

// MARK: - NSWindowDelegate

extension DockVisibilityController: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        openWindows.remove(window)

        // `windowWillClose` fires before the window is torn down, so the policy
        // change waits a turn to avoid dropping the Dock icon mid-close.
        DispatchQueue.main.async { [weak self] in
            self?.hideDockIconIfIdle()
        }
    }
}

// MARK: - Private Helpers

private extension DockVisibilityController {

    func hideDockIconIfIdle() {
        guard openWindows.allObjects.isEmpty else { return }
        apply(.accessory)
    }

    func apply(_ policy: NSApplication.ActivationPolicy) {
        guard NSApp.activationPolicy() != policy else { return }

        NSApp.setActivationPolicy(policy)

        // A freshly promoted `.regular` app is not frontmost yet; without this
        // the window opens behind whatever the user was working in.
        if policy == .regular {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
