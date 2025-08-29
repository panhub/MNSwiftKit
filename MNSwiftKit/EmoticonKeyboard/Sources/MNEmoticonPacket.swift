//
//  MNEmoticonPacket.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情包

import UIKit
import Foundation

public class MNEmoticonPacket {
    
    public enum Style: Int {
        case emoji, image
    }
    
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
    
    /// 创建时间戳
    public let time: Int
    
    /// 名称
    public let name: String
    
    /// 封面文件名
    public let cover: String
    
    /// 文件目录
    public let directory: String
    
    /// 类型
    public let style: Style
    
    /// 是否允许编辑
    internal var allowsEditing: Bool = false
    
    /// 表情集合
    public internal(set) var emoticons: [MNEmoticon] = [MNEmoticon]()
    
    
    /// 构造表情包
    /// - Parameters:
    ///   - url: json文件地址
    public init?(url: URL) {
        do {
            let jsonData = try Data(contentsOf: url, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let json = jsonObject as? [String:Any] else { return nil }
            guard let rawValue = json[MNEmoticonPacket.Key.style.rawValue] as? Int, let style = MNEmoticonPacket.Style(rawValue: rawValue) else { return nil }
            guard let time = json[MNEmoticonPacket.Key.style.rawValue] as? Int else { return nil }
            guard let cover = json[MNEmoticonPacket.Key.cover.rawValue] as? String else { return nil }
            guard let array = json[MNEmoticonPacket.Key.emoticons.rawValue] as? [[String:String]] else { return nil }
            self.time = time
            self.cover = cover
            self.style = style
            let directoryURL = url.deletingPathExtension()
            self.name = directoryURL.lastPathComponent
            if #available(iOS 16.0, *) {
                self.directory = directoryURL.path(percentEncoded: false)
            } else {
                self.directory = directoryURL.path
            }
            if let value = json[MNEmoticonPacket.Key.editing.rawValue] as? Int, value == 1 {
                self.allowsEditing = true
            }
            let emoticons = array.compactMap { MNEmoticon(json: $0, in: directory) }
            self.emoticons.append(contentsOf: emoticons)
        } catch {
#if DEBUG
            print("解析json失败: \(url)")
#endif
            return nil
        }
    }
}

extension MNEmoticonPacket: Equatable {
    
    public static func == (lhs: MNEmoticonPacket, rhs: MNEmoticonPacket) -> Bool {
        lhs.name == rhs.name
    }
}

extension MNEmoticonPacket.Name: Equatable {
    
    public static func == (lhs: MNEmoticonPacket.Name, rhs: MNEmoticonPacket.Name) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension MNEmoticonPacket.Name {
    /// 默认表情包
    public static let `default`: MNEmoticonPacket.Name = MNEmoticonPacket.Name(rawValue: "default")
    /// 收藏夹
    public static let favorites: MNEmoticonPacket.Name = MNEmoticonPacket.Name(rawValue: "favorites")
}

extension MNEmoticonPacket.Key {
    /// 名字字段
    public static let name: MNEmoticonPacket.Key = MNEmoticonPacket.Key(rawValue: "name")
    /// 样式字段
    public static let style: MNEmoticonPacket.Key = MNEmoticonPacket.Key(rawValue: "style")
    /// 时间字段
    public static let time: MNEmoticonPacket.Key = MNEmoticonPacket.Key(rawValue: "time")
    /// 封面字段
    public static let cover: MNEmoticonPacket.Key = MNEmoticonPacket.Key(rawValue: "cover")
    /// 是否可编辑字段
    public static let editing: MNEmoticonPacket.Key = MNEmoticonPacket.Key(rawValue: "editing")
    /// 表情字段
    public static let emoticons: MNEmoticonPacket.Key = MNEmoticonPacket.Key(rawValue: "emoticons")
}
