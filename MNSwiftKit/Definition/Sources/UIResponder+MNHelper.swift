//
//  UIResponder+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/8/2.
//  核心扩展方法

import UIKit
import Foundation
import CoreGraphics

extension UIResponder {
    
    /// 寻找符合条件的响应者
    /// - Parameter cls: 指定类型
    /// - Returns: 响应者
    public func seek<T>(as cls: T.Type) -> T? {
        var next = next
        while let responder = next {
            if responder is T { return responder as? T }
            next = responder.next
        }
        return nil
    }
}
