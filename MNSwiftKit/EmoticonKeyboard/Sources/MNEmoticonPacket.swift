//
//  MNEmoticonPacket.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情包

import UIKit
import Foundation

extension MNEmoticon {
    
    public class Packet {
        
        public struct Name: RawRepresentable {
            
            public let rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
        
        public struct Key: RawRepresentable {
            
            public let rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
        
        /// 名称
        public let name: String
        
        /// 封面文件名
        public let cover: String
        
        /// 文件目录
        public let directory: String
        
        /// 类型
        public let style: MNEmoticon.Style
        
        /// 是否允许编辑
        private(set) var allowsEditing: Bool = false
        
        /// 表情集合
        public internal(set) var emoticons: [MNEmoticon] = []
        
        
        /// 构造表情包
        /// - Parameters:
        ///   - url: json文件地址
        public init?(url: URL) {
            do {
                let jsonData = try Data(contentsOf: url, options: [])
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let json = jsonObject as? [String:Any] else { return nil }
                guard let rawValue = json[MNEmoticon.Packet.Key.style.rawValue] as? Int, let style = MNEmoticon.Style(rawValue: rawValue) else { return nil }
                guard let name = json[MNEmoticon.Packet.Key.name.rawValue] as? String else { return nil }
                guard let cover = json[MNEmoticon.Packet.Key.cover.rawValue] as? String else { return nil }
                guard let array = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] else { return nil }
                self.style = style
                self.name = name
                self.cover = cover
                self.allowsEditing = name == MNEmoticon.Packet.Name.favorites.rawValue
                let directoryURL = url.deletingPathExtension()
                if #available(iOS 16.0, *) {
                    self.directory = directoryURL.path(percentEncoded: false)
                } else {
                    self.directory = directoryURL.path
                }
                let emoticons = array.compactMap { MNEmoticon(json: $0, style: style, in: directory) }
                self.emoticons.append(contentsOf: emoticons)
            } catch {
#if DEBUG
                print("解析表情包失败: \(url)\n\(error)")
#endif
                return nil
            }
        }
    }
}


extension MNEmoticon.Packet: Equatable {
    
    public static func == (lhs: MNEmoticon.Packet, rhs: MNEmoticon.Packet) -> Bool {
        lhs.name == rhs.name
    }
}

extension MNEmoticon.Packet.Name: Equatable {
    
    public static func == (lhs: MNEmoticon.Packet.Name, rhs: MNEmoticon.Packet.Name) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension MNEmoticon.Packet.Name {
    /// 微信表情
    public static let wechat: MNEmoticon.Packet.Name = MNEmoticon.Packet.Name(rawValue: "wechat")
    /// 收藏夹
    public static let favorites: MNEmoticon.Packet.Name = MNEmoticon.Packet.Name(rawValue: "收藏夹")
    /// Unicode - 动物和自然
    public static let animal: MNEmoticon.Packet.Name = MNEmoticon.Packet.Name(rawValue: "animal")
    /// Unicode - 笑脸和情感
    public static let emotion: MNEmoticon.Packet.Name = MNEmoticon.Packet.Name(rawValue: "emotion")
    /// Unicode - 食物和饮料
    public static let food: MNEmoticon.Packet.Name = MNEmoticon.Packet.Name(rawValue: "food")
    /// Unicode - 符号和对象
    public static let symbol: MNEmoticon.Packet.Name = MNEmoticon.Packet.Name(rawValue: "symbol")
    /// Unicode - 交通工具
    public static let vehicle: MNEmoticon.Packet.Name = MNEmoticon.Packet.Name(rawValue: "vehicle")
}

extension MNEmoticon.Packet.Key {
    /// 样式字段
    public static let style: MNEmoticon.Packet.Key = MNEmoticon.Packet.Key(rawValue: "style")
    /// 名字字段
    public static let name: MNEmoticon.Packet.Key = MNEmoticon.Packet.Key(rawValue: "name")
    /// 封面字段
    public static let cover: MNEmoticon.Packet.Key = MNEmoticon.Packet.Key(rawValue: "cover")
    /// 表情字段
    public static let emoticons: MNEmoticon.Packet.Key = MNEmoticon.Packet.Key(rawValue: "emoticons")
}
