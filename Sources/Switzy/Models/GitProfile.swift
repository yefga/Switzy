//
//  GitProfile.swift
//  Switzy
//
//  Created by Yefga on 26/03/2026
//

import Foundation

struct GitProfile: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var userName: String
    var userEmail: String
    var signingKey: String?
    var sshKeyPath: String?
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        userName: String,
        userEmail: String,
        signingKey: String? = nil,
        sshKeyPath: String? = nil,
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.userName = userName
        self.userEmail = userEmail
        self.signingKey = signingKey
        self.sshKeyPath = sshKeyPath
        self.isActive = isActive
    }
}

extension GitProfile {
    static let example = GitProfile(
        name: "Personal",
        userName: "John Doe",
        userEmail: "john@personal.com",
        sshKeyPath: "~/.ssh/id_ed25519",
        isActive: true
    )

    static let examples: [GitProfile] = [
        GitProfile(
            name: "Personal",
            userName: "John Doe",
            userEmail: "john@personal.com",
            sshKeyPath: "~/.ssh/id_ed25519_personal",
            isActive: true
        ),
        GitProfile(
            name: "Work",
            userName: "John Doe",
            userEmail: "john.doe@company.com",
            sshKeyPath: "~/.ssh/id_ed25519_work",
            isActive: false
        ),
    ]
}
