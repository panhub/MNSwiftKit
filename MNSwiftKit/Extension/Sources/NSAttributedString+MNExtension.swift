//
//  NSAttributedString+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/7/4.
//  富文本辅助方法

import UIKit
import Foundation
import CoreGraphics

extension NameSpaceWrapper where Base: NSAttributedString {
    
    /// 自身范围
    public var rangeOfAll: NSRange {
        NSRange(location: 0, length: base.length)
    }
    
    /// 富文本尺寸
    /// - Parameter width: 最大宽度
    /// - Returns: 尺寸
    public func sizeFit(width: CGFloat) -> CGSize {
        base.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size
    }
    
    /// 富文本尺寸
    /// - Parameter height: 最大高度
    /// - Returns: 尺寸
    public func sizeFit(height: CGFloat) -> CGSize {
        base.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size
    }
}
