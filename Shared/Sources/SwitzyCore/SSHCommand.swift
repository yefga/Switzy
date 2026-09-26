//
//  SSHCommand.swift
//  Switzy
//
//  Created by Yefga on 27/09/2026
//

import Foundation

/// Builds the `core.sshCommand` value that pins git to one SSH key.
enum SSHCommand {

    /// `IdentitiesOnly=yes` stops ssh offering agent keys that are not the
    /// profile's own. Without it, a key the agent holds for another profile
    /// can be accepted first and the push authenticates as that account.
    static func make(keyPath expandedPath: String) -> String {
        "ssh -o IdentitiesOnly=yes -i \(shellQuoted(expandedPath))"
    }

    /// git hands `core.sshCommand` to the shell, so a path with spaces or
    /// quotes has to be quoted to reach ssh as one argument.
    private static func shellQuoted(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
