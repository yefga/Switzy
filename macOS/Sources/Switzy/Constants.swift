//
//  Constants.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

enum Constants {

    // MARK: - System Images

    enum SystemImage {
        static let appIcon = "person.2.circle"
        static let appIconFill = "person.2.circle.fill"
        static let profile = "person.circle.fill"
        static let profileAdd = "person.crop.circle.badge.plus"
        static let switchProfile = "arrow.right.circle.fill"
        static let editProfile = "pencil.circle.fill"
        static let deleteProfile = "trash.circle.fill"
        static let key = "key.fill"
        static let keySlash = "key.slash"
        static let shieldCheck = "checkmark.shield.fill"
        static let copy = "doc.on.doc.fill"
        static let refresh = "arrow.clockwise"
        static let folder = "folder.fill"
        static let power = "power"
        static let info = "info.circle.fill"
        static let settings = "slider.horizontal.3"
        static let gear = "gearshape.fill"
        static let drive = "externaldrive.fill"
        static let warning = "exclamationmark.triangle.fill"
        static let checkmark = "checkmark.circle.fill"
        static let circle = "circle"
        static let plus = "plus"
        static let minus = "minus"
        static let plusCircle = "plus.circle.fill"
        static let sshManage = "key.horizontal.fill"
        static let profileManage = "person.text.rectangle.fill"
        static let quit = "rectangle.portrait.and.arrow.right"
        static let profileTab = "person.2.fill"
        static let sshTab = "key.fill"
        static let settingsTab = "gearshape.fill"
        static let generateKey = "bolt.fill"
        static let calendar = "calendar"
        static let sparkle = "sparkles"
        static let update = "arrow.up.circle.fill"
    }

    // MARK: - Font Sizes

    enum FontSize {
        static let title: CGFloat = 16
        static let headline: CGFloat = 14
        static let body: CGFloat = 13
        static let callout: CGFloat = 12
        static let caption: CGFloat = 11
        static let caption2: CGFloat = 10
        static let statusBarIcon: CGFloat = 18
        static let emptyStateIcon: CGFloat = 36
        static let aboutIcon: CGFloat = 50
        static let aboutTitle: CGFloat = 28
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 1
        static let xs: CGFloat = 2
        static let sm: CGFloat = 4
        static let md: CGFloat = 6
        static let lg: CGFloat = 8
        static let xl: CGFloat = 10
        static let xxl: CGFloat = 12
        static let xxxl: CGFloat = 16
        static let xxxxl: CGFloat = 20
    }

    // MARK: - Layout

    enum Layout {
        static let popoverWidth: CGFloat = 280
        static let popoverHeight: CGFloat = 400
        static let cornerRadius: CGFloat = 12
        static let cornerRadiusSmall: CGFloat = 8
        static let cornerRadiusCapsule: CGFloat = 6
        static let borderWidth: CGFloat = 0.5
        static let activeIndicatorSize: CGFloat = 8
        static let statusBarIconSize: CGFloat = 18
        static let dotSize: CGFloat = 10
        static let managementWidth: CGFloat = 480
        static let managementHeight: CGFloat = 480
        static let sidebarWidth: CGFloat = 180
        static let tabPillHeight: CGFloat = 28
        static let aboutWidth: CGFloat = 320
        static let iconSize: CGFloat = 20
        static let rowHeight: CGFloat = 36
    }

    // MARK: - Opacity

    enum Opacity {
        static let backgroundBlur: Double = 0.8
        static let divider: Double = 0.2
        static let hover: Double = 0.05
        static let active: Double = 0.12
        static let secondary: Double = 0.6
        static let tertiary: Double = 0.4
    }

    // MARK: - Strings

    enum Strings {
        static let appName = "Switzy"
        static let appSubtitle = "Git Identity Manager"
        static let noActiveProfile = "No active profile"
        static let noProfiles = "No Profiles Yet"
        static let noProfilesHint = "Add a git profile to get started."
        static let noSSHKeys = "No SSH Keys Found"
        static let noSSHKeysHint = "No keys were detected in ~/.ssh"
        static let addProfile = "Add Profile"
        static let createProfile = "Create Profile"
        static let editProfile = "Edit Profile"
        static let newProfile = "New Profile"
        static let saveChanges = "Save Changes"
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let refresh = "Refresh"
        static let openSSH = "Open .ssh"
        static let active = "Active"
        static let activate = "Activate"
        static let edit = "Edit"
        static let done = "Done"
        static let manageSSH = "Manage SSH"
        static let manageProfile = "Manage Profile"
        static let openSettings = "Open Settings"
        static let settings = "Settings"
        static let statusBarDisplay = "Menu Bar Display"
        static let statusBarDisplayDescription = "Choose what appears beside the Switzy menu bar icon."
        static let preview = "PREVIEW"
        static let showBesideIcon = "SHOW BESIDE ICON"
        static let noAdditionalText = "No additional text"
        static let iconOnly = "Icon Only"
        static let activeProfile = "Active Profile"
        static let profileCountOption = "Profile Count"
        static let sshKeyCountOption = "SSH Key Count"
        static let quitSwitzy = "Quit Switzy"
        static let scanningSSH = "Scanning SSH keys..."
        static let deleteProfileTitle = "Delete Profile?"
        static let deleteProfileMessage = "This will remove the profile from Switzy."
        static let deleteSSHTitle = "Delete SSH Key?"
        static let keyGeneratedSuccessfully = "Key generated successfully"
        static let publicKeyCopied = "Public key copied!"
        static let noPublicKey = "No public key found."
        static let publicKey = "Public Key"
        static let fingerprint = "Fingerprint"
        static let fingerprintHeading = "FINGERPRINT"
        static let createdHeading = "CREATED"
        static let expiresHeading = "EXPIRES"
        static let notAvailable = "N/A"
        static let sshKeys = "SSH Keys"
        static let generateKey = "Generate Key"
        static let selectYourKey = "Select your key"
        static let identity = "IDENTITY"
        static let sshKey = "SSH KEY"
        static let type = "Type"
        static let email = "Email"
        static let file = "File"
        static let passphrase = "Passphrase"
        static let optional = "Optional"
        static let checkForUpdates = "Check for Updates..."
        static let updateAvailable = "New update available!"
        static let updateNow = "Update Now"
        static let aboutApp = "About \(appName)"
        static let version = "Version"
        static let build = "Build"
        static let aboutDescription = "Seamlessly switch Git identities from your\nmacOS Menu Bar."
        static let collaborationMessage = "Open for collaboration and contribution."
        static let githubRepository = "GitHub Repository"
        static let defaultVersion = "0.1.0"
        static let defaultBuild = "1"
        static let defaultCopyright = "Created by Yefga © 2026"

