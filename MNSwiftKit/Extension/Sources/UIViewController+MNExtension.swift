//
//  UIViewController+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/15.
//

import UIKit

extension MNNameSpaceWrapper where Base: UIViewController {
    
    /// 寻找当前控制器
    public class var current: UIViewController? {
        guard let window = UIWindow.mn.current else { return nil }
        var viewController = window.rootViewController
        while let vc = viewController {
            if let presented = vc.presentedViewController {
                viewController = presented
            } else if vc is UINavigationController {
                let navigationController = vc as! UINavigationController
                viewController = navigationController.viewControllers.last
            } else if vc is UITabBarController {
                let tabBarController = vc as! UITabBarController
                viewController = tabBarController.selectedViewController
            } else { break }
        }
        return viewController
    }
    
    /// 依据情况出栈或模态弹出
    /// - Parameters:
    ///   - animated: 是否动态显示
    ///   - completionHandler: 结束回调(对模态弹出有效)
    public func pop(animated: Bool = true, completion completionHandler: (()->Void)? = nil) {
        if let nav = base.navigationController {
            if nav.viewControllers.count > 1 {
                nav.popViewController(animated: animated)
                if let completionHandler = completionHandler {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: completionHandler)
                }
            } else if let _ = nav.presentingViewController {
                nav.dismiss(animated: animated, completion: completionHandler)
            }
        } else if let _ = base.presentingViewController {
            base.dismiss(animated: animated, completion: completionHandler)
        }
    }
    
    /// 从父控制器中移除自身
    public func removeFromParent() {
        guard let _ = base.parent else { return }
        base.willMove(toParent: nil)
        base.view.removeFromSuperview()
        // 内部已调用did
        base.removeFromParent()
    }
    
    /// 添加子控制器
    /// - Parameters:
    ///   - childController: 自控制器
    ///   - superview: 指定视图
    public func addChild(_ childController: UIViewController, to superview: UIView? = nil) {
        // 内部已调用will
        base.addChild(childController)
        if let superview = superview {
            superview.addSubview(childController.view)
        } else {
            base.view.addSubview(childController.view)
        }
        childController.didMove(toParent: base)
    }
    
    /// 添加子控制器
    /// - Parameters:
    ///   - childController: 自控制器
    ///   - superview: 指定视图
    ///   - index: 在父视图上的索引
    public func insertChild(_ childController: UIViewController, to superview: UIView, at index: Int) {
        // add内部已调用will
        base.addChild(childController)
        superview.insertSubview(childController.view, at: index)
        childController.didMove(toParent: base)
    }
    
    /// 是否是加载在标签控制器或导航控制器中
    public var isRootViewController: Bool {
        if base is UITabBarController { return false }
        if base is UINavigationController { return false }
        guard let parent = base.parent else { return false }
        if parent is UITabBarController {
            let tabBarController = parent as! UITabBarController
            guard let viewControllers = tabBarController.viewControllers else { return false }
            return viewControllers.contains(base)
        }
        if parent is UINavigationController {
            let navigationController = parent as! UINavigationController
            return navigationController.viewControllers.contains(base)
        }
        return false
    }
    
    /// 是否以子控制器方式加载
    public var isChildViewController: Bool {
        guard let parent = base.parent else { return false }
        return parent.children.contains(base)
    }
    
    /// 获取主控制器
    /// - 若自身加载在标签控制器或导航控制器中则返回自身
    /// - 反之递归向上寻找
    public var rootViewController: UIViewController? {
        var viewController: UIViewController? = base
        while let vc = viewController {
            if vc.mn.isRootViewController { return vc }
            viewController = vc.parent
        }
        return nil
    }
}
