//
//  MNPHError.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/12/20.
//  选择器错误

import Foundation

/// 文件不存在错误码
public let MNPickErrorFileDoesNotExist = NSURLErrorFileDoesNotExist

/// 相册错误
public enum MNPickError: Swift.Error {
    
    /// 导出相关错误
    public enum ExportFailureReason {
        case fileNotExist
        case requestFailed
        case underlyingError(Swift.Error)
    }
    
    /// 删除相关错误
    public enum DeleteFailureReason {
        case unknown
        case fileIsEmpty
        case underlyingError(Swift.Error)
    }
    
    /// 保存相关错误
    public enum WriteFailureReason {
        case unknown
        case underlyingError(Swift.Error)
    }
    
    ///  导出相关错误
    case exportError(ExportFailureReason)
    /// 删除相关错误
    case deleteError(DeleteFailureReason)
    /// 保存相关错误
    case writeError(WriteFailureReason)
}

extension MNPickError {
    
    /// 错误信息
    public var msg: String {
        switch self {
        case .exportError(let exportFailureReason): return exportFailureReason.msg
        case .deleteError(let deleteFailureReason): return deleteFailureReason.msg
        case .writeError(let writeFailureReason): return writeFailureReason.msg
        }
    }
    
    /// 内部错误
    public var underlyingError: Error? {
        switch self {
        case .exportError(let exportFailureReason): return exportFailureReason.underlyingError
        case .deleteError(let deleteFailureReason): return deleteFailureReason.underlyingError
        case .writeError(let writeFailureReason): return writeFailureReason.underlyingError
        }
    }
}

extension MNPickError: CustomNSError {
    
    public static var errorDomain: String {
        
        "com.mn.asset.pick.error"
    }
    
    public var errorCode: Int {
        switch self {
        case .exportError(let exportFailureReason): return exportFailureReason.code
        case .deleteError(let deleteFailureReason): return deleteFailureReason.code
        case .writeError(let writeFailureReason): return writeFailureReason.code
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

extension MNPickError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .exportError(let exportFailureReason): return exportFailureReason.debugDescription
        case .deleteError(let deleteFailureReason): return deleteFailureReason.debugDescription
        case .writeError(let writeFailureReason): return writeFailureReason.debugDescription
        }
    }
}

extension MNPickError.ExportFailureReason {
    
    /// 错误码
    public var code: Int {
        switch self {
        case .fileNotExist: return MNPickErrorFileDoesNotExist
        case .requestFailed: return -18130
        case .underlyingError(let error): return error._code
        }
    }
    
    /// 错误信息
    public var msg: String {
        switch self {
        case .fileNotExist: return "文件不存在"
        case .requestFailed: return "请求资源失败"
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

extension MNPickError.ExportFailureReason: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .fileNotExist: return "文件不存在"
        case .requestFailed: return "请求资源失败"
        case .underlyingError(let error): return "\(error)"
        }
    }
}

extension MNPickError.DeleteFailureReason {
    
    /// 错误码
    public var code: Int {
        switch self {
        case .unknown: return -18131
        case .fileIsEmpty: return -18132
        case .underlyingError(let error): return error._code
        }
    }
    
    /// 错误信息
    public var msg: String {
        switch self {
        case .unknown: return "发生未知错误"
        case .fileIsEmpty: return "文件为空"
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

extension MNPickError.DeleteFailureReason: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .unknown: return "文件不存在"
        case .fileIsEmpty: return "请求资源失败"
        case .underlyingError(let error): return "\(error)"
        }
    }
}

extension MNPickError.WriteFailureReason {
    
    /// 错误码
    public var code: Int {
        switch self {
        case .unknown: return -18133
        case .underlyingError(let error): return error._code
        }
    }
    
    /// 错误信息
    public var msg: String {
        switch self {
        case .unknown: return "发生未知错误"
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

extension MNPickError.WriteFailureReason: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .unknown: return "文件不存在"
        case .underlyingError(let error): return "\(error)"
        }
    }
}

extension Swift.Error {
    
    /// 转换错误类型
    public var asPickError: MNPickError! { self as? MNPickError }
}
