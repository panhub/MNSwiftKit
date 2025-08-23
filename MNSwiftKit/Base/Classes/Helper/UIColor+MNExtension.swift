//
//  UIColor+MNExtension.swift
//  MNKit
//
//  Created by 冯盼 on 2021/10/15.
//  颜色扩展

import UIKit
import Foundation

// MARK: - 颜色值
extension UIColor {
    
    /// 随机颜色
    public class var random: UIColor {
        let red: CGFloat = .random(in: 0.0...255.0)/255.0
        let green: CGFloat = .random(in: 0.0...255.0)/255.0
        let blue: CGFloat = .random(in: 0.0...255.0)/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 反色
    public var filter: UIColor? {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
    }
    
    /// 实例化颜色
    /// - Parameters:
    ///   - hex: 16进制颜色值
    ///   - alpha: 透明度
    @objc public convenience init(hex: String) {
        var alpha: CGFloat = 1.0
        var string = hex.replacingOccurrences(of: " ", with: "")
        // 存储转换后的数值
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        // 如果传入的十六进制颜色有前缀则去掉前缀
        if string.hasPrefix("0x") || string.hasPrefix("0X") {
            string = String(string[string.index(string.startIndex, offsetBy: 2)...])
        } else if string.hasPrefix("#") {
            string = String(string[string.index(string.startIndex, offsetBy: 1)...])
        }
        // 如果传入的字符数量不足6位按照后边都为0处理
        if string.count < 6 {
            string += [String](repeating: "0", count: 6 - string.count).joined(separator: "")
        } else if string.count > 6 {
            let other = String(string[string.index(string.startIndex, offsetBy: 6)...])
            alpha = CGFloat(NSDecimalNumber(string: other).doubleValue)
            string = String(string[..<string.index(string.startIndex, offsetBy: 6)])
        }
        // 红
        Scanner(string: String(string[..<string.index(string.startIndex, offsetBy: 2)])).scanHexInt64(&red)
        // 绿
        Scanner(string: String(string[string.index(string.startIndex, offsetBy: 2)..<string.index(string.startIndex, offsetBy: 4)])).scanHexInt64(&green)
        // 蓝
        Scanner(string: String(string[string.index(string.startIndex, offsetBy: 4)...])).scanHexInt64(&blue)
        // 实例化
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    @objc public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    @objc public convenience init(all value: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: value/255.0, green: value/255.0, blue: value/255.0, alpha: alpha)
    }
    
    /// 16进制颜色值
    @objc public var rawHex: String {
        let multiplier: CGFloat = 255.999999
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return "#000000" }
        if alpha >= 1.0 {
            return String(format: "#%02lX%02lX%02lX", Int(red*multiplier), Int(green*multiplier), Int(blue*multiplier))
        }
        return String(format: "#%02lX%02lX%02lX%.2f", Int(red*multiplier), Int(green*multiplier), Int(blue*multiplier), alpha)
    }
}
