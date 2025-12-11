//
//  UIScreen+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/20.
//

import UIKit
import Foundation
import CoreFoundation

/// 内部保留屏幕尺寸
fileprivate var MNScreenSize: CGSize?

extension NameSpaceWrapper where Base: UIScreen {
    
    /// 屏幕尺寸最小值
    public class var min: CGFloat {
        if let size = MNScreenSize {
            return Swift.min(size.width, size.height)
        }
        var size: CGSize = .zero
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            size = screen.bounds.size
        } else {
            let window = UIWindow()
            let screen = window.screen
            if screen.bounds.width > 0.0, screen.bounds.height > 0.0 {
                size = screen.bounds.size
            } else {
                size = Base.main.bounds.size
            }
        }
        MNScreenSize = size
        return Swift.min(size.width, size.height)
    }
    
    /// 屏幕尺寸最大值
    public class var max: CGFloat {
        if let size = MNScreenSize {
            return Swift.max(size.width, size.height)
        }
        var size: CGSize = .zero
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            size = screen.bounds.size
        } else {
            let window = UIWindow()
            let screen = window.screen
            if screen.bounds.width > 0.0, screen.bounds.height > 0.0 {
                size = screen.bounds.size
            } else {
                size = Base.main.bounds.size
            }
        }
        MNScreenSize = size
        return Swift.max(size.width, size.height)
    }
    
    /// 当前屏幕宽
    public class var width: CGFloat {
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            return screen.bounds.width
        }
        return Base.main.bounds.width
    }
    
    /// 当前屏幕高
    public class var height: CGFloat {
        if #available(iOS 13.0, *), let screen = UIApplication.shared.delegate?.window??.windowScene?.screen {
            return screen.bounds.height
        }
        return Base.main.bounds.height
    }
}
