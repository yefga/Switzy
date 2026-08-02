//
//  ManagementViewModel.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import Foundation
import Combine

enum TransitionDirection {
    case leading
    case trailing
}

@MainActor
final class ManagementViewModel: ObservableObject {
    @Published var transitionDirection: TransitionDirection = .trailing
    
    // Shared state for the "+" button across tabs
    @Published var showProfileForm: Bool = false
    @Published var isCreatingNewProfile: Bool = false
    @Published var showNewSSHKeyForm: Bool = false
    
    func selectTab(appModel: AppModel, tab: Constants.ManagementTab) {
        let tabs = Constants.ManagementTab.allCases
        let currentIndex = tabs.firstIndex(of: appModel.selectedManagementTab) ?? 0
        let targetIndex = tabs.firstIndex(of: tab) ?? 0
        
        transitionDirection = targetIndex > currentIndex ? .trailing : .leading
        
        appModel.selectedManagementTab = tab
    }
}
