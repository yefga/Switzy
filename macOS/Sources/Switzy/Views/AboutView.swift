//
//  AboutView.swift
//  
//
//  Created by Yefga on 27/03/26.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            // App Icon
            Image(systemName: Constants.SystemImage.key)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.FontSize.aboutIcon, height: Constants.FontSize.aboutIcon)
                .foregroundStyle(.white)
                .padding(.top, Constants.Spacing.xxxxl * 2)
            
            // App Name
            Text(Constants.Strings.appName)
                .font(.system(size: Constants.FontSize.aboutTitle, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, Constants.Spacing.xxxl)
            
            // Subtitle
            Text(Constants.Strings.appSubtitle)
                .font(.system(size: Constants.FontSize.headline, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.top, Constants.Spacing.lg)
                .fixedSize(horizontal: false, vertical: true)
            
            // Version Info
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            
            Text("\(Constants.Strings.version) \(version) (Build \(build))")
                .font(.system(size: Constants.FontSize.callout))
                .foregroundStyle(.secondary.opacity(0.8))
                .padding(.top, Constants.Spacing.xxl)
            
            // Copyright
            let copyright = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "Created by Yefga © 2026"
            
            Text(copyright)
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
            
            Divider()
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            
            // Description
            VStack(spacing: 12) {
                Text("Seamlessly switch Git identities from your\nmacOS Menu Bar.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Open for collaboration and contribution.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Link("GitHub Repository", destination: URL(string: "https://github.com/yefga/Switzy")!)
                    .font(.system(size: 13))
                    .foregroundStyle(.blue)
            }
            .padding(.bottom, 40)
        }
        .frame(width: Constants.Layout.aboutWidth)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func closeWindow() {
        NSApp.keyWindow?.close()
    }
}
