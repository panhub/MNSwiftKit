//
//  UINavigationBar+MNHelper.swift
//  MNSwiftKit
//
//  Created by mellow on 2025/8/20.
//

import UIKit
import Foundation
import CoreGraphics

// MARK: - UINavigationBar
extension UINavigationBar {
    
    /// 导航栏高度
    @objc public static let Height: CGFloat = {
        var height: CGFloat = 0.0
        if Thread.isMainThread {
            height = UINavigationController().navigationBar.frame.height
        } else {
            DispatchQueue.main.sync {
                height = UINavigationController().navigationBar.frame.height
            }
        }
        return height
    }()
}
