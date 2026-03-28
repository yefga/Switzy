//
//  SSHKeyRowView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct SSHKeyRowView: View {
    let key: SSHKeyInfo
    @ObservedObject var viewModel: SSHKeysViewModel
    @Binding var expandedKeyIDs: Set<UUID>

    var body: some View {
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
                                        .foregroundStyle(.blue)
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
                                viewModel.copyPublicKey(key) {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(
                                        $0.trimmingCharacters(in: .whitespacesAndNewlines),
                                        forType: .string
                                    )
                                }
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
    
    private func copyToClipboard(_ text: String, label: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        viewModel.statusMessage = "\(label) copied!"
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if !Task.isCancelled {
                viewModel.statusMessage = nil
            }
        }
    }
}
