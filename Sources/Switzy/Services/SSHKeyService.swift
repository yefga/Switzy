//
//  SSHKeyService.swift
//  Switzy
//
//  Created by Yefga on 26/03/2026
//

import Foundation

enum SSHKeyError: LocalizedError {
    case sshDirectoryNotFound
    case keyNotFound(String)
    case generationFailed(String)
    case deletionFailed(String)
    case importFailed(String)

    var errorDescription: String? {
        switch self {
        case .sshDirectoryNotFound:
            return "~/.ssh directory not found."
        case .keyNotFound(let path):
            return "SSH key not found at \(path)."
        case .generationFailed(let detail):
            return "SSH key generation failed: \(detail)"
        case .deletionFailed(let detail):
            return "SSH key deletion failed: \(detail)"
        case .importFailed(let detail):
            return "SSH key import failed: \(detail)"
        }
    }
}

/// Alias services referenced by existing ViewModels.
typealias SSHKeyMetadataService = SSHKeyService
typealias SSHKeyGeneratorService = SSHKeyService

actor SSHKeyService {

    private let shell = ShellService()
    private let fileManager = FileManager.default

    private var sshDirectoryURL: URL {
        fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".ssh")
    }

    // MARK: - Scan Keys

    func scanKeys() async throws -> [SSHKeyInfo] {
        let sshDir = sshDirectoryURL
        guard fileManager.fileExists(atPath: sshDir.path) else {
            throw SSHKeyError.sshDirectoryNotFound
        }

        let contents = try fileManager.contentsOfDirectory(atPath: sshDir.path)

        // Find private keys (files without .pub extension, excluding known_hosts, config, etc.)
        let excludedFiles: Set<String> = ["known_hosts", "known_hosts.old", "config", "authorized_keys", "environment", "agent_sock"]
        let privateKeys = contents.filter { filename in
            !filename.hasPrefix(".") &&
            !filename.hasSuffix(".pub") &&
            !excludedFiles.contains(filename)
        }

        var keys: [SSHKeyInfo] = []
        for filename in privateKeys.sorted() {
            let privatePath = sshDir.appendingPathComponent(filename).path

            // Verify it's actually a key file by checking first line
            guard let firstLine = try? String(contentsOfFile: privatePath, encoding: .utf8)
                .components(separatedBy: .newlines)
                .first,
                firstLine.contains("PRIVATE KEY") || firstLine.contains("OPENSSH") || firstLine.hasPrefix("-----BEGIN")
            else { continue }

            let publicPath = sshDir.appendingPathComponent("\(filename).pub").path
            let hasPublicKey = fileManager.fileExists(atPath: publicPath)

            let keyType = detectKeyType(from: filename)
            let fingerprint = await getFingerprint(publicKeyPath: hasPublicKey ? publicPath : nil)
            let comment = await getComment(publicKeyPath: hasPublicKey ? publicPath : nil)
            
            let attrs = try? fileManager.attributesOfItem(atPath: privatePath)
            let createdAt = attrs?[.creationDate] as? Date

            keys.append(SSHKeyInfo(
                filename: filename,
                privateKeyPath: privatePath,
                publicKeyPath: hasPublicKey ? publicPath : nil,
                keyType: keyType,
                fingerprint: fingerprint,
                comment: comment,
                createdAt: createdAt
            ))
        }

        return keys
    }

    // MARK: - Generate Key

    func generateKey(
        type: SSHKeyType,
        email: String,
        filename: String,
        passphrase: String
    ) async throws -> SSHKeyResult {
        let sshDir = sshDirectoryURL

        // Ensure .ssh directory exists
        if !fileManager.fileExists(atPath: sshDir.path) {
            try fileManager.createDirectory(at: sshDir, withIntermediateDirectories: true)
            try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: sshDir.path)
        }

        let keyPath = sshDir.appendingPathComponent(filename).path

        var args = ["-t", type.rawValue]
        if let bits = type.defaultBits {
            args += ["-b", "\(bits)"]
        }
        args += ["-C", email, "-f", keyPath, "-N", passphrase]

        do {
            _ = try await shell.run("ssh-keygen", arguments: args)
        } catch {
            throw SSHKeyError.generationFailed(error.localizedDescription)
        }

        let publicPath = "\(keyPath).pub"
        let fingerprint = await getFingerprint(publicKeyPath: publicPath) ?? ""

        return SSHKeyResult(
            privateKeyPath: keyPath,
            publicKeyPath: publicPath,
            fingerprint: fingerprint
        )
    }

    // MARK: - Delete Key

    func deleteKeyPair(privateKeyPath: String) async throws {
        let privatePath = privateKeyPath
        let publicPath = "\(privatePath).pub"

        // Remove from agent first, ignore error if not in agent
        _ = try? await removeFromAgent(privateKeyPath: privatePath)

        do {
            if fileManager.fileExists(atPath: privatePath) {
                try fileManager.removeItem(atPath: privatePath)
            }
            if fileManager.fileExists(atPath: publicPath) {
                try fileManager.removeItem(atPath: publicPath)
            }
        } catch {
            // Fallback to shell rm -f if FileManager fails
            do {
                _ = try await shell.run("rm", arguments: ["-f", privatePath])
                _ = try await shell.run("rm", arguments: ["-f", publicPath])
            } catch {
                throw SSHKeyError.deletionFailed(error.localizedDescription)
            }
        }
    }

    // MARK: - SSH Agent Management

    func addToAgent(privateKeyPath: String) async throws {
        let expandedPath = (privateKeyPath as NSString).expandingTildeInPath
        
        // Ensure the SSH agent is running. If SSH_AUTH_SOCK is missing, it's not running.
        if ProcessInfo.processInfo.environment["SSH_AUTH_SOCK"] == nil {
            // On macOS, it's usually managed by launchd, but let's try to be helpful.
            print("SSH_AUTH_SOCK not found. SSH agent might not be running.")
        }
        
        // We use 'ssh-add' to add the key.
        // We use -K on older macOS or --apple-use-keychain on newer ones if we want keychain integration.
        // But for a simple switcher, just ssh-add is what was requested.
        _ = try await shell.run("ssh-add", arguments: [expandedPath])
    }

    func removeFromAgent(privateKeyPath: String) async throws {
        let expandedPath = (privateKeyPath as NSString).expandingTildeInPath
        _ = try await shell.run("ssh-add", arguments: ["-d", expandedPath])
    }

    func clearAgent() async throws {
        _ = try await shell.run("ssh-add", arguments: ["-D"])
    }

    // MARK: - Import Key

    func importKey(from sourcePath: String) throws -> String {
        let filename = (sourcePath as NSString).lastPathComponent
        let destPath = sshDirectoryURL.appendingPathComponent(filename).path

        guard fileManager.fileExists(atPath: sourcePath) else {
            throw SSHKeyError.keyNotFound(sourcePath)
        }

        do {
            try fileManager.copyItem(atPath: sourcePath, toPath: destPath)
            try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: destPath)

            // Also copy public key if it exists alongside
            let pubSource = "\(sourcePath).pub"
            let pubDest = "\(destPath).pub"
            if fileManager.fileExists(atPath: pubSource) {
                try fileManager.copyItem(atPath: pubSource, toPath: pubDest)
                try fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: pubDest)
            }
        } catch {
            throw SSHKeyError.importFailed(error.localizedDescription)
        }

        return destPath
    }

    // MARK: - Private Helpers

    private func detectKeyType(from filename: String) -> SSHKeyType {
        let lower = filename.lowercased()
        if lower.contains("ed25519") { return .ed25519 }
        if lower.contains("ecdsa") { return .ecdsa }
        if lower.contains("dsa") { return .dsa }
        if lower.contains("rsa") { return .rsa }
        return .ed25519
    }

    private func getFingerprint(publicKeyPath: String?) async -> String? {
        guard let pubPath = publicKeyPath else { return nil }
        return try? await shell.run("ssh-keygen", arguments: ["-lf", pubPath])
    }

    private func getComment(publicKeyPath: String?) async -> String? {
        guard let pubPath = publicKeyPath,
              let content = try? String(contentsOfFile: pubPath, encoding: .utf8) else {
            return nil
        }
        let parts = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
        return parts.count >= 3 ? parts[2] : nil
    }
}
