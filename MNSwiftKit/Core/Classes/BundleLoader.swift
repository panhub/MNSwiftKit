//
//  BundleLoader.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/8/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

extension Bundle {
    
    /// 获取指定名称资源束
    /// - Parameter named: 资源束名称
    convenience init?(for named: String) {
        if let url = BundleLoader.url(for: named) {
            self.init(url: url)
        } else {
            self.init(for: BundleLoader.self)
        }
    }
}

public class BundleLoader {
    
    /// 获取资源束位置
    /// - Parameter named: 资源束名称
    /// - Returns: 资源束位置
    public class func url(for named: String) -> URL? {
        // 尝试从 CocoaPods 生成的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle.main.url(forResource: named, withExtension: "bundle") {
            return url
        }
        // 尝试从当前框架/模块的 bundle 中加载（库作为 Pod 使用时）
        if let url = Bundle(for: BundleLoader.self).url(forResource: named, withExtension: "bundle") {
            return url
        }
        // 可能是直接源代码集成，尝试在框架 bundle 的上级目录查找
        if let url = Bundle(for: BundleLoader.self).url(forResource: named, withExtension: "bundle", subdirectory: "Frameworks/MNSwiftKit.framework") {
            return url
        }
        return nil
    }
}
