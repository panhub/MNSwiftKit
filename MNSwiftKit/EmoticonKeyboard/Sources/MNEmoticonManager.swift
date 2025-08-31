//
//  MNEmoticonManager.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/29.
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
    private let expression: NSRegularExpression = try! NSRegularExpression(pattern: "\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]", options: [])
    /// 唯一实例化入口
    public static let shared: MNEmoticonManager = MNEmoticonManager()
    /// 内部加载的表情集合
    private(set) var collections: [MNEmoticonCollection] = []
    /// 用户缓存目录
    public let userCacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/MNEmoticon"
    /// 收藏夹路径
    public private(set) lazy var favoritesDirectory = userCacheDirectory.appendingPathComponent(MNEmoticon.Packet.Name.favorites.rawValue)
    
    private init() {
        // 解析表情
        var urls: [URL] = []
        if let elements = EmoticonResource.urls(forResourcesWithExtension: "json") {
            urls.append(contentsOf: elements)
        }
        if let subpaths = FileManager.default.subpaths(atPath: userCacheDirectory) {
            for subpath in subpaths {
                if subpath.pathExtension == "json" {
                    let jsonPath = userCacheDirectory.appendingPathComponent(subpath)
                    if #available(iOS 16.0, *) {
                        urls.append(URL(filePath: jsonPath))
                    } else {
                        urls.append(URL(fileURLWithPath: jsonPath))
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
    public func fetchEmoticonPacket(_ names: [String]) -> [MNEmoticon.Packet] {
        // 先去重
        let elements = names.reduce(into: [String]()) { partialResult, name in
            guard partialResult.contains(name) == false else { return }
            partialResult.append(name)
        }
        // 解析表情
        var urls: [URL] = []
        for name in elements {
            if let url = EmoticonResource.url(forResource: name, withExtension: "json")  {
                urls.append(url)
                continue
            }
            let jsonPath = userCacheDirectory.appendingPathComponent(name + ".json")
            var jsonURL: URL!
            if #available(iOS 16.0, *) {
                jsonURL = URL(filePath: jsonPath)
            } else {
                jsonURL = URL(fileURLWithPath: jsonPath)
            }
            if FileManager.default.fileExists(atPath: jsonPath) {
                urls.append(jsonURL)
            } else if name == MNEmoticon.Packet.Name.favorites.rawValue {
                // 没有收藏夹, 主动创建
                if FileManager.default.fileExists(atPath: favoritesDirectory) == false {
                    do {
                        try FileManager.default.createDirectory(atPath: favoritesDirectory, withIntermediateDirectories: true)
                    } catch {
#if DEBUG
                        print("创建收藏夹文件夹失败: \(error)")
#endif
                        continue
                    }
                }
                // 创建json文件
                let json: [String:Any] = [
                    MNEmoticon.Packet.Key.time.rawValue:1,
                    MNEmoticon.Packet.Key.favorites.rawValue:1,
                    MNEmoticon.Packet.Key.style.rawValue:MNEmoticon.Style.image.rawValue,
                    MNEmoticon.Packet.Key.cover.rawValue:"favorites.png",
                    MNEmoticon.Packet.Key.emoticons.rawValue:[[String:String]]()
                ]
                if #available(iOS 11.0, *) {
                    do {
                        try (json as NSDictionary).write(to: jsonURL)
                    } catch  {
                        try? FileManager.default.removeItem(atPath: favoritesDirectory)
        #if DEBUG
                        print("创建收藏夹json失败: \(error)")
        #endif
                        continue
                    }
                } else {
                    guard (json as NSDictionary).write(to: jsonURL, atomically: true) else {
                        try? FileManager.default.removeItem(atPath: favoritesDirectory)
        #if DEBUG
                        print("创建收藏夹json失败")
        #endif
                        continue
                    }
                }
                urls.append(jsonURL)
            }
        }
        var packets = urls.compactMap { MNEmoticon.Packet(url: $0) }
        packets.sort { $0.time <= $1.time }
        return packets
    }
    
    /// 获取表情包
    /// - Parameters:
    ///   - names: 表情包文件名集合
    ///   - queue: 执行队列
    ///   - completionHandler: 结果回调
    public class func fetchEmoticonPacket(_ names: [String], using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: @escaping ([MNEmoticon.Packet])->Void) {
        queue.async {
            let packets = MNEmoticonManager.shared.fetchEmoticonPacket(names)
            DispatchQueue.main.async {
                completionHandler(packets)
            }
        }
    }
    
    /// 获取表情包
    /// - Parameter names: 表情包名称集合
    /// - Returns: 查询结果
    public func fetchEmoticonPacket(names: [MNEmoticon.Packet.Name]) -> [MNEmoticon.Packet] {
        fetchEmoticonPacket(names.compactMap({ $0.rawValue }))
    }
    
    /// 获取表情包
    /// - Parameters:
    ///   - names: 表情包名称集合
    ///   - queue: 执行队列
    ///   - completionHandler: 结果回调
    public class func fetchEmoticonPacket(names: [MNEmoticon.Packet.Name], using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: @escaping ([MNEmoticon.Packet])->Void) {
        queue.async {
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
    public func matchsEmoticon(in string: String) -> [MNEmoticonAttachment] {
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
    public func emoticon(for desc: String, in packet: String) -> UIImage? {
        guard let path = collections.path(for: desc, in: packet) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

// MARK: - 收藏夹
extension MNEmoticonManager {
    
    /// 添加图片到收藏夹
    /// - Parameter imagePath: 图片路径
    /// - Returns: 是否添加成功
    private func addEmoticonToFavorites(atPath imagePath: String) -> Bool {
        var json: [String:Any] = [:]
        let jsonPath = favoritesDirectory + ".json"
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        if FileManager.default.fileExists(atPath: jsonPath) {
            // 已存在收藏夹, 解析数据
            do {
                let jsonData = try Data(contentsOf: jsonURL, options: [])
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let dic = jsonObject as? [String:Any] else { return false }
                json.merge(dic) { $1 }
            } catch {
#if DEBUG
                print("解析收藏夹失败: \(error)")
#endif
                return false
            }
        } else if FileManager.default.fileExists(atPath: favoritesDirectory) == false {
            // 创建收藏夹文件夹
            do {
                try FileManager.default.createDirectory(atPath: favoritesDirectory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("创建收藏文件夹失败: \(error)")
#endif
                return false
            }
            // 默认信息
            json[MNEmoticon.Packet.Key.time.rawValue] = 1
            json[MNEmoticon.Packet.Key.favorites.rawValue] = 1
            json[MNEmoticon.Packet.Key.cover.rawValue] = "favorites.png"
            json[MNEmoticon.Packet.Key.style.rawValue] = MNEmoticon.Style.image.rawValue
            json[MNEmoticon.Packet.Key.emoticons.rawValue] = [[String:String]]()
        }
        // 复制图片到文件夹
        var isDirectory: ObjCBool = true
        guard FileManager.default.fileExists(atPath: imagePath, isDirectory: &isDirectory), isDirectory.boolValue == false else {
#if DEBUG
            print("图片路径不合法或文件不存在: \(imagePath)")
#endif
            return false
        }
        guard let targetPath = favoritesDirectory.appendingPathComponent(imagePath.lastPathComponent).absolutePath else {
#if DEBUG
            print("计算目标路径失败: \(imagePath)")
#endif
            return false
        }
        do {
            try FileManager.default.copyItem(atPath: imagePath, toPath: targetPath)
        } catch {
#if DEBUG
            print("复制图片失败: \(targetPath)")
#endif
            return false
        }
        let emoticon: [String:String] = [MNEmoticon.Key.img.rawValue:targetPath.lastPathComponent,MNEmoticon.Key.desc.rawValue:targetPath.deletingPathExtension.lastPathComponent]
        var emoticons = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] ?? []
        emoticons.insert(emoticon, at: 0)
        json[MNEmoticon.Packet.Key.emoticons.rawValue] = emoticons
        if #available(iOS 11.0, *) {
            do {
                try (json as NSDictionary).write(to: jsonURL)
            } catch  {
                try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
                print("更新收藏夹失败: \(error)")
#endif
                return false
            }
        } else {
            guard (json as NSDictionary).write(to: jsonURL, atomically: true) else {
                try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
                print("更新收藏夹失败")
#endif
                return false
            }
        }
        return true
    }
    
    /// 异步添加图片到收藏夹
    /// - Parameters:
    ///   - imagePath: 图片路径
    ///   - queue: 执行队列
    ///   - completionHandler: 结束回调
    public class func addEmoticonToFavorites(atPath imagePath: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.addEmoticonToFavorites(atPath: imagePath)
            DispatchQueue.main.async {
                // 通知收藏夹变化
                if isSuccess {
                    NotificationCenter.default.post(name: MNEmoticonDidChangeNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:MNEmoticon.Packet.Name.favorites.rawValue])
                }
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 添加图片到收藏夹
    /// - Parameter image: 图片
    /// - Returns: 是否添加成功
    public func addEmoticonToFavorites(_ image: UIImage) -> Bool {
        var json: [String:Any] = [:]
        let jsonPath = favoritesDirectory + ".json"
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        if FileManager.default.fileExists(atPath: jsonPath) {
            // 已存在收藏夹, 解析数据
            do {
                let jsonData = try Data(contentsOf: jsonURL, options: [])
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let dic = jsonObject as? [String:Any] else { return false }
                json.merge(dic) { $1 }
            } catch {
#if DEBUG
                print("解析收藏夹失败: \(error)")
#endif
                return false
            }
        } else if FileManager.default.fileExists(atPath: favoritesDirectory) == false {
            // 创建收藏夹文件夹
            do {
                try FileManager.default.createDirectory(atPath: favoritesDirectory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("创建收藏文件夹失败: \(error)")
#endif
                return false
            }
            // 默认信息
            json[MNEmoticon.Packet.Key.time.rawValue] = 1
            json[MNEmoticon.Packet.Key.favorites.rawValue] = 1
            json[MNEmoticon.Packet.Key.cover.rawValue] = "favorites.png"
            json[MNEmoticon.Packet.Key.style.rawValue] = MNEmoticon.Style.image.rawValue
            json[MNEmoticon.Packet.Key.emoticons.rawValue] = [[String:String]]()
        }
        // 写入图片
        guard let imagePath = favoritesDirectory.appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0)).png").absolutePath else {
#if DEBUG
            print("计算图片路径失败")
#endif
            return false
        }
        var ext = imagePath.pathExtension
        guard let imageData = Data(image: image, compression: 0.75, extension: &ext) else {
#if DEBUG
            print("转换图片数据流失败")
#endif
            return false
        }
        let targetPath = imagePath.deletingPathExtension + "." + ext
        var targetURL: URL!
        if #available(iOS 16.0, *) {
            targetURL = URL(filePath: targetPath)
        } else {
            targetURL = URL(fileURLWithPath: targetPath)
        }
        do {
            try imageData.write(to: targetURL, options: .atomic)
        } catch {
#if DEBUG
            print("写入图片失败: \(error)")
#endif
            return false
        }
        // 更新json
        let emoticon: [String:String] = [MNEmoticon.Key.img.rawValue:targetPath.lastPathComponent,MNEmoticon.Key.desc.rawValue:targetPath.deletingPathExtension.lastPathComponent]
        var emoticons = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] ?? []
        emoticons.insert(emoticon, at: 0)
        json[MNEmoticon.Packet.Key.emoticons.rawValue] = emoticons
        if #available(iOS 11.0, *) {
            do {
                try (json as NSDictionary).write(to: jsonURL)
            } catch  {
                try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
                print("更新收藏夹失败: \(error)")
#endif
                return false
            }
        } else {
            guard (json as NSDictionary).write(to: jsonURL, atomically: true) else {
                try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
                print("更新收藏夹失败")
#endif
                return false
            }
        }
        return true
    }
    
    /// 异步添加图片到收藏夹
    /// - Parameters:
    ///   - image: 图片
    ///   - queue: 执行队列
    ///   - completionHandler: 结束回调
    public class func addEmoticonToFavorites(_ image: UIImage, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.addEmoticonToFavorites(image)
            DispatchQueue.main.async {
                // 通知收藏夹变化
                if isSuccess {
                    NotificationCenter.default.post(name: MNEmoticonDidChangeNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:MNEmoticon.Packet.Name.favorites.rawValue])
                }
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 从收藏夹删除表情
    /// - Parameter imageName: 表情图片名称
    /// - Returns: 是否删除成功
    private func removeEmoticonFromFavorites(named imageName: String) -> Bool {
        guard imageName.isEmpty == false else {
#if DEBUG
            print("表情图片名称不合法: \(imageName)")
#endif
            return false
        }
        let jsonPath = favoritesDirectory + ".json"
        guard FileManager.default.fileExists(atPath: jsonPath) else {
#if DEBUG
            print("未发现收藏夹")
#endif
            return false
        }
        var json: [String:Any] = [:]
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        // 已存在收藏夹, 解析数据
        do {
            let jsonData = try Data(contentsOf: jsonURL, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dic = jsonObject as? [String:Any] else { return false }
            json.merge(dic) { $1 }
        } catch {
#if DEBUG
            print("解析收藏夹失败: \(error)")
#endif
            return false
        }
        guard var emoticons = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] else {
#if DEBUG
            print("当前为空收藏夹")
#endif
            return false
        }
        emoticons.removeAll { item in
            guard let img = item[MNEmoticon.Key.img.rawValue], img == imageName else { return false }
            return true
        }
        json[MNEmoticon.Packet.Key.emoticons.rawValue] = emoticons
        if #available(iOS 11.0, *) {
            do {
                try (json as NSDictionary).write(to: jsonURL)
            } catch  {
#if DEBUG
                print("更新收藏夹失败: \(error)")
#endif
                return false
            }
        } else {
            guard (json as NSDictionary).write(to: jsonURL, atomically: true) else {
#if DEBUG
                print("更新收藏夹失败")
#endif
                return false
            }
        }
        let imagePath = favoritesDirectory.appendingPathComponent(imageName)
        do {
            try FileManager.default.removeItem(atPath: imagePath)
        } catch {
#if DEBUG
            print("删除收藏夹内图片失败: \(error)")
#endif
        }
        return true
    }
    
    /// 异步从收藏夹删除表情
    /// - Parameters:
    ///   - imageName: 表情图片名称
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public class func removeEmoticonFromFavorites(named imageName: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.removeEmoticonFromFavorites(named: imageName)
            DispatchQueue.main.async {
                // 通知收藏夹变化
                if isSuccess {
                    NotificationCenter.default.post(name: MNEmoticonDidChangeNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:MNEmoticon.Packet.Name.favorites.rawValue])
                }
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 从收藏夹删除表情
    /// - Parameter emoticon: 表情
    /// - Returns: 是否删除成功
    private func removeEmoticonFromFavorites(_ emoticon: MNEmoticon) -> Bool {
        removeEmoticonFromFavorites(named: emoticon.img)
    }
    
    /// 异步从收藏夹删除表情
    /// - Parameters:
    ///   - emoticon: 表情
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public class func removeEmoticonFromFavorites(_ emoticon: MNEmoticon, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.removeEmoticonFromFavorites(emoticon)
            DispatchQueue.main.async {
                // 通知收藏夹变化
                if isSuccess {
                    NotificationCenter.default.post(name: MNEmoticonDidChangeNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:MNEmoticon.Packet.Name.favorites.rawValue])
                }
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
}
