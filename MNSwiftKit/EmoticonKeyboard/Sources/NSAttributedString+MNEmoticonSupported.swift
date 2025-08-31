//
//  NSAttributedString+MNEmojiSupported.swift
//  MNSwiftKit
//
//  Created by 小斯 on 2023/2/13.
//

import UIKit
import Foundation


extension NameSpaceWrapper where Base: NSAttributedString {
    
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
        base.enumerateAttribute(.emojiBacked, in: range) { backed, subRange, stop in
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
    public func matchsEmoticon(font: UIFont! = nil) {
        let attachments: [MNEmoticonAttachment] = MNEmoticonManager.shared.matchsEmoticon(in: base.string)
        guard attachments.isEmpty == false else { return }
        var offset : Int = 0
        let bounds: CGRect = font == nil ? .zero : CGRect(x: 0.0, y: font.descender, width: font.lineHeight, height: font.lineHeight)
        for attachment in attachments {
            attachment.bounds = bounds
            let attributedString = NSMutableAttributedString(attachment: attachment)
            attributedString.addAttribute(.emojiBacked, value: MNEmoticonBackedString(string: attachment.desc), range: NSRange(location: 0, length: attributedString.length))
            let range = NSRange(location: attachment.range.location - offset, length: attachment.range.length)
            base.replaceCharacters(in: range, with: attributedString)
            offset += (attachment.range.length - attributedString.length)
        }
    }
}
