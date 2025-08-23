//
//  UIViewController+MNHelper.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/15.
//

import UIKit

extension UIViewController {
    
    /// 依据情况出栈或模态弹出
    /// - Parameters:
    ///   - animated: 是否动态显示
    ///   - completionHandler: 结束回调(对模态弹出有效)
    @objc public func pop(animated: Bool = true, completion completionHandler: (()->Void)? = nil) {
        if let nav = navigationController {
            if nav.viewControllers.count > 1 {
                nav.popViewController(animated: animated)
                if let completionHandler = completionHandler {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: completionHandler)
                }
            } else if let _ = nav.presentingViewController {
                nav.dismiss(animated: animated, completion: completionHandler)
            }
        } else if let _ = presentingViewController {
            dismiss(animated: animated, completion: completionHandler)
        }
    }
    
    /// 从父控制器中移除自身
    @objc public func removeFromParentController() {
        guard let _ = parent else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        // add内部已调用did
        removeFromParent()
    }
    
    /// 添加子控制器
    /// - Parameters:
    ///   - childController: 自控制器
    ///   - superview: 指定视图
    @objc public func addChild(_ childController: UIViewController, to superview: UIView) {
        // add内部已调用will
        addChild(childController)
        superview.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    /// 添加子控制器
    /// - Parameters:
    ///   - childController: 自控制器
    ///   - superview: 指定视图
    ///   - index: 在父视图上的索引
    @objc public func insertChild(_ childController: UIViewController, to superview: UIView, at index: Int) {
        // add内部已调用will
        addChild(childController)
        superview.insertSubview(childController.view, at: index)
        childController.didMove(toParent: self)
    }
    
    /// 寻找当前控制器
    @objc public class var current: UIViewController? {
        var viewController = UIApplication.shared.delegate?.window??.rootViewController
        while let vc = viewController {
            if let presented = vc.presentedViewController {
                viewController = presented
            } else if let navigationController = vc as? UINavigationController {
                viewController = navigationController.viewControllers.last
            } else if let tabBarController = vc as? UITabBarController {
                viewController = tabBarController.selectedViewController
            } else { break }
        }
        return viewController
    }
}
