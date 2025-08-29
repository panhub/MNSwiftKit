//
//  MNEmoticonCollection.swift
//  MNKit
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
    /// - Parameter url: json文件地址
    init?(url: URL) {
        do {
            let jsonData = try Data(contentsOf: url, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let json = jsonObject as? [String:Any] else { return nil }
            guard let style = json[MNEmoticonPacket.Key.style.rawValue] as? Int, style == MNEmoticonPacket.Style.emoji.rawValue else { return nil }
            guard let emoticons = json[MNEmoticonPacket.Key.emoticons.rawValue] as? [[String:String]] else { return nil }
            self.emoticons = emoticons.reduce(into: [String:String](), { partialResult, dic in
                partialResult.merge(dic) { _, new in new }
            })
            let directoryURL = url.deletingPathExtension()
            self.name = directoryURL.lastPathComponent
            if #available(iOS 16.0, *) {
                self.directory = directoryURL.path(percentEncoded: false)
            } else {
                self.directory = directoryURL.path
            }
        } catch {
#if DEBUG
            print("解析json失败: \(url)")
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
