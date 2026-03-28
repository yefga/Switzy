//
//  AboutWindowController.swift
//  
//
//  Created by Yefga on 27/03/26.
//

import Cocoa
import SwiftUI

@MainActor
final class AboutWindowController {
    
    static let shared = AboutWindowController()
    
    private var window: NSWindow?
    
    private init() {}
    
    func showAbout(appModel: AppModel) {
        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let aboutView = AboutView()
            .environmentObject(appModel)
        
        let hostingController = NSHostingController(rootView: aboutView)
        
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        newWindow.contentViewController = hostingController
        newWindow.title = "About Switzy"
        newWindow.titleVisibility = .visible
        newWindow.titlebarAppearsTransparent = true
        newWindow.isMovableByWindowBackground = true
        newWindow.isReleasedWhenClosed = false
        
        // Remove minimize/maximize buttons
        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
        
        self.window = newWindow
        DispatchQueue.main.async {
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
