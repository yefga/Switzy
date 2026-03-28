//
//  ProfileFormView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct ProfileFormView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var profileName: String = ""
    @State private var gitUserName: String = ""
    @State private var gitEmail: String = ""
    @State private var selectedSSHKey: String = ""
    @State private var availableKeys: [String] = []
    @State private var isCreatingNewProfile: Bool = false
    @State private var showForm: Bool = false
    @State private var scanTask: Task<Void, Never>?

    private var currentProfile: GitProfile? {
        appModel.selectedProfile
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            formHeader
            Divider().opacity(0.2)

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxxxl) {
                    if showForm {
                        profileForm
                    }
                    existingProfilesList
                }
                .padding(Constants.Spacing.xxxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: appModel.selectedProfileID) { _ in
            if showForm && !isCreatingNewProfile {
                loadProfile()
            }
        }
        .onAppear {
            if appModel.availableProfiles.isEmpty {
                showForm = true
                isCreatingNewProfile = true
            }
            loadProfile()
            scanSSHKeys()
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
                withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                    if !showForm {
                        showForm = true
                        isCreatingNewProfile = true
                        resetForm()
                    } else if isCreatingNewProfile {
                        showForm = false
                        isCreatingNewProfile = false
                    } else {
                        isCreatingNewProfile = true
                        resetForm()
                    }
                }
            } label: {
                Image(systemName: (showForm && isCreatingNewProfile) ? Constants.SystemImage.minus : Constants.SystemImage.plus)
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
                text: $profileName
            )

            formField(
                label: Constants.Placeholder.gitUserName,
                text: $gitUserName
            )

            formField(
                label: Constants.Placeholder.gitEmail,
                text: $gitEmail
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
                if availableKeys.isEmpty {
                    Text(Constants.Strings.selectYourKey)
                        .font(.system(size: Constants.FontSize.body))
                        .foregroundStyle(.tertiary)
                } else {
                    Picker("", selection: $selectedSSHKey) {
                        Text(Constants.Strings.selectYourKey).tag("")
                        ForEach(availableKeys, id: \.self) { key in
                            Text(keyDisplayName(key)).tag(key)
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
            saveProfile()
        } label: {
            Text(isCreatingNewProfile ? "Create Profile" : Constants.Strings.saveChanges)
                .font(.system(
                    size: Constants.FontSize.body,
                    weight: .semibold
                ))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.lg)
        }
        .disabled(!isFormValid)
        .buttonStyle(.borderedProminent)
    }

    // MARK: - List

    @ViewBuilder
    private var existingProfilesList: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxl) {
            ForEach(appModel.availableProfiles) { profile in
                if !showForm || (showForm && !isCreatingNewProfile && appModel.selectedProfileID == profile.id) {
                    profileRow(profile: profile)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    private func profileRow(profile: GitProfile) -> some View {
        let isSelected = appModel.selectedProfileID == profile.id
        
        HStack {
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                HStack(spacing: Constants.Spacing.lg) {
                    Text(profile.name)
                        .font(.system(
                            size: Constants.FontSize.body,
                            weight: .semibold
                        ))
                    
                    if profile.isActive {
                        Text("ACTIVE")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
                            )
                            .clipShape(Capsule())
                    }
                }
                
                Text("\(profile.userName) · \(profile.userEmail)")
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundStyle(.secondary)
                
                if let ssh = profile.sshKeyPath {
                    HStack(spacing: 4) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 10))
                        Text((ssh as NSString).lastPathComponent)
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundStyle(.tertiary)
                }
            }
            Spacer()

            if !showForm || !isSelected {
                Button {
                    appModel.selectedProfileID = profile.id
                    withAnimation {
                        showForm = true
                        isCreatingNewProfile = false
                        loadProfile()
                    }
                } label: {
                    Text("Edit")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            } else if isSelected && showForm && !isCreatingNewProfile {
                Button {
                    withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                        showForm = false
                    }
                } label: {
                    Text("Done")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            Button {

                appModel.deleteProfile(id: profile.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundStyle(.red.opacity(0.6))
            }
            .buttonStyle(.plain)
            .padding(.leading, 12)
        }
        .padding(Constants.Spacing.xxl)
        .glassBackground(
            cornerRadius: Constants.Layout.cornerRadiusSmall,
            material: .hudWindow,
            opacity: 0.4
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadiusSmall)
                .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - Logic

    private func loadProfile() {
        guard let profile = currentProfile else { return }
        profileName = profile.name
        gitUserName = profile.userName
        gitEmail = profile.userEmail
        selectedSSHKey = profile.sshKeyPath ?? ""
    }

    private func resetForm() {
        profileName = ""
        gitUserName = ""
        gitEmail = ""
        selectedSSHKey = ""
    }

    private func saveProfile() {
        if isCreatingNewProfile {
            let newProfile = GitProfile(
                name: profileName,
                userName: gitUserName,
                userEmail: gitEmail,
                sshKeyPath: selectedSSHKey.isEmpty ? nil : selectedSSHKey
            )
            appModel.addOrUpdateProfile(newProfile)
            appModel.selectedProfileID = newProfile.id
            withAnimation {
                isCreatingNewProfile = false
                showForm = false
            }
        } else {
            guard let existing = currentProfile else { return }
            var updated = existing
            updated.name = profileName
            updated.userName = gitUserName
            updated.userEmail = gitEmail
            updated.sshKeyPath = selectedSSHKey.isEmpty ? nil : selectedSSHKey
            appModel.addOrUpdateProfile(updated)
            withAnimation {
                showForm = false
            }
        }
    }

    private func scanSSHKeys() {
        let service = SSHKeyService()
        scanTask = Task {
            if let keys = try? await service.scanKeys() {
                availableKeys = keys.map(\.privateKeyPath)
            }
        }
    }

    private func keyDisplayName(_ path: String) -> String {
        (path as NSString).lastPathComponent
    }

    private var isFormValid: Bool {
        !profileName.trimmingCharacters(in: .whitespaces).isEmpty
            && !gitUserName.trimmingCharacters(in: .whitespaces).isEmpty
            && !gitEmail.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
