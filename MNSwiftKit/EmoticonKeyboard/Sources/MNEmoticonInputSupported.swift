//
//  MNEmoticonInputSupported.swift
//  MNSwiftKit
//
//  Created by 小斯 on 2023/2/13.
//  表情输入支持

import UIKit
import Foundation

extension MNNameSpaceWrapper where Base: UITextView {
    
    /// 对attributedText解析表情后的内容
    public var plainText: String {
        get {
            guard let attributedText = base.attributedText else { return "" }
            return attributedText.mn.plainString
        }
        set {
            var font = base.font
            if let attributedText = base.attributedText {
                font = attributedText.mn.font
            }
            let attributedText = NSMutableAttributedString(string: newValue)
            if let font = font {
                attributedText.addAttribute(.font, value: font, range: .init(location: 0, length: attributedText.length))
            }
            attributedText.mn.matchsEmoticon()
            let selectedRange = base.selectedRange
            base.attributedText = attributedText
            if selectedRange.location != NSNotFound {
                base.selectedRange = NSRange(location: attributedText.length, length: 0)
            }
        }
    }
    
    /// 输入表情
    /// - Parameter emoticon: 表情模型
    public func input(emoticon: MNEmoticon) {
        switch emoticon.style {
        case .emoticon:
            input(emoticon.image, desc: emoticon.desc)
        case .unicode:
            input(emoticon.img)
        default: break
        }
    }
    
    /// 输入表情
    /// - Parameters:
    ///   - emoticon: 表情图片
    ///   - desc: 表情描述
    public func input(_ emoticon: UIImage!, desc: String) {
        guard desc.isEmpty == false else { return }
        // 匹配表情附件
        var attachment: MNEmoticonAttachment!
        if let image = emoticon {
            attachment = MNEmoticonAttachment(image: image, desc: desc)
        } else {
            attachment = MNEmoticonManager.shared.matchsEmoticon(in: desc).first
        }
        // 制作富文本
        var attributedString: NSMutableAttributedString!
        if let attachment = attachment {
            attributedString = NSMutableAttributedString(attachment: attachment)
            attributedString.addAttribute(.emoticonBacked, value: MNEmoticonBackedString(string: desc), range: NSMakeRange(0, attributedString.length))
        } else {
            attributedString = NSMutableAttributedString(string: desc)
        }
        let content = base.attributedText ?? NSAttributedString(string: "")
        let font = content.mn.font ?? (base.font ?? .systemFont(ofSize: 17.0, weight: .regular))
        attributedString.addAttribute(.font, value: font, range: NSMakeRange(0, attributedString.length))
        // 拼接富文本
        let attributedText = NSMutableAttributedString(attributedString: content)
        let selectedRange = base.selectedRange
        if selectedRange.location == NSNotFound {
            attributedText.append(attributedString)
        } else {
            attributedText.replaceCharacters(in: selectedRange, with: attributedString)
        }
        base.attributedText = attributedText
        if selectedRange.location != NSNotFound {
            base.selectedRange = NSRange(location: selectedRange.location + attributedString.length, length: 0)
        }
    }
    
    /// 输入内容
    /// - Parameter text: 文本内容
    public func input(_ text: String) {
        let content = base.attributedText ?? NSAttributedString(string: "")
        let font = content.mn.font ?? (base.font ?? .systemFont(ofSize: 17.0, weight: .regular))
        let attributedString = NSAttributedString(string: text, attributes: [.font:font])
        // 拼接富文本
        let attributedText = NSMutableAttributedString(attributedString: content)
        let selectedRange = base.selectedRange
        if selectedRange.location == NSNotFound {
            attributedText.append(attributedString)
        } else {
            attributedText.replaceCharacters(in: selectedRange, with: attributedString)
        }
        base.attributedText = attributedText
        if selectedRange.location != NSNotFound {
            base.selectedRange = NSRange(location: selectedRange.location + attributedString.length, length: 0)
        }
    }
}

extension MNNameSpaceWrapper where Base: UILabel {
    
    /// 对attributedText解析表情后的内容
    public var plainText: String {
        get {
            guard let attributedText = base.attributedText else { return "" }
            return attributedText.mn.plainString
        }
        set {
            var font = base.font
            if let attributedText = base.attributedText {
                font = attributedText.mn.font
            }
            let attributedText = NSMutableAttributedString(string: newValue)
            if let font = font {
                attributedText.addAttribute(.font, value: font, range: .init(location: 0, length: attributedText.length))
            }
            attributedText.mn.matchsEmoticon()
            base.attributedText = attributedText
        }
    }
    
    /// 追加表情
    /// - Parameters:
    ///   - emoticon: 表情图片
    ///   - desc: 表情描述
    public func append(_ emoticon: UIImage!, desc: String) {
        guard desc.isEmpty == false else { return }
        // 匹配表情附件
        var attachment: MNEmoticonAttachment!
        if let image = emoticon {
            attachment = MNEmoticonAttachment(image: image, desc: desc)
        } else {
            attachment = MNEmoticonManager.shared.matchsEmoticon(in: desc).first
        }
        // 制作富文本
        var attributedString: NSMutableAttributedString!
        if let attachment = attachment {
            attributedString = NSMutableAttributedString(attachment: attachment)
            attributedString.addAttribute(.emoticonBacked, value: MNEmoticonBackedString(string: desc), range: NSMakeRange(0, attributedString.length))
        } else {
            attributedString = NSMutableAttributedString(string: desc)
        }
        let content = base.attributedText ?? NSAttributedString(string: "")
        let font = content.mn.font ?? (base.font ?? .systemFont(ofSize: 17.0, weight: .regular))
        attributedString.addAttribute(.font, value: font, range: NSMakeRange(0, attributedString.length))
        // 拼接富文本
        let attributedText = NSMutableAttributedString(attributedString: content)
        attributedText.append(attributedString)
        base.attributedText = attributedText
    }
}
