//
//  HTTPDownloadOptions.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

/// 下载选项
public struct HTTPDownloadOptions: OptionSet {
    
    /// 当路径不存在时自动创建文件夹
    public static let createIntermediateDirectories = HTTPDownloadOptions(rawValue: 1 << 0)
    
    /// 删除已存在的文件 否则存在则使用旧文件
    public static let removeExistsFile = HTTPDownloadOptions(rawValue: 1 << 1)
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
