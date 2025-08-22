//
//  UINavigationController+MNExtension.swift
//  MNKit
//
//  Created by 冯盼 on 2022/1/14.
//  导航控制器扩展

import UIKit

extension UINavigationController {
    
    // 当前导航控制器
    @objc public static var present: UINavigationController? {
        guard let vc = UIViewController.current else { return nil }
        return vc.navigationController
    }
    
    // 寻找控制器
    public func seek<T>(_ cls: T.Type) -> T? {
        for vc in viewControllers.reversed() {
            if vc is T {
                return vc as? T
            }
        }
        return nil
    }
}
