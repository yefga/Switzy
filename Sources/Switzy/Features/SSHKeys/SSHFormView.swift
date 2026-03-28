//
//  SSHFormView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct SSHFormView: View {
    @State private var selectedKeyType: SSHKeyType = .ed25519
    @State private var email: String = ""
    @State private var filename: String = ""
    @State private var passphrase: String = ""
    @State private var showNewKeyForm: Bool = false
    @State private var generateTask: Task<Void, Never>?
    @State private var errorMessage: String?
    @State private var statusMessage: String?
    @State private var expandedKeyIDs: Set<UUID> = []

    @StateObject private var viewModel = SSHKeysViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            formHeader
            Divider().opacity(0.2)

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxxl) {
                    if showNewKeyForm {
                        newKeyForm
                    }
                    existingKeysList
                }
                .padding(Constants.Spacing.xxxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            viewModel.loadKeys()
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var formHeader: some View {
        HStack {
            Text(Constants.Strings.sshKeys)
                .font(.system(
                    size: Constants.FontSize.headline,
                    weight: .semibold
                ))

            Text("\(viewModel.keys.count) keys")
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                    showNewKeyForm.toggle()
                }
            } label: {
                Image(systemName: showNewKeyForm ? Constants.SystemImage.minus : Constants.SystemImage.plus)
                    .font(.system(size: Constants.FontSize.body))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Spacing.xxxxl)
        .padding(.vertical, Constants.Spacing.xxl)
    }

    // MARK: - New Key Form

    @ViewBuilder
    private var newKeyForm: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxl) {
            keyTypeSelector

            formField(
                label: Constants.Strings.email,
                text: $email,
                placeholder: Constants.Placeholder.email
            )

            formField(
                label: Constants.Strings.file,
                text: $filename,
                placeholder: Constants.Placeholder.filename
            )

            formField(
                label: Constants.Strings.passphrase,
                text: $passphrase,
                placeholder: Constants.Placeholder.passphrase
            )

            generateButton

            statusMessages
        }
        .padding(Constants.Spacing.xxxl)
        .glassBackground(
            cornerRadius: Constants.Layout.cornerRadius,
            material: .hudWindow,
            opacity: 0.5
        )
    }

    @ViewBuilder
    private var keyTypeSelector: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(Constants.Strings.type)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.tertiary)

            HStack(spacing: Constants.Spacing.lg) {
                ForEach(
                    [SSHKeyType.ed25519, SSHKeyType.rsa],
                    id: \.self
                ) { keyType in
                    keyTypePill(keyType)
                }
            }
        }
    }

    @ViewBuilder
    private func keyTypePill(_ keyType: SSHKeyType) -> some View {
        Button {
            selectedKeyType = keyType
        } label: {
            Text(keyType.displayName)
                .font(.system(
                    size: Constants.FontSize.caption,
                    weight: .semibold
                ))
                .padding(.horizontal, Constants.Spacing.xxl)
                .padding(.vertical, Constants.Spacing.md)
                .background(
                    selectedKeyType == keyType
                        ? Color.green
                        : Color.white.opacity(0.1)
                )
                .foregroundStyle(
                    selectedKeyType == keyType ? .white : .secondary
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func formField(
        label: String,
        text: Binding<String>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(label)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.tertiary)

            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: Constants.FontSize.body))
        }
    }

    @ViewBuilder
    private var generateButton: some View {
        Button {
            generateKey()
        } label: {
            Text(Constants.Strings.generateKey)
                .font(.system(
                    size: Constants.FontSize.body,
                    weight: .semibold
                ))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.lg)
        }
        .buttonStyle(.borderedProminent)
        .disabled(email.isEmpty || filename.isEmpty)
    }

    @ViewBuilder
    private var statusMessages: some View {
        if let error = errorMessage {
            Text(error)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.red)
        }

        if let status = statusMessage {
            Text(status)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.green)
        }
    }

    // MARK: - Existing Keys List

    @ViewBuilder
    private var existingKeysList: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxl) {
            ForEach(viewModel.keys) { key in
                existingKeyRow(key: key)
            }
        }
    }

    @ViewBuilder
    private func existingKeyRow(key: SSHKeyInfo) -> some View {
        let isExpanded = expandedKeyIDs.contains(key.id)
        
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    HStack(spacing: Constants.Spacing.lg) {
                        Text(key.filename)
                            .font(.system(
                                size: Constants.FontSize.body,
                                weight: .semibold
                            ))

                        Text(key.keyType.displayName)
                            .font(.system(size: Constants.FontSize.caption2))
                            .padding(.horizontal, Constants.Spacing.md)
                            .padding(.vertical, Constants.Spacing.xs)
                            .background(Color.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }

                    if let comment = key.comment {
                        Text(comment)
                            .font(.system(size: Constants.FontSize.caption))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if isExpanded {
                            expandedKeyIDs.remove(key.id)
                        } else {
                            expandedKeyIDs.insert(key.id)
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundStyle(.secondary)
                        .padding(Constants.Spacing.sm)
                }
                .buttonStyle(.plain)
            }
            .padding(Constants.Spacing.xxl)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if isExpanded {
                        expandedKeyIDs.remove(key.id)
                    } else {
                        expandedKeyIDs.insert(key.id)
                    }
                }
            }
            
            if isExpanded {
                Divider().opacity(0.1)
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xl) {
                    if let fingerprint = key.fingerprint {
                        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                            Text("FINGERPRINT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.tertiary)
                            
                            HStack {
                                Text(fingerprint)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                                Button {
                                    copyToClipboard(fingerprint, label: "Fingerprint")
                                } label: {
                                    Image(systemName: Constants.SystemImage.copy)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.purple)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(Constants.Spacing.lg)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    
                    HStack(spacing: Constants.Spacing.xxxl) {
                        dateInfo(label: "CREATED", date: key.createdAt)
                        dateInfo(label: "EXPIRES", date: key.expiresAt)
                        
                        Spacer()
                        
                        HStack(spacing: Constants.Spacing.lg) {
                            Button {
                                viewModel.copyPublicKey(key)
                            } label: {
                                Label("Public Key", systemImage: Constants.SystemImage.copy)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .buttonStyle(.bordered)
                            
                            Button {
                                viewModel.confirmDelete(key: key)
                            } label: {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                            .padding(Constants.Spacing.md)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .padding(Constants.Spacing.xxl)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .glassBackground(
            cornerRadius: Constants.Layout.cornerRadiusSmall,
            material: .hudWindow,
            opacity: 0.4
        )
    }
    
    @ViewBuilder
    private func dateInfo(label: String, date: Date?) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.tertiary)
            
            if let date = date {
                Text(date, style: .date)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            } else {
                Text("N/A")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Logic

    private func generateKey() {
        let service = SSHKeyService()
        errorMessage = nil
        statusMessage = nil

        generateTask = Task {
            do {
                _ = try await service.generateKey(
                    type: selectedKeyType,
                    email: email,
                    filename: filename,
                    passphrase: passphrase
                )
                statusMessage = "Key generated successfully"
                viewModel.loadKeys()
                resetForm()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func resetForm() {
        email = ""
        filename = ""
        passphrase = ""
    }
    
    private func copyToClipboard(_ text: String, label: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        statusMessage = "\(label) copied!"
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            statusMessage = nil
        }
    }
}
