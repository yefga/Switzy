//
//  GlassBackground.swift
//  
//
//  Created by Yefga on 28/03/26.
//

import SwiftUI

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat
    var material: NSVisualEffectView.Material
    var opacity: Double

    init(
        cornerRadius: CGFloat = Constants.Layout.cornerRadius,
        material: NSVisualEffectView.Material = .hudWindow,
        opacity: Double = 0.7
    ) {
        self.cornerRadius = cornerRadius
        self.material = material
        self.opacity = opacity
    }

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    VisualEffectView(
                        material: material,
                        blendingMode: .behindWindow,
                        state: .active
                    )

                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                )
                .opacity(opacity)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: Constants.Layout.borderWidth
                )
            )
    }
}

extension View {
    func glassBackground(
        cornerRadius: CGFloat = Constants.Layout.cornerRadius,
        material: NSVisualEffectView.Material = .hudWindow,
        opacity: Double = 0.7
    ) -> some View {
        modifier(GlassBackground(
            cornerRadius: cornerRadius,
            material: material,
            opacity: opacity
        ))
    }
}
