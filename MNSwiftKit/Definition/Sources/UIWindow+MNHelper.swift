//
//  UIWindow+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/20.
//

import UIKit
import Foundation
import CoreFoundation

/// 内部保留屏幕安全区域
fileprivate var MNWindowSafeAreaInsets: UIEdgeInsets?

extension MNNameSpaceWrapper where Base: UIWindow {
    
    /// 安全区域
    public class var safeAreaInsets: UIEdgeInsets {
        if let areaInsets = MNWindowSafeAreaInsets { return areaInsets }
        var areaInsets: UIEdgeInsets = .zero
        if #available(iOS 13.0, *), let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }) {
            if #available(iOS 15.0, *), let keyWindow = windowScene.keyWindow {
                areaInsets = keyWindow.safeAreaInsets
            } else if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                areaInsets = keyWindow.safeAreaInsets
            }
        } else if #available(iOS 11.0, *) {
            areaInsets = UIWindow().safeAreaInsets
        }
        MNWindowSafeAreaInsets = areaInsets
        return areaInsets
    }
}
