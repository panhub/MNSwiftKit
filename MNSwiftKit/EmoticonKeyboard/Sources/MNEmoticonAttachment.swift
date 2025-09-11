//
//  MNEmoticonAttachment.swift
//  MNSwiftKit
//
//  Created by 小斯 on 2023/2/13.
//  表情配件

import UIKit

/// 表情配件
public class MNEmoticonAttachment: NSTextAttachment {
    /// 描述
    public var desc: String = ""
    /// 匹配范围
    public var range: NSRange = NSRange(location: 0, length: 0)
    
    /// 构建表情附件
    /// - Parameters:
    ///   - image: 表情图片
    ///   - desc: 表情描述
    public convenience init(image: UIImage, desc: String) {
        self.init()
        self.desc = desc
        self.image = image
    }
    
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        return bounds == .zero ? CGRect(x: 0.0, y: position.y - lineFrag.height, width: lineFrag.height, height: lineFrag.height) : bounds
    }
}
