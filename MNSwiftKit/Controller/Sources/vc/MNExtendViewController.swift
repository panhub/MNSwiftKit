//
//  MNExtendViewController.swift
//  MNKit
//
//  Created by 冯盼 on 2021/7/18.
//  附带导航条的控制器基类

import UIKit
#if canImport(MNSwiftKit_Definition)
import MNSwiftKit_Definition
#endif

/// 导航栏控制器
open class MNExtendViewController: MNBaseViewController {
    
    /// 导航栏
    fileprivate var referenceNavigationBar: MNNavigationBar!
    
    /// 获取导航栏
    @objc public override var navigationBar: MNNavigationBar! { referenceNavigationBar }
    
    /// 标题
    open override var title: String? {
        get { super.title }
        set {
            super.title = newValue
            referenceNavigationBar?.title = newValue
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 创建导航条
        guard isChildViewController == false else { return }
        let edges = preferredContentEdges
        if edges.contains(.top) {
            contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: preferredNavigationHeight + MN_STATUS_BAR_HEIGHT, left: 0.0, bottom: 0.0, right: 0.0))
        }
        referenceNavigationBar = MNNavigationBar(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: preferredNavigationHeight + MN_STATUS_BAR_HEIGHT))
        referenceNavigationBar.title = title
        referenceNavigationBar.delegate = self
        view.addSubview(referenceNavigationBar)
    }
    
    /// 定制内容约束
    /// - Returns: 内容约束
    open override var preferredContentEdges: UIViewController.Edge {
        let edges = super.preferredContentEdges
        guard isChildViewController == false else { return edges }
        return edges.union(.top)
    }
}

// MARK: - MNNavigationBarDelegate
extension MNExtendViewController: MNNavigationBarDelegate {
    open func navigationBarShouldCreateLeftBarItem() -> UIView? { return nil }
    open func navigationBarShouldCreateRightBarItem() -> UIView? { return nil }
    open func navigationBarShouldDrawBackBarItem() -> Bool { !isRootViewController }
    open func navigationBarDidLayoutSubitems(_ navigationBar: MNNavigationBar) {}
    open func navigationBarRightBarItemTouchUpInside(_ rightBarItem: UIView!) {}
    open func navigationBarLeftBarItemTouchUpInside(_ leftBarItem: UIView!) {
        let animated = UIApplication.shared.applicationState == .active
        if let nav = navigationController {
            if nav.viewControllers.count > 1 {
                nav.popViewController(animated: animated)
            } else if let _ = nav.presentingViewController {
                nav.dismiss(animated: animated, completion: nil)
            }
        } else if let _ = presentingViewController {
            dismiss(animated: animated, completion: nil)
        }
    }
}

// MARK: - NavigationBarWrapper
public protocol NavigationBarWrapper {
    
    /// 导航条
    var navigationBar: MNNavigationBar! { get }
    
    /// 定制导航条高度
    var preferredNavigationHeight: CGFloat { get }
}

extension UIViewController: NavigationBarWrapper {
    
    @objc public var navigationBar: MNNavigationBar! {
        var viewController: UIViewController? = self
        while let vc = viewController {
            if vc.isChildViewController {
                viewController = vc.parent
            } else if vc is MNExtendViewController {
                return (vc as! MNExtendViewController).referenceNavigationBar
            } else { break }
        }
        return nil
    }
    
    @objc public var preferredNavigationHeight: CGFloat { MN_NAV_BAR_HEIGHT }
}
