//
//  ShellService.swift
//  Switzy
//
//  Created by Yefga on 26/03/2026
//

import Foundation

enum ShellError: LocalizedError {
    case executionFailed(String)
    case commandNotFound(String)

    var errorDescription: String? {
        switch self {
        case .executionFailed(let message):
            return "Shell execution failed: \(message)"
        case .commandNotFound(let command):
            return "Command not found: \(command)"
        }
    }
}

actor ShellService {

    /// Execute a shell command and return trimmed stdout.
    func run(_ command: String, arguments: [String] = []) async throws -> String {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard process.terminationStatus == 0 else {
            throw ShellError.executionFailed(errorOutput.isEmpty ? "Exit code \(process.terminationStatus)" : errorOutput)
        }

        return output
    }

    /// Execute a shell command using /bin/sh -c for piped/complex commands.
    func runShell(_ command: String) async throws -> String {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard process.terminationStatus == 0 else {
            throw ShellError.executionFailed(errorOutput.isEmpty ? "Exit code \(process.terminationStatus)" : errorOutput)
        }

        return output
    }
}
