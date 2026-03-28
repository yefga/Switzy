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
            Image(systemName: "key.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundStyle(.white)
                .padding(.top, 40)
            
            // App Name
            Text(Constants.Strings.appName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 16)
            
            // Subtitle
            Text("SSH and Git Profile Manager")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .fixedSize(horizontal: false, vertical: true)
            
            // Version Info
            Text("Version 1.0.0 (Build 1)")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
                .padding(.top, 12)
            
            // Copyright
            Text("Created by Yefga © 2026")
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
        .frame(width: 320)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func closeWindow() {
        NSApp.keyWindow?.close()
    }
}
