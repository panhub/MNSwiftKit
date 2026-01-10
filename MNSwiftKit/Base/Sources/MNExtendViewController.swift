//
//  MNExtendViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/18.
//  附带导航条的控制器基类

import UIKit

/// 导航栏控制器
open class MNExtendViewController: MNBaseViewController {
    
    /// 导航栏
    fileprivate var navigationBar: MNNavigationBar!
    
    /// 标题
    open override var title: String? {
        get { super.title }
        set {
            super.title = newValue
            guard let navigationBar = navigationBar else { return }
            navigationBar.title = newValue
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 调整内容视图尺寸以适配导航栏
        guard preferredNavigationHeight > 0.0 else { return }
        if preferredContentRectEdge.contains(.top) {
            contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: preferredNavigationHeight + MN_STATUS_BAR_HEIGHT, left: 0.0, bottom: 0.0, right: 0.0))
        }
        
        // 创建导航栏
        navigationBar = MNNavigationBar(frame: .init(origin: .zero, size: .init(width: view.frame.width, height: preferredNavigationHeight + (automaticallyAdjustsForStatusBar ? MN_STATUS_BAR_HEIGHT : 0.0))))
        navigationBar.title = title
        navigationBar.delegate = self
        navigationBar.adjustsForStatusBar = automaticallyAdjustsForStatusBar
        view.addSubview(navigationBar)
    }
    
    /// 定制内容约束
    /// - Returns: 内容约束
    open override var preferredContentRectEdge: UIRectEdge {
        
        preferredNavigationHeight > 0.0 ? super.preferredContentRectEdge.union(.top) : super.preferredContentRectEdge
    }
}

// MARK: - MNNavigationBarDelegate
extension MNExtendViewController: MNNavigationBarDelegate {
    
    open func navigationBarShouldCreateLeftBarItem() -> UIView? { nil }
    
    open func navigationBarShouldCreateRightBarItem() -> UIView? { nil }
    
    open func navigationBarShouldRenderBackBarItem() -> Bool { false }
    
    open func navigationBarDidLayoutSubitems(_ navigationBar: MNNavigationBar) {}
    
    open func navigationBarRightBarItemTouchUpInside(_ rightBarItem: UIView!) {}
    
    open func navigationBarLeftBarItemTouchUpInside(_ leftBarItem: UIView!) {
        mn.pop()
    }
}
 
// MARK: - MNNavigationBarSupported
public protocol MNNavigationBarSupported {
    
    /// 定制导航栏高度
    var preferredNavigationHeight: CGFloat { get }
    
    /// 导航栏高度是否应适配状态栏高度
    var automaticallyAdjustsForStatusBar: Bool { get }
}

extension UIViewController: MNNavigationBarSupported {
    
    @objc public var preferredNavigationHeight: CGFloat { MN_NAV_BAR_HEIGHT }
    
    @objc public var automaticallyAdjustsForStatusBar: Bool { true }
}

extension MNNameSpaceWrapper where Base: UIViewController {
    
    /// 获取导航栏
    public var navigationBar: MNNavigationBar! {
        var viewController: UIViewController? = base
        while let vc = viewController {
            if let extendViewController = vc as? MNExtendViewController, extendViewController.preferredNavigationHeight > 0.0 {
                return extendViewController.navigationBar
            }
            viewController = vc.parent
        }
        return nil
    }
}
