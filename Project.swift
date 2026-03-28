import ProjectDescription

// MARK: - Project

let project = Project(
    name: "Switzy",
    options: .options(
        automaticSchemesOptions: .disabled,
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    ),
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
            ]),
            sources: ["Sources/Switzy/**"],
            resources: ["Resources/**"],
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
