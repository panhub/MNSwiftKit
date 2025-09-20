//
//  MNPHError.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/12/20.
//

import Foundation

/// 文件不存在错误码
public let MNPHErrorFileDoesNotExist = NSURLErrorFileDoesNotExist

/// 相册错误
public enum MNPHError: Swift.Error {
    
    public enum LivePhotoErrorReason {
        case fileNotExist
        case requestFailed
        case underlyingError(Error)
    }
    
    public enum AssetDeleteErrorReason {
        case unknown
        case isEmpty
        case underlyingError(Error)
    }
    
    public enum AssetWriteErrorReason {
        case unknown
        case underlyingError(Error)
    }
    
    //  LivePhoto导出/合成失败
    case livePhotoError(LivePhotoErrorReason)
    // 删除系统媒体时错误
    case deleteError(AssetDeleteErrorReason)
    // 保存媒体文件时错误
    case writeError(AssetWriteErrorReason)
}

extension Swift.Error {
    
    /// 转换为相册错误
    public var phError: MNPHError? { self as? MNPHError }
}
