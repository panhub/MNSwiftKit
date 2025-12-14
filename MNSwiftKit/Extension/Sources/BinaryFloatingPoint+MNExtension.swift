//
//  BinaryFloatingPoint+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/9/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

extension MNNameSpaceWrapper where Base: BinaryFloatingPoint {
    
    /// 百分比形式字符串, 不允许小数部分
    public var percent: String {
        
        percentFormat(fraction: 0)
    }
    
    /// 格式化百分比形式字符串
    /// - Parameters:
    ///   - digits: 小数位最大数量
    /// - Returns: 格式化后字符串
    public func percentFormat(fraction digits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = digits
        formatter.usesGroupingSeparator = false
        formatter.alwaysShowsDecimalSeparator = false
        let number = NSNumber(value: Double(base))
        return formatter.string(from: number)!
    }
}
