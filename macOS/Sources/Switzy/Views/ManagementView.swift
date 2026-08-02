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
        contentArea
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(
            minWidth: Constants.Layout.managementWidth,
            minHeight: Constants.Layout.managementHeight
        )
        .toolbar {
            if #available(macOS 26.0, *) {
                ToolbarItem(placement: .principal) {
                    managementTabSelector
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .principal) {
                    managementTabSelector
                }
            }

            ToolbarItem(placement: .primaryAction) {
                if appModel.selectedManagementTab != .settings {
                    managementActionButton
                }
            }
        }
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
        .onChange(of: sshKeysViewModel.keys) { keys in
            appModel.updateSSHKeyCount(keys.count)
        }
    }
    
    // MARK: - Toolbar
    
    @ViewBuilder
    private var managementActionButton: some View {
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
        .help(actionButtonHelp)
    }

    private var actionButtonHelp: String {
        if appModel.selectedManagementTab == .profile {
            return viewModel.showProfileForm && viewModel.isCreatingNewProfile
                ? Constants.Strings.cancel
                : Constants.Strings.addProfile
        }

        return viewModel.showNewSSHKeyForm
            ? Constants.Strings.cancel
            : Constants.Strings.generateKey
    }

    private var managementTabSelector: some View {
        ManagementTabSelector(
            viewModel: viewModel,
            sshKeysViewModel: sshKeysViewModel
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
            case .settings:
                EmptyView()
            }
            
        }
    }

    // MARK: - Profile Sidebar

    @ViewBuilder
    private var profileSidebar: some View {
        SidebarListView(
            title: Constants.Label.profiles,
            subtitle: Constants.Strings.profileCount(appModel.availableProfiles.count),
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
                if appModel.selectedManagementTab == .ssh {
                    SSHFormView()
                        .environmentObject(viewModel)
                        .environmentObject(sshKeysViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: viewModel.transitionDirection == .trailing ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: viewModel.transitionDirection == .trailing ? .trailing : .leading).combined(with: .opacity)
                        ))
                } else {
                    ManagementSettingsView()
                        .transition(.opacity)
                }
            }
        }
        .clipped()
    }

}
