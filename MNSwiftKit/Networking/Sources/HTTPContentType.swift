//
//  HTTPContentType.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/11/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

/// 编码选项
public enum HTTPContentType: String {
    
    /// JSON数据
    case json = "application/json"
    
    /// XML数据
    case xml = "application/xml"
    
    /// HTML数据
    case html = "text/html"
    
    /// 纯文本
    case plainText = "text/plain"
    
    /// HTML数据
    case plist = "application/x-plist"
    
    /// 文件上传
    case formData = "multipart/form-data"
    
    /// 二进制数据
    case binary = "application/octet-stream"
    
    /// URL编码数据
    case formURLEncoded = "application/x-www-form-urlencoded"
}
