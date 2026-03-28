//
//  ManagementViewModel.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

@MainActor
final class ManagementViewModel: ObservableObject {
    @Published var transitionDirection: Edge = .trailing
    
    func selectTab(appModel: AppModel, tab: Constants.ManagementTab) {
        let tabs = Constants.ManagementTab.allCases
        let currentIndex = tabs.firstIndex(of: appModel.selectedManagementTab) ?? 0
        let targetIndex = tabs.firstIndex(of: tab) ?? 0
        
        transitionDirection = targetIndex > currentIndex ? .trailing : .leading
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            appModel.selectedManagementTab = tab
        }
    }
}
