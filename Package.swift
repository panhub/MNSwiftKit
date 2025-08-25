// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MNSwiftKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MNSwiftKit",
            targets: [
                "MNSwiftKit"
            ]
        ),
        .library(
            name: "MNSwiftKitBase",
            targets: [
                "Base"
            ]
        ),
        .library(
            name: "MNSwiftKitToast",
            targets: [
                "Toast"
            ]
        ),
        .library(
            name: "MNSwiftKitSlider",
            targets: [
                "Slider"
            ]
        ),
        .library(
            name: "MNSwiftKitUtility",
            targets: [
                "Utility"
            ]
        ),
        .library(
            name: "MNSwiftKitPlayer",
            targets: [
                "Player"
            ]
        ),
        .library(
            name: "MNSwiftKitSpliter",
            targets: [
                "Spliter"
            ]
        ),
        .library(
            name: "MNSwiftKitLayout",
            targets: [
                "Layout"
            ]
        ),
        .library(
            name: "MNSwiftKitRefresh",
            targets: [
                "Refresh"
            ]
        ),
        .library(
            name: "MNSwiftKitRequest",
            targets: [
                "Request"
            ]
        ),
        .library(
            name: "MNSwiftKitExporter",
            targets: [
                "Exporter"
            ]
        ),
        .library(
            name: "MNSwiftKitPurchase",
            targets: [
                "Purchase"
            ]
        ),
        .library(
            name: "MNSwiftKitDatabase",
            targets: [
                "Database"
            ]
        ),
        .library(
            name: "MNSwiftKitDefinition",
            targets: [
                "Definition"
            ]
        ),
        .library(
            name: "MNSwiftKitExtension",
            targets: [
                "Extension"
            ]
        ),
        .library(
            name: "MNSwiftKitEmptyView",
            targets: [
                "EmptyView"
            ]
        ),
        .library(
            name: "MNSwiftKitNetworking",
            targets: [
                "Networking"
            ]
        ),
        .library(
            name: "MNSwiftKitAssetPicker",
            targets: [
                "AssetPicker"
            ]
        ),
        .library(
            name: "MNSwiftKitComponents",
            targets: [
                "Components"
            ]
        ),
        .library(
            name: "MNSwiftKitTransitioning",
            targets: [
                "Transitioning"
            ]
        ),
        .library(
            name: "MNSwiftKitAnimatedImage",
            targets: [
                "AnimatedImage"
            ]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MNSwiftKit",
            dependencies: [
                "Base","Toast","Utility","Slider","Player","Spliter","Layout","Refresh","Request","Exporter","Purchase","Database","Definition","Extension","EmptyView","Networking","AssetPicker","Components","Transitioning","AnimatedImage"
            ],
            path: "MNSwiftKit/Full",
            swiftSettings: [
                // 控制并发检查严格度
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
                // 更宽松的设置
                //.unsafeFlags(["-Xfrontend", "-strict-concurrency=targeted"])
            ]
        ),
        .target(
            name: "Base",
            dependencies: [
                "Toast","Layout","Refresh","Request","Definition","EmptyView","Transitioning"
            ],
            path: "MNSwiftKit/Base",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("WebKit")
            ]
        ),
        .target(
            name: "Toast",
            path: "MNSwiftKit/Toast",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Utility",
            path: "MNSwiftKit/Utility",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Photos"),
                .linkedFramework("AdSupport"),
                .linkedFramework("AppTrackingTransparency"),
                .linkedFramework("AuthenticationServices")
            ]
        ),
        .target(
            name: "Slider",
            path: "MNSwiftKit/Slider",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Player",
            path: "MNSwiftKit/Player",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("AudioToolbox")
            ]
        ),
        .target(
            name: "Spliter",
            path: "MNSwiftKit/Spliter",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Layout",
            path: "MNSwiftKit/Layout",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Refresh",
            path: "MNSwiftKit/Refresh",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Request",
            dependencies: ["Networking"],
            path: "MNSwiftKit/Request",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Exporter",
            path: "MNSwiftKit/Exporter",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Purchase",
            path: "MNSwiftKit/Purchase",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("StoreKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Database",
            path: "MNSwiftKit/Database",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreGraphics"),
                .linkedLibrary("sqlite3")
            ]
        ),
        .target(
            name: "Definition",
            path: "MNSwiftKit/Definition",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Extension",
            dependencies: ["AnimatedImage"],
            path: "MNSwiftKit/Extension",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "EmptyView",
            path: "MNSwiftKit/EmptyView",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Networking",
            path: "MNSwiftKit/Networking",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("Security"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "AssetPicker",
            dependencies: [
                "Toast","Slider","Player","Layout","Refresh","Exporter","Definition","EmptyView","AnimatedImage"
            ],
            path: "MNSwiftKit/AssetPicker",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Photos"),
                .linkedFramework("PhotosUI"),
                .linkedFramework("Foundation"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Components",
            dependencies: [
                "Layout","Extension"
            ],
            path: "MNSwiftKit/Components",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("ImageIO"),
                .linkedFramework("Foundation"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreServices"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        ),
        .target(
            name: "Transitioning",
            path: "MNSwiftKit/Transitioning",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "AnimatedImage",
            path: "MNSwiftKit/AnimatedImage",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("ImageIO"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreServices"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        )
        //.testTarget(name: "testTests", dependencies: ["test"])
    ]
)
