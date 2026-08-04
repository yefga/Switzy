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
            Image(Constants.AssetImage.aboutIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.FontSize.aboutIcon, height: Constants.FontSize.aboutIcon)
                .padding(.top, Constants.Spacing.xxxxl * 2)
                .tint(.white)
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
            let version: String = {
                if let val = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, !val.isEmpty {
                    return val
                }
                if let val = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, !val.isEmpty {
                    return val
                }
                return ""
            }()
            
            let build: String = {
                if let val = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String, !val.isEmpty {
                    return val
                }
                if let val = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, !val.isEmpty {
                    return val
                }
                return ""
            }()

            Text(Constants.Strings.versionDescription(version: version, build: build))
                .font(.system(size: Constants.FontSize.callout))
                .foregroundStyle(.secondary.opacity(0.8))
                .padding(.top, Constants.Spacing.xxl)
            
            // Copyright
            let copyright = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String
                ?? Constants.Strings.defaultCopyright
            
            Text(copyright)
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
            
            Divider()
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            
            // Description
            VStack(spacing: 12) {
                Text(Constants.Strings.aboutDescription + " " +  Constants.Strings.collaborationMessage)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                Link(
                    Constants.Strings.githubRepository,
                    destination: URL(string: "https://github.com/yefga/Switzy")!
                )
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
