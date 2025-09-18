//
//  UIWindow+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/20.
//

import UIKit
import Foundation
import CoreGraphics

/// 内部保留屏幕安全区域
fileprivate var MNWindowSafeAreaInsets: UIEdgeInsets?

extension NameSpaceWrapper where Base: UIWindow {
    
    /// 安全区域
    public class var safeAreaInsets: UIEdgeInsets {
        if let areaInsets = MNWindowSafeAreaInsets { return areaInsets }
        var areaInsets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            if Thread.isMainThread {
                areaInsets = UIWindow().safeAreaInsets
            } else {
                DispatchQueue.main.sync {
                    areaInsets = UIWindow().safeAreaInsets
                }
            }
        }
        MNWindowSafeAreaInsets = areaInsets
        return areaInsets
    }
}
