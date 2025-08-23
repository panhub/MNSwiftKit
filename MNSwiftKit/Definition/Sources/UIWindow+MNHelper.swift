//
//  UIWindow+MNHelper.swift
//  MNFoundation
//
//  Created by mellow on 2025/8/20.
//

import UIKit
import Foundation
import CoreGraphics

// MARK: - UIWindow
extension UIWindow {
    
    /// 安全区域
    @objc public static let Safe: UIEdgeInsets = {
        var inset: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            if Thread.isMainThread {
                inset = UIWindow().safeAreaInsets
            } else {
                DispatchQueue.main.sync {
                    inset = UIWindow().safeAreaInsets
                }
            }
        }
        return inset
    }()
}
