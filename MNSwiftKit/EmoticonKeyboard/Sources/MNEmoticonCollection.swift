//
//  MNEmoticonCollection.swift
//  MNSwiftKit
//
//  Created by 小斯 on 2023/2/13.
//  文字表情集合

import UIKit
import Foundation

class MNEmoticonCollection {
    
    /// 名称
    let name: String
    
    /// 文件目录
    let directory: String
    
    /// 表情集合 '[开心]:kaixin.png'
    let emoticons: [String:String]
    
    /// 构造表情集合
    /// - Parameter filePath: json文件路径
    init?(fileAtPath filePath: String) {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else { return nil }
        var jsonData: Data!
        if #available(iOS 13.4, *) {
            do {
                jsonData = try fileHandle.readToEnd()
            } catch {
#if DEBUG
                print("读取json文件失败: \(error)")
#endif
                return nil
            }
        } else {
            jsonData = fileHandle.readDataToEndOfFile()
        }
        guard let jsonData = jsonData, jsonData.isEmpty == false else {
#if DEBUG
            print("未发现json数据: \(filePath)")
#endif
            return nil
        }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let json = jsonObject as? [String:Any] else { return nil }
            guard let style = json[MNEmoticon.Packet.Key.style.rawValue] as? Int, style == MNEmoticon.Style.emoticon.rawValue else { return nil }
            guard let elements = json[MNEmoticon.Packet.Key.emoticons.rawValue] as? [[String:String]] else { return nil }
            emoticons = elements.reduce(into: [String:String](), { partialResult, dic in
                guard let key = dic[MNEmoticon.Key.desc.rawValue], let value = dic[MNEmoticon.Key.img.rawValue] else { return }
                partialResult[key] = value
            })
            let path = filePath.deletingPathExtension
            name = path.lastPathComponent
            if name == MNEmoticon.Packet.Name.default.rawValue {
                directory = path.deletingLastPathComponent
            } else {
                directory = path
            }
        } catch {
#if DEBUG
            print("解析json失败: \(filePath)")
#endif
            return nil
        }
    }
}

extension Array where Element: MNEmoticonCollection {
    
    /// 获取表情路径
    /// - Parameters:
    ///   - desc: 表情描述
    ///   - name: 表情包名
    /// - Returns: 表情图片路径
    func path(for desc: String, in name: String? = nil) -> String? {
        if let name = name {
            guard let collection = first(where: { $0.name == name }) else { return nil }
            guard let img = collection.emoticons[desc] else { return nil }
            return (collection.directory as NSString).appendingPathComponent(img)
        }
        for collection in self {
            guard let img = collection.emoticons[desc] else { continue }
            return (collection.directory as NSString).appendingPathComponent(img)
        }
        return nil
    }
}
