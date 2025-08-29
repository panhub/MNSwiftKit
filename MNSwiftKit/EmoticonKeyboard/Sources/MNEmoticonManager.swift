//
//  MNEmoticonManager.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/29.
//  表情管理工具

import UIKit
import Foundation

/// 通知-添加表情键
public let MNEmoticonAddedUserInfoKey: String = "add.emoticon"
/// 通知-删除表情键
public let MNEmoticonRemovedUserInfoKey: String = "removed.emoticon"
/// 通知-删除表情键
public let MNEmoticonPacketNameUserInfoKey: String = "emoticon.packet.name"
/// 表情变化通知
public let MNEmoticonDidChangeNotification: Notification.Name = Notification.Name(rawValue: "com.mn.emoticon.changed")

public class MNEmoticonManager {
    /// 表情检索表达式
    private(set) var expression: NSRegularExpression!
    /// 唯一实例化入口
    public static let shared: MNEmoticonManager = MNEmoticonManager()
    /// 内部加载的表情集合
    private(set) var collections: [MNEmoticonCollection] = []
    /// 用户缓存目录
    public let userCacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/MNEmoticon"
    
    private init() {
        // 表情验证规则
        do {
            // "\\[.+?\\]"
            expression = try NSRegularExpression(pattern: "\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]", options: [])
        } catch {
#if DEBUG
            print("加载表情验证规则出错: \(error)")
#endif
        }
        // 解析表情
        var urls: [URL] = []
        if let elements = EmoticonResource.urls(forResourcesWithExtension: "json") {
            urls.append(contentsOf: elements)
        }
        if let subpaths = FileManager.default.subpaths(atPath: userCacheDirectory) {
            for subpath in subpaths {
                if subpath.hasSuffix("json") {
                    let filePath = (userCacheDirectory as NSString).appendingPathComponent(subpath)
                    if #available(iOS 16.0, *) {
                        urls.append(URL(filePath: filePath))
                    } else {
                        urls.append(URL(fileURLWithPath: filePath))
                    }
                }
            }
        }
        let collections = urls.compactMap { MNEmoticonCollection(url: $0) }
        self.collections.append(contentsOf: collections)
    }
}

// MARK: - 加载表情包
extension MNEmoticonManager {
    
    /// 获取表情包
    /// - Parameter names: 表情包文件名集合
    /// - Returns: 查询结果
    public func fetchEmoticonPacket(_ names: [String]) -> [MNEmoticonPacket] {
        let names = names.compactMap { MNEmoticonPacket.Name(rawValue: $0) }
        return fetchEmoticonPacket(names: names)
    }
    
    /// 获取表情包
    /// - Parameters:
    ///   - names: 表情包文件名集合
    ///   - queue: 执行队列
    ///   - completionHandler: 结果回调
    public class func fetchEmojiPacket(_ names: [String], using queue: DispatchQueue? = nil, completion completionHandler: @escaping ([MNEmoticonPacket])->Void) {
        (queue ?? DispatchQueue.global(qos: .default)).async {
            let packets = MNEmoticonManager.shared.fetchEmoticonPacket(names)
            DispatchQueue.main.async {
                completionHandler(packets)
            }
        }
    }
    
    /// 获取表情包
    /// - Parameter names: 表情包名称集合
    /// - Returns: 查询结果
    public func fetchEmoticonPacket(names: [MNEmoticonPacket.Name]) -> [MNEmoticonPacket] {
        // 解析表情
        var urls: [URL] = []
        for name in names {
            if let url = EmoticonResource.url(forResource: name.rawValue, withExtension: "json")  {
                urls.append(url)
                continue
            }
            let jsonPath = (userCacheDirectory as NSString).appendingPathComponent(name.rawValue + ".json")
            if FileManager.default.fileExists(atPath: jsonPath) {
                if #available(iOS 16.0, *) {
                    urls.append(URL(filePath: jsonPath))
                } else {
                    urls.append(URL(fileURLWithPath: jsonPath))
                }
            }
        }
        var packets = urls.compactMap { MNEmoticonPacket(url: $0) }
        packets.sort { $0.time <= $1.time }
        return packets
    }
    
    /// 获取表情包
    /// - Parameters:
    ///   - names: 表情包名称集合
    ///   - queue: 执行队列
    ///   - completionHandler: 结果回调
    public class func fetchEmojiPacket(names: [MNEmoticonPacket.Name], using queue: DispatchQueue? = nil, completion completionHandler: @escaping ([MNEmoticonPacket])->Void) {
        (queue ?? DispatchQueue.global(qos: .default)).async {
            let packets = MNEmoticonManager.shared.fetchEmoticonPacket(names: names)
            DispatchQueue.main.async {
                completionHandler(packets)
            }
        }
    }
}

