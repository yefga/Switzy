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
        let rawVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentVersion = (rawVersion != nil && !rawVersion!.isEmpty) ? rawVersion! : ""
        
        let rawBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let currentBuild = (rawBuild != nil && !rawBuild!.isEmpty) ? rawBuild! : ""
        
        let comparator = SUStandardVersionComparator.default
        let buildComparison = comparator.compareVersion(item.versionString, toVersion: currentBuild)
        
        if buildComparison == .orderedDescending {
            isUpdateAvailable = true
        } else if buildComparison == .orderedSame {
            let itemVersion = item.displayVersionString
            let versionComparison = comparator.compareVersion(itemVersion, toVersion: currentVersion)
            isUpdateAvailable = (versionComparison == .orderedDescending)
        } else {
            isUpdateAvailable = false
        }
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        isUpdateAvailable = false
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        isUpdateAvailable = false
    }
}

extension UpdaterService: @MainActor SPUStandardUserDriverDelegate {
    var supportsGentleScheduledUpdateReminders: Bool {
        true
    }
}
#endif
