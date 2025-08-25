//
//  MNAssetPicker.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  资源选择器

import UIKit

/// 资源选择器取消回调
public typealias MNPickingCancelHandler = (_ picker: MNAssetPicker)->Void

/// 资源选择器结束回调
public typealias MNPickingResultHandler = (_ picker: MNAssetPicker, _ assets: [MNAsset])->Void

/// 资源选择器代理事件
@objc public protocol MNAssetPickerDelegate {
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
    /// 是否动态展示
    private var isAnimated: Bool = true
    /// 取消回调
    private var cancelHandler: MNPickingCancelHandler?
    /// 选择回调
    private var pickingHandler: MNPickingResultHandler!
    /// 配置信息
    public let options: MNAssetPickerOptions
    
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
    @objc public func present(pickingHandler: @escaping MNPickingResultHandler, cancelHandler: MNPickingCancelHandler? = nil) {
        present(in: nil, animated: true, pickingHandler: pickingHandler, cancelHandler: cancelHandler)
    }
    
    /// 弹起资源选择器
    /// - Parameters:
    ///   - viewController: 指定控制器
    ///   - animated: 是否动态展示
    ///   - pickingHandler: 选择结束回调
    ///   - cancelHandler: 取消事件回调
    @objc public func present(in viewController: UIViewController?, animated: Bool = true, pickingHandler: @escaping MNPickingResultHandler, cancelHandler: MNPickingCancelHandler? = nil) {
        finish(pickingHandler).cancel(cancelHandler ?? {_ in}).present(in: viewController, animated: animated)
    }
    
    @discardableResult
    /// 设置选择结果回调
    /// - Parameter pickingHandler: 选择结束回调代码块
    /// - Returns: 选择器
    public func finish(_ pickingHandler: @escaping (_ picker: MNAssetPicker, _ assets: [MNAsset])->Void) -> MNAssetPicker {
        self.pickingHandler = pickingHandler
        return self
    }
    
    @discardableResult
    /// 设置取消选择回调
    /// - Parameter cancelHandler: 回调代码块
    /// - Returns: 选择器
    public func cancel(_ cancelHandler: @escaping (_ picker: MNAssetPicker)->Void) -> MNAssetPicker {
        self.cancelHandler = cancelHandler
        return self
    }
    
    /// 弹出资源选择器
    /// - Parameters:
    ///   - viewController: 指定父控制器 (nil则寻找上层控制器)
    ///   - animated: 是否动态
    ///   - completion: 弹出结束回调
    public func present(in viewController: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        let parentViewController: UIViewController? = viewController ?? .mn_picker.current
        guard let parentViewController = parentViewController else { return }
        isAnimated = animated
        options.delegate = self
        modalPresentationStyle = options.presentationStyle
        parentViewController.present(self, animated: (animated && UIApplication.shared.applicationState == .active), completion: completion)
    }
}

// MARK: - MNAssetPickerDelegate
extension MNAssetPicker: MNAssetPickerDelegate {
    
    public func assetPickerDidCancel(_ picker: MNAssetPicker) {
        let executeHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.cancelHandler?(self)
        }
        if options.allowsAutoDismiss {
            dismiss(animated: (isAnimated && UIApplication.shared.applicationState == .active), completion: executeHandler)
        } else {
            executeHandler()
        }
    }
    
    public func assetPicker(_ picker: MNAssetPicker, didFinishPicking assets: [MNAsset]) {
        let executeHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.pickingHandler?(self, assets)
        }
        if options.allowsAutoDismiss {
            dismiss(animated: (isAnimated && UIApplication.shared.applicationState == .active), completion: executeHandler)
        } else {
            executeHandler()
        }
    }
}

// MARK: - 屏幕旋转相关
extension MNAssetPicker {
    
    public override var shouldAutorotate: Bool { false }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask { .portrait }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation { .portrait }
}

// MARK: - 状态栏
extension MNAssetPicker {
    public override var childForStatusBarStyle: UIViewController? { topViewController }
    public override var childForStatusBarHidden: UIViewController? { topViewController }
}