        static let github = "GitHub"
        static let gitlab = "GitLab"
        static let bitbucket = "Bitbucket"
        static let azureDevOps = "Azure DevOps"
        static let azure = "Azure"
        static let other = "Other"
        static let git = "Git"

        static func profileIdentity(userName: String, email: String) -> String {
            "\(userName) · \(email)"
        }

        static func itemCount(title: String, count: Int) -> String {
            "\(title) (\(count))"
        }

        static func profileCount(_ count: Int) -> String {
            "\(count) profiles"
        }

        static func sshKeyCount(_ count: Int) -> String {
            "\(count) keys"
        }

        static func gitHost(_ provider: String) -> String {
            "Git host: \(provider)"
        }

        static func versionDescription(version: String, build: String) -> String {
            "\(Constants.Strings.version) \(version) (\(Constants.Strings.build) \(build))"
        }

        static func deleteSSHKeyMessage(filename: String) -> String {
            "Are you sure you want to delete '\(filename)'? This will permanently remove the key file from your ~/.ssh directory."
        }

        static func copied(_ label: String) -> String {
            "\(label) copied!"
        }

        static func deleted(_ filename: String) -> String {
            "Deleted \(filename)"
        }

        static func settingOption(title: String, value: String) -> String {
            "\(title): \(value)"
        }

        static func profilePlatform(name: String, platform: String) -> String {
            "\(name) # \(platform)"
        }
    }

    // MARK: - Form Placeholders

    enum Placeholder {
        static let profileName = "Profile Name"
        static let gitUserName = "Git User Name"
        static let gitEmail = "Git Email"
        static let email = "your@email.com"
        static let filename = "id_ed25519_new"
        static let passphrase = "Optional"
    }

    // MARK: - Form Labels

    enum Label {
        static let profileName = "Profile Name"
        static let gitUserName = "Git User Name"
        static let gitEmail = "Git Email"
        static let gitHost = "Git Host"
        static let sshKey = "SSH KEY"
        static let profiles = "Profiles"
        static let profile = "Profile"
        static let ssh = "SSH"
    }

    // MARK: - Animation

    enum Animation {
        static let defaultDuration: Double = 0.15
        static let formDuration: Double = 0.2
        static let statusDuration: UInt64 = 2_500_000_000
    }

    // MARK: - Persistence

    enum Persistence {
        static let profilesKey = "com.yefga.switzy.profiles"
        static let statusBarDisplayModeKey = "com.yefga.switzy.statusBarDisplayMode"
    }

    enum StatusBarDisplayMode: String, CaseIterable, Identifiable {
        case iconOnly
        case activeProfile
        case profileCount
        case sshKeyCount

        var id: String { rawValue }

        var title: String {
            switch self {
            case .iconOnly: return Constants.Strings.iconOnly
            case .activeProfile: return Constants.Strings.activeProfile
            case .profileCount: return Constants.Strings.profileCountOption
            case .sshKeyCount: return Constants.Strings.sshKeyCountOption
            }
        }

        var systemImage: String {
            switch self {
            case .iconOnly: return Constants.SystemImage.appIcon
            case .activeProfile: return Constants.SystemImage.profile
            case .profileCount: return Constants.SystemImage.profileManage
            case .sshKeyCount: return Constants.SystemImage.sshManage
            }
        }
    }

    // MARK: - Management Tab

    enum ManagementTab: CaseIterable, Identifiable, Hashable {
        case profile
        case ssh
        case settings

        var id: Self { self }

        var title: String {
            switch self {
            case .profile: return Constants.Label.profile
            case .ssh: return Constants.Label.ssh
            case .settings: return Constants.Strings.settings
            }
        }
    }
}

extension GitProvider {
    var displayName: String {
        switch self {
        case .github: return Constants.Strings.github
        case .gitlab: return Constants.Strings.gitlab
        case .bitbucket: return Constants.Strings.bitbucket
        case .azureDevOps: return Constants.Strings.azureDevOps
        case .other: return Constants.Strings.other
        }
    }

    var badgeLabel: String {
        switch self {
        case .github: return Constants.Strings.github
        case .gitlab: return Constants.Strings.gitlab
        case .bitbucket: return Constants.Strings.bitbucket
        case .azureDevOps: return Constants.Strings.azure
        case .other: return Constants.Strings.git
        }
    }

    var statusBarName: String {
        self == .other ? Constants.Strings.git : displayName
    }
}
