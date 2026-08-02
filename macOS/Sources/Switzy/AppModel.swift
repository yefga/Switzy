//
//  AppModel.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI
import Combine

@MainActor
final class AppModel: ObservableObject {

    // MARK: - Published State

    @Published var availableProfiles: [GitProfile] = []
    @Published var activeProfileID: UUID?
    @Published var availableSSHKeyCount: Int = 0
    @Published var statusBarDisplayMode: Constants.StatusBarDisplayMode {
        didSet {
            userDefaults.set(
                statusBarDisplayMode.rawValue,
                forKey: Constants.Persistence.statusBarDisplayModeKey
            )
        }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Services

    private let gitConfig = GitConfigService()
    private let sshService = SSHKeyService()
    private let userDefaults: UserDefaults

    // MARK: - Task Management

    private var loadTask: Task<Void, Never>?

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let savedMode = userDefaults.string(
            forKey: Constants.Persistence.statusBarDisplayModeKey
        )
        statusBarDisplayMode = Constants.StatusBarDisplayMode(rawValue: savedMode ?? "")
            ?? .iconOnly
    }

    deinit {
        loadTask?.cancel()
    }

    // MARK: - Initialization

    func loadOnLaunch() {
        loadTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            loadSavedProfiles()
            await importCurrentGitProfileIfNeeded()
            await detectActiveProfile()
            await loadSSHKeyCount()
            isLoading = false
        }
    }

    // MARK: - Profile Management

    func addOrUpdateProfile(_ profile: GitProfile) {
        if let index = availableProfiles.firstIndex(where: { $0.id == profile.id }) {
            availableProfiles[index] = profile
        } else {
            availableProfiles.append(profile)
        }
        saveProfiles()
    }

    func deleteProfile(id: UUID) {
        availableProfiles.removeAll { $0.id == id }
        if activeProfileID == id {
            activeProfileID = nil
        }
        saveProfiles()
    }

    func switchProfile(to profile: GitProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            try await gitConfig.applyProfile(profile)
            
            // Activate SSH key in agent if provided
            if let sshKeyPath = profile.sshKeyPath, !sshKeyPath.isEmpty {
                do {
                    // Try to clear default keys first? Or just add?
                    // User said "ssh-add selected_ssh_on profile"
                    try await sshService.addToAgent(privateKeyPath: sshKeyPath)
                } catch {
                    // Log but don't fail profile switch
                    print("SSH-ADD failed: \(error.localizedDescription)")
                }
            }
            
            activeProfileID = profile.id
            syncActiveFlags()
            saveProfiles()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func detectActiveProfile() async {
        activeProfileID = await gitConfig.detectActiveProfile(
            from: availableProfiles
        )
        syncActiveFlags()
    }

    // MARK: - Management Window

    @Published var selectedManagementTab: Constants.ManagementTab = .profile
    @Published var selectedProfileID: UUID?

    var selectedProfile: GitProfile? {
        guard let id = selectedProfileID else {
            return availableProfiles.first
        }
        return availableProfiles.first { $0.id == id }
    }

    func openManagementWindow(tab: Constants.ManagementTab) {
        selectedManagementTab = tab
        ManagementWindowController.shared.showWindow(appModel: self)
    }

    // MARK: - Computed

    var activeProfile: GitProfile? {
        availableProfiles.first { $0.id == activeProfileID }
    }

    var statusBarTitle: String? {
        switch statusBarDisplayMode {
        case .iconOnly:
            return nil
        case .activeProfile:
            return activeProfileStatusTitle
        case .profileCount:
            return Constants.Strings.profileCount(availableProfiles.count)
        case .sshKeyCount:
            return Constants.Strings.sshKeyCount(availableSSHKeyCount)
        }
    }

    func statusBarOptionLabel(for mode: Constants.StatusBarDisplayMode) -> String {
        if mode == .iconOnly {
            return mode.title
        }
        return Constants.Strings.settingOption(
            title: mode.title,
            value: statusBarValue(for: mode)
        )
    }

    func statusBarValue(for mode: Constants.StatusBarDisplayMode) -> String {
        switch mode {
        case .iconOnly:
            return Constants.Strings.noAdditionalText
        case .activeProfile:
            return activeProfileStatusTitle
        case .profileCount:
            return Constants.Strings.profileCount(availableProfiles.count)
        case .sshKeyCount:
            return Constants.Strings.sshKeyCount(availableSSHKeyCount)
        }
    }

    private var activeProfileStatusTitle: String {
        guard let activeProfile else {
            return Constants.Strings.noActiveProfile
        }

        return Constants.Strings.profilePlatform(
            name: activeProfile.name,
            platform: activeProfile.resolvedGitProvider.statusBarName
        )
    }

    func refreshSSHKeyCount() {
        Task { [weak self] in
            guard let self else { return }
            await loadSSHKeyCount()
        }
    }

    func updateSSHKeyCount(_ count: Int) {
        availableSSHKeyCount = count
    }

    // MARK: - Import Current Git Config

    private func importCurrentGitProfileIfNeeded() async {
        guard availableProfiles.isEmpty else { return }

        let name = await gitConfig.currentUserName()
        let email = await gitConfig.currentUserEmail()

        guard let name, !name.isEmpty, let email, !email.isEmpty else { return }

        let profile = GitProfile(
            name: name,
            userName: name,
            userEmail: email,
            sshKeyPath: nil,
            isActive: true
        )
        availableProfiles.append(profile)
        activeProfileID = profile.id
        saveProfiles()
    }

    // MARK: - Private Helpers

    private func syncActiveFlags() {
        for index in availableProfiles.indices {
            availableProfiles[index].isActive = (
                availableProfiles[index].id == activeProfileID
            )
        }
    }

    private func loadSSHKeyCount() async {
        if let keys = try? await sshService.scanKeys() {
            availableSSHKeyCount = keys.count
        }
    }

    private func saveProfiles() {
        if let data = try? JSONEncoder().encode(availableProfiles) {
            UserDefaults.standard.set(
                data,
                forKey: Constants.Persistence.profilesKey
            )
        }
    }

    private func loadSavedProfiles() {
        guard
            let data = UserDefaults.standard.data(
                forKey: Constants.Persistence.profilesKey
            ),
            let profiles = try? JSONDecoder().decode(
                [GitProfile].self,
                from: data
            )
        else {
            return
        }
        availableProfiles = profiles
    }
}
