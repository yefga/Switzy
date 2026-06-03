//
//  SwitzyApp.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

@main
struct SwitzyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
