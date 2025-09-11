//
//  NSAttributedString+MNEmoticonSupported.swift
//  MNSwiftKit
//
//  Created by 小斯 on 2023/2/13.
//

import UIKit
import Foundation


extension NameSpaceWrapper where Base: NSAttributedString {
    
    /// 主要字体
    public var font: UIFont? {
        var fonts: [UIFont:Int] = [:]
        base.enumerateAttribute(.font, in: NSRange(location: 0, length: base.length)) { value, range, _ in
            guard let font = value as? UIFont else { return }
            var length = range.length
            if let count = fonts[font] {
                length += count
            }
            fonts[font] = length
        }
        var length = 0
        var font: UIFont?
        for item in fonts {
            guard item.value > length else { continue }
            font = item.key
            length = item.value
        }
        return font
    }
    
    /// 主要颜色
    public var foregroundColor: UIColor? {
        var colors: [UIColor:Int] = [:]
        base.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: base.length)) { value, range, _ in
            guard let color = value as? UIColor else { return }
            var length = range.length
            if let count = colors[color] {
                length += count
            }
            colors[color] = length
        }
        var length = 0
        var color: UIColor?
        for item in colors {
            guard item.value > length else { continue }
            color = item.key
            length = item.value
        }
        return color
    }
    
    /// 获取全部范围
    public var rangeOfAll: NSRange {
        NSRange(location: 0, length: base.length)
    }
    
    /// 去除表情后的简单字符串
    public var plainString: String {
        plainString(in: NSRange(location: 0, length: base.length))
    }
    
    /// 去除表情后的简单字符串
    /// - Parameter range: 范围
    /// - Returns: 简单字符串
    public func plainString(in range: NSRange) -> String {
        if range.location == NSNotFound { return "" }
        guard NSMaxRange(range) <= base.length else { return "" }
        var result: String = ""
        let string: String = base.string
        base.enumerateAttribute(.emoticonBacked, in: range) { backed, subRange, _ in
            if let backed = backed as? MNEmoticonBackedString {
                result.append(backed.string)
            } else {
                result.append((string as NSString).substring(with: subRange))
            }
        }
        return result
    }
}

extension NameSpaceWrapper where Base: NSMutableAttributedString {
    
    /// 匹配表情
    /// - Parameter font: 字体
    public func matchsEmoticon(with font: UIFont! = nil) {
        let attachments: [MNEmoticonAttachment] = MNEmoticonManager.shared.matchsEmoticon(in: base.string)
        guard attachments.isEmpty == false else { return }
        var offset : Int = 0
        let textFont = font ?? self.font
        for attachment in attachments {
            let attributedString = NSMutableAttributedString(attachment: attachment)
            attributedString.addAttribute(.emoticonBacked, value: MNEmoticonBackedString(string: attachment.desc), range: NSRange(location: 0, length: attributedString.length))
            if let textFont = textFont {
                attachment.bounds = CGRect(x: 0.0, y: textFont.descender, width: textFont.lineHeight, height: textFont.lineHeight)
                attributedString.addAttribute(.font, value: textFont, range: NSRange(location: 0, length: attributedString.length))
            }
            let range = NSRange(location: attachment.range.location - offset, length: attachment.range.length)
            base.replaceCharacters(in: range, with: attributedString)
            offset += (attachment.range.length - attributedString.length)
        }
    }
}
