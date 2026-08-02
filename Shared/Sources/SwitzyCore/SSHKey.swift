//
//  SSHKey.swift
//  Switzy
//
//  Created by Yefga on 26/03/2026
//

import Foundation

struct SSHKeyInfo: Identifiable, Equatable, Hashable {
    let id: UUID
    let filename: String
    let privateKeyPath: String
    let publicKeyPath: String?
    let keyType: SSHKeyType
    let fingerprint: String?
    let comment: String?
    let createdAt: Date?
    let expiresAt: Date?

    init(
        id: UUID = UUID(),
        filename: String,
        privateKeyPath: String,
        publicKeyPath: String? = nil,
        keyType: SSHKeyType = .ed25519,
        fingerprint: String? = nil,
        comment: String? = nil,
        createdAt: Date? = nil,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.filename = filename
        self.privateKeyPath = privateKeyPath
        self.publicKeyPath = publicKeyPath
        self.keyType = keyType
        self.fingerprint = fingerprint
        self.comment = comment
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
}

enum SSHKeyType: String, CaseIterable, Identifiable {
    case ed25519
    case rsa
    case ecdsa
    case dsa

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ed25519: return "Ed25519"
        case .rsa: return "RSA"
        case .ecdsa: return "ECDSA"
        case .dsa: return "DSA"
        }
    }

    var defaultBits: Int? {
        switch self {
        case .rsa: return 4096
        case .ecdsa: return 256
        default: return nil
        }
    }
}

struct SSHKeyResult: Equatable {
    let privateKeyPath: String
    let publicKeyPath: String
    let fingerprint: String
}

extension SSHKeyInfo {
    static let example = SSHKeyInfo(
        filename: "id_ed25519",
        privateKeyPath: "~/.ssh/id_ed25519",
        publicKeyPath: "~/.ssh/id_ed25519.pub",
        keyType: .ed25519,
        fingerprint: "SHA256:abc123...",
        comment: "john@personal.com"
    )
}
