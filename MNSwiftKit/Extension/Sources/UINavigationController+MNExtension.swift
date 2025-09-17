//
//  UINavigationController+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/1/14.
//  导航控制器扩展

import UIKit

extension NameSpaceWrapper where Base: UINavigationController {
    
    /// 当前导航控制器
    public class var present: UINavigationController? {
        guard let vc = UIViewController.mn.current else { return nil }
        return vc.navigationController
    }
    
    /// 寻找子控制器
    public func seek<T>(_ cls: T.Type) -> T? {
        for vc in base.viewControllers.reversed() {
            if vc is T {
                return vc as? T
            }
        }
        return nil
    }
}
