//
//  UIScreen+MNHelper.swift
//  MNFoundation
//
//  Created by mellow on 2025/8/20.
//

import UIKit
import Foundation
import CoreGraphics

extension UIScreen {
    
    /// 屏幕尺寸最小值
    @objc public static let Min = {
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            return min(screen.bounds.width, screen.bounds.height)
        }
        let window = UIWindow()
        let screen = window.screen
        if screen.bounds.width > 0.0, screen.bounds.height > 0.0 {
            return min(screen.bounds.width, screen.bounds.height)
        }
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }()
    
    /// 屏幕尺寸最大值
    @objc public static let Max = {
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            return max(screen.bounds.width, screen.bounds.height)
        }
        let window = UIWindow()
        let screen = window.screen
        if screen.bounds.width > 0.0, screen.bounds.height > 0.0 {
            return max(screen.bounds.width, screen.bounds.height)
        }
        return max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }()
    
    /// 当前屏幕宽
    @objc public static var Width: CGFloat {
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            return screen.bounds.width
        }
        return UIScreen.main.bounds.width
    }
    
    /// 当前屏幕高
    @objc public static var Height: CGFloat {
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            return screen.bounds.height
        }
        return UIScreen.main.bounds.height
    }
}
