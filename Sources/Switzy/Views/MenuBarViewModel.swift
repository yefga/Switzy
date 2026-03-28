//
//  MenuBarViewModel.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published var hoveredProfileID: UUID?
    @Published var hoveredActionID: String?
    
    private var switchTask: Task<Void, Never>?
    
    func switchProfile(appModel: AppModel, to profile: GitProfile) {
        switchTask = Task {
            await appModel.switchProfile(to: profile)
        }
    }
    
    func setHoveredProfile(id: UUID?, isHovering: Bool) {
        withAnimation(.easeInOut(duration: 0.1)) {
            hoveredProfileID = isHovering ? id : nil
        }
    }
    
    func setHoveredAction(id: String?, isHovering: Bool) {
        withAnimation(.easeInOut(duration: 0.1)) {
            hoveredActionID = isHovering ? id : nil
        }
    }
    
    func quit() {
        NSApplication.shared.terminate(nil)
    }
}
