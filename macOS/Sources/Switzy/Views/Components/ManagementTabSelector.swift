//
//  ManagementTabSelector.swift
//  Switzy
//
//  Created by Yefga on 02/08/2026.
//

import SwiftUI

struct ManagementTabSelector: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject var viewModel: ManagementViewModel
    @ObservedObject var sshKeysViewModel: SSHKeysViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            selectionIndicator

            HStack(spacing: 0) {
                ForEach(Constants.ManagementTab.allCases) { tab in
                    tabButton(tab)
                }
            }
        }
        .frame(width: 300, height: Constants.Layout.tabPillHeight)
        .panelBackground(cornerRadius: Constants.Layout.cornerRadiusCapsule)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private var selectionIndicator: some View {
        GeometryReader { geometry in
            let tabs = Constants.ManagementTab.allCases
            let pillWidth = geometry.size.width / CGFloat(tabs.count)
            let selectedIndex = tabs.firstIndex(of: appModel.selectedManagementTab) ?? 0

            RoundedRectangle(
                cornerRadius: Constants.Layout.cornerRadiusCapsule,
                style: .continuous
            )
            .fill(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: Constants.Layout.cornerRadiusCapsule,
                    style: .continuous
                )
                .strokeBorder(
                    Color.white.opacity(Constants.Opacity.divider),
                    lineWidth: Constants.Layout.borderWidth
                )
            )
            .padding(2)
            .frame(width: pillWidth)
            .offset(x: CGFloat(selectedIndex) * pillWidth)
        }
    }

    private func tabButton(_ tab: Constants.ManagementTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectTab(appModel: appModel, tab: tab)
            }
        } label: {
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: icon(for: tab))
                    .font(.system(size: Constants.FontSize.caption))

                Text(title(for: tab))
                    .font(.system(
                        size: Constants.FontSize.caption,
                        weight: appModel.selectedManagementTab == tab
                            ? .semibold
                            : .regular
                    ))
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Layout.tabPillHeight)
        }
        .buttonStyle(.plain)
        .foregroundStyle(
            appModel.selectedManagementTab == tab ? .white : .secondary
        )
    }

    private func icon(for tab: Constants.ManagementTab) -> String {
        switch tab {
        case .profile: return Constants.SystemImage.profileManage
        case .ssh: return Constants.SystemImage.sshManage
        case .settings: return Constants.SystemImage.settingsTab
        }
    }

    private func title(for tab: Constants.ManagementTab) -> String {
        switch tab {
        case .profile:
            return Constants.Strings.itemCount(
                title: tab.title,
                count: appModel.availableProfiles.count
            )
        case .ssh:
            return Constants.Strings.itemCount(
                title: tab.title,
                count: sshKeysViewModel.keys.count
            )
        case .settings:
            return tab.title
        }
    }
}
