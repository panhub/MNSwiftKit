//
//  MNEmoticon.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情

import UIKit
import Foundation

/// 表情
public class MNEmoticon: NSObject {
    
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
    public var style: MNEmoticonPacket.Style = .emoticon
    
    public override init() {
        super.init()
    }
    
    /// 构造表情实例
    /// - Parameter json: 表情描述
    public convenience init?(json: [String:String], in directory: String? = nil) {
        guard let img = json[MNEmoticon.Key.img.rawValue] else { return nil }
        guard let desc = json[MNEmoticon.Key.desc.rawValue] else { return nil }
        var image: UIImage!
        if let directory = directory {
            let path = (directory as NSString).appendingPathComponent(img)
            guard let emoticon = UIImage.image(contentsAtFile: path) else { return nil }
            image = emoticon
        }
        self.init()
        self.img = img
        self.desc = desc
        self.image = image
    }
}

// 表情解析字段
extension MNEmoticon.Key {
    /// 图片字段
    public static let img: MNEmoticon.Key = MNEmoticon.Key(rawValue: "img")
    /// 描述字段
    public static let desc: MNEmoticon.Key = MNEmoticon.Key(rawValue: "desc")
}

