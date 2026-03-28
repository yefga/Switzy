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

actor GitConfigService {

    private let shell = ShellService()

    private var gitConfigPath: String {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".gitconfig")
            .path
    }

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
        } else {
            // Unset signing key if not provided
            _ = try? await shell.run("git", arguments: ["config", "--global", "--unset", "user.signingkey"])
        }

        if let sshKeyPath = profile.sshKeyPath, !sshKeyPath.isEmpty {
            let expandedPath = (sshKeyPath as NSString).expandingTildeInPath
            let sshCommand = "ssh -i \(expandedPath)"
            _ = try await shell.run("git", arguments: ["config", "--global", "core.sshCommand", sshCommand])
        } else {
            _ = try? await shell.run("git", arguments: ["config", "--global", "--unset", "core.sshCommand"])
        }
        return true
    }

    // MARK: - Detect Active Profile

    /// Determine which saved profile matches the current git config.
    func detectActiveProfile(from profiles: [GitProfile]) async -> UUID? {
        let name = await currentUserName()
        let email = await currentUserEmail()

        guard let name, let email else { return nil }

        return profiles.first { profile in
            profile.userName == name && profile.userEmail == email
        }?.id
    }
}
