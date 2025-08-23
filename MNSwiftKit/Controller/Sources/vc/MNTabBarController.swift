//
//  MNTabBarController.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/15.
//  标签栏控制器

import UIKit

/// 重复选择回调
public protocol MNTabBarItemRepeatSelection {
    /// 标签项重复选择
    /// - Parameters:
    ///   - tabBarController: 标签栏控制器
    ///   - index: 索引
    func tabBarController(_ tabBarController: MNTabBarController, repeatSelectItem index: Int) -> Void
}

/// 标签栏控制器
open class MNTabBarController: UITabBarController {
    
    /// 标签栏
    private let referenceBottomBar = MNTabBar()
    public override var bottomBar: MNTabBar! { referenceBottomBar }
    
    /// 设置子控制器
    @objc public var controllers: [Any]? {
        didSet {
            self.viewControllers = nil
            guard let controllers = controllers else { return }
            var viewControllers: [UIViewController] = [UIViewController]()
            for (index, element) in controllers.enumerated() {
                if element is String {
                    guard let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else { continue }
                    let cls: AnyClass? = NSClassFromString("\(nameSpace).\(element as! String)")
                    guard let type = cls as? UIViewController.Type else { continue }
                    var vc = type.init()
                    if let obj = prepareAddChild(vc, for: index) {
                        vc = obj
                    }
                    viewControllers.append(vc)
                } else if element is UIViewController {
                    var vc = element as! UIViewController
                    if let obj = prepareAddChild(vc, for: index) {
                        vc = obj
                    }
                    viewControllers.append(vc)
                }
            }
            self.viewControllers = viewControllers
        }
    }
    
    /// 设置控制器
    open override var viewControllers: [UIViewController]? {
        get { super.viewControllers }
        set {
            super.viewControllers = newValue
            bottomBar.setViewControllers(newValue)
        }
    }
    
    /// 设置选择索引
    open override var selectedIndex: Int {
        get { super.selectedIndex }
        set {
            bottomBar.selectedIndex = newValue
            super.selectedIndex = newValue
            if let viewControllers = viewControllers, viewControllers.count > newValue {
                delegate?.tabBarController?(self, didSelect: viewControllers[newValue])
            }
        }
    }
    
    /// 设置选择控制器
    open override var selectedViewController: UIViewController? {
        get { super.selectedViewController }
        set {
            guard let viewController = newValue else { return }
            guard let index = viewControllers?.firstIndex(of: viewController) else { return }
            bottomBar.selectedIndex = index
            super.selectedViewController = viewController
        }
    }
    
    /// 设置控制器
    open override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        bottomBar.setViewControllers(viewControllers)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 添加标签条
        tabBar.isHidden = true
        bottomBar.delegate = self
        bottomBar.backgroundColor = .white
        view.addSubview(bottomBar)
    }
    
    /// 告知即将添加控制器
    /// - Parameters:
    ///   - viewController: 控制器
    ///   - index: 索引
    /// - Returns: 包装后的控制器
    @objc open func prepareAddChild(_ viewController: UIViewController, for index: Int) -> UIViewController? {
        if viewController is UINavigationController {
            return viewController
        }
        return MNNavigationController(rootViewController: viewController)
    }
}

// MARK: - 标签栏按钮点击事件
extension MNTabBarController: MNTabBarDelegate {
    
    public func tabBar(_ tabBar: MNTabBar, shouldSelectItem index: Int) -> Bool {
        guard let viewControllers = viewControllers else { return false }
        guard index < viewControllers.count else { return false }
        return (delegate?.tabBarController?(self, shouldSelect: viewControllers[index]) ?? true)
    }
    
    public func tabBar(_ tabBar: MNTabBar, selectedItem index: Int) {
        if selectedIndex == index {
            // 再次选中
            var viewController = selectedViewController
            while let vc = viewController {
                if vc is UINavigationController {
                    viewController = (vc as! UINavigationController).viewControllers.last
                } else if vc is UITabBarController {
                    viewController = (vc as! UITabBarController).selectedViewController
                } else { break }
            }
            guard let delegate = viewController as? MNTabBarItemRepeatSelection else { return }
            delegate.tabBarController(self, repeatSelectItem: index)
        } else {
            // 修改当前选中状态
            selectedIndex = index
        }
    }
}

// MARK: - 获取标签栏
extension MNTabBarController {
    
    open override var shouldAutorotate: Bool {
        guard let vc = selectedViewController else { return false }
        return vc.shouldAutorotate
    }
}

// MARK: - 方向支持
extension MNTabBarController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let vc = selectedViewController else { return .portrait }
        return vc.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        guard let vc = selectedViewController else { return .portrait }
        return vc.preferredInterfaceOrientationForPresentation
    }
}

// MARK: - UITabBarControllerDelegate
extension MNTabBarController: UITabBarControllerDelegate {
    
    public func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        guard let vc = selectedViewController else { return .portrait }
        return vc.supportedInterfaceOrientations
    }
    
    public func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
        guard let vc = selectedViewController else { return .portrait }
        return vc.preferredInterfaceOrientationForPresentation
    }
}

// MARK: - 状态栏
extension MNTabBarController {
    
    open override var childForStatusBarStyle: UIViewController? { selectedViewController }
    open override var childForStatusBarHidden: UIViewController? { selectedViewController }
}

// MARK: - BottomBarWrapper
public protocol BottomBarWrapper {
    
    var bottomBar: MNTabBar! { get }
}

extension UITabBarController: BottomBarWrapper {
    
    @objc public var bottomBar: MNTabBar! { nil }
}
