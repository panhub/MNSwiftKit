//
//  EmoticonResource.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  资源加载

import Foundation

/// 资源加载器
public class EmoticonResource {
    
    /// 资源束
    nonisolated(unsafe) private static var bundle: Bundle = {
        // 尝试从 CocoaPods 生成的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle.main.url(forResource: "MNSwiftKit_EmoticonKeyboard", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        // 尝试从当前框架/模块的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle(for: EmoticonResource.self).url(forResource: "MNSwiftKit_EmoticonKeyboard", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        // 可能是直接源代码集成，尝试在框架 bundle 的上级目录查找
        if let url = Bundle(for: EmoticonResource.self).url(forResource: "MNSwiftKit_EmoticonKeyboard", withExtension: "bundle", subdirectory: "Frameworks/MNSwiftKit.framework"), let bundle = Bundle(url: url) {
            return bundle
        }
        return Bundle(for: EmoticonResource.self)
    }()
    
    
    /// 获取资源束内图片
    /// - Parameter named: 图片名称
    /// - Parameter ext: 图片类型
    /// - Returns: 图片
    public class func image(named: String, type ext: String = "png") -> UIImage? {
        var imagePath: String?
        if named.contains("@") == false {
            var scale: Int = 3
            while scale > 0 {
                let suffix = "@\(scale)x"
                if let path = bundle.path(forResource: named + suffix, ofType: ext) {
                    imagePath = path
                    break
                }
                scale -= 1
            }
        }
        if imagePath == nil {
            imagePath = bundle.path(forResource: named, ofType: ext)
        }
        guard let imagePath = imagePath else { return nil }
        return UIImage(contentsOfFile: imagePath)
    }
    
    /// 获取资源束内文件路径
    /// - Parameter name: 文件名, nil则忽略
    /// - Parameter ext: 文件后缀, nil则忽略
    /// - Parameter subpath: 所在文件夹
    /// - Returns: 文件路径
    public class func path(forResource name: String?, ofType ext: String?, inDirectory subpath: String? = nil) -> String? {
        bundle.path(forResource: name, ofType: ext, inDirectory: subpath)
    }
    
    /// 获取资源束内文件路径
    /// - Parameter ext: 文件后缀, nil则忽略
    /// - Parameter subpath: 所在文件夹
    /// - Returns: 文件路径集合
    public class func paths(forResourcesOfType ext: String?, inDirectory subpath: String?) -> [String] {
        bundle.paths(forResourcesOfType: ext, inDirectory: subpath)
    }
    
    /// 获取资源束内文件地址
    /// - Parameter name: 文件名, nil则忽略
    /// - Parameter ext: 文件后缀, nil则忽略
    /// - Parameter subpath: 所在子文件
    /// - Returns: 文件地址
    public class func url(forResource name: String?, withExtension ext: String?, subdirectory subpath: String? = nil) -> URL? {
        bundle.url(forResource: name, withExtension: ext, subdirectory: subpath)
    }
    
    /// 获取资源束内文件地址
    /// - Parameter ext: 后缀, nil则忽略, 表示所有
    /// - Parameter subpath: 所在子文件
    /// - Returns: 文件地址集合
    public class func urls(forResourcesWithExtension ext: String?, subdirectory subpath: String? = nil) -> [URL]? {
        bundle.urls(forResourcesWithExtension: ext, subdirectory: subpath)
    }
    
    /// 获取资源束内json内容
    /// - Parameter named: json文件名
    /// - Returns: json内容
    public class func json(named: String) -> Any? {
        guard let jsonURL = bundle.url(forResource: named, withExtension: "json") else { return nil }
        do {
            let jsonData = try Data(contentsOf: jsonURL, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return jsonObject
        } catch {
#if DEBUG
            print("解析json失败: \(jsonURL)")
#endif
            return nil
        }
    }
}
