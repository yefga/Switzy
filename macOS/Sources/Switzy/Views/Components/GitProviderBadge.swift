//
//  GitProviderBadge.swift
//  Switzy
//
//  Created by Yefga on 02/08/2026.
//

import SwiftUI

struct GitProviderBadge: View {
    let provider: GitProvider

    var body: some View {
        Text(provider.badgeLabel)
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.horizontal, Constants.Spacing.sm)
            .padding(.vertical, Constants.Spacing.xs)
            .background(Color.primary.opacity(0.08))
            .clipShape(Capsule())
            .help(Constants.Strings.gitHost(provider.displayName))
            .accessibilityLabel(Constants.Strings.gitHost(provider.displayName))
    }
}
