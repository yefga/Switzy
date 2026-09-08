//
//  GitConfigService.swift
//  Switzy
//
//  Created by Yefga on 26/03/2026
//

import Foundation

enum GitConfigError: LocalizedError {
    case gitNotInstalled
    case configNotFound
    case profileNotFound(String)
    case readFailed(String)
    case writeFailed(String)

    var errorDescription: String? {
        switch self {
        case .gitNotInstalled:
            return "Git is not installed on this system."
        case .configNotFound:
            return "Could not locate ~/.gitconfig."
        case .profileNotFound(let name):
            return "Profile '\(name)' not found."
        case .readFailed(let detail):
            return "Failed to read git config: \(detail)"
        case .writeFailed(let detail):
            return "Failed to write git config: \(detail)"
        }
    }
}

/// Outcome of matching the current git config against the saved profiles.
enum ActiveProfileDetection {
    /// The global git config matches a saved profile.
    case matched(UUID)
    /// The global git config was readable but matches no saved profile.
    case noMatch
    /// The global git config could not be read (git missing, empty, or blocked).
    case unavailable
}

actor GitConfigService {

    private let shell = ShellService()

    // MARK: - Read Current Config

    /// Read the current global git user.name.
    func currentUserName() async -> String? {
        try? await shell.run("git", arguments: ["config", "--global", "user.name"])
    }

    /// Read the current global git user.email.
    func currentUserEmail() async -> String? {
        try? await shell.run("git", arguments: ["config", "--global", "user.email"])
    }

    /// Read the current global user.signingkey.
    func currentSigningKey() async -> String? {
        try? await shell.run("git", arguments: ["config", "--global", "user.signingkey"])
    }

    /// Read the current global core.sshCommand to determine active SSH key.
    func currentSSHCommand() async -> String? {
        try? await shell.run("git", arguments: ["config", "--global", "core.sshCommand"])
    }

    // MARK: - Switch Profile

    /// Apply a GitProfile to the global git config.
    @discardableResult
    func applyProfile(_ profile: GitProfile) async throws -> Bool {
        _ = try await shell.run("git", arguments: ["config", "--global", "user.name", profile.userName])
        _ = try await shell.run("git", arguments: ["config", "--global", "user.email", profile.userEmail])

        if let signingKey = profile.signingKey, !signingKey.isEmpty {
            _ = try await shell.run("git", arguments: ["config", "--global", "user.signingkey", signingKey])

            // Setting user.signingkey alone signs nothing. A key given as a path
            // is an SSH key, which git only accepts once gpg.format says so.
            if isSSHSigningKey(signingKey) {
                _ = try await shell.run("git", arguments: ["config", "--global", "gpg.format", "ssh"])
            } else {
                _ = try? await shell.run("git", arguments: ["config", "--global", "--unset", "gpg.format"])
            }
            _ = try await shell.run("git", arguments: ["config", "--global", "commit.gpgsign", "true"])
        } else {
            // Unset signing key if not provided
            _ = try? await shell.run("git", arguments: ["config", "--global", "--unset", "user.signingkey"])
            _ = try? await shell.run("git", arguments: ["config", "--global", "--unset", "gpg.format"])
            _ = try? await shell.run("git", arguments: ["config", "--global", "--unset", "commit.gpgsign"])
        }

        if let sshKeyPath = profile.sshKeyPath, !sshKeyPath.isEmpty {
            let expandedPath = expandTilde(in: sshKeyPath)
            let sshCommand = "ssh -i \(expandedPath)"
            _ = try await shell.run("git", arguments: ["config", "--global", "core.sshCommand", sshCommand])
        } else {
            _ = try? await shell.run("git", arguments: ["config", "--global", "--unset", "core.sshCommand"])
        }
        return true
    }

    // MARK: - Detect Active Profile

    /// Determine which saved profile matches the current git config.
    func detectActiveProfile(from profiles: [GitProfile]) async -> ActiveProfileDetection {
        let name = await currentUserName()
        let email = await currentUserEmail()

        guard
            let name, !name.isEmpty,
            let email, !email.isEmpty
        else {
            return .unavailable
        }

        let candidates = profiles.filter { profile in
            profile.userName == name && profile.userEmail == email
        }

        guard let first = candidates.first else { return .noMatch }
        guard candidates.count > 1 else { return .matched(first.id) }

        // Profiles that share an identity (the same person on two hosts) are
        // indistinguishable by name and email alone. Break the tie on the SSH
        // key and signing key actually in the config.
        let sshCommand = await currentSSHCommand()
        let signingKey = await currentSigningKey()

        let resolved = candidates.first { profile in
            guard let keyPath = profile.sshKeyPath, !keyPath.isEmpty else { return false }
            return sshCommand?.contains(expandTilde(in: keyPath)) == true
        } ?? candidates.first { profile in
            guard let key = profile.signingKey, !key.isEmpty else { return false }
            return signingKey == key
        }

        return .matched((resolved ?? first).id)
    }

    /// An SSH signing key is given as a path; a GPG key is a key id.
    private func isSSHSigningKey(_ key: String) -> Bool {
        key.hasPrefix("/") || key.hasPrefix("~") || key.contains(".ssh/")
    }

    private func expandTilde(in path: String) -> String {
        guard path == "~" || path.hasPrefix("~/") else { return path }

        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        if path == "~" {
            return homeDirectory.path
        }

        let relativePath = String(path.dropFirst(2))
        return homeDirectory.appendingPathComponent(relativePath).path
    }
}
