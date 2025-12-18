//
//  MNEmoticonManager.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/29.
//  表情管理工具

import UIKit
import Foundation

/// 通知-表情包名称键
public let MNEmoticonPacketNameUserInfoKey: String = "emoticon.packet.name"
/// 添加表情包通知
public let MNEmoticonPacketAddedNotification: Notification.Name = Notification.Name(rawValue: "com.mn.emoticon.packet.added")
/// 删除表情包通知
public let MNEmoticonPacketRemovedNotification: Notification.Name = Notification.Name(rawValue: "com.mn.emoticon.packet.removed")
/// 表情包变化通知(删除/添加表情)
public let MNEmoticonPacketChangedNotification: Notification.Name = Notification.Name(rawValue: "com.mn.emoticon.packet.changed")

public class MNEmoticonManager {
    /// 表情检索表达式
    private let expression: NSRegularExpression = try! NSRegularExpression(pattern: "\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]", options: [])
    /// 唯一实例化入口
    public static let shared: MNEmoticonManager = MNEmoticonManager()
    /// 内部加载的表情集合
    private(set) var collections: [MNEmoticonCollection] = []
    /// 用户缓存目录
    public let userEmoticonDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/MNSwiftKit/emoticons"
    /// 收藏夹路径
    public private(set) lazy var favoritesDirectory = userEmoticonDirectory.mn.appendingPathComponent(MNEmoticon.Packet.Name.favorites.rawValue.mn.md5)
    
    /// 构造表情管理者
    private init() {
        var urls: [URL] = []
        if let url = EmoticonKeyboardResource.url(forResource: MNEmoticon.Packet.Name.wechat.rawValue, withExtension: "json") {
            urls.append(url)
        }
        if let subpaths = FileManager.default.subpaths(atPath: userEmoticonDirectory) {
            for subpath in subpaths {
                guard subpath.mn.pathExtension == "json" else { continue }
                let jsonPath = userEmoticonDirectory.mn.appendingPathComponent(subpath)
                if #available(iOS 16.0, *) {
                    urls.append(URL(filePath: jsonPath))
                } else {
                    urls.append(URL(fileURLWithPath: jsonPath))
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
    /// - Parameter names: 表情包名集合
    /// - Returns: 查询结果
    public func fetchEmoticonPacket(_ names: [MNEmoticon.Packet.Name]) -> [MNEmoticon.Packet] {
        // 先去重
        let elements = names.reduce(into: [String]()) { partialResult, name in
            let rawValue = name.rawValue
            guard partialResult.contains(rawValue) == false else { return }
            partialResult.append(rawValue)
        }
        // 解析表情
        var urls: [URL] = []
        for name in elements {
            if let url = EmoticonKeyboardResource.url(forResource: name, withExtension: "json")  {
                urls.append(url)
                continue
            }
            let jsonPath = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5 + ".json")
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
                guard createEmoticonPacket(name: name) else { continue }
                urls.append(jsonURL)
            }
        }
        let packets = urls.compactMap { MNEmoticon.Packet(url: $0) }
        return packets
    }
    
    /// 获取表情包
    /// - Parameters:
    ///   - names: 表情包文件名集合
    ///   - queue: 执行队列
    ///   - completionHandler: 结果回调
    public class func fetchEmoticonPacket(_ names: [MNEmoticon.Packet.Name], using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: @escaping ([MNEmoticon.Packet])->Void) {
        queue.async {
            let packets = MNEmoticonManager.shared.fetchEmoticonPacket(names)
            DispatchQueue.main.async {
                completionHandler(packets)
            }
        }
    }
}

// MARK: - 收藏夹
extension MNEmoticonManager {
    
