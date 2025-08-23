//
//  UITabBar+MNHelper.swift
//  MNFoundation
//
//  Created by mellow on 2025/8/20.
//

import UIKit
import Foundation
import CoreGraphics

// MARK: - UITabBar
extension UITabBar {
    
    /// 标签栏高度
    @objc public static let Height: CGFloat = {
        var height: CGFloat = 0.0
        if Thread.isMainThread {
            height = UITabBarController().tabBar.frame.height
        } else {
            DispatchQueue.main.sync {
                height = UITabBarController().tabBar.frame.height
            }
        }
        return height
    }()
}
