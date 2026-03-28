//
//  UpdaterService.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import Foundation
import SwiftUI

#if canImport(Sparkle)
import Sparkle
#endif

@MainActor
final class UpdaterService: NSObject, ObservableObject {
    
    @Published var isUpdateAvailable: Bool = false
    
    #if canImport(Sparkle)
    private var updater: SPUUpdater?
    #endif

    override init() {
        super.init()
    }
    
    #if canImport(Sparkle)
    func setup(with updater: SPUUpdater) {
        self.updater = updater
    }
    #endif
}

#if canImport(Sparkle)
extension UpdaterService: SPUUpdaterDelegate {
    
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        isUpdateAvailable = true
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        isUpdateAvailable = false
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        isUpdateAvailable = false
    }
}
#endif