    /// 创建表情包
    /// - Parameter name: 表情包名称
    /// - Returns: 是否创建成功
    @discardableResult public func createEmoticonPacket(name: String) -> Bool {
        guard name.isEmpty == false else {
#if DEBUG
            print("表情包名称不合法")
#endif
            return false
        }
        if name == MNEmoticon.Packet.Name.wechat.rawValue {
#if DEBUG
            print("'default'表情包不可编辑")
#endif
            return false
        }
        let packetDirectory = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5)
        let jsonPath = packetDirectory + ".json"
        if FileManager.default.fileExists(atPath: jsonPath) { return true }
        // 不存在就创建文件夹
        if FileManager.default.fileExists(atPath: packetDirectory) == false {
            do {
                try FileManager.default.createDirectory(atPath: packetDirectory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("创建表情包文件夹失败: \(error)")
#endif
                return false
            }
        }
        var json: [String:Any] = [:]
        json[MNEmoticon.Packet.Key.name.rawValue] = name
        json[MNEmoticon.Packet.Key.cover.rawValue] = "favorites.png"
        json[MNEmoticon.Packet.Key.style.rawValue] = MNEmoticon.Style.image.rawValue
        json[MNEmoticon.Packet.Key.emoticons.rawValue] = [[String:String]]()
        // 保存配置文件
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try jsonData.write(to: jsonURL, options: .atomic)
        } catch {
#if DEBUG
            print("保存表情包配置失败: \(error)")
#endif
            return false
        }
        // 通知表情包变化
        let notifyHandler: ()->Void = {
            NotificationCenter.default.post(name: MNEmoticonPacketAddedNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:name])
        }
        if Thread.isMainThread {
            notifyHandler()
        } else {
            DispatchQueue.main.async(execute: notifyHandler)
        }
        return true
    }
    
    /// 异步创建表情包
    /// - Parameters:
    ///   - name: 表情包名称
    ///   - queue: 操作队列
    ///   - completionHandler: 结果回调
    public func createEmoticonPacket(name: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.createEmoticonPacket(name: name)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 删除表情包
    /// - Parameter name: 表情包名称
    /// - Returns: 是否删除成功
    @discardableResult public func removeEmoticonPacket(name: String) -> Bool {
        guard name.isEmpty == false else {
#if DEBUG
            print("表情包名称不合法")
#endif
            return false
        }
        if name == MNEmoticon.Packet.Name.wechat.rawValue {
#if DEBUG
            print("'default'表情包不可编辑")
#endif
            return false
        }
        let packetDirectory = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5)
        let jsonPath = packetDirectory + ".json"
        guard FileManager.default.fileExists(atPath: jsonPath) else {
#if DEBUG
            print("表情包不存在: \(name)")
#endif
            return false
        }
        do {
            try FileManager.default.removeItem(atPath: jsonPath)
        } catch {
#if DEBUG
            print("删除表情包配置失败: \(error)")
#endif
            return false
        }
        do {
            try FileManager.default.removeItem(atPath: packetDirectory)
        } catch {
#if DEBUG
            print("删除表情包文件夹失败: \(error)")
#endif
        }
        // 通知删除表情包
        let notifyHandler: ()->Void = {
            NotificationCenter.default.post(name: MNEmoticonPacketRemovedNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:name])
        }
        if Thread.isMainThread {
            notifyHandler()
        } else {
            DispatchQueue.main.async(execute: notifyHandler)
        }
        return true
    }
    
    /// 异步删除表情包
    /// - Parameters:
    ///   - name: 表情包名称
    ///   - queue: 操作队列
    ///   - completionHandler: 结果回调
    public func removeEmoticonPacket(name: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.removeEmoticonPacket(name: name)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 添加图片到表情包
    /// - Parameters:
    ///   - imagePath: 表情图片路径
    ///   - desc: 表情描述
    ///   - name: 表情包名称
    /// - Returns: 是否添加成功
    @discardableResult public func addEmoticon(atPath imagePath: String, desc: String? = nil, to name: String) -> Bool {
        var isDirectory: ObjCBool = true
        guard FileManager.default.fileExists(atPath: imagePath, isDirectory: &isDirectory), isDirectory.boolValue == false else {
#if DEBUG
            print("表情图片不存在或路径不合法: \(imagePath)")
#endif
            return false
        }
        // 创建表情包
        guard createEmoticonPacket(name: name) else { return false }
        let packetDirectory = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5)
        let jsonPath = packetDirectory + ".json"
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        // 解析表情包
        var json: [String:Any] = [:]
        do {
            let jsonData = try Data(contentsOf: jsonURL, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dic = jsonObject as? [String:Any] else { return false }
            json.merge(dic) { $1 }
        } catch {
#if DEBUG
            print("解析表情包失败: \(error)")
#endif
            return false
        }
        // 复制图片到文件夹
        guard let targetPath = packetDirectory.mn.appendingPathComponent(imagePath.mn.lastPathComponent).mn.availablePath else {
#if DEBUG
            print("计算表情图片目标路径失败: \(imagePath)")
#endif
            return false
        }
        do {
            try FileManager.default.copyItem(atPath: imagePath, toPath: targetPath)
        } catch {
#if DEBUG
            print("复制表情图片失败: \(targetPath)")
#endif
            return false
        }
        var emoticonDesc = targetPath.mn.deletingPathExtension.mn.lastPathComponent
        if let desc = desc, desc.isEmpty == false {
            emoticonDesc = desc
        }
        let emoticon: [String:String] = [MNEmoticon.Key.img.rawValue: targetPath.mn.lastPathComponent, MNEmoticon.Key.desc.rawValue: emoticonDesc]
        var emoticons = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] ?? []
        emoticons.insert(emoticon, at: 0)
        json[MNEmoticon.Packet.Key.emoticons.rawValue] = emoticons
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try jsonData.write(to: jsonURL, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
            print("更新表情包配置失败: \(error)")
#endif
            return false
        }
        // 通知表情包变化
        let notifyHandler: ()->Void = {
            NotificationCenter.default.post(name: MNEmoticonPacketChangedNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:name])
        }
        if Thread.isMainThread {
            notifyHandler()
        } else {
            DispatchQueue.main.async(execute: notifyHandler)
        }
        return true
    }
    
    /// 异步添加图片到表情包
    /// - Parameters:
    ///   - imagePath: 表情图片路径
    ///   - desc: 表情描述
    ///   - name: 表情包名称
    ///   - queue: 执行队列
    ///   - completionHandler: 结束回调
    public class func addEmoticon(atPath imagePath: String, desc: String? = nil, to name: String,  using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.addEmoticon(atPath: imagePath, desc: desc, to: name)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    
    /// 添加图片到表情包
    /// - Parameters:
    ///   - image: 表情图片
    ///   - desc: 表情描述
    ///   - name: 表情包名称
    /// - Returns: 是否添加成功
    @discardableResult public func addEmoticon(image: UIImage, desc: String? = nil, to name: String) -> Bool {
        // 创建表情包
        guard createEmoticonPacket(name: name) else { return false }
        let packetDirectory = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5)
        let jsonPath = packetDirectory + ".json"
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        // 解析表情包
        var json: [String:Any] = [:]
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
        // 写入图片
        guard let imagePath = packetDirectory.mn.appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0)).png").mn.availablePath else {
