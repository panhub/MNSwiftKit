//
//  MNNetworkContentType.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/11/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

/// 编码选项
public enum MNNetworkContentType: String {
    
    /// 二进制数据
    case binary = "application/octet-stream"
    
    /// JSON数据
    case json = "application/json"
    
    /// 纯文本
    case plainText = "text/plain"
    
    /// HTML数据
    case plist = "application/x-plist"
    
    /// XML数据
    case xml = "application/xml"
    
    /// HTML数据
    case html = "text/html"
    
    /// 文件上传
    case formData = "multipart/form-data"
    
    /// URL编码数据
    case formURL = "application/x-www-form-urlencoded"
}
