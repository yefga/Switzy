//
//  ManagementSettingsView.swift
//  Switzy
//
//  Created by Yefga on 02/08/2026.
//

import SwiftUI

struct ManagementSettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxxxl) {
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                Text(Constants.Strings.statusBarDisplay)
                    .font(.system(size: Constants.FontSize.title, weight: .semibold))

                Text(Constants.Strings.statusBarDisplayDescription)
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                sectionTitle(Constants.Strings.preview)
                statusBarPreview
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                sectionTitle(Constants.Strings.showBesideIcon)
                displayOptions
            }

            Spacer()
        }
        .padding(Constants.Spacing.xxxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            appModel.refreshSSHKeyCount()
        }
    }

    private var displayOptions: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Constants.Spacing.xxl),
                GridItem(.flexible(), spacing: Constants.Spacing.xxl)
            ],
            spacing: Constants.Spacing.xxl
        ) {
            ForEach(Constants.StatusBarDisplayMode.allCases) { mode in
                statusBarOption(mode)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: Constants.FontSize.caption2, weight: .semibold))
            .foregroundStyle(.tertiary)
    }

    private var statusBarPreview: some View {
        HStack(spacing: Constants.Spacing.lg) {
            Image("img_status_bar")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(
                    width: Constants.Layout.statusBarIconSize,
                    height: Constants.Layout.statusBarIconSize
                )

            if let title = appModel.statusBarTitle {
                Text(title)
                    .font(.system(size: Constants.FontSize.body, weight: .semibold))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, Constants.Spacing.xxxl)
        .padding(.vertical, Constants.Spacing.xxxxl)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(previewShape)
        .overlay(
            previewShape.strokeBorder(
                Color(nsColor: .separatorColor),
                lineWidth: Constants.Layout.borderWidth
            )
        )
    }

    private var previewShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: Constants.Layout.cornerRadiusSmall,
            style: .continuous
        )
    }

    private func statusBarOption(_ mode: Constants.StatusBarDisplayMode) -> some View {
        let isSelected = appModel.statusBarDisplayMode == mode

        return Button {
            appModel.statusBarDisplayMode = mode
        } label: {
            VStack(alignment: .leading, spacing: Constants.Spacing.xl) {
                optionHeader(mode: mode, isSelected: isSelected)
                optionDescription(mode)
            }
            .padding(Constants.Spacing.xxl)
            .frame(maxWidth: .infinity, minHeight: 94, alignment: .leading)
            .background(optionBackground(isSelected: isSelected))
            .clipShape(previewShape)
            .overlay(optionBorder(isSelected: isSelected))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func optionHeader(
        mode: Constants.StatusBarDisplayMode,
        isSelected: Bool
    ) -> some View {
        HStack {
            Image(systemName: mode.systemImage)
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(
                        isSelected
                            ? Color.accentColor.opacity(0.14)
                            : Color.primary.opacity(0.06)
                    )
                )

            Spacer()

            Image(systemName: isSelected
                ? Constants.SystemImage.checkmark
                : Constants.SystemImage.circle
            )
            .font(.system(size: Constants.FontSize.callout))
            .foregroundStyle(
                isSelected
                    ? Color.accentColor
                    : Color(nsColor: .tertiaryLabelColor)
            )
        }
    }

    private func optionDescription(
        _ mode: Constants.StatusBarDisplayMode
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            Text(mode.title)
                .font(.system(size: Constants.FontSize.body, weight: .semibold))

            Text(appModel.statusBarValue(for: mode))
                .font(.system(size: Constants.FontSize.caption))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private func optionBackground(isSelected: Bool) -> Color {
        isSelected
            ? Color.accentColor.opacity(0.10)
            : Color(nsColor: .controlBackgroundColor)
    }

    private func optionBorder(isSelected: Bool) -> some View {
        previewShape.strokeBorder(
            isSelected
                ? Color.accentColor.opacity(0.65)
                : Color(nsColor: .separatorColor),
            lineWidth: isSelected ? 1 : Constants.Layout.borderWidth
        )
    }
}
