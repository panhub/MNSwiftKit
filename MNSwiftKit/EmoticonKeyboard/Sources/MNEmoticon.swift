//
//  MNEmoticon.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情

import UIKit
import Foundation

/// 表情
public class MNEmoticon: NSObject {
    
    @objc(MNEmoticonStyle)
    public enum Style: Int {
        /// 类似于微信表情
        case emoticon
        /// Unicode形式
        case unicode
        /// 图片
        case image
    }
    
    public struct Key: RawRepresentable {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    /// 图片名
    public private(set) var img: String!
    /// 表情描述
    public private(set) var desc: String!
    /// 图像实例
    public private(set) var image: UIImage!
    /// 类型
    public private(set) var style: MNEmoticon.Style = .emoticon
    
    fileprivate override init() {
        super.init()
    }
    
    /// 构造表情实例
    /// - Parameter json: 表情描述
    public init?(json: [String:String], style: MNEmoticon.Style = .emoticon, in directory: String) {
        guard var img = json[MNEmoticon.Key.img.rawValue], img.isEmpty == false else { return nil }
        guard let desc = json[MNEmoticon.Key.desc.rawValue], desc.isEmpty == false else { return nil }
        if style == .unicode {
            if let codePoint = UInt32(img, radix: 16), let scalar = UnicodeScalar(codePoint) {
                let character = Character(scalar)
                img = String(character)
            }
        } else {
            let imagePath = (directory as NSString).appendingPathComponent(img)
            guard let image = UIImage.mn.image(contentsAtFile: imagePath) else { return nil }
            self.image = image
        }
        self.img = img
        self.style = style
        self.desc = desc
    }
}

extension MNEmoticon {
    
    class Adding: MNEmoticon {
        
        override init() {
            super.init()
            img = "add.png"
            desc = "[添加]"
            style = .image
            image = EmoticonKeyboardResource.image(named: "add")
        }
    }
}

// 表情解析字段
extension MNEmoticon.Key {
    /// 图片字段
    public static let img: MNEmoticon.Key = MNEmoticon.Key(rawValue: "img")
    /// 描述字段
    public static let desc: MNEmoticon.Key = MNEmoticon.Key(rawValue: "desc")
}

