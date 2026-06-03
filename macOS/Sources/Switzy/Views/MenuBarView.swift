//
//  MenuBarView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var updater: UpdaterService
    @StateObject private var viewModel = MenuBarViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if updater.isUpdateAvailable {
                updateBanner
                Divider().opacity(Constants.Opacity.divider)
            }
            headerView
            Divider().opacity(Constants.Opacity.divider)
            profileListView
            Divider().opacity(Constants.Opacity.divider)
            actionButtons
            Divider().opacity(Constants.Opacity.divider)
            quitButton
        }
        .frame(width: Constants.Layout.popoverWidth)
        .background(
            VisualEffectView(
                material: .popover,
                blendingMode: .behindWindow,
                state: .active
            )
            .opacity(Constants.Opacity.backgroundBlur)
        )
        .onAppear {
            appModel.loadOnLaunch()
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerView: some View {
        HStack {
            Text(Constants.Strings.appName)
                .font(.system(
                    size: Constants.FontSize.headline,
                    weight: .semibold
                ))

            Spacer()

            Button {
                AboutWindowController.shared.showAbout(appModel: appModel)
            } label: {
                Image(systemName: Constants.SystemImage.info)
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Spacing.xxxl)
        .padding(.vertical, Constants.Spacing.xxl)
    }
    
    // MARK: - Update Banner
    
    @ViewBuilder
    private var updateBanner: some View {
        Button {
            if let delegate = NSApp.delegate as? AppDelegate {
                delegate.checkForUpdates(nil)
            }
        } label: {
            HStack(spacing: Constants.Spacing.xl) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: Constants.SystemImage.sparkle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(Constants.Strings.updateAvailable)
                        .font(.system(size: Constants.FontSize.callout, weight: .semibold))
                    Text(Constants.Strings.updateNow)
                        .font(.system(size: Constants.FontSize.caption))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, Constants.Spacing.xxxl)
            .padding(.vertical, Constants.Spacing.xl)
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.08),
                        Color.blue.opacity(0.02)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Profile List

    @ViewBuilder
    private var profileListView: some View {
        VStack(spacing: Constants.Spacing.md) {
            if appModel.availableProfiles.isEmpty {
                emptyProfileState
            } else {
                ForEach(appModel.availableProfiles) { profile in
                    popoverProfileRow(profile: profile)
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.xxl)
        .padding(.vertical, Constants.Spacing.xl)
    }

    @ViewBuilder
    private var emptyProfileState: some View {
        HStack(spacing: Constants.Spacing.xl) {
            Image(systemName: Constants.SystemImage.profileAdd)
                .font(.title3)
                .foregroundStyle(.tertiary)

            Text(Constants.Strings.noProfilesHint)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, Constants.Spacing.xl)
    }

    @ViewBuilder
    private func popoverProfileRow(profile: GitProfile) -> some View {
        let isActive = profile.id == appModel.activeProfileID
        let isHovered = viewModel.hoveredProfileID == profile.id

        Button {
            viewModel.switchProfile(appModel: appModel, to: profile)
        } label: {
            HStack(spacing: Constants.Spacing.xl) {
                Image(systemName: isActive
                    ? Constants.SystemImage.checkmark
                    : Constants.SystemImage.profile
                )
                .font(.system(size: Constants.FontSize.body))
                .foregroundStyle(isActive ? .green : .gray)

                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text(profile.name)
                        .font(.system(
                            size: Constants.FontSize.body,
                            weight: .medium
                        ))

                    Text("\(profile.userName) · \(profile.userEmail)")
                        .font(.system(size: Constants.FontSize.caption))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.xxl)
            .padding(.vertical, Constants.Spacing.lg)
            .background(
                isActive
                    ? Color.white.opacity(Constants.Opacity.active)
                    : (isHovered ? Color.white.opacity(Constants.Opacity.hover) : Color.clear)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Constants.Layout.cornerRadiusSmall,
                    style: .continuous
                )
            )
            .contentShape(Rectangle())
            .onHover { hovering in
                viewModel.setHoveredProfile(id: profile.id, isHovering: hovering)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 0) {

            actionRow(
                id: "ssh",
                icon: Constants.SystemImage.sshManage,
                title: Constants.Strings.manageSSH
            ) {
                appModel.openManagementWindow(tab: .ssh)
            }

            actionRow(
                id: "profile",
                icon: Constants.SystemImage.profileManage,
                title: Constants.Strings.manageProfile
            ) {
                appModel.openManagementWindow(tab: .profile)
            }
        }
    }

    @ViewBuilder
    private func actionRow(
        id: String,
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        let isHovered = viewModel.hoveredActionID == id
        
        Button(action: action) {
            HStack(spacing: Constants.Spacing.xl) {
                Image(systemName: icon)
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundStyle(.secondary)
                    .frame(width: Constants.Layout.iconSize)

                Text(title)
                    .font(.system(size: Constants.FontSize.body))

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.xxxl)
            .padding(.vertical, Constants.Spacing.lg)
            .background(isHovered ? Color.white.opacity(Constants.Opacity.hover) : Color.clear)
            .contentShape(Rectangle())
            .onHover { hovering in
                viewModel.setHoveredAction(id: id, isHovering: hovering)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quit

    @ViewBuilder
    private var quitButton: some View {
        let isHovered = viewModel.hoveredActionID == "quit"
        
        Button {
            viewModel.quit()
        } label: {
            HStack(spacing: Constants.Spacing.xl) {
                Image(systemName: Constants.SystemImage.quit)
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundStyle(.secondary)
                    .frame(width: Constants.Layout.iconSize)

                Text(Constants.Strings.quitSwitzy)
                    .font(.system(size: Constants.FontSize.body))

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.xxxl)
            .padding(.vertical, Constants.Spacing.lg)
            .padding(.bottom, Constants.Spacing.lg)
            .background(isHovered ? Color.white.opacity(Constants.Opacity.hover) : Color.clear)
            .contentShape(Rectangle())
            .onHover { hovering in
                viewModel.setHoveredAction(id: "quit", isHovering: hovering)
            }
        }
        .buttonStyle(.plain)
    }
}
