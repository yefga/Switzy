//
//  AppDelegate.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import Cocoa
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    let appModel = AppModel()

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        if let button = statusItem?.button {
            if let image = NSImage(named: "img_status_bar") {
                image.isTemplate = true
                button.image = image
            } else {
                button.image = NSImage(
                    systemSymbolName: Constants.SystemImage.info,
                    accessibilityDescription: Constants.Strings.appName
                )
                button.image?.size = NSSize(
                    width: Constants.Layout.statusBarIconSize,
                    height: Constants.Layout.statusBarIconSize
                )
            }
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    // MARK: - Popover

    private func setupPopover() {
        let contentView = MenuBarView()
            .environmentObject(appModel)

        let popover = NSPopover()
        popover.contentSize = NSSize(
            width: Constants.Layout.popoverWidth,
            height: 400
        )
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: contentView)

        self.popover = popover
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(
                relativeTo: button.bounds,
                of: button,
                preferredEdge: .minY
            )
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
