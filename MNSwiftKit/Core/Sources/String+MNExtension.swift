//
//  String+MNExtension.swift
//  MNFoundation
//
//  Created by MNFoundation on 2021/7/15.
//

import UIKit
import Foundation
import CoreGraphics

extension String {
    // String => Bool
    public var boolValue: Bool {
        guard (self as NSString).boolValue == false else { return true }
        switch self {
        case "1", "true", "yes", "YES", "y", "Y": return true
        default: return false
        }
    }
    // String => Int
    public var intValue: Int { (self as NSString).integerValue }
    // String => Int64
    public var int64Value: Int64 { (self as NSString).longLongValue }
    // String => Double
    public var doubleValue: Double { (self as NSString).doubleValue }
}

// MARK: - 字符串截取
extension String {
    
    /// 自身范围
    public var rangeOfAll: NSRange { NSRange(location: 0, length: count) }
    
    public func sub(from index: Int) -> String {
        (self as NSString).substring(from: index)
    }
    
    public func sub(to index: Int) -> String {
        (self as NSString).substring(to: index)
    }
    
    public func sub(with range: NSRange) -> String {
        (self as NSString).substring(with: range)
    }
}

// MARK: - 计算尺寸
extension String {
    
    /// 计算文本尺寸
    /// - Parameter font: 字体
    /// - Returns: 尺寸
    public func size(font: UIFont) -> CGSize {
        return self.size(withAttributes: [.font:font])
    }
    
    /// 计算文本尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - bounding: 尺寸范围
    /// - Returns: 文本尺寸
    public func size(font: UIFont, bounding: CGSize) -> CGSize {
        return self.boundingRect(with: bounding, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil).size
    }
    
    /// 计算文本尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - width: 最大宽度
    /// - Returns: 文本尺寸
    public func size(font: UIFont, width: CGFloat) -> CGSize {
        return size(font: font, bounding: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    /// 计算文本尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - height: 最大高度
    /// - Returns: 文本尺寸
    public func size(font: UIFont, height: CGFloat) -> CGSize {
        return size(font: font, bounding: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height))
    }
}

extension String {
    
    /// 倒叙字符串
    public var reversed: String { String(reversed()) }
    
    /// 倒叙
    /// - Parameter separator: 分割符
    /// - Returns: 倒叙结果
    public func reversed(separatedBy separator: String) -> String {
        let components = components(separatedBy: separator)
        return components.reversed().joined(separator: separator)
    }
    
    /// 判断字符串是否全是数字
    public var isNumberString: Bool {
        guard count > 0 else { return false }
        let scanner: Scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = CharacterSet()
        return (scanner.scanInt64(nil) && scanner.isAtEnd)
    }
}

extension String {
    
    /// 是否是空字符串
    /// eg: "", " ", "\t\r\n", "\u{00a0}";
    public var isBlank: Bool {
        allSatisfy { $0.isWhitespace }
    }
}
