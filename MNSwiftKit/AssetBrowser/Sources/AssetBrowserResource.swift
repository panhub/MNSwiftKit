//
//  AssetBrowserResource.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  资源加载

import UIKit
import Foundation

/// 资源浏览器图片加载器
public class AssetBrowserResource {
    
    /// 资源束
    private class var bundle: Bundle {
#if SWIFT_PACKAGE
        // SPM 会为每个包含资源的模块自动生成一个 Bundle.module 属性
        return Bundle.module
#endif
        if let url = Bundle(for: AssetBrowserResource.self).url(forResource: "MNSwiftKit_AssetBrowser", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        if let url = Bundle.main.url(forResource: "MNSwiftKit_AssetBrowser", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        return Bundle(for: AssetBrowserResource.self)
    }
    
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
