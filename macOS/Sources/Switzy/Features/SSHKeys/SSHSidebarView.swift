//
//  SSHSidebarView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct SSHSidebarView: View {
    @StateObject private var viewModel = SSHKeysViewModel()

    var body: some View {
        SidebarListView(
            title: Constants.Strings.sshKeys,
            subtitle: "\(viewModel.keys.count) keys",
            items: viewModel.keys
        ) { key in
            sshKeyRow(key: key)
        }
        .onAppear {
            viewModel.loadKeys()
        }
    }

    @ViewBuilder
    private func sshKeyRow(key: SSHKeyInfo) -> some View {
        HStack(spacing: Constants.Spacing.lg) {
            VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                Text(key.filename)
                    .font(.system(
                        size: Constants.FontSize.caption,
                        weight: .medium,
                        design: .monospaced
                    ))
                    .lineLimit(1)

                HStack(spacing: Constants.Spacing.sm) {
                    Text(key.keyType.displayName)
                        .font(.system(size: Constants.FontSize.caption2))
                        .padding(.horizontal, Constants.Spacing.sm)
                        .padding(.vertical, Constants.Spacing.xxs)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())

                    if let comment = key.comment {
                        Text(comment)
                            .font(.system(size: Constants.FontSize.caption2))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, Constants.Spacing.lg)
        .padding(.vertical, Constants.Spacing.md)
    }
}