// MARK: - 表情
extension MNEmoticonManager {
    
    /// 匹配字符串中的表情
    /// - Parameter string: 字符串
    /// - Returns: 匹配到的表情
    public func matchsEmoji(in string: String) -> [MNEmoticonAttachment] {
        guard let expression = expression else { return [] }
        let results = expression.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        var attachments: [MNEmoticonAttachment] = [MNEmoticonAttachment]()
        for result in results {
            if result.range.location == NSNotFound { continue }
            guard result.range.length > 2 else { continue }
            let desc = (string as NSString).substring(with: result.range)
            guard let image = self[desc] else { continue }
            let attachment = MNEmoticonAttachment()
            attachment.desc = desc
            attachment.image = image
            attachment.range = result.range
            attachments.append(attachment)
        }
        return attachments
    }
    
    /// 获取表情图片
    public subscript(_ desc: String) -> UIImage? {
        guard let path = collections.path(for: desc) else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    /// 获取表情图片
    /// - Parameters:
    ///   - desc: 表情描述
    ///   - packet: 指定表情包
    /// - Returns: 表情图片
    public func emoji(for desc: String, in packet: MNEmoticonPacket.Name) -> UIImage? {
        guard let path = collections.path(for: desc, in: packet.rawValue) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

// MARK: - 收藏夹
extension MNEmoticonManager {
    
    /// 添加图片到收藏夹
    /// - Parameter image: 图片
    /// - Returns: 是否添加成功
    public func addEmojiToFavorites(_ image: UIImage) -> Bool {
        // 解析json
        guard let jsonPath = MNEmoticonKeyboard.bundle?.path(forResource: MNEmoticonPacket.Name.favorites.rawValue, ofType: "json") else { return false }
        let jsonURL: URL?
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        guard let jsonURL = jsonURL else { return false }
        let jsonObject: Any!
        do {
            let jsonData = try Data(contentsOf: jsonURL, options: [])
            jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        } catch {
            return false
        }
        guard var json = jsonObject as? [String:Any] else { return false }
        guard var emojis = json[MNEmoticonPacket.Key.emojis.rawValue] as? [[String:String]] else { return false }
        // 保存图片
        var directoryPath: String!
        if #available(iOS 16.0, *) {
            directoryPath = jsonURL.deletingPathExtension().path()
        } else {
            directoryPath = jsonURL.deletingPathExtension().path
        }
        guard let directoryPath = directoryPath else { return false }
        let time = NSDecimalNumber(value: Int(Date().timeIntervalSince1970*1000.0)).stringValue
        let referencePath = "\(directoryPath)/\(time).png"
        guard let imagePath = image.writeToFile(referencePath: referencePath) else { return false }
        var imageURL: URL?
        if #available(iOS 16.0, *) {
            imageURL = URL(filePath: imagePath)
        } else {
            imageURL = URL(fileURLWithPath: imagePath)
        }
        guard let imageURL = imageURL else { return false }
        // 添加描述
        let emojiJson: [String:String] = [MNEmoticon.Key.img.rawValue:imageURL.lastPathComponent, MNEmoticon.Key.desc.rawValue:"[\(imageURL.deletingPathExtension().lastPathComponent)]"]
        guard let emoji = MNEmoticon(json: emojiJson) else { return false }
        emoji.style = .image
        emoji.image = image
        emojis.insert( emojiJson, at: 1)
        json[MNEmoticonPacket.Key.emojis.rawValue] = emojis
        let dictionary: NSDictionary = json as NSDictionary
        if #available(iOS 11.0, *) {
            do {
                try dictionary.write(to: jsonURL)
            } catch  {
                try? FileManager.default.removeItem(at: imageURL)
                return false
            }
        } else {
            guard dictionary.write(to: jsonURL, atomically: true) else {
                try? FileManager.default.removeItem(at: imageURL)
                return false
            }
        }
        // 通知已添加
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: MNEmoticonDidChangeNotification, object: self, userInfo: [MNEmoticonAddedUserInfoKey:emoji, MNEmoticonPacketNameUserInfoKey:MNEmoticonPacket.Name.favorites])
        }
        return true
    }
    
    /// 异步添加图片到收藏夹
    /// - Parameters:
    ///   - image: 图片
    ///   - queue: 执行队列
    ///   - completionHandler: 结束回调
    public func addEmojiToFavorites(_ image: UIImage, using queue: DispatchQueue? = nil, completion completionHandler: ((Bool)->Void)?) {
        (queue ?? DispatchQueue.global(qos: .default)).async {
            let result = MNEmoticonManager.default.addEmojiToFavorites(image)
            DispatchQueue.main.async {
                completionHandler?(result)
            }
        }
    }
    
    /// 从收藏夹删除表情
    /// - Parameter emoji: 表情
    /// - Returns: 是否删除成功
    public func removeEmojiFromFavorites(_ emoji: MNEmoticon) -> Bool {
        // 依据表情描述删除
        guard let desc = emoji.desc, desc.count > 0 else { return false }
        // 解析json
        guard let jsonPath = MNEmoticonKeyboard.bundle?.path(forResource: MNEmoticonPacket.Name.favorites.rawValue, ofType: "json") else { return false }
        let jsonURL: URL?
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        guard let jsonURL = jsonURL else { return false }
        let jsonObject: Any!
        do {
            let jsonData = try Data(contentsOf: jsonURL, options: [])
            jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        } catch {
            return false
        }
        guard var json = jsonObject as? [String:Any] else { return false }
        guard var emojis = json[MNEmoticonPacket.Key.emojis.rawValue] as? [[String:String]] else { return false }
        emojis.removeAll { emojiJson in
            guard let string = emojiJson[MNEmoticon.Key.desc.rawValue] else { return false }
            return string == desc
        }
        json[MNEmoticonPacket.Key.emojis.rawValue] = emojis
        let dictionary: NSDictionary = json as NSDictionary
        if #available(iOS 11.0, *) {
            do {
                try dictionary.write(to: jsonURL)
            } catch  {
                return false
            }
        } else {
            guard dictionary.write(to: jsonURL, atomically: true) else { return false }
        }
        // 删除图片
        if let img = emoji.img, img.count > 0 {
            let imageURL = jsonURL.deletingPathExtension().appendingPathComponent(img)
            try? FileManager.default.removeItem(at: imageURL)
        }
        // 通知已删除
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: MNEmoticonDidChangeNotification, object: self, userInfo: [MNEmoticonRemovedUserInfoKey:emoji,MNEmoticonPacketNameUserInfoKey:MNEmoticonPacket.Name.favorites])
        }
        return true
    }
    
    /// 异步从收藏夹删除表情
    /// - Parameters:
    ///   - emoji: 表情
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public func removeEmojiFromFavorites(_ emoji: MNEmoticon, using queue: DispatchQueue? = nil, completion completionHandler: ((Bool)->Void)?) {
        (queue ?? DispatchQueue.global(qos: .default)).async {
            let result = MNEmoticonManager.default.removeEmojiFromFavorites(emoji)
            DispatchQueue.main.async {
                completionHandler?(result)
            }
        }
    }
}
