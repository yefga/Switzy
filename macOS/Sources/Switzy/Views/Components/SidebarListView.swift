//
//  SidebarListView.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct SidebarListView<Item: Identifiable, Row: View>: View {
    let title: String
    let subtitle: String
    let items: [Item]
    @ViewBuilder let rowContent: (Item) -> Row

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text(title)
                        .font(.system(
                            size: Constants.FontSize.caption,
                            weight: .medium
                        ))
                        .foregroundStyle(.secondary)

                    Text(subtitle)
                        .font(.system(size: Constants.FontSize.caption2))
                        .foregroundStyle(.tertiary)
                }

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.xxl)
            .padding(.top, Constants.Spacing.lg)

            ScrollView {
                LazyVStack(spacing: Constants.Spacing.xs) {
                    ForEach(items) { item in
                        rowContent(item)
                    }
                }
                .padding(.horizontal, Constants.Spacing.lg)
            }
        }
    }
}