#if DEBUG
            print("计算表情图片目标路径失败")
#endif
            return false
        }
        var ext = imagePath.mn.pathExtension
        guard let imageData = image.mn.data(compression: 0.75, extension: &ext) else {
#if DEBUG
            print("解压表情图片失败")
#endif
            return false
        }
        let targetPath = imagePath.mn.deletingPathExtension + "." + ext
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
            print("保存表情图片失败: \(error)")
#endif
            return false
        }
        // 更新json
        var emoticonDesc = targetPath.mn.deletingPathExtension.mn.lastPathComponent
        if let desc = desc, desc.isEmpty == false {
            emoticonDesc = desc
        }
        let emoticon: [String:String] = [MNEmoticon.Key.img.rawValue: targetPath.mn.lastPathComponent, MNEmoticon.Key.desc.rawValue: emoticonDesc]
        var emoticons = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] ?? []
        emoticons.insert(emoticon, at: 0)
        json[MNEmoticon.Packet.Key.emoticons.rawValue] = emoticons
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try jsonData.write(to: jsonURL, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
            print("更新表情包配置失败: \(error)")
#endif
            return false
        }
        // 通知表情包变化
        let notifyHandler: ()->Void = {
            NotificationCenter.default.post(name: MNEmoticonPacketChangedNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:name])
        }
        if Thread.isMainThread {
            notifyHandler()
        } else {
            DispatchQueue.main.async(execute: notifyHandler)
        }
        return true
    }
    
    
    /// 异步添加图片到表情包
    /// - Parameters:
    ///   - image: 表情图片
    ///   - desc: 表情描述
    ///   - name: 表情包名称
    ///   - queue: 操作队列
    ///   - completionHandler: 回调结果
    public class func addEmoticon(image: UIImage, desc: String? = nil, to name: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.addEmoticon(image: image, desc: desc, to: name)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    
    /// 收藏表情到收藏夹
    /// - Parameters:
    ///   - imagePath: 表情图片路径
    ///   - desc: 表情描述
    /// - Returns: 是否收藏成功
    @discardableResult public func addEmoticonToFavorites(atPath imagePath: String, desc: String? = nil) -> Bool {
        addEmoticon(atPath: imagePath, desc: desc, to: MNEmoticon.Packet.Name.favorites.rawValue)
    }
    
    /// 异步收藏表情到收藏夹
    /// - Parameters:
    ///   - imagePath: 表情图片路径
    ///   - desc: 表情描述
    ///   - queue: 执行队列
    ///   - completionHandler: 结束回调
    public class func addEmoticonToFavorites(atPath imagePath: String, desc: String? = nil, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.addEmoticonToFavorites(atPath: imagePath, desc: desc)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 收藏表情到收藏夹
    /// - Parameters:
    ///   - image: 表情图片
    ///   - desc: 表情描述
    /// - Returns: 是否收藏成功
    @discardableResult public func addEmoticonToFavorites(image: UIImage, desc: String? = nil) -> Bool {
        addEmoticon(image: image, desc: desc, to: MNEmoticon.Packet.Name.favorites.rawValue)
    }
    
    /// 异步收藏表情到收藏夹
    /// - Parameters:
    ///   - image: 表情图片
    ///   - desc: 表情描述
    ///   - queue: 执行队列
    ///   - completionHandler: 结束回调
    public class func addEmoticonToFavorites(image: UIImage, desc: String? = nil, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.addEmoticonToFavorites(image: image, desc: desc)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 从表情包中删除表情
    /// - Parameters:
    ///   - desc: 表情描述
    ///   - name: 表情包名称
    /// - Returns: 是否删除成功
    @discardableResult public func removeEmoticon(desc: String, from name: String) -> Bool {
        guard name.isEmpty == false else {
#if DEBUG
            print("表情包名称不合法")
#endif
            return false
        }
        guard desc.isEmpty == false else {
#if DEBUG
            print("表情描述不合法")
#endif
            return false
        }
        if name == MNEmoticon.Packet.Name.wechat.rawValue {
#if DEBUG
            print("'default'表情包不可编辑")
#endif
            return false
        }
        let packetDirectory = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5)
        let jsonPath = packetDirectory + ".json"
        guard FileManager.default.fileExists(atPath: jsonPath) else {
#if DEBUG
            print("表情包不存在: \(name)")
#endif
            return false
        }
        // 解析表情包
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        var json: [String:Any] = [:]
        do {
            let jsonData = try Data(contentsOf: jsonURL, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dic = jsonObject as? [String:Any] else { return false }
            json.merge(dic) { $1 }
        } catch {
#if DEBUG
            print("解析表情包失败: \(error)")
#endif
            return false
        }
        guard var emoticons = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] else {
#if DEBUG
            print("表情包内无表情")
#endif
            return false
        }
        var imgs: [String] = []
        emoticons.removeAll { item in
            guard let string = item[MNEmoticon.Key.desc.rawValue], string == desc else { return false }
            if let img = item[MNEmoticon.Key.img.rawValue] {
                imgs.append(img)
            }
            return true
        }
        json[MNEmoticon.Packet.Key.emoticons.rawValue] = emoticons
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try jsonData.write(to: jsonURL, options: .atomic)
        } catch {
#if DEBUG
            print("更新表情包配置失败: \(error)")
#endif
            return false
        }
        for img in imgs {
            let imagePath = packetDirectory.mn.appendingPathComponent(img)
            do {
                try FileManager.default.removeItem(atPath: imagePath)
            } catch {
#if DEBUG
                print("删除收藏夹内图片失败: \(error)")
#endif
            }
        }
        // 通知表情包变化
        let notifyHandler: ()->Void = {
            NotificationCenter.default.post(name: MNEmoticonPacketChangedNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:name])
        }
        if Thread.isMainThread {
            notifyHandler()
        } else {
            DispatchQueue.main.async(execute: notifyHandler)
        }
        return true
    }
    
    
    /// 异步删除表情包内表情
    /// - Parameters:
    ///   - desc: 表情描述
    ///   - name: 表情包名称
    ///   - queue: 操作队列
    ///   - completionHandler: 结果回调
    public class func removeEmoticon(desc: String, from name: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.removeEmoticon(desc: desc, from: name)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 从收藏夹删除表情
    /// - Parameter desc: 表情描述
    /// - Returns: 是否删除成功
    @discardableResult public func removeEmoticonFromFavorites(desc: String) -> Bool {
        removeEmoticon(desc: desc, from: MNEmoticon.Packet.Name.favorites.rawValue)
    }
    
    /// 异步从收藏夹删除表情
    /// - Parameters:
    ///   - desc: 表情描述
    ///   - queue: 操作队列
    ///   - completionHandler: 结束回调
    public class func removeEmoticonFromFavorites(desc: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.removeEmoticonFromFavorites(desc: desc)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 更新表情包封面
    /// - Parameters:
    ///   - imagePath: 封面图片路径
    ///   - name: 表情包名称
    /// - Returns: 是否更换成功
    @discardableResult public func updateCover(atPath imagePath: String, to name: String) -> Bool {
        guard name.isEmpty == false else {
#if DEBUG
            print("表情包名称不合法")
#endif
            return false
        }
        if name == MNEmoticon.Packet.Name.wechat.rawValue {
#if DEBUG
            print("'default'表情包不可编辑")
#endif
            return false
        }
        var isDirectory: ObjCBool = true
        guard FileManager.default.fileExists(atPath: imagePath, isDirectory: &isDirectory), isDirectory.boolValue == false else {
#if DEBUG
            print("封面图片不存在或路径不合法: \(imagePath)")
#endif
            return false
        }
        let packetDirectory = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5)
        let jsonPath = packetDirectory + ".json"
        guard FileManager.default.fileExists(atPath: jsonPath) else {
#if DEBUG
            print("表情包不存在: \(name)")
#endif
            return false
        }
        // 解析表情包
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        var json: [String:Any] = [:]
        do {
            let jsonData = try Data(contentsOf: jsonURL, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dic = jsonObject as? [String:Any] else { return false }
            json.merge(dic) { $1 }
        } catch {
#if DEBUG
            print("解析表情包失败: \(error)")
#endif
            return false
        }
        // 复制图片到文件夹
        guard let targetPath = packetDirectory.mn.appendingPathComponent(imagePath.mn.lastPathComponent).mn.availablePath else {
#if DEBUG
            print("计算封面目标路径失败: \(imagePath)")
#endif
            return false
        }
        do {
            try FileManager.default.copyItem(atPath: imagePath, toPath: targetPath)
        } catch {
#if DEBUG
            print("复制封面图片失败: \(targetPath)")
#endif
            return false
        }
        let oldCoverName = json[MNEmoticon.Packet.Key.cover.rawValue] as? String
        json[MNEmoticon.Packet.Key.cover.rawValue] = targetPath.mn.lastPathComponent
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try jsonData.write(to: jsonURL, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
            print("更新表情包配置失败: \(error)")
#endif
            return false
        }
        // 删除原封面
        if let oldCoverName = oldCoverName, oldCoverName.mn.pathExtension.isEmpty == false {
            let coverPath = packetDirectory.mn.appendingPathComponent(oldCoverName)
            if FileManager.default.fileExists(atPath: coverPath) {
                do {
                    try FileManager.default.removeItem(atPath: coverPath)
                } catch {
#if DEBUG
                print("删除原封面图片失败: \(error)")
#endif
                }
            }
        }
        // 通知表情包变化
        let notifyHandler: ()->Void = {
            NotificationCenter.default.post(name: MNEmoticonPacketChangedNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:name])
        }
        if Thread.isMainThread {
            notifyHandler()
        } else {
            DispatchQueue.main.async(execute: notifyHandler)
        }
        return false
    }
    
    /// 异步更新表情包封面
    /// - Parameters:
    ///   - imagePath: 封面路径
    ///   - name: 表情包名称
    ///   - queue: 操作的队列
    ///   - completionHandler: 结果回调
    public func updateCover(atPath imagePath: String, to name: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.updateCover(atPath: imagePath, to: name)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
    
    /// 更新表情包封面
    /// - Parameters:
    ///   - image: 封面图片
    ///   - name: 表情包名称
    /// - Returns: 是否更新成功
    @discardableResult public func updateCover(image: UIImage, to name: String) -> Bool {
        guard name.isEmpty == false else {
#if DEBUG
            print("表情包名称不合法")
#endif
            return false
        }
        if name == MNEmoticon.Packet.Name.wechat.rawValue {
#if DEBUG
            print("'default'表情包不可编辑")
#endif
            return false
        }
        let packetDirectory = userEmoticonDirectory.mn.appendingPathComponent(name.mn.md5)
        let jsonPath = packetDirectory + ".json"
        var jsonURL: URL!
        if #available(iOS 16.0, *) {
            jsonURL = URL(filePath: jsonPath)
        } else {
            jsonURL = URL(fileURLWithPath: jsonPath)
        }
        // 解析表情包
        var json: [String:Any] = [:]
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
        // 写入图片
        guard let imagePath = packetDirectory.mn.appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0)).png").mn.availablePath else {
