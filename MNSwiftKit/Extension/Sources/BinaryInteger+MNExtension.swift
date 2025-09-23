//
//  BinaryInteger+MNExtension.swift
//  MNSwiftKitKit
//
//  Created by panhub on 2025/9/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

extension NameSpaceWrapper where Base: BinaryInteger {
    
    /// 文件存储形式字符串
    public var fileSizeString: String {
        
        byteFormat(for: .file, units: .useAll)
    }
    
    /// 内存大小形式字符串
    public var memorySizeString: String {
        
        byteFormat(for: .memory, units: .useAll)
    }
    
    /// 格式化储存形式字符串
    /// - Parameters:
    ///   - style: 格式化类型
    ///   - units: 单位
    /// - Returns: 格式化后字符串
    public func byteFormat(for style: ByteCountFormatter.CountStyle, units: ByteCountFormatter.Units) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = style
        formatter.isAdaptive = true
        formatter.includesUnit = true
        formatter.allowedUnits = units
        return formatter.string(fromByteCount: Int64(base))
    }
}
