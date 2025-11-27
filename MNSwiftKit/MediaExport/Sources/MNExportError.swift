//
//  MNExportError.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/12/8.
//  媒体输出信息

import Foundation
import AVFoundation

/// 媒体输出错误信息
public enum MNExportError: Swift.Error {
    
    /// 未知输出目录
    case unknownOutputDirectory
    /// 无法输出文件
    case cannotExportFile
    /// 媒体资源为空
    case assetIsEmpty
    /// 无法创建输出目录
    case cannotCreateDirectory(String)
    /// 文件已存在
    case fileDoesExist(String)
    /// 无法添加轨道
    case cannotInsertTrack(AVMediaType)
    /// 底层错误
    case underlyingError(Swift.Error)
}

extension Swift.Error {
    
    /// 转化错误
    public var asExportError: MNExportError? { self as? MNExportError }
}

extension MNExportError {
    
    /// 错误信息
    public var msg: String {
        switch self {
        case .unknownOutputDirectory: return "未知输出目录"
        case .cannotExportFile: return "无法输出文件"
        case .assetIsEmpty: return "媒体资源为空"
        case .cannotCreateDirectory: return "无法创建输出目录"
        case .fileDoesExist: return "文件已存在"
        case .cannotInsertTrack: return "无法插入媒体轨道"
        case .underlyingError(let error): return error.localizedDescription
        }
    }
    
    /// 内部错误
    public var underlyingError: Error? {
        switch self {
        case .underlyingError(let error): return error
        default: return nil
        }
    }
}

extension MNExportError: CustomNSError {
    
    public static var errorDomain: String {
        
        "com.mn.asset.export.error"
    }
    
    public var errorCode: Int {
        switch self {
        case .unknownOutputDirectory: return -181377
        case .cannotExportFile: return -181378
        case .assetIsEmpty: return -181379
        case .cannotCreateDirectory: return -181380
        case .fileDoesExist(let string): return -181381
        case .cannotInsertTrack: return -181382
        case .underlyingError(let error): return error._code
        }
    }
    
    public var errorUserInfo: [String : Any] {
        var userInfo: [String : Any] = [NSLocalizedDescriptionKey: msg]
        if let error = underlyingError {
            userInfo[NSUnderlyingErrorKey] = error
        }
        return userInfo
    }
}

extension MNExportError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .unknownOutputDirectory:
            return "输出目录为空"
        case .cannotExportFile:
            return "创建输出会话失败"
        case .assetIsEmpty:
            return "未插入任何资源轨道"
        case .cannotCreateDirectory(let string):
            return "无法创建创建输出目录: \(string)"
        case .fileDoesExist(let string):
            return "文件已经存在: \(string)"
        case .cannotInsertTrack(let aVMediaType):
            return "无法插入资源轨道: \(aVMediaType == .video ? "视频" : "音频")"
        case .underlyingError(let error):
            return "\(error)"
        }
    }
}
