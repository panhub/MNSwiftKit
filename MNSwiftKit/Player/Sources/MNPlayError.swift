//
//  MNPlayer+Error.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/10/28.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  播放器错误

import Foundation

/// 播放器错误
public enum MNPlayError: Swift.Error {
    
    /// 播放失败
    case playFailed
    
    /// 寻找进度失败
    case seekFailed(String)
    
    /// 设置Category失败
    case setCategoryFailed(String)
    
    /// 内部错误
    case underlyingError(Swift.Error)
}

extension MNPlayError {
    
    /// 错误码
    public var errCode: Int {
        switch self {
        case .playFailed: return -101
        case .seekFailed: return -102
        case .setCategoryFailed: return -103
        case .underlyingError(let error): return error._code
        }
    }
    
    /// 错误信息
    public var errMsg: String {
        switch self {
        case .playFailed: return "播放失败"
        case .seekFailed: return "寻找播放进度失败"
        case .setCategoryFailed: return "设置媒体类别失败"
        case .underlyingError(let error): return error.localizedDescription
        }
    }
}

extension MNPlayError: CustomNSError {
    
    public static var errorDomain: String {
        
        "com.mn.play.error"
    }
    
    public var errorCode: Int {
        
        errCode
    }
    
    public var errorUserInfo: [String : Any] {
        var userInfo: [String : Any] = [NSLocalizedDescriptionKey:errMsg]
        switch self {
        case .underlyingError(let error):
            userInfo[NSUnderlyingErrorKey] = error
        default: break
        }
        return userInfo
    }
}

extension MNPlayError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .playFailed: return "播放失败"
        case .seekFailed(let desc): return "寻找播放进度失败: \(desc)"
        case .setCategoryFailed(let desc): return "设置媒体类别失败: \(desc)"
        case .underlyingError(let error): return error.localizedDescription
        }
    }
}

extension Swift.Error {
    
    /// 转换为播放器错误
    public var asPlayError: MNPlayError? { self as? MNPlayError }
}
