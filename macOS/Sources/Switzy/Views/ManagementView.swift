//
//  ManagementView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct ManagementView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var viewModel = ManagementViewModel()
    @StateObject private var sshKeysViewModel = SSHKeysViewModel()

    var body: some View {
        VStack(spacing: 0) {
            contentHeader
            Divider().opacity(Constants.Opacity.divider)
            contentArea   
        }
        .background(
            VisualEffectView(
                material: .underWindowBackground,
                blendingMode: .behindWindow,
                state: .active
            )
        )
        .frame(
            minWidth: Constants.Layout.managementWidth,
            minHeight: Constants.Layout.managementHeight
        )
        .overlay(alignment: .bottom) {
            if let message = sshKeysViewModel.statusMessage {
                Text(message)
                    .font(.system(size: Constants.FontSize.body, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Constants.Spacing.xxl)
                    .padding(.vertical, Constants.Spacing.md)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .padding(.bottom, Constants.Spacing.xxxxl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: sshKeysViewModel.statusMessage)
        .onAppear {
            sshKeysViewModel.loadKeys()
        }
    }
    
    // MARK: - Content Header
    
    @ViewBuilder
    private var contentHeader: some View {
        HStack {
            tabToggle
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                    if appModel.selectedManagementTab == .profile {
                        if !viewModel.showProfileForm {
                            viewModel.showProfileForm = true
                            viewModel.isCreatingNewProfile = true
                        } else if viewModel.isCreatingNewProfile {
                            viewModel.showProfileForm = false
                            viewModel.isCreatingNewProfile = false
                        } else {
                            viewModel.isCreatingNewProfile = true
                        }
                    } else {
                        viewModel.showNewSSHKeyForm.toggle()
                    }
                }
            } label: {
                let isMinus = appModel.selectedManagementTab == .profile 
                    ? (viewModel.showProfileForm && viewModel.isCreatingNewProfile)
                    : viewModel.showNewSSHKeyForm
                
                Image(systemName: isMinus ? Constants.SystemImage.minus : Constants.SystemImage.plus)
                    .font(.system(size: Constants.FontSize.body))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Spacing.xxxxl)
        .padding(.vertical, Constants.Spacing.xxl)
    }

    @ViewBuilder
    private var tabToggle: some View {
        ZStack(alignment: .leading) {
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
                            .strokeBorder(Color.white.opacity(Constants.Opacity.divider), lineWidth: 0.5)
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
        .frame(width: 200, height: Constants.Layout.tabPillHeight)
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectTab(appModel: appModel, tab: tab)
            }
        } label: {
            let count = tab == .profile ? appModel.availableProfiles.count : sshKeysViewModel.keys.count
            let icon = tab == .profile ? Constants.SystemImage.profileManage : Constants.SystemImage.sshManage
            
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: Constants.FontSize.caption))
                Text("\(tab.rawValue) (\(count))")
                    .font(.system(
                        size: Constants.FontSize.caption,
                        weight: appModel.selectedManagementTab == tab ? .semibold : .regular
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

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            sidebarContent
        }
        .frame(width: Constants.Layout.sidebarWidth)
        .background(Color.white.opacity(Constants.Opacity.hover))
    }

    @ViewBuilder
    private var sidebarContent: some View {
        ZStack {
            switch appModel.selectedManagementTab {
            case .profile:
                profileSidebar
                    .transition(.asymmetric(
                        insertion: .move(edge: viewModel.transitionDirection == .trailing ? .leading : .trailing).combined(with: .opacity),
                        removal: .move(edge: viewModel.transitionDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                    ))
            case .ssh:
                sshSidebar
                    .transition(.asymmetric(
                        insertion: .move(edge: viewModel.transitionDirection == .trailing ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: viewModel.transitionDirection == .trailing ? .trailing : .leading).combined(with: .opacity)
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
                    ? Color.white.opacity(Constants.Opacity.active)
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
            .environmentObject(sshKeysViewModel)
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        ZStack {
            if appModel.selectedManagementTab == .profile {
                ProfileFormView()
                    .environmentObject(viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: viewModel.transitionDirection == .trailing ? .leading : .trailing).combined(with: .opacity),
                        removal: .move(edge: viewModel.transitionDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                    ))
            } else {
                SSHFormView()
                    .environmentObject(viewModel)
                    .environmentObject(sshKeysViewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: viewModel.transitionDirection == .trailing ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: viewModel.transitionDirection == .trailing ? .trailing : .leading).combined(with: .opacity)
                    ))
            }
        }
        .clipped()
    }
}
