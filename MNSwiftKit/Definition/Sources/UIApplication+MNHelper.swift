//
//  UIApplication+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/20.
//

import UIKit
import Foundation

/// 内部保留状态栏高度
fileprivate var MNApplicationStatusBarHeight: CGFloat?

extension MNNameSpaceWrapper where Base: UIApplication {
    
    /// 状态栏高度
    public class var statusBarHeight: CGFloat {
        if let height = MNApplicationStatusBarHeight { return height }
        var height: CGFloat = 0.0
        if #available(iOS 13.0, *), let windowScene = Base.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }), let statusBarManager = windowScene.statusBarManager {
            height = statusBarManager.statusBarFrame.height
        } else {
            height = Base.shared.statusBarFrame.height
        }
        MNApplicationStatusBarHeight = height
        return height
    }
}
