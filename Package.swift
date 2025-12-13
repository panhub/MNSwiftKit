// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MNSwiftKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "MNSwiftKit", targets: ["MNSwiftKit"]),
        .library(name: "MNBase", targets: ["MNBase"]),
        .library(name: "MNUtility",targets: ["MNUtility"]),
        .library(name: "MNSlider",targets: ["MNSlider"]),
        .library(name: "MNToast", targets: ["MNToast"]),
        .library(name: "MNPlayer", targets: ["MNPlayer"]),
        .library(name: "MNLayout",targets: ["MNLayout"]),
        .library(name: "MNRefresh",targets: ["MNRefresh"]),
        .library(name: "MNRequest", targets: ["MNRequest"]),
        .library(name: "MNPurchase", targets: ["MNPurchase"]),
        .library(name: "MNDatabase", targets: ["MNDatabase"]),
        .library(name: "MNDefinition", targets: ["MNDefinition"]),
        .library(name: "MNExtension", targets: ["MNExtension"]),
        .library(name: "MNEmptyView", targets: ["MNEmptyView"]),
        .library(name: "MNNetworking", targets: ["MNNetworking"]),
        .library(name: "MNAssetPicker", targets: ["MNAssetPicker"]),
        .library(name: "MNNameSpace", targets: ["MNNameSpace"]),
        .library(name: "MNPageControl", targets: ["MNPageControl"]),
        .library(name: "MNComponents", targets: ["MNComponents"]),
        .library(name: "MNMediaExport", targets: ["MNMediaExport"]),
        .library(name: "MNTransitioning", targets: ["MNTransitioning"]),
        .library(name: "MNAssetBrowser", targets: ["MNAssetBrowser"]),
        .library(name: "MNSplitController", targets: ["MNSplitController"]),
        .library(name: "MNAnimatedImage", targets: ["MNAnimatedImage"]),
        .library(name: "MNCollectionLayout", targets: ["MNCollectionLayout"]),
        .library(name: "MNEmoticonKeyboard", targets: ["MNEmoticonKeyboard"])
    ],
    targets: [
        .target(
            name: "MNSwiftKit",
            dependencies: [
                "MNBase", "MNUtility", "MNSlider", "MNToast", "MNPlayer", "MNLayout", "MNRefresh", "MNRequest", "MNPurchase", "MNDatabase", "MNDefinition", "MNExtension", "MNEmptyView", "MNNetworking", "MNAssetPicker", "MNNameSpace", "MNPageControl", "MNComponents", "MNMediaExport", "MNTransitioning", "MNAssetBrowser", "MNSplitController", "MNAnimatedImage", "MNCollectionLayout", "MNEmoticonKeyboard"
            ],
            path: "MNSwiftKit/MNSwiftKit"
        ),
        .target(
            name: "MNBase",
            dependencies: [
                "MNToast", "MNLayout", "MNRefresh", "MNRequest", "MNDefinition", "MNExtension", "MNEmptyView", "MNTransitioning", "MNCollectionLayout"
            ],
            path: "MNSwiftKit/Base",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("WebKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNUtility",
            path: "MNSwiftKit/Utility",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Photos"),
                .linkedFramework("AdSupport"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreImage"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("AuthenticationServices"),
                .linkedFramework("AppTrackingTransparency")
            ]
        ),
        .target(
            name: "MNSlider",
            path: "MNSwiftKit/Slider",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNToast",
            dependencies: [
                "MNNameSpace"
            ],
            path: "MNSwiftKit/Toast",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNPlayer",
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
            name: "MNLayout",
            dependencies: [
                "MNNameSpace"
            ],
            path: "MNSwiftKit/Layout",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNRefresh",
            dependencies: [
                "MNNameSpace"
            ],
            path: "MNSwiftKit/Refresh",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNRequest",
            dependencies: [
                "MNNetworking"
            ],
            path: "MNSwiftKit/Request",
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedFramework("UIKit"),
                .linkedFramework("ImageIO"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreServices"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        ),
        .target(
            name: "MNPurchase",
            path: "MNSwiftKit/Purchase",
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedFramework("UIKit"),
                .linkedFramework("StoreKit"),
                .linkedFramework("Foundation")
            ]
        ),
        .target(
            name: "MNDatabase",
            path: "MNSwiftKit/Database",
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedFramework("Foundation"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNDefinition",
            dependencies: [
                "MNNameSpace"
            ],
            path: "MNSwiftKit/Definition",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNExtension",
            dependencies: [
                "MNNameSpace", "MNAnimatedImage"
            ],
            path: "MNSwiftKit/Extension",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("StoreKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNEmptyView",
            dependencies: [
                "MNNameSpace"
            ],
            path: "MNSwiftKit/EmptyView",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNNetworking",
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
            name: "MNAssetPicker",
            dependencies: [
                "MNToast", "MNSlider", "MNPlayer", "MNLayout", "MNRefresh", "MNDefinition", "MNExtension", "MNEmptyView", "MNNameSpace", "MNMediaExport", "MNAssetBrowser", "MNAnimatedImage"
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
            name: "MNNameSpace",
            path: "MNSwiftKit/NameSpace",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNPageControl",
            path: "MNSwiftKit/PageControl",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNComponents",
            dependencies: [
                "MNLayout", "MNExtension"
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
            name: "MNMediaExport",
            dependencies: [
                "MNNameSpace"
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
            name: "MNTransitioning",
            dependencies: [
                "MNNameSpace"
            ],
            path: "MNSwiftKit/Transitioning",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNAssetBrowser",
            dependencies: [
                "MNSlider", "MNPlayer", "MNLayout", "MNDefinition", "MNExtension", "MNAnimatedImage"
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
            name: "MNSplitController",
            dependencies: [
                "MNLayout", "MNNameSpace"
            ],
            path: "MNSwiftKit/SplitController",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNAnimatedImage",
            dependencies: [
                "MNNameSpace"
            ],
            path: "MNSwiftKit/AnimatedImage",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("ImageIO"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreServices"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        ),
        .target(
            name: "MNCollectionLayout",
            path: "MNSwiftKit/CollectionLayout",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .target(
            name: "MNEmoticonKeyboard",
            dependencies: [
                "MNDefinition", "MNExtension", "MNNameSpace", "MNPageControl", "MNAnimatedImage"
            ],
            path: "MNSwiftKit/EmoticonKeyboard",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreFoundation")
            ]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
