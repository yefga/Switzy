# Switzy for macOS

**Effortless Git identity management for macOS**

Switzy is a lightweight menu bar application for developers who use multiple Git identities. It switches Git profiles, user names, emails, signing keys, and SSH keys from a native macOS interface.

![Switzy menu bar](demo.png)

## Features

- Instant switching between work, personal, and project-specific Git profiles.
- SSH key generation, import, deletion, and agent management.
- Native SwiftUI/AppKit menu bar experience.
- Automatic global Git configuration updates.
- Sparkle update support for signed releases.

## Installation

### Homebrew

```bash
brew tap yefga/tap
brew install --cask switzy
```

### Manual

Download the latest `.dmg` from the [Releases](https://github.com/yefga/Switzy/releases) page, open it, and drag `Switzy.app` into `Applications`.

Official releases are notarized by Apple. Local development builds are not notarized unless you sign and notarize them yourself.

## Development

Switzy for macOS is built with SwiftUI/AppKit and managed with Tuist.

```bash
cd macOS
tuist generate
tuist build --configuration Debug
```

Open `macOS/Switzy.xcworkspace` and run the `Switzy` scheme for local development.

The target compiles the shared core files from `../Shared/Sources/SwitzyCore` directly into the macOS app target.

## Release Metadata

- `appcast.xml` is the macOS source copy of the Sparkle feed.
- `../appcast.xml` remains the compatibility feed URL used by existing installed clients.
- `Homebrew/switzy.rb` is a local cask copy only. The external Homebrew tap is updated separately when version, SHA, or URL metadata changes.
- `scripts/build_dmg.sh` builds the macOS app and writes DMGs to `../release`.
