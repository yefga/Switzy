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
    
    func selectTab(appModel: AppModel, tab: Constants.ManagementTab) {
        let tabs = Constants.ManagementTab.allCases
        let currentIndex = tabs.firstIndex(of: appModel.selectedManagementTab) ?? 0
        let targetIndex = tabs.firstIndex(of: tab) ?? 0
        
        transitionDirection = targetIndex > currentIndex ? .trailing : .leading
        
        // We defer the actual animation to the view layer when the state changes.
        // The AppModel state is updated here.
        appModel.selectedManagementTab = tab
    }
}
