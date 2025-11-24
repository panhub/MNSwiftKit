//
//  MNNavigationController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/16.
//  导航控制器

import UIKit

open class MNNavigationController: UINavigationController {
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        modalPresentationStyle = .fullScreen
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 隐藏系统导航栏
        navigationBar.isHidden = true
        // 设置转场代理
        delegate = self
        mn.transitioningDelegate = MNTransitionDelegate()
    }
}

// MARK: - 屏幕旋转相关
extension MNNavigationController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let vc = topViewController else { return .portrait }
        return vc.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        guard let vc = topViewController else { return .portrait }
        return vc.preferredInterfaceOrientationForPresentation
    }
}

extension MNNavigationController: UINavigationControllerDelegate {
    
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard let vc = topViewController else { return .portrait }
        return vc.supportedInterfaceOrientations
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        guard let vc = topViewController else { return .portrait }
        return vc.preferredInterfaceOrientationForPresentation
    }
}

extension MNNavigationController {
    
    open override var shouldAutorotate: Bool {
        guard let vc = topViewController else { return false }
        return vc.shouldAutorotate
    }
}

// MARK: - 状态栏样式
extension MNNavigationController {
    open override var childForStatusBarStyle: UIViewController? { topViewController }
    open override var childForStatusBarHidden: UIViewController? { topViewController }
}
