//
//  UITabBar+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/20.
//

import UIKit
import Foundation
import CoreGraphics

/// 内部保留标签栏高度
fileprivate var MNTabBarHeight: CGFloat?

extension NameSpaceWrapper where Base: UITabBar {
    
    /// 标签栏高度
    public class var height: CGFloat {
        if let height = MNTabBarHeight { return height }
        var height: CGFloat = 0.0
        if Thread.isMainThread {
            height = UITabBarController().tabBar.frame.height
        } else {
            DispatchQueue.main.sync {
                height = UITabBarController().tabBar.frame.height
            }
        }
        MNTabBarHeight = height
        return height
    }
}
