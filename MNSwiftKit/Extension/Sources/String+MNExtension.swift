//
//  String+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/15.
//

import UIKit
import Foundation
import CoreFoundation

extension MNNameSpaceWrapper where Base == String {
    
    // String => Bool
    public var boolValue: Bool {
        if (base as NSString).boolValue { return true }
        switch base.lowercased() {
        case "1", "true", "t", "yes", "y", "enable", "enabled", "on": return true
        default: return false
        }
    }
    
    // String => Int
    public var intValue: Int { (base as NSString).integerValue }
    
    // String => Int64
    public var int64Value: Int64 { (base as NSString).longLongValue }
    
    // String => Double
    public var doubleValue: Double { (base as NSString).doubleValue }
    
    /// 自身范围
    public var rangeOfAll: NSRange { NSRange(location: 0, length: base.utf16.count) }
    
    /// 截取字符串
    /// - Parameter index: 截取开始索引
    /// - Returns: 截取后的字符串
    public func substring(from index: Int) -> String {
        (base as NSString).substring(from: index)
    }
    
    /// 截取字符串
    /// - Parameter index: 截取停止索引
    /// - Returns: 截取后的字符串
    public func substring(to index: Int) -> String {
        (base as NSString).substring(to: index)
    }
    
    /// 截取字符串
    /// - Parameter range: 截取范围
    /// - Returns: 截取后的字符串
    public func substring(with range: NSRange) -> String {
        (base as NSString).substring(with: range)
    }
    
    /// 计算文本尺寸
    /// - Parameter font: 字体
    /// - Returns: 尺寸
    public func size(with font: UIFont) -> CGSize {
        base.size(withAttributes: [.font:font])
    }
    
    /// 计算文本尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - bounding: 尺寸范围
    /// - Returns: 文本尺寸
    public func size(with font: UIFont, bounding: CGSize) -> CGSize {
        base.boundingRect(with: bounding, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil).size
    }
    
    /// 计算文本尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - width: 最大宽度
    /// - Returns: 文本尺寸
    public func size(with font: UIFont, width: CGFloat) -> CGSize {
        size(with: font, bounding: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    /// 计算文本尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - height: 最大高度
    /// - Returns: 文本尺寸
    public func size(with font: UIFont, height: CGFloat) -> CGSize {
        size(with: font, bounding: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height))
    }
    
    /// 倒叙字符串
    public var reversed: String { String(base.reversed()) }
    
    /// 倒叙
    /// - Parameter separator: 分割符
    /// - Returns: 倒叙结果
    public func reversed(separatedBy separator: String) -> String {
        let components = base.components(separatedBy: separator)
        return components.reversed().joined(separator: separator)
    }
    
    /// 判断字符串是否全是数字
    public var isAllDigits: Bool {
        guard base.isEmpty == false else { return false }
        let digitCharacterSet: CharacterSet = .decimalDigits
        return base.unicodeScalars.allSatisfy { digitCharacterSet.contains($0) }
    }
    
    /// 是否是空字符串
    /// eg: "", " ", "\t\r\n", "\u{00a0}";
    public var isBlank: Bool {
        base.allSatisfy { $0.isWhitespace }
    }
}


extension MNNameSpaceWrapper where Base == String {
    
    /// 根据下标获取字符串
    public subscript(of index: Int) -> String {
        guard index >= 0, index < base.count else { return "" }
        return String(base[base.index(base.startIndex, offsetBy: index)])
    }
    
    /// 根据闭区间获取字符串 eg: a[1...3]
    public subscript(range: ClosedRange<Int>) -> String {
        let start = base.index(base.startIndex, offsetBy: Swift.max(range.lowerBound, 0))
        let end = base.index(base.startIndex, offsetBy: Swift.min(range.upperBound, base.count - 1))
        return String(base[start...end])
    }
    
    /// 根据半开半闭区间获取字符串 eg: a[1..<3]
    public subscript(range: Range<Int>) -> String {
        let start = base.index(base.startIndex, offsetBy: Swift.max(range.lowerBound, 0))
        let end = base.index(base.startIndex, offsetBy: Swift.min(range.upperBound, base.count))
        return String(base[start..<end])
    }
    
    /// 根据半区间获取字符串 eg: a[...2]
    public subscript(range: PartialRangeThrough<Int>) -> String {
        let end = base.index(base.startIndex, offsetBy: Swift.min(range.upperBound, base.count - 1))
        return String(base[base.startIndex...end])
    }

    /// 根据半区间获取字符串 eg: a[0...]
    public subscript(range: PartialRangeFrom<Int>) -> String {
        let start = base.index(base.startIndex, offsetBy: Swift.max(range.lowerBound, 0))
        let end = base.index(base.startIndex, offsetBy: base.count - 1)
        return String(base[start...end])
    }

    /// 根据半区间获取字符串 eg: a[..<3]
    public subscript(range: PartialRangeUpTo<Int>) -> String {
        let end = base.index(base.startIndex, offsetBy: Swift.min(range.upperBound, base.count))
        return String(base[base.startIndex..<end])
    }
}
