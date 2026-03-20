//
//  UIColor+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/15.
//  颜色扩展

import UIKit
import Foundation

// MARK: - 颜色值
extension UIColor {
    
    /// 实例化颜色
    /// - Parameters:
    ///   - hex: 16进制颜色值
    ///   - alpha: 透明度
    @objc(mn_initWithHexString:alpha:)
    public convenience init(mn_hex hex: String, alpha: CGFloat = 1.0) {
        var alpha = alpha
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
    
    /// 实例化颜色
    /// - Parameters:
    ///   - value: 6进制颜色值
    ///   - alpha: 透明度
    @objc(mn_initWithHexValue:alpha:)
    public convenience init(mn_hex value: Int, alpha: CGFloat = 1.0) {
        if (0x000000 ... 0xFFFFFF) ~= value {
            self.init(red: CGFloat((value & 0xFF0000) >> 16)/255.0, green: CGFloat((value & 0x00FF00) >> 8)/255.0, blue: CGFloat((value & 0x0000FF) >> 0)/255.0, alpha: alpha)
        } else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
        }
    }
    
    /// 实例化颜色
    /// - Parameters:
    ///   - red: 红色值 (0.0-255.0)
    ///   - green: 绿色值 (0.0-255.0)
    ///   - blue: 蓝色值 (0.0-255.0)
    ///   - alpha: 透明度 (0.0-1.0)
    public convenience init(mn_red red: any BinaryFloatingPoint, green: any BinaryFloatingPoint, blue: any BinaryFloatingPoint, alpha: any BinaryFloatingPoint = 1.0) {
        let r = CGFloat(red)
        let g = CGFloat(green)
        let b = CGFloat(blue)
        let a = CGFloat(alpha)
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    /// 实例化颜色
    /// - Parameters:
    ///   - value: 红绿蓝色值 (0.0-255.0)
    ///   - alpha: 透明度 (0.0-1.0)
    public convenience init(mn_rgb value: any BinaryFloatingPoint, alpha: any BinaryFloatingPoint = 1.0) {
        self.init(mn_red: value, green: value, blue: value, alpha: alpha)
    }
}

extension MNNameSpaceWrapper where Base: UIColor {
    
    /// 随机颜色
    public class var random: UIColor {
        let red: CGFloat = .random(in: 0.0...255.0)/255.0
        let green: CGFloat = .random(in: 0.0...255.0)/255.0
        let blue: CGFloat = .random(in: 0.0...255.0)/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 反色
    public var reversed: UIColor? {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        guard base.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
    }
    
    /// 16进制颜色值
    public var hexString: String {
        let multiplier: CGFloat = 255.999999
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        guard base.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return "#000000" }
        if alpha >= 1.0 {
            return String(format: "#%02lX%02lX%02lX", Int(red*multiplier), Int(green*multiplier), Int(blue*multiplier))
        }
        return String(format: "#%02lX%02lX%02lX%.2f", Int(red*multiplier), Int(green*multiplier), Int(blue*multiplier), alpha)
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
extension Color {
    
    /// 实例化颜色
    /// - Parameters:
    ///   - red: 红色值 (0.0-255.0)
    ///   - green: 绿色值 (0.0-255.0)
    ///   - blue: 蓝色值 (0.0-255.0)
    ///   - opacity: 透明度 (0.0-1.0)
    public init(mn_red red: any BinaryFloatingPoint, green: any BinaryFloatingPoint, blue: any BinaryFloatingPoint, opacity: any BinaryFloatingPoint = 1.0) {
        
        self.init(.sRGB, red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0, opacity: Double(opacity))
    }
    
    /// 实例化颜色
    /// - Parameters:
    ///   - hex: 16进制颜色值
    public init(mn_hex string: String) {
        let hex = string.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, int >> 24)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(.sRGB, red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: Double(a) / 255.0)
    }
}
#endif
