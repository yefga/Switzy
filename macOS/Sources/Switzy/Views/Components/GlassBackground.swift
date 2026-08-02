//
//  GlassBackground.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct PanelBackground: ViewModifier {
    var cornerRadius: CGFloat

    init(
        cornerRadius: CGFloat = Constants.Layout.cornerRadius
    ) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(
                Color(nsColor: .controlBackgroundColor)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .strokeBorder(
                    Color(nsColor: .separatorColor),
                    lineWidth: Constants.Layout.borderWidth
                )
            )
    }
}

extension View {
    func panelBackground(
        cornerRadius: CGFloat = Constants.Layout.cornerRadius
    ) -> some View {
        modifier(PanelBackground(
            cornerRadius: cornerRadius
        ))
    }
}
