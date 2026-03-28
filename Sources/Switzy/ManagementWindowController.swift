//
//  ManagementWindowController.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import Cocoa
import SwiftUI

@MainActor
final class ManagementWindowController {

    static let shared = ManagementWindowController()

    private var window: NSWindow?

    private init() {}

    private func centerWindowOnScreen(_ window: NSWindow) {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            window.center()
            return
        }
        
        let visibleFrame = screen.visibleFrame
        let windowFrame = window.frame
        
        let x = visibleFrame.origin.x + (visibleFrame.width - windowFrame.width) / 2
        let y = visibleFrame.origin.y + (visibleFrame.height - windowFrame.height) / 2
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }

    func showWindow(appModel: AppModel) {
        if let existingWindow = window {
            DispatchQueue.main.async { [weak self] in
                self?.centerWindowOnScreen(existingWindow)
                existingWindow.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let managementView = ManagementView()
            .environmentObject(appModel)

        let hostingController = NSHostingController(rootView: managementView)

        let newWindow = NSWindow(
            contentRect: NSRect(
                x: .zero, y: .zero,
                width: Constants.Layout.managementWidth,
                height: Constants.Layout.managementHeight
            ),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        newWindow.contentViewController = hostingController
        newWindow.title = Constants.Strings.appName
        newWindow.minSize = NSSize(
            width: Constants.Layout.managementWidth,
            height: Constants.Layout.managementHeight
        )
        newWindow.isReleasedWhenClosed = false
        newWindow.titlebarAppearsTransparent = false
        newWindow.titleVisibility = .visible
        newWindow.isOpaque = false
        newWindow.backgroundColor = .black.withAlphaComponent(0.8)

        self.window = newWindow
        centerWindowOnScreen(newWindow)
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