#if DEBUG
            print("计算封面图片目标路径失败")
#endif
            return false
        }
        var ext = imagePath.mn.pathExtension
        guard let imageData = image.mn.data(compression: 0.75, extension: &ext) else {
#if DEBUG
            print("解压封面图片失败")
#endif
            return false
        }
        let targetPath = imagePath.mn.deletingPathExtension + "." + ext
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
            print("保存表情图片失败: \(error)")
#endif
            return false
        }
        // 更新json
        let oldCoverName = json[MNEmoticon.Packet.Key.cover.rawValue] as? String
        json[MNEmoticon.Packet.Key.cover.rawValue] = targetPath.mn.lastPathComponent
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try jsonData.write(to: jsonURL, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(atPath: targetPath)
#if DEBUG
            print("更新表情包配置失败: \(error)")
#endif
            return false
        }
        // 删除原封面
        if let oldCoverName = oldCoverName, oldCoverName.mn.pathExtension.isEmpty == false {
            let coverPath = packetDirectory.mn.appendingPathComponent(oldCoverName)
            if FileManager.default.fileExists(atPath: coverPath) {
                do {
                    try FileManager.default.removeItem(atPath: coverPath)
                } catch {
#if DEBUG
                print("删除原封面图片失败: \(error)")
#endif
                }
            }
        }
        // 通知表情包变化
        let notifyHandler: ()->Void = {
            NotificationCenter.default.post(name: MNEmoticonPacketChangedNotification, object: self, userInfo: [MNEmoticonPacketNameUserInfoKey:name])
        }
        if Thread.isMainThread {
            notifyHandler()
        } else {
            DispatchQueue.main.async(execute: notifyHandler)
        }
        return true
    }
    
    /// 异步更新表情包封面
    /// - Parameters:
    ///   - image: 封面图片
    ///   - name: 表情包名称
    ///   - queue: 操作队列
    ///   - completionHandler: 结果回调
    public func updateCover(image: UIImage, to name: String, using queue: DispatchQueue = DispatchQueue.global(qos: .default), completion completionHandler: ((_ isSuccess: Bool)->Void)?) {
        queue.async {
            let isSuccess = MNEmoticonManager.shared.updateCover(image: image, to: name)
            DispatchQueue.main.async {
                // 回调
                completionHandler?(isSuccess)
            }
        }
    }
}

// MARK: - 表情
extension MNEmoticonManager {
    
    /// 匹配字符串中的表情
    /// - Parameter string: 字符串
    /// - Returns: 匹配到的表情配件
    public func matchsEmoticon(in string: String) -> [MNEmoticonAttachment] {
        var attachments: [MNEmoticonAttachment] = []
        let results = expression.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        for result in results {
            if result.range.location == NSNotFound { continue }
            let desc = (string as NSString).substring(with: result.range)
            guard let image = emoticonImage(for: desc) else { continue }
            let attachment = MNEmoticonAttachment(image: image, desc: desc)
            attachment.range = result.range
            attachments.append(attachment)
        }
        return attachments
    }
    
    /// 获取表情图片
    /// - Parameters:
    ///   - desc: 表情描述
    ///   - packet: 指定表情包
    /// - Returns: 表情图片
    public func emoticonImage(for desc: String, in packet: String? = nil) -> UIImage? {
        guard let path = collections.path(for: desc, in: packet) else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    /// 获取表情图片
    public subscript(_ desc: String) -> UIImage? {
        guard let path = collections.path(for: desc) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
