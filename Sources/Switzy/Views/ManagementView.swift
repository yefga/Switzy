//
//  ManagementView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct ManagementView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var transitionDirection: Edge = .trailing

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                sidebar
                Divider()
                contentArea
            }
            .background(
                VisualEffectView(
                    material: .underWindowBackground,
                    blendingMode: .behindWindow,
                    state: .active
                )
            )
        }
        .frame(
            minWidth: Constants.Layout.managementWidth,
            minHeight: Constants.Layout.managementHeight
        )
    }


    // MARK: - Sidebar

    @ViewBuilder
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            tabToggle
                .padding(Constants.Spacing.xxl)

            sidebarContent
        }
        .frame(width: Constants.Layout.sidebarWidth)
        .background(Color.white.opacity(0.05))
    }

    @ViewBuilder
    private var tabToggle: some View {
        ZStack(alignment: .leading) {
            // Sliding Background Pill
            GeometryReader { geo in
                let tabs = Constants.ManagementTab.allCases
                let pillWidth = geo.size.width / CGFloat(tabs.count)
                let selectedIndex = tabs.firstIndex(of: appModel.selectedManagementTab) ?? 0
                
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadiusCapsule, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadiusCapsule, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .padding(2)
                    .frame(width: pillWidth)
                    .offset(x: CGFloat(selectedIndex) * pillWidth)
            }
            
            HStack(spacing: 0) {
                ForEach(Constants.ManagementTab.allCases) { tab in
                    tabPill(for: tab)
                }
            }
        }
        .frame(height: Constants.Layout.tabPillHeight)
        .glassBackground(
            cornerRadius: Constants.Layout.cornerRadiusCapsule,
            material: .hudWindow,
            opacity: 0.25
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    @ViewBuilder
    private func tabPill(for tab: Constants.ManagementTab) -> some View {
        Button {
            let tabs = Constants.ManagementTab.allCases
            let currentIndex = tabs.firstIndex(of: appModel.selectedManagementTab) ?? 0
            let targetIndex = tabs.firstIndex(of: tab) ?? 0
            
            transitionDirection = targetIndex > currentIndex ? .trailing : .leading
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                appModel.selectedManagementTab = tab
            }
        } label: {
            Text(tab.rawValue)
                .font(.system(
                    size: Constants.FontSize.caption,
                    weight: appModel.selectedManagementTab == tab ? .semibold : .regular
                ))
                .frame(maxWidth: .infinity)
                .frame(height: Constants.Layout.tabPillHeight)
        }
        .buttonStyle(.plain)
        .foregroundStyle(
            appModel.selectedManagementTab == tab ? .white : .secondary
        )
    }

    @ViewBuilder
    private var sidebarContent: some View {
        ZStack {
            if appModel.selectedManagementTab == .profile {
                profileSidebar
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                sshSidebar
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
    }

    // MARK: - Profile Sidebar

    @ViewBuilder
    private var profileSidebar: some View {
        SidebarListView(
            title: Constants.Label.profiles,
            subtitle: "\(appModel.availableProfiles.count) profiles",
            items: appModel.availableProfiles
        ) { profile in
            sidebarProfileRow(profile: profile)
        }
    }

    @ViewBuilder
    private func sidebarProfileRow(profile: GitProfile) -> some View {
        let isSelected = appModel.selectedProfileID == profile.id
            || (appModel.selectedProfileID == nil
                && profile.id == appModel.availableProfiles.first?.id)

        Button {
            appModel.selectedProfileID = profile.id
        } label: {
            HStack(spacing: Constants.Spacing.lg) {
                Circle()
                    .fill(profile.isActive ? Color.blue : Color.gray.opacity(0.4))
                    .frame(
                        width: Constants.Layout.activeIndicatorSize,
                        height: Constants.Layout.activeIndicatorSize
                    )

                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text(profile.name)
                        .font(.system(
                            size: Constants.FontSize.caption,
                            weight: .medium
                        ))
                        .lineLimit(1)

                    Text(profile.userEmail)
                        .font(.system(size: Constants.FontSize.caption2))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.lg)
            .padding(.vertical, Constants.Spacing.md)
            .background(
                isSelected
                    ? Color.white.opacity(0.1)
                    : Color.clear
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Constants.Layout.cornerRadiusCapsule,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - SSH Sidebar

    @ViewBuilder
    private var sshSidebar: some View {
        SSHSidebarView()
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        ZStack {
            if appModel.selectedManagementTab == .profile {
                ProfileFormView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                SSHFormView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .clipped()
    }
}
