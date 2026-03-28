//
//  ProfileFormViewModel.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

@MainActor
final class ProfileFormViewModel: ObservableObject {
    @Published var profileName: String = ""
    @Published var gitUserName: String = ""
    @Published var gitEmail: String = ""
    @Published var selectedSSHKey: String = ""
    @Published var availableKeys: [String] = []
    
    @Published var isCreatingNewProfile: Bool = false
    @Published var showForm: Bool = false
    
    private var scanTask: Task<Void, Never>?
    
    var isFormValid: Bool {
        !profileName.trimmingCharacters(in: .whitespaces).isEmpty
            && !gitUserName.trimmingCharacters(in: .whitespaces).isEmpty
            && !gitEmail.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func loadProfile(currentProfile: GitProfile?) {
        guard let profile = currentProfile else { return }
        profileName = profile.name
        gitUserName = profile.userName
        gitEmail = profile.userEmail
        selectedSSHKey = profile.sshKeyPath ?? ""
    }

    func resetForm() {
        profileName = ""
        gitUserName = ""
        gitEmail = ""
        selectedSSHKey = ""
    }

    func saveProfile(appModel: AppModel, currentProfile: GitProfile?) {
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

    func scanSSHKeys() {
        let service = SSHKeyService()
        scanTask = Task { [weak self] in
            if let keys = try? await service.scanKeys() {
                // Ensure we don't update if task was cancelled
                if !Task.isCancelled {
                    self?.availableKeys = keys.map(\.privateKeyPath)
                }
            }
        }
    }
    
    func toggleFormState(appModel: AppModel) {
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
    }
}
