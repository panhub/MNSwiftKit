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
    /// 未知文件类型
    case unknownFileType(String)
    /// 无资源轨道
    case trackIsEmpty
    /// 无法创建输出目录
    case cannotCreateDirectory(String)
    /// 文件已存在
    case fileDoesExist(String)
    /// 无法输出轨道
    case cannotExportTrack(AVMediaType)
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
        case .unknownFileType: return "未知输出文件类型"
        case .trackIsEmpty: return "媒体资源为空"
        case .cannotCreateDirectory: return "无法创建输出目录"
        case .fileDoesExist: return "文件已存在"
        case .cannotExportTrack: return "无法添加媒体轨道"
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
        case .unknownFileType: return -181379
        case .trackIsEmpty: return -181380
        case .cannotCreateDirectory: return -181381
        case .fileDoesExist: return -181382
        case .cannotExportTrack: return -181383
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
        case .unknownFileType(let pathExtension):
            return "未知文件类型: \(pathExtension)"
        case .trackIsEmpty:
            return "未插入任何资源轨道"
        case .cannotCreateDirectory(let directory):
            return "无法创建创建输出目录: \(directory)"
        case .fileDoesExist(let filePath):
            return "文件已经存在: \(filePath)"
        case .cannotExportTrack(let mediaType):
            return "无法导入\(mediaType == .video ? "视频" : "音频")轨道"
        case .underlyingError(let error):
            return "\(error)"
        }
    }
}
