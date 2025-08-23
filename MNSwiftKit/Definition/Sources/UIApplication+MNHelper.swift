//
//  UIApplication+MNHelper.swift
//  MNSwiftKit
//
//  Created by mellow on 2025/8/20.
//

import UIKit
import Foundation

extension UIApplication {
    
    /// 状态栏高度
    @objc public static let StatusBarHeight: CGFloat = {
        if #available(iOS 13.0, *) {
            guard let statusBarManager = UIApplication.shared.delegate?.window??.windowScene?.statusBarManager else { return 0.0 }
            return statusBarManager.statusBarFrame.height
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }()
}
