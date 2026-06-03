//
//  ProfileRowView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct ProfileRowView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject var viewModel: ProfileFormViewModel
    let profile: GitProfile
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                HStack(spacing: Constants.Spacing.lg) {
                    Text(profile.name)
                        .font(.system(
                            size: Constants.FontSize.body,
                            weight: .semibold
                        ))
                    
                    if profile.isActive {
                        Text("ACTIVE")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
                            )
                            .clipShape(Capsule())
                    }
                }
                
                Text("\(profile.userName) · \(profile.userEmail)")
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundStyle(.secondary)
                
                if let ssh = profile.sshKeyPath {
                    HStack(spacing: 4) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 10))
                        Text((ssh as NSString).lastPathComponent)
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundStyle(.tertiary)
                }
            }
            Spacer()

            if !viewModel.showForm || !isSelected {
                HStack(spacing: Constants.Spacing.lg) {
                    if !profile.isActive {
                        Button {
                            Task {
                                await appModel.switchProfile(to: profile)
                            }
                        } label: {
                            Text("Activate")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        appModel.selectedProfileID = profile.id
                        withAnimation {
                            viewModel.showForm = true
                            viewModel.isCreatingNewProfile = false
                            viewModel.loadProfile(currentProfile: appModel.selectedProfile)
                        }
                    } label: {
                        Text("Edit")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            } else if isSelected && viewModel.showForm && !viewModel.isCreatingNewProfile {
                Button {
                    withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                        viewModel.showForm = false
                    }
                } label: {
                    Text("Done")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            Button {
                appModel.deleteProfile(id: profile.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundStyle(.red.opacity(0.6))
            }
            .buttonStyle(.plain)
            .padding(.leading, 12)
        }
        .padding(Constants.Spacing.xxl)
        .glassBackground(
            cornerRadius: Constants.Layout.cornerRadiusSmall,
            material: .hudWindow,
            opacity: 0.4
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadiusSmall)
                .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
