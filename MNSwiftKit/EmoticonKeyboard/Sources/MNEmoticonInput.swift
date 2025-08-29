//
//  MNEmoticonInput.swift
//  MNKit
//
//  Created by 小斯 on 2023/2/13.
//  表情输入支持

import UIKit
import Foundation

public protocol MNEmoticonInput {
    /// 字体
    var textFont: UIFont { get }
    /// 表情文字化后的文本
    var plainText: String { get }
    /// 文本选择区域
    var selectedStringRange: NSRange { get set }
    /// 富文本
    var attributedString: NSAttributedString { set get }
}

extension UITextField: MNEmoticonInput {
    
    public var textFont: UIFont {
        font ?? .systemFont(ofSize: 17.0, weight: .regular)
    }
    
    public var plainText: String {
        guard let attributedText = attributedText else { return "" }
        return attributedText.mn.plainString
    }
    
    public var attributedString: NSAttributedString {
        get { attributedText ?? NSAttributedString(string: "") }
        set { attributedText = newValue }
    }
    
    public var selectedStringRange: NSRange {
        get {
            guard let selectedTextRange = selectedTextRange else { return NSRange(location: NSNotFound, length: 0) }
            let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
            let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
            return NSRange(location: location, length: length)
        }
        set {
            if newValue.location == NSNotFound { return }
            guard let startPosition = position(from: beginningOfDocument, offset: newValue.location) else { return }
            guard let endPosition = position(from: beginningOfDocument, offset: NSMaxRange(newValue)) else { return }
            selectedTextRange = textRange(from: startPosition, to: endPosition)
        }
    }
}

extension UITextView: MNEmoticonInput {
    
    public var textFont: UIFont {
        font ?? .systemFont(ofSize: 17.0, weight: .regular)
    }
    
    public var plainText: String {
        guard let attributedText = attributedText else { return "" }
        return attributedText.mn.plainString
    }
    
    public var selectedStringRange: NSRange {
        get { selectedRange }
        set { selectedRange = newValue }
    }
    
    public var attributedString: NSAttributedString {
        get { attributedText ?? NSAttributedString(string: "") }
        set { attributedText = newValue }
    }
}

extension MNEmoticonInput {
    
    /// 输入表情
    /// - Parameter emoji: 表情实例
    public mutating func inputEmoji(_ emoji: MNEmoticon) {
        guard let desc = emoji.desc, desc.count > 0 else { return }
        // 匹配表情附件
        var attachment: MNEmoticonAttachment?
        if let image = emoji.image {
            attachment = MNEmoticonAttachment(image: image, desc: desc)
        } else {
            attachment = MNEmoticonManager.default.matchsEmoji(in: desc).first
        }
        // 制作富文本
        var attributedString: NSAttributedString!
        if let attachment = attachment {
            let string = NSMutableAttributedString(attachment: attachment)
            string.addAttribute(.emojiBacked, value: MNEmoticonBackedString(string: desc), range: NSMakeRange(0, string.length))
            attributedString = string
        } else {
            attributedString = NSAttributedString(string: desc)
        }
        // 拼接富文本
        let attributedText = NSMutableAttributedString(attributedString: self.attributedString)
        let selectedRange = selectedStringRange
        if selectedRange.location == NSNotFound {
            attributedText.append(attributedString)
        } else {
            attributedText.replaceCharacters(in: selectedRange, with: attributedString)
        }
        attributedText.addAttribute(.font, value: textFont, range: NSRange(location: 0, length: attributedText.length))
        self.attributedString = attributedText
        /*
        // 拼接/插入表情
        let attributedString = NSMutableAttributedString(string: desc)
        attributedString.mn.matchsEmoji()
        let attributedText = NSMutableAttributedString(attributedString: self.attributedString)
        let selectedRange = selectedStringRange
        if selectedRange.location == NSNotFound {
            attributedText.append(attributedString)
        } else {
            attributedText.replaceCharacters(in: selectedRange, with: attributedString)
        }
        attributedText.addAttribute(.font, value: textFont, range: NSRange(location: 0, length: attributedText.length))
        self.attributedString = attributedText
        */
        /*
        // 拼接
        let string = NSAttributedString(string: desc, attributes: [.emojiBacked:MNEmoticonBackedString(string: desc)])
        let attributedString = NSMutableAttributedString(attributedString: self.attributedString)
        let selectedRange = selectedStringRange
        if selectedRange.location == NSNotFound {
            attributedString.append(string)
        } else {
            attributedString.replaceCharacters(in: selectedRange, with: string)
        }
        // 重新匹配表情
        let font: UIFont = textFont
        let plainText = attributedString.mn.plainString
        let attributedText = NSMutableAttributedString(string: plainText)
        attributedText.mn.matchsEmoji(with: font)
        attributedText.addAttribute(.font, value: font, range: NSRange(location: 0, length: attributedText.length))
        self.attributedString = attributedText
        */
    }
}
