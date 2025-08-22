//
//  ToastResourceLoader.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/8/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  资源加载

import Foundation

/// 资源加载器
public class ToastResourceLoader {
    
    /// 资源束
    private static var bundle: Bundle = {
        // 尝试从 CocoaPods 生成的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle.main.url(forResource: "MNSwiftKit_Toast", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        // 尝试从当前框架/模块的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle(for: ToastResourceLoader.self).url(forResource: "MNSwiftKit_Toast", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        // 可能是直接源代码集成，尝试在框架 bundle 的上级目录查找
        if let url = Bundle(for: ToastResourceLoader.self).url(forResource: "MNSwiftKit_Toast", withExtension: "bundle", subdirectory: "Frameworks/MNSwiftKit.framework"), let bundle = Bundle(url: url) {
            return bundle
        }
        return Bundle(for: ToastResourceLoader.self)
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
}
