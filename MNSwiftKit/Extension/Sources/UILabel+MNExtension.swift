//
//  UILabel+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/14.
//

import UIKit
import Foundation

extension MNNameSpaceWrapper where Base: UILabel {
    
    /// 以宽度约束尺寸
    public func sizeFitToWidth() {
        if let attributedText = base.attributedText {
            // 富文本
            var frame = base.frame
            let size = attributedText.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size
            frame.size.height = size.height
            base.frame = frame
        } else if let text = base.text {
            // 文字
            let font = base.font ?? .systemFont(ofSize: 17.0, weight: .regular)
            var frame = base.frame
            let size = NSAttributedString(string: text, attributes: [.font:font]).boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size
            frame.size.height = size.height
            base.frame = frame
        }
    }
    
    /// 以高度约束尺寸
    public func sizeFitToHeight() {
        if let attributedText = base.attributedText {
            // 富文本
            var frame = base.frame
            let size = attributedText.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height), options: .usesLineFragmentOrigin, context: nil).size
            frame.size.width = size.width
            base.frame = frame
        } else if let text = base.text {
            // 文字
            let font = base.font ?? .systemFont(ofSize: 17.0, weight: .regular)
            var frame = base.frame
            let size = NSAttributedString(string: text, attributes: [.font:font]).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height), options: .usesLineFragmentOrigin, context: nil).size
            frame.size.width = size.width
            base.frame = frame
        }
    }
}
