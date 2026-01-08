//
//  HTTPContentType.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/11/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

/// 编码选项
public enum HTTPContentType {
    
    /// 不做处理
    case none
    
    /// JSON数据
    case json
    
    /// 纯文本
    case plainText
    
    /// HTML数据
    case plist
    
    /// XML数据
    case xml
    
    /// HTML数据
    case html
    
    /// 文件上传
    case formData
    
    /// 二进制数据
    case binary
    
    /// URL编码数据
    case formURLEncoded
}

extension HTTPContentType {
    
    /// 内容类型的字符串表达
    public var rawString: String {
        switch self {
        case .none: return "application/octet-stream"
        case .json: return "application/json"
        case .plainText: return "text/plain"
        case .plist: return "application/x-plist"
        case .xml: return "application/xml"
        case .html: return "text/html"
        case .formData: return "multipart/form-data"
        case .binary: return "application/octet-stream"
        case .formURLEncoded: return "application/x-www-form-urlencoded"
        }
    }
}
