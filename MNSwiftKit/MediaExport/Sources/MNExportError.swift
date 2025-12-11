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
    /// 未知错误
    case unknown
    /// 已取消
    case cancelled
    /// 繁忙
    case exporting
    /// 资源不可用
    case unexportable
    /// 资源不可读
    case unreadable
    /// 无法输出文件
    case cannotExportFile(URL, fileType: AVFileType)
    /// 未知文件类型
    case unknownFileType(String)
    /// 无法创建输出目录
    case cannotCreateDirectory(Error)
    /// 文件已存在
    case fileDoesExist(URL)
    /// 无法添加资源轨道
    case cannotAppendTrack(AVMediaType)
    /// 无法读取资源
    case cannotReadAsset(Error)
    /// 无法读写入文件
    case cannotWritToFile(URL, fileType: AVFileType, error: Error)
    /// 无法添加Output
    case cannotAddOutput(AVMediaType)
    /// 未知输出设置
    case unknownExportSetting(AVMediaType, fileType: AVFileType)
    /// 无法添加Input
    case cannotAddInput(AVMediaType)
    /// 无法开始读取
    case cannotStartReading(Error)
    /// 无法开始写入
    case cannotStartWriting(Error)
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
        case .unknown: return "发生未知错误"
        case .cancelled: return "已取消任务"
        case .exporting: return "输出会话繁忙, 请稍后重试"
        case .unreadable: return "无法读取资源"
        case .unexportable: return "无法输出资源"
        case .cannotExportFile: return "不支持输出文件类型"
        case .unknownFileType: return "未知输出文件类型"
        case .cannotCreateDirectory: return "无法创建输出目录"
        case .fileDoesExist: return "文件已存在"
        case .cannotAppendTrack(let mediaType): return "添加\(mediaType == .audio ? "音频" : "视频")轨道失败"
        case .cannotReadAsset: return "构建资源读取器失败"
        case .cannotWritToFile: return "构建资源写入器失败"
        case .cannotAddOutput(let mediaType): return "添加\(mediaType == .audio ? "音频" : "视频")读取配置失败"
        case .unknownExportSetting(let mediaType, _): return "获取\(mediaType == .audio ? "音频" : "视频")输出配置失败"
        case .cannotAddInput(let mediaType): return "添加\(mediaType == .audio ? "音频" : "视频")输入配置失败"
        case .cannotStartReading(let error): return error.localizedDescription
        case .cannotStartWriting(let error): return error.localizedDescription
        case .underlyingError(let error): return error.localizedDescription
        }
    }
    
    /// 内部错误
    public var underlyingError: Error? {
        switch self {
        case .cannotCreateDirectory(let error): return error
        case .cannotReadAsset(let error): return error
        case .cannotWritToFile(_, _, let error): return error
        case .cannotStartReading(let error): return error
        case .cannotStartWriting(let error): return error
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
        case .unknown: return -133303
        case .cancelled: return -181377
        case .exporting: return -181378
        case .unexportable: return -181379
        case .unreadable: return -181380
        case .cannotExportFile: return -181381
        case .unknownFileType: return -181382
        case .cannotCreateDirectory: return -181383
        case .fileDoesExist: return -181384
        case .cannotAppendTrack: return -181385
        case .cannotReadAsset: return -181386
        case .cannotWritToFile: return -181387
        case .cannotAddOutput: return -181388
        case .unknownExportSetting: return -181389
        case .cannotAddInput: return -181390
        case .cannotStartReading: return -181391
        case .cannotStartWriting: return -181392
        case .underlyingError: return -181393
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
        case .unknown: return "发生未知错误"
        case .cancelled: return "已取消操作"
        case .exporting: return "正在输出操作"
        case .unexportable: return "检查导出操作失败"
        case .unreadable: return "检查可读性失败"
        case .cannotExportFile(let url, let fileType): return "不支持输出该类型的文件(请参考'outputURL'对于文件类型的解释): \(fileType) \(url)"
        case .unknownFileType(let string): return "分析文件类型失败: \(string)"
        case .cannotCreateDirectory(let error): return "创建输出文件夹失败: \(error)"
        case .fileDoesExist(let path): return "输出文件已存在: \(path)"
        case .cannotAppendTrack(let mediaType): return "添加\(mediaType == .audio ? "音频" : "视频")轨道失败"
        case .cannotReadAsset(let error): return "构建资源读取器失败: \(error)"
        case .cannotWritToFile(let url, let fileType, let error): return "构建资源写入器失败: \(url)\n文件类型: \(fileType)\n错误信息: \(error)"
        case .cannotAddOutput(let mediaType): return "添加\(mediaType == .audio ? "音频" : "视频")输出失败"
        case .unknownExportSetting(let mediaType, _): return "获取\(mediaType == .audio ? "音频" : "视频")输出配置失败"
        case .cannotAddInput(let mediaType): return "添加\(mediaType == .audio ? "音频" : "视频")输入失败"
        case .cannotStartReading(let error): return "开启读取操作失败: \(error)"
        case .cannotStartWriting(let error): return "开启写入操作失败: \(error)"
        case .underlyingError(let error): return "\(error)"
        }
    }
}
