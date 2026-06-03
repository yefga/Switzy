//
//  ProfileFormView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct ProfileFormView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var managementViewModel: ManagementViewModel
    @StateObject private var viewModel = ProfileFormViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxxxl) {
                    if managementViewModel.showProfileForm {
                        profileForm
                    }
                    existingProfilesList
                }
                .padding(Constants.Spacing.xxxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: appModel.selectedProfileID) { _ in
            if managementViewModel.showProfileForm && !managementViewModel.isCreatingNewProfile {
                viewModel.loadProfile(currentProfile: appModel.selectedProfile)
            }
        }
        .onAppear {
            if appModel.availableProfiles.isEmpty {
                managementViewModel.showProfileForm = true
                managementViewModel.isCreatingNewProfile = true
            }
            viewModel.loadProfile(currentProfile: appModel.selectedProfile)
            viewModel.scanSSHKeys()
        }
        .onExitCommand {
            if managementViewModel.showProfileForm {
                withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                    managementViewModel.showProfileForm = false
                    managementViewModel.isCreatingNewProfile = false
                }
            }
        }
        // Sync local view model state with global management state
        .onChange(of: managementViewModel.isCreatingNewProfile) { isCreating in
            viewModel.isCreatingNewProfile = isCreating
            if isCreating {
                viewModel.resetForm()
            }
        }
        .onChange(of: managementViewModel.showProfileForm) { show in
            viewModel.showForm = show
        }
        // And vice-versa for when save is clicked
        .onChange(of: viewModel.showForm) { show in
            managementViewModel.showProfileForm = show
        }
        .onChange(of: viewModel.isCreatingNewProfile) { isCreating in
            managementViewModel.isCreatingNewProfile = isCreating
        }
    }

    // MARK: - Form

    @ViewBuilder
    private var profileForm: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxxl) {
            identitySection
            sshKeySection
            saveButton
        }
        .padding(Constants.Spacing.xxxl)
        .glassBackground(
            cornerRadius: Constants.Layout.cornerRadius,
            material: .hudWindow,
            opacity: 0.5
        )
    }

    @ViewBuilder
    private var identitySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxxl) {
            Text(Constants.Strings.identity)
                .font(.system(
                    size: Constants.FontSize.caption,
                    weight: .semibold
                ))
                .foregroundStyle(.secondary)

            formField(
                label: Constants.Placeholder.profileName,
                text: $viewModel.profileName
            )

            formField(
                label: Constants.Placeholder.gitUserName,
                text: $viewModel.gitUserName
            )

            formField(
                label: Constants.Placeholder.gitEmail,
                text: $viewModel.gitEmail
            )
        }
    }

    @ViewBuilder
    private var sshKeySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxl) {
            Text(Constants.Label.sshKey)
                .font(.system(
                    size: Constants.FontSize.caption,
                    weight: .semibold
                ))
                .foregroundStyle(.secondary)

            HStack {
                if viewModel.availableKeys.isEmpty {
                    Text(Constants.Strings.selectYourKey)
                        .font(.system(size: Constants.FontSize.body))
                        .foregroundStyle(.tertiary)
                } else {
                    Picker("", selection: $viewModel.selectedSSHKey) {
                        Text(Constants.Strings.selectYourKey).tag("")
                        ForEach(viewModel.availableKeys, id: \.self) { key in
                            Text((key as NSString).lastPathComponent).tag(key)
                        }
                    }
                    .labelsHidden()
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    private func formField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(label)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.tertiary)

            TextField("", text: text)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: Constants.FontSize.body))
        }
    }

    @ViewBuilder
    private var saveButton: some View {
        Button {
            viewModel.saveProfile(appModel: appModel, currentProfile: appModel.selectedProfile)
        } label: {
            Text(viewModel.isCreatingNewProfile ? "Create Profile" : Constants.Strings.saveChanges)
                .font(.system(
                    size: Constants.FontSize.body,
                    weight: .semibold
                ))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.lg)
        }
        .disabled(!viewModel.isFormValid)
        .buttonStyle(.borderedProminent)
    }

    // MARK: - List

    @ViewBuilder
    private var existingProfilesList: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxl) {
            ForEach(appModel.availableProfiles) { profile in
                if !viewModel.showForm || (viewModel.showForm && !viewModel.isCreatingNewProfile && appModel.selectedProfileID == profile.id) {
                    ProfileRowView(
                        viewModel: viewModel,
                        profile: profile,
                        isSelected: appModel.selectedProfileID == profile.id
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}
