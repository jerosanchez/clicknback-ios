import ProjectDescription

let project = Project(
    name: "ClickNBack",
    targets: [
        .target(
            name: "ClickNBack",
            destinations: .iOS,
            product: .app,
            bundleId: "com.jerosanchez.clicknback",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleLocalizations": ["en", "es"],
                "UILaunchScreen": .dictionary([:]),
            ]),
            sources: "ClickNBack/**",
            resources: ["ClickNBack/Assets.xcassets/**", "ClickNBack/**/*.xcstrings"],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_STRICT_CONCURRENCY_ENABLED": "COMPLETE",
                    "DEVELOPMENT_LANGUAGE": "en",
                ]
            )
        ),
        .target(
            name: "ClickNBackTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jerosanchez.clicknback.tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["ClickNBackTests/Unit/**", "ClickNBackTests/Support/**"],
            dependencies: [
                .target(name: "ClickNBack"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_STRICT_CONCURRENCY_ENABLED": "COMPLETE",
                ]
            )
        ),
        .target(
            name: "ClickNBackIntegrationTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jerosanchez.clicknback.integration-tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["ClickNBackTests/Integration/**", "ClickNBackTests/Support/**"],
            dependencies: [
                .target(name: "ClickNBack"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_STRICT_CONCURRENCY_ENABLED": "COMPLETE",
                ]
            )
        ),
        .target(
            name: "ClickNBackUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.jerosanchez.clicknback.ui-tests",
            deploymentTargets: .iOS("26.0"),
            sources: "ClickNBackUITests/**",
            dependencies: [
                .target(name: "ClickNBack"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_STRICT_CONCURRENCY_ENABLED": "COMPLETE",
                ]
            )
        ),
    ],
    schemes: [
        .scheme(
            name: "ClickNBack-Dev",
            buildAction: .buildAction(targets: ["ClickNBack", "ClickNBackTests", "ClickNBackIntegrationTests", "ClickNBackUITests"]),
            testAction: .targets(
                [
                    .testableTarget(target: .target("ClickNBackTests")),
                    .testableTarget(target: .target("ClickNBackIntegrationTests")),
                ],
                options: .options(coverage: true, codeCoverageTargets: [.target("ClickNBack")])
            )
        ),
        .scheme(
            name: "ClickNBack-Prod",
            buildAction: .buildAction(targets: ["ClickNBack"]),
            testAction: .targets(["ClickNBackTests", "ClickNBackUITests"])
        ),
    ]
)
