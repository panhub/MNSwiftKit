//
//  MNEmoticon.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情

import UIKit
import Foundation

/// 表情
public class MNEmoticon {
    
    @objc(MNEmoticonStyle)
    public enum Style: Int {
        case emoticon, image
    }
    
    public struct Key: RawRepresentable {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    /// 图片名
    public var img: String!
    /// 表情描述
    public var desc: String!
    /// 图像实例
    public var image: UIImage!
    /// 类型
    public var style: MNEmoticon.Style = .emoticon
    
    fileprivate init() {}
    
    /// 构造表情实例
    /// - Parameter json: 表情描述
    public init?(json: [String:String], style: MNEmoticon.Style = .emoticon, in directory: String? = nil) {
        guard let img = json[MNEmoticon.Key.img.rawValue], img.isEmpty == false else { return nil }
        guard let desc = json[MNEmoticon.Key.desc.rawValue], desc.isEmpty == false else { return nil }
        var image: UIImage!
        if let directory = directory {
            let path = directory.appendingPathComponent(img)
            guard let emoticon = UIImage.image(contentsAtFile: path) else { return nil }
            image = emoticon
        }
        self.img = img
        self.desc = desc
        self.image = image
    }
}

extension MNEmoticon {
    
    class Adding: MNEmoticon {
        
        override init() {
            super.init()
            img = "add.png"
            desc = "[添加]"
            style = .image
            image = EmoticonResource.image(named: "add")
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

