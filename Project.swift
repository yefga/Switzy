import ProjectDescription

// MARK: - Project

let project = Project(
    name: "Switzy",
    options: .options(
        automaticSchemesOptions: .disabled,
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    ),
    packages: [
        .remote(url: "https://github.com/sparkle-project/Sparkle", requirement: .upToNextMajor(from: "2.6.0"))
    ],
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Project.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Project.xcconfig"),
        ]
    ),
    targets: [
        .target(
            name: "Switzy",
            destinations: .macOS,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "$(PROJECT_NAME)",
                "CFBundleName": "$(PROJECT_NAME)",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "LSUIElement": true,
                "NSHumanReadableCopyright": "Created by $(PROJECT_CREATOR)",
                "SUFeedURL": "https://raw.githubusercontent.com/yefga/Switzy/main/appcast.xml",
                "SUPublicEDKey": "YOUR_PUBLIC_ED_KEY",
                "SUEnableAutomaticChecks": true
            ]),
            sources: ["Sources/Switzy/**"],
            resources: ["Resources/**"],
            dependencies: [
                .package(product: "Sparkle")
            ],
            settings: .settings(
                base: [
                    "GENERATE_INFOPLIST_FILE": "YES",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                ]
            )
        ),
    ],
    schemes: [
        .scheme(
            name: "Switzy",
            shared: true,
            buildAction: .buildAction(targets: ["Switzy"]),
            runAction: .runAction(
                configuration: "Debug",
                executable: "Switzy"
            ),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(
                configuration: "Release",
                executable: "Switzy"
            ),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
    ]
)
