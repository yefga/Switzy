//
//  SSHFormView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct SSHFormView: View {
    @EnvironmentObject private var managementViewModel: ManagementViewModel
    @EnvironmentObject private var viewModel: SSHKeysViewModel
    @StateObject private var formViewModel = SSHFormViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxxl) {
                    if managementViewModel.showNewSSHKeyForm {
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
        .onExitCommand {
            if managementViewModel.showNewSSHKeyForm {
                withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                    managementViewModel.showNewSSHKeyForm = false
                }
            }
        }
    }

    // MARK: - New Key Form

    @ViewBuilder
    private var newKeyForm: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxl) {
            keyTypeSelector

            formField(
                label: Constants.Strings.email,
                text: $formViewModel.email,
                placeholder: Constants.Placeholder.email
            )

            formField(
                label: Constants.Strings.file,
                text: $formViewModel.filename,
                placeholder: Constants.Placeholder.filename
            )

            formField(
                label: Constants.Strings.passphrase,
                text: $formViewModel.passphrase,
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
            formViewModel.selectedKeyType = keyType
        } label: {
            Text(keyType.displayName)
                .font(.system(
                    size: Constants.FontSize.caption,
                    weight: .semibold
                ))
                .padding(.horizontal, Constants.Spacing.xxl)
                .padding(.vertical, Constants.Spacing.md)
                .background(
                    ZStack {
                        if formViewModel.selectedKeyType == keyType {
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.white.opacity(0.05)
                        }
                    }
                )
                .overlay(
                    Capsule()
                        .strokeBorder(
                            formViewModel.selectedKeyType == keyType 
                                ? Color.white.opacity(0.2) 
                                : Color.white.opacity(0.1), 
                            lineWidth: 0.5
                        )
                )
                .foregroundStyle(
                    formViewModel.selectedKeyType == keyType ? .white : .secondary
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
            formViewModel.generateKey {
                viewModel.loadKeys()
                withAnimation(.easeInOut(duration: Constants.Animation.formDuration)) {
                    managementViewModel.showNewSSHKeyForm = false
                }
            }
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
        .disabled(formViewModel.email.isEmpty || formViewModel.filename.isEmpty)
    }

    @ViewBuilder
    private var statusMessages: some View {
        if let error = formViewModel.errorMessage {
            Text(error)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.red)
        }

        if let status = formViewModel.statusMessage ?? viewModel.statusMessage {
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
                SSHKeyRowView(key: key, viewModel: viewModel, expandedKeyIDs: $formViewModel.expandedKeyIDs)
            }
        }
    }
}
