//
//  UINavigationBar+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/20.
//

import UIKit
import Foundation
import CoreGraphics

/// 内部保留导航栏高度
fileprivate var MNNavigationBarHeight: CGFloat?

extension NameSpaceWrapper where Base: UINavigationBar {
    
    /// 导航栏高度
    public class var height: CGFloat {
        if let height = MNNavigationBarHeight { return height }
        var height: CGFloat = 0.0
        if Thread.isMainThread {
            height = UINavigationController().navigationBar.frame.height
        } else {
            DispatchQueue.main.sync {
                height = UINavigationController().navigationBar.frame.height
            }
        }
        MNNavigationBarHeight = height
        return height
    }
}
