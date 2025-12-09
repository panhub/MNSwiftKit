// swift-tools-version: 5.4
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
            name: "MNSwiftKitUtility",
            targets: [
                "Utility"
            ]
        ),
        .library(
            name: "MNSwiftKitSlider",
            targets: [
                "Slider"
            ]
        ),
        .library(
            name: "MNSwiftKitPlayer",
            targets: [
                "Player"
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
            name: "MNSwiftKitMediaExport",
            targets: [
                "MediaExport"
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
            name: "MNSwiftKitNameSpace",
            targets: [
                "NameSpace"
            ]
        ),
        .library(
            name: "MNSwiftKitAssetBrowser",
            targets: [
                "AssetBrowser"
            ]
        ),
        .library(
            name: "MNSwiftKitSplitController",
            targets: [
                "SplitController"
            ]
        ),
        .library(
            name: "MNSwiftKitPageControl",
            targets: [
                "PageControl"
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
            name: "MNSwiftKitEmoticonKeyboard",
            targets: [
                "EmoticonKeyboard"
            ]
        ),
        .library(
            name: "MNSwiftKitAnimatedImage",
            targets: [
                "AnimatedImage"
            ]
        ),
        .library(
            name: "MNSwiftKitCollectionLayout",
            targets: [
                "CollectionLayout"
            ]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MNSwiftKit",
            dependencies: [
                "Base", "Toast", "Slider", "Utility", "Player", "Layout", "Refresh", "Request", "Purchase", "Database", "Definition", "Extension", "EmptyView", "Networking", "AssetPicker", "NameSpace", "PageControl", "Components", "MediaExport", "Transitioning", "AssetBrowser", "SplitController", "AnimatedImage", "CollectionLayout", "EmoticonKeyboard"
            ],
            path: "MNSwiftKit/Full"
        ),
        .target(
            name: "Base",
            dependencies: [
                "Toast", "Layout", "Refresh", "Request", "Definition", "Extension", "EmptyView", "Transitioning", "CollectionLayout"
            ],
            path: "MNSwiftKit/Base",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("WebKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Toast",
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/Toast",
            resources: [
                .process("Resources")
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
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("AVFAudio"),
                .linkedFramework("Foundation"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("AVFoundation")
            ]
        ),
        .target(
            name: "Layout",
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/Layout",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Refresh",
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/Refresh",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Request",
            dependencies: [
                "Networking"
            ],
            path: "MNSwiftKit/Request",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("ImageIO"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreServices"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        ),
        .target(
            name: "MediaExport",
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/MediaExport",
            linkerSettings: [
                .linkedFramework("CoreMedia"),
                .linkedFramework("Foundation"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "Purchase",
            path: "MNSwiftKit/Purchase",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("StoreKit"),
                .linkedFramework("Foundation")
            ]
        ),
        .target(
            name: "Database",
            path: "MNSwiftKit/Database",
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedFramework("Foundation"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Definition",
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/Definition",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Extension",
            dependencies: [
                "NameSpace", "AnimatedImage"
            ],
            path: "MNSwiftKit/Extension",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "EmptyView",
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/EmptyView",
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
            linkerSettings: [
                .linkedFramework("Security"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("SystemConfiguration")
            ]
        ),
        .target(
            name: "AssetPicker",
            dependencies: [
                "Toast", "Slider", "Player", "Layout", "Refresh", "Definition", "Extension", "EmptyView", "NameSpace", "MediaExport", "AssetBrowser", "AnimatedImage"
            ],
            path: "MNSwiftKit/AssetPicker",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Photos"),
                .linkedFramework("PhotosUI"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        ),
        .target(
            name: "NameSpace",
            path: "MNSwiftKit/NameSpace",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "AssetBrowser",
            dependencies: [
                "Slider", "Player", "Layout", "Definition", "Extension", "AnimatedImage"
            ],
            path: "MNSwiftKit/AssetBrowser",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Photos"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "PageControl",
            path: "MNSwiftKit/PageControl",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Components",
            dependencies: [
                "Layout", "Extension"
            ],
            path: "MNSwiftKit/Components",
            resources: [
                .process("Resources")
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
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/Transitioning",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "SplitController",
            dependencies: [
                "Layout", "NameSpace"
            ],
            path: "MNSwiftKit/SplitController",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "EmoticonKeyboard",
            dependencies: [
                "Definition", "Extension", "NameSpace", "PageControl", "AnimatedImage"
            ],
            path: "MNSwiftKit/EmoticonKeyboard",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "AnimatedImage",
            dependencies: [
                "NameSpace"
            ],
            path: "MNSwiftKit/AnimatedImage",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("ImageIO"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreServices"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        ),
        .target(
            name: "CollectionLayout",
            path: "MNSwiftKit/CollectionLayout",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        )
        //.testTarget(name: "testTests", dependencies: ["test"])
    ]
)
