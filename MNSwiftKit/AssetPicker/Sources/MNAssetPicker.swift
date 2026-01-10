//
//  MNAssetPicker.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  资源选择器

import UIKit
import Foundation
#if SWIFT_PACKAGE
@_exported import MNToast
@_exported import MNSlider
@_exported import MNPlayer
@_exported import MNRefresh
@_exported import MNDefinition
@_exported import MNExtension
@_exported import MNEmptyView
@_exported import MNNameSpace
@_exported import MNMediaExport
@_exported import MNAssetBrowser
@_exported import MNAnimatedImage
#endif

/// 资源选择器代理事件
@objc public protocol MNAssetPickerDelegate: UINavigationControllerDelegate {
    
    /// 资源选择器取消事件
    /// - Parameter picker: 资源选择器
    @objc optional func assetPickerDidCancel(_ picker: MNAssetPicker)
    
    /// 资源选择器结束选择事件
    /// - Parameters:
    ///   - picker: 资源选择器
    ///   - assets: 已选择的资源集合
    func assetPicker(_ picker: MNAssetPicker, didFinishPicking assets: [MNAsset])
}

/// 资源选择器
public class MNAssetPicker: UINavigationController {
    
    /// 资源选择器取消回调
    public typealias CancelHandler = (_ picker: MNAssetPicker)->Void

    /// 资源选择器结束回调
    public typealias ResultHandler = (_ picker: MNAssetPicker, _ assets: [MNAsset])->Void
    
    /// 取消回调
    private var cancelHandler: CancelHandler?
    /// 选择回调
    private var pickingHandler: ResultHandler!
    /// 配置信息
    public let options: MNAssetPickerOptions
    /// 选择器代理
    private weak var _delegate:  MNAssetPickerDelegate?
    /// 事件代理入口
    public override var delegate: (any UINavigationControllerDelegate)? {
        get { _delegate }
        set { _delegate = newValue as? MNAssetPickerDelegate }
    }
    
    /// 构造资源选择器
    /// - Parameter options: 配置选项
    public init(options: MNAssetPickerOptions = .init()) {
        self.options = options
        super.init(rootViewController: MNAssetPickerController(options: options))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        navigationBar.isHidden = true
    }
}

// MARK: - 调起资源选择器
extension MNAssetPicker {
    
    /// 弹起资源选择器
    /// - Parameters:
    ///   - pickingHandler: 选择结束回调
    ///   - cancelHandler: 取消事件回调
    public func present(pickingHandler: @escaping ResultHandler, cancelHandler: CancelHandler? = nil) {
        present(in: nil, animated: true, pickingHandler: pickingHandler, cancelHandler: cancelHandler)
    }
    
    /// 弹起资源选择器
    /// - Parameters:
    ///   - viewController: 指定控制器
    ///   - animated: 是否动态展示
    ///   - pickingHandler: 选择结束回调
    ///   - cancelHandler: 取消事件回调
    public func present(in viewController: UIViewController?, animated: Bool = true, pickingHandler: @escaping ResultHandler, cancelHandler: CancelHandler? = nil) {
        let vc: UIViewController? = viewController ?? .mn.current
        guard let vc = vc else { return }
        delegate = self
        self.cancelHandler = cancelHandler
        self.pickingHandler = pickingHandler
        modalPresentationStyle = options.presentationStyle
        vc.present(self, animated: (animated && UIApplication.shared.applicationState == .active))
    }
}

// MARK: - MNAssetPickerDelegate
extension MNAssetPicker: MNAssetPickerDelegate {
    
    public func assetPickerDidCancel(_ picker: MNAssetPicker) {
        dismiss(animated: UIApplication.shared.applicationState == .active) { [weak self] in
            guard let self = self else { return }
            self.cancelHandler?(self)
        }
    }
    
    public func assetPicker(_ picker: MNAssetPicker, didFinishPicking assets: [MNAsset]) {
        dismiss(animated: UIApplication.shared.applicationState == .active) { [weak self] in
            guard let self = self else { return }
            self.pickingHandler?(self, assets)
        }
    }
    
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        
        .portrait
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        
        .portrait
    }
}

// MARK: - 屏幕旋转相关
extension MNAssetPicker {
    
    public override var shouldAutorotate: Bool { false }
}

// MARK: - 状态栏
extension MNAssetPicker {
    
    public override var childForStatusBarStyle: UIViewController? { topViewController }
    
    public override var childForStatusBarHidden: UIViewController? { topViewController }
}
