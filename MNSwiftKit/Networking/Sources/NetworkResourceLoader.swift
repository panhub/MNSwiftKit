//
//  NetworkResourceLoader.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/8/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  资源加载

import Foundation

/// 资源加载器
public class NetworkResourceLoader {
    
    /// 资源束
    private class var bundle: Bundle {
        // 尝试从 CocoaPods 生成的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle.main.url(forResource: "MNSwiftKit_Networking", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        // 尝试从当前框架/模块的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle(for: NetworkResourceLoader.self).url(forResource: "MNSwiftKit_Networking", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        // 可能是直接源代码集成，尝试在框架 bundle 的上级目录查找
        if let url = Bundle(for: NetworkResourceLoader.self).url(forResource: "MNSwiftKit_Networking", withExtension: "bundle", subdirectory: "Frameworks/MNSwiftKit.framework"), let bundle = Bundle(url: url) {
            return bundle
        }
        return Bundle(for: NetworkResourceLoader.self)
    }
    
    /// 获取资源束下文件路径
    /// - Parameters:
    ///   - name: 文件名称
    ///   - ext: 后缀
    /// - Returns: 文件路径
    public class func path(forResource name: String?, ofType ext: String?) -> String? {
        
        bundle.path(forResource: name, ofType: ext)
    }
    
    /// 获取资源束下文件位置
    /// - Parameters:
    ///   - name: 文件名称
    ///   - ext: 后缀
    /// - Returns: 文件位置
    public class func url(forResource name: String?, withExtension ext: String?) -> URL? {
        
        bundle.url(forResource: name, withExtension: ext)
    }
    
    /// 资源束下json文件路径
    public class var jsonPath: String? {
        
        bundle.path(forResource: "HTTPCode", ofType: "json")
    }
    
    /// 资源束下json文件位置
    public class var jsonURL: URL? {
        
        bundle.url(forResource: "HTTPCode", withExtension: "json")
    }
}
