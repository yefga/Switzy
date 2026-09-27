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
    @Published var activeProfileID: UUID? {
        didSet {
            userDefaults.set(
                activeProfileID?.uuidString,
                forKey: Constants.Persistence.activeProfileIDKey
            )
        }
    }
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
    /// A step that failed without failing the switch as a whole.
    @Published var warningMessage: String?

    // MARK: - Services

    private let gitConfig = GitConfigService()
    private let gitInclude = GitIncludeService()
    private let sshService = SSHKeyService()
    private let userDefaults: UserDefaults

    // MARK: - Task Management

    private var loadTask: Task<Void, Never>?
    private var ruleTask: Task<Void, Never>?

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
        ruleTask?.cancel()
    }

    // MARK: - Initialization

    func loadOnLaunch() {
        loadTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            loadSavedProfiles()
            await importCurrentGitProfileIfNeeded()
            await detectActiveProfile()
            await refreshWrittenConfig()
            await loadSSHKeyCount()
            isLoading = false
        }
    }

    // MARK: - Profile Management

    func addOrUpdateProfile(_ profile: GitProfile) {
        let previousRules = availableProfiles
            .first { $0.id == profile.id }?
            .resolvedDirectoryRules ?? []

        if let index = availableProfiles.firstIndex(where: { $0.id == profile.id }) {
            availableProfiles[index] = profile
        } else {
            availableProfiles.append(profile)
        }
        saveProfiles()
        syncDirectoryRules(for: profile, removing: previousRules)
    }

    func deleteProfile(id: UUID) {
        let removed = availableProfiles.first { $0.id == id }

        availableProfiles.removeAll { $0.id == id }
        if activeProfileID == id {
            activeProfileID = nil
        }
        saveProfiles()

        guard let removed else { return }
        ruleTask = Task { [gitInclude] in
            await gitInclude.removeAllRules(for: removed)
        }
    }

    /// Reconcile a profile's `includeIf` rules with what it claimed before, so
    /// directories the user removed stop resolving to this identity.
    private func syncDirectoryRules(for profile: GitProfile, removing previousRules: [String]) {
        let staleRules = previousRules.filter { !profile.resolvedDirectoryRules.contains($0) }

        ruleTask = Task { [gitInclude] in
            for directory in staleRules {
                await gitInclude.removeRule(directory: directory)
            }

            do {
                try await gitInclude.applyRules(for: profile)
            } catch {
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }

    /// Rewrite what earlier versions wrote — profile config files, folder rules
    /// and the global ssh command — in the current format, so fixes to that
    /// format reach existing setups without the user re-saving each profile.
    private func refreshWrittenConfig() async {
        for profile in availableProfiles where !profile.resolvedDirectoryRules.isEmpty {
            do {
                try await gitInclude.applyRules(for: profile)
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        if let activeProfile {
            try? await gitConfig.refreshSSHCommand(for: activeProfile)
        }
    }

    func switchProfile(to profile: GitProfile) async {
        isLoading = true
        errorMessage = nil
        warningMessage = nil

        let outgoingKeyPath = activeProfile?.sshKeyPath

        do {
            try await gitConfig.applyProfile(profile)

            // Drop the outgoing key before adding the new one, otherwise
            // identities pile up in the agent and ssh may offer the wrong
            // one first. Removal fails harmlessly if it was never loaded.
            if let outgoingKeyPath,
               !outgoingKeyPath.isEmpty,
               outgoingKeyPath != profile.sshKeyPath {
                try? await sshService.removeFromAgent(privateKeyPath: outgoingKeyPath)
            }

            // Activate SSH key in agent if provided
            if let sshKeyPath = profile.sshKeyPath, !sshKeyPath.isEmpty {
                do {
                    try await sshService.addToAgent(privateKeyPath: sshKeyPath)
                } catch {
                    // The identity switch itself succeeded, so this is a
                    // warning rather than a failure.
                    warningMessage = Constants.Strings.sshAddFailed(
                        detail: error.localizedDescription
                    )
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
        let detection = await gitConfig.detectActiveProfile(
            from: availableProfiles
        )

        switch detection {
        case .matched(let id):
            activeProfileID = id
        case .noMatch:
            activeProfileID = nil
        case .unavailable:
            // Keep whatever was restored from disk rather than dropping the
            // active profile just because git could not be read.
            break
        }

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
            userDefaults.set(
                data,
                forKey: Constants.Persistence.profilesKey
            )
        }
    }

    private func loadSavedProfiles() {
        guard
            let data = userDefaults.data(
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
        restoreActiveProfileID()
    }

    private func restoreActiveProfileID() {
        let storedID = userDefaults.string(
            forKey: Constants.Persistence.activeProfileIDKey
        )
        .flatMap(UUID.init(uuidString:))

        if let storedID, availableProfiles.contains(where: { $0.id == storedID }) {
            activeProfileID = storedID
            return
        }

        activeProfileID = availableProfiles.first { $0.isActive }?.id
    }
}
