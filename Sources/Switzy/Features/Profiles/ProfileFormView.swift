//
//  ProfileFormView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct ProfileFormView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var viewModel = ProfileFormViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            formHeader
            Divider().opacity(0.2)

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxxxl) {
                    if viewModel.showForm {
                        profileForm
                    }
                    existingProfilesList
                }
                .padding(Constants.Spacing.xxxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: appModel.selectedProfileID) { _ in
            if viewModel.showForm && !viewModel.isCreatingNewProfile {
                viewModel.loadProfile(currentProfile: appModel.selectedProfile)
            }
        }
        .onAppear {
            if appModel.availableProfiles.isEmpty {
                viewModel.showForm = true
                viewModel.isCreatingNewProfile = true
            }
            viewModel.loadProfile(currentProfile: appModel.selectedProfile)
            viewModel.scanSSHKeys()
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var formHeader: some View {
        HStack {
            Text(Constants.Label.profiles)
                .font(.system(
                    size: Constants.FontSize.headline,
                    weight: .semibold
                ))

            Text("\(appModel.availableProfiles.count) profiles")
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                viewModel.toggleFormState(appModel: appModel)
            } label: {
                Image(systemName: (viewModel.showForm && viewModel.isCreatingNewProfile) ? Constants.SystemImage.minus : Constants.SystemImage.plus)
                    .font(.system(size: Constants.FontSize.body))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Spacing.xxxxl)
        .padding(.vertical, Constants.Spacing.xxl)
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
