//
//  ContentView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appModel: AppModel
    
    @State private var hoveredProfileID: UUID?
    @State private var hoveredActionID: String?

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider().opacity(0.2)
            profileListView
            Divider().opacity(0.2)
            actionButtons
            Divider().opacity(0.2)
            quitButton
        }
        .frame(width: Constants.Layout.popoverWidth)
        .background(
            VisualEffectView(
                material: .popover,
                blendingMode: .behindWindow,
                state: .active
            )
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
        let isHovered = hoveredProfileID == profile.id

        Button {
            switchTask = Task {
                await appModel.switchProfile(to: profile)
            }
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
                    ? Color.white.opacity(0.12)
                    : (isHovered ? Color.white.opacity(0.05) : Color.clear)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Constants.Layout.cornerRadiusSmall,
                    style: .continuous
                )
            )
            .contentShape(Rectangle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredProfileID = hovering ? profile.id : nil
                }
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
        let isHovered = hoveredActionID == id
        
        Button(action: action) {
            HStack(spacing: Constants.Spacing.xl) {
                Image(systemName: icon)
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: Constants.FontSize.body))

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.xxxl)
            .padding(.vertical, Constants.Spacing.lg)
            .background(isHovered ? Color.white.opacity(0.05) : Color.clear)
            .contentShape(Rectangle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredActionID = hovering ? id : nil
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quit

    @ViewBuilder
    private var quitButton: some View {
        let isHovered = hoveredActionID == "quit"
        
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            HStack(spacing: Constants.Spacing.xl) {
                Image(systemName: Constants.SystemImage.quit)
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Text(Constants.Strings.quitSwitzy)
                    .font(.system(size: Constants.FontSize.body))

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.xxxl)
            .padding(.vertical, Constants.Spacing.lg)
            .padding(.bottom, 8)
            .background(isHovered ? Color.white.opacity(0.05) : Color.clear)
            .contentShape(Rectangle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredActionID = hovering ? "quit" : nil
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Task Management

    @State private var switchTask: Task<Void, Never>?
}
