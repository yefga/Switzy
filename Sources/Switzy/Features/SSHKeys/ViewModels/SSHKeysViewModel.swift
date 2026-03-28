//
//  SSHKeysViewModel.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI
import Combine

@MainActor
final class SSHKeysViewModel: ObservableObject {

    @Published var keys: [SSHKeyInfo] = []
    @Published var isLoading: Bool = true
    @Published var showDeleteConfirmation: Bool = false
    @Published var keyToDelete: SSHKeyInfo?
    @Published var statusMessage: String?
    @Published var errorMessage: String?

    private let sshService = SSHKeyService()

    // MARK: - Task Management

    private var loadTask: Task<Void, Never>?
    private var statusTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?

    deinit {
        loadTask?.cancel()
        statusTask?.cancel()
        deleteTask?.cancel()
    }

    // MARK: - Load

    func loadKeys() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            do {
                keys = try await sshService.scanKeys()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Delete

    func confirmDelete(key: SSHKeyInfo) {
        keyToDelete = key
        showDeleteConfirmation = true
    }

    func deleteKey() {
        guard let key = keyToDelete else { return }
        deleteTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await sshService.deleteKeyPair(
                    privateKeyPath: key.privateKeyPath
                )
                keys.removeAll { $0.id == key.id }
                showStatus("Deleted \(key.filename)")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        keyToDelete = nil
    }

    // MARK: - Clipboard

    func copyPublicKey(_ key: SSHKeyInfo, completion: @escaping (String) -> Void) {
        guard
            let pubPath = key.publicKeyPath,
            let content = try? String(contentsOfFile: pubPath, encoding: .utf8)
        else {
            errorMessage = Constants.Strings.noPublicKey
            return
        }
        completion(content)
        showStatus(Constants.Strings.publicKeyCopied)
    }

    // MARK: - Toast
    
    func showStatus(_ message: String) {
        statusMessage = message
        statusTask?.cancel()
        statusTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Constants.Animation.statusDuration)
            if !Task.isCancelled {
                self?.statusMessage = nil
            }
        }
    }
}
