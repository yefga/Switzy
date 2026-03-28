//
//  SSHFormViewModel.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

@MainActor
final class SSHFormViewModel: ObservableObject {
    @Published var selectedKeyType: SSHKeyType = .ed25519
    @Published var email: String = ""
    @Published var filename: String = ""
    @Published var passphrase: String = ""
    @Published var errorMessage: String?
    @Published var statusMessage: String?
    @Published var expandedKeyIDs: Set<UUID> = []

    func generateKey(viewModel: SSHKeysViewModel, managementViewModel: ManagementViewModel) {
        let service = SSHKeyService()
        errorMessage = nil
        statusMessage = nil

        // Copy captured properties
        let keyType = selectedKeyType
        let userEmail = email
        let name = filename
        let pass = passphrase

        Task {
            do {
                _ = try await service.generateKey(
                    type: keyType,
                    email: userEmail,
                    filename: name,
                    passphrase: pass
                )

                // Update UI on MainActor
                if !Task.isCancelled {
                    statusMessage = "Key generated successfully"
                    viewModel.loadKeys()
                    resetForm()
                    withAnimation {
                        managementViewModel.showNewSSHKeyForm = false
                    }
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    func resetForm() {
        email = ""
        filename = ""
        passphrase = ""
    }
}


