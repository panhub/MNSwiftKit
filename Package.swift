// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MNSwiftKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .kit,
        .base,
        .utility,
        .slider,
        .toast,
        .player,
        .refresh,
        .request,
        .purchase,
        .database,
        .definition,
        .extension,
        .emptyView,
        .networking,
        .editingView,
        .assetPicker,
        .nameSpace,
        .pageControl,
        .components,
        .mediaExport,
        .transitioning,
        .assetBrowser,
        .animatedImage,
        .collectionLayout,
        .emoticonKeyboard,
        .segmentedViewController
    ],
    targets: [
        .kit,
        .base,
        .utility,
        .slider,
        .toast,
        .player,
        .refresh,
        .request,
        .purchase,
        .database,
        .definition,
        .extension,
        .emptyView,
        .networking,
        .editingView,
        .assetPicker,
        .nameSpace,
        .pageControl,
        .components,
        .mediaExport,
        .transitioning,
        .assetBrowser,
        .animatedImage,
        .collectionLayout,
        .emoticonKeyboard,
        .segmentedViewController
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

fileprivate extension Product {
    
    static let kit = library(name: .kit, targets: [.kit])
    
    static let base = library(name: .base, targets: [.base])
    
    static let utility = library(name: .utility, targets: [.utility])
    
    static let slider = library(name: .slider, targets: [.slider])
    
    static let toast = library(name: .toast, targets: [.toast])
    
    static let player = library(name: .player, targets: [.player])
    
    static let refresh = library(name: .refresh, targets: [.refresh])
    
    static let request = library(name: .request, targets: [.request])
    
    static let purchase = library(name: .purchase, targets: [.purchase])
    
    static let database = library(name: .database, targets: [.database])
    
    static let definition = library(name: .definition, targets: [.definition])
    
    static let `extension` = library(name: .extension, targets: [.extension])
    
    static let emptyView = library(name: .emptyView, targets: [.emptyView])
    
    static let networking = library(name: .networking, targets: [.networking])
    
    static let editingView = library(name: .editingView, targets: [.editingView])
    
    static let assetPicker = library(name: .assetPicker, targets: [.assetPicker])
    
    static let nameSpace = library(name: .nameSpace, targets: [.nameSpace])
    
    static let pageControl = library(name: .pageControl, targets: [.pageControl])
    
    static let components = library(name: .components, targets: [.components])
    
    static let mediaExport = library(name: .mediaExport, targets: [.mediaExport])
    
    static let transitioning = library(name: .transitioning, targets: [.transitioning])
    
    static let assetBrowser = library(name: .assetBrowser, targets: [.assetBrowser])
    
    static let animatedImage = library(name: .animatedImage, targets: [.animatedImage])
    
    static let collectionLayout = library(name: .collectionLayout, targets: [.collectionLayout])
    
    static let emoticonKeyboard = library(name: .emoticonKeyboard, targets: [.emoticonKeyboard])
    
    static let segmentedViewController = library(name: .segmentedViewController, targets: [.segmentedViewController])
}

fileprivate extension Target {
    
    static let kit = target(
        name: .kit,
        dependencies: [
            .base,
            .utility,
            .slider,
            .toast,
            .player,
            .refresh,
            .request,
            .purchase,
            .database,
            .definition,
            .extension,
            .emptyView,
            .networking,
            .editingView,
            .assetPicker,
            .nameSpace,
            .pageControl,
            .components,
            .mediaExport,
            .transitioning,
            .assetBrowser,
            .animatedImage,
            .collectionLayout,
            .emoticonKeyboard,
            .segmentedViewController
        ],
        path: .kit.path
    )
    
    static let base = target(
        name: .base,
        dependencies: [
            .toast,
            .refresh,
            .request,
            .definition,
            .extension,
            .emptyView,
            .nameSpace,
            .transitioning,
            .collectionLayout
        ],
        path: .base.path,
        resources: [
            .process("Resources")
        ],
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("WebKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let utility = target(
        name: .utility,
        path: .utility.path,
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
    )
    
    static let slider = target(
        name: .slider,
        path: .slider.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("QuartzCore"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let toast = target(
        name: .toast,
        dependencies: [
            .nameSpace
        ],
        path: .toast.path,
        resources: [
            .process("Resources")
        ],
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let player = target(
        name: .player,
        path: .player.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("AVFAudio"),
            .linkedFramework("Foundation"),
            .linkedFramework("AudioToolbox"),
            .linkedFramework("AVFoundation")
        ]
    )
    
    static let refresh = target(
        name: .refresh,
        dependencies: [
            .nameSpace
        ],
        path: .refresh.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let request = target(
        name: .request,
        dependencies: [
            .networking
        ],
        path: .request.path,
        linkerSettings: [
            .linkedLibrary("sqlite3"),
            .linkedFramework("UIKit"),
            .linkedFramework("ImageIO"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreServices"),
            .linkedFramework("CoreFoundation"),
            .linkedFramework("UniformTypeIdentifiers")
        ]
    )
    
    static let purchase = target(
        name: .purchase,
        path: .purchase.path,
        linkerSettings: [
            .linkedLibrary("sqlite3"),
            .linkedFramework("UIKit"),
            .linkedFramework("StoreKit"),
            .linkedFramework("Foundation")
        ]
    )
    
    static let database = target(
        name: .database,
        path: .database.path,
        linkerSettings: [
            .linkedLibrary("sqlite3"),
            .linkedFramework("Foundation"),
            .linkedFramework("AVFoundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let definition = target(
        name: .definition,
        dependencies: [
            .nameSpace
        ],
        path: .definition.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let `extension` = target(
        name: .extension,
        dependencies: [
            .nameSpace,
            .animatedImage
        ],
        path: .extension.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("StoreKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("QuartzCore"),
            .linkedFramework("CoreGraphics"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let emptyView = target(
        name: .emptyView,
        dependencies: [
            .nameSpace
        ],
        path: .emptyView.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let networking = target(
        name: .networking,
        path: .networking.path,
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
    )
    
    static let editingView = target(
        name: .editingView,
        dependencies: [
            .nameSpace
        ],
        path: .editingView.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let assetPicker = target(
        name: .assetPicker,
        dependencies: [
            .toast,
            .slider,
            .player,
            .refresh,
            .definition,
            .extension,
            .emptyView,
            .nameSpace,
            .mediaExport,
            .assetBrowser,
            .animatedImage
        ],
        path: .assetPicker.path,
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
    )
    
    static let nameSpace = target(
        name: .nameSpace,
        path: .nameSpace.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("QuartzCore"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let pageControl = target(
        name: .pageControl,
        path: .pageControl.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let components = target(
        name: .components,
        dependencies: [
            .extension,
            .nameSpace
        ],
        path: .components.path,
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
    )
    
    static let mediaExport = target(
        name: .mediaExport,
        dependencies: [
            .nameSpace
        ],
        path: .mediaExport.path,
        linkerSettings: [
            .linkedFramework("CoreMedia"),
            .linkedFramework("Foundation"),
            .linkedFramework("AVFoundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let transitioning = target(
        name: .transitioning,
        dependencies: [
            .nameSpace
        ],
        path: .transitioning.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let assetBrowser = target(
        name: .assetBrowser,
        dependencies: [
            .slider,
            .player,
            .definition,
            .extension,
            .animatedImage
        ],
        path: .assetBrowser.path,
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
    )
    
    static let animatedImage = target(
        name: .animatedImage,
        dependencies: [
            .nameSpace
        ],
        path: .animatedImage.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("ImageIO"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreServices"),
            .linkedFramework("CoreFoundation"),
            .linkedFramework("UniformTypeIdentifiers")
        ]
    )
    
    static let collectionLayout = target(
        name: .collectionLayout,
        path: .collectionLayout.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let emoticonKeyboard = target(
        name: .emoticonKeyboard,
        dependencies: [
            .definition,
            .extension,
            .nameSpace,
            .pageControl,
            .animatedImage
        ],
        path: .emoticonKeyboard.path,
        resources: [
            .process("Resources")
        ],
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
    
    static let segmentedViewController = target(
        name: .segmentedViewController,
        dependencies: [
            .nameSpace
        ],
        path: .segmentedViewController.path,
        linkerSettings: [
            .linkedFramework("UIKit"),
            .linkedFramework("Foundation"),
            .linkedFramework("CoreFoundation")
        ]
    )
}

fileprivate extension Target.Dependency {
    
    static let base = byName(name: .base)
    
    static let utility = byName(name: .utility)
    
    static let slider = byName(name: .slider)
    
    static let toast = byName(name: .toast)
    
    static let player = byName(name: .player)
    
    static let refresh = byName(name: .refresh)
    
    static let request = byName(name: .request)
    
    static let purchase = byName(name: .purchase)
    
    static let database = byName(name: .database)
    
    static let definition = byName(name: .definition)
    
    static let `extension` = byName(name: .extension)
    
    static let emptyView = byName(name: .emptyView)
    
    static let networking = byName(name: .networking)
    
    static let editingView = byName(name: .editingView)
    
    static let assetPicker = byName(name: .assetPicker)
    
    static let nameSpace = byName(name: .nameSpace)
    
    static let pageControl = byName(name: .pageControl)
    
    static let components = byName(name: .components)
    
    static let mediaExport = byName(name: .mediaExport)
    
    static let transitioning = byName(name: .transitioning)
    
    static let assetBrowser = byName(name: .assetBrowser)
    
    static let animatedImage = byName(name: .animatedImage)
    
    static let collectionLayout = byName(name: .collectionLayout)
    
    static let emoticonKeyboard = byName(name: .emoticonKeyboard)
    
    static let segmentedViewController = byName(name: .segmentedViewController)
}

fileprivate extension String {
    
    static let kit = "MNSwiftKit"
    
    static let base = "MNBase"
    
    static let utility = "MNUtility"
    
    static let slider = "MNSlider"
    
    static let toast = "MNToast"
    
    static let player = "MNPlayer"
    
    static let refresh = "MNRefresh"
    
    static let request = "MNRequest"
    
    static let purchase = "MNPurchase"
    
    static let database = "MNDatabase"
    
    static let definition = "MNDefinition"
    
    static let `extension` = "MNExtension"
    
    static let emptyView = "MNEmptyView"
    
    static let networking = "MNNetworking"
    
    static let editingView = "MNEditingView"
    
    static let assetPicker = "MNAssetPicker"
    
    static let nameSpace = "MNNameSpace"
    
    static let pageControl = "MNPageControl"
    
    static let components = "MNComponents"
    
    static let mediaExport = "MNMediaExport"
    
    static let transitioning = "MNTransitioning"
    
    static let assetBrowser = "MNAssetBrowser"
    
    static let animatedImage = "MNAnimatedImage"
    
    static let collectionLayout = "MNCollectionLayout"
    
    static let emoticonKeyboard = "MNEmoticonKeyboard"
    
    static let segmentedViewController = "MNSegmentedViewController"
    
    var path: String {
        
        return .kit + "/" + (self == .kit ? self : self.replacingOccurrences(of: "MN", with: ""))
    }
}

/**
 // 旧版
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
         .library(name: "MNRefresh",targets: ["MNRefresh"]),
         .library(name: "MNRequest", targets: ["MNRequest"]),
         .library(name: "MNPurchase", targets: ["MNPurchase"]),
         .library(name: "MNDatabase", targets: ["MNDatabase"]),
         .library(name: "MNDefinition", targets: ["MNDefinition"]),
         .library(name: "MNExtension", targets: ["MNExtension"]),
         .library(name: "MNEmptyView", targets: ["MNEmptyView"]),
         .library(name: "MNNetworking", targets: ["MNNetworking"]),
         .library(name: "MNEditingView", targets: ["MNEditingView"]),
         .library(name: "MNAssetPicker", targets: ["MNAssetPicker"]),
         .library(name: "MNNameSpace", targets: ["MNNameSpace"]),
         .library(name: "MNPageControl", targets: ["MNPageControl"]),
         .library(name: "MNComponents", targets: ["MNComponents"]),
         .library(name: "MNMediaExport", targets: ["MNMediaExport"]),
         .library(name: "MNTransitioning", targets: ["MNTransitioning"]),
         .library(name: "MNAssetBrowser", targets: ["MNAssetBrowser"]),
         .library(name: "MNAnimatedImage", targets: ["MNAnimatedImage"]),
         .library(name: "MNCollectionLayout", targets: ["MNCollectionLayout"]),
         .library(name: "MNEmoticonKeyboard", targets: ["MNEmoticonKeyboard"]),
         .library(name: "MNSegmentedViewController", targets: ["MNSegmentedViewController"]),
     ],
     targets: [
         .target(
             name: "MNSwiftKit",
             dependencies: [
                 "MNBase", "MNUtility", "MNSlider", "MNToast", "MNPlayer", "MNRefresh", "MNRequest", "MNPurchase", "MNDatabase", "MNDefinition", "MNExtension", "MNEmptyView", "MNNetworking", "MNEditingView", "MNAssetPicker", "MNNameSpace", "MNPageControl", "MNComponents", "MNMediaExport", "MNTransitioning", "MNAssetBrowser", "MNAnimatedImage", "MNCollectionLayout", "MNEmoticonKeyboard", "MNSegmentedViewController"
             ],
             path: "MNSwiftKit/MNSwiftKit"
         ),
         .target(
             name: "MNBase",
             dependencies: [
                 "MNToast", "MNRefresh", "MNRequest", "MNDefinition", "MNExtension", "MNEmptyView", "MNNameSpace", "MNTransitioning", "MNCollectionLayout"
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
             name: "MNEditingView",
             dependencies: [
                 "MNNameSpace"
             ],
             path: "MNSwiftKit/EditingView",
             linkerSettings: [
                 .linkedFramework("UIKit"),
                 .linkedFramework("Foundation"),
                 .linkedFramework("CoreFoundation")
             ]
         ),
         .target(
             name: "MNAssetPicker",
             dependencies: [
                 "MNToast", "MNSlider", "MNPlayer", "MNRefresh", "MNDefinition", "MNExtension", "MNEmptyView", "MNNameSpace", "MNMediaExport", "MNAssetBrowser", "MNAnimatedImage"
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
                 "MNExtension", "MNNameSpace"
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
                 "MNSlider", "MNPlayer", "MNDefinition", "MNExtension", "MNAnimatedImage"
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
         ),
         .target(
             name: "MNSegmentedViewController",
             dependencies: [
                 "MNNameSpace"
             ],
             path: "MNSwiftKit/SegmentedViewController",
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
 */
