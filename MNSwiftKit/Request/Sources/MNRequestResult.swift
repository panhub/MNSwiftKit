//
//  MNHTTPResult.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/1.
//  网络请求结果

import Foundation

/// 网络请求结果
extension Result where Success == Any, Failure == MNNetworkError {
    
    /// 错误体
    public var error: MNNetworkError? {
        switch self {
        case .failure(let error): return error
        default: return nil
        }
    }
    
    /// 响应码
    public var code: Int {
        switch self {
        case .failure(let error): return error.errCode
        default: return MNRequestResult.Code.succeed.rawValue
        }
    }
    
    /// 响应信息
    public var msg: String {
        switch self {
        case .failure(let error): return error.errMsg
        default: return "success"
        }
    }
    
    /// 请求数据
    public var data: Any? {
        switch self {
        case .success(let data): return data
        default: return nil
        }
    }
    
    /// 是否成功
    public var isSuccess: Bool {
        switch self {
        case .success(_): return true
        default: return false
        }
    }
    
    /// HTTP响应码
    public var responseCode: Int {
        switch self {
        case .failure(let error): return error.responseCode
        default: return 200
        }
    }
}

extension Result: @retroactive CustomDebugStringConvertible where Success == Any, Failure == MNNetworkError {
    
    public var debugDescription: String {
        switch self {
        case .success(let success):
            if let debuger = success as? CustomDebugStringConvertible {
                return debuger.debugDescription
            }
            return "请求成功"
        case .failure(let failure):
            return failure.debugDescription
        }
    }
}

/// 请求结果
public class MNRequestResult: NSObject {
    
    /// 请求结果码
    public enum Code: Int {
        case succeed = 1
        case failed = 0
        case unknown = -1
        case cancelled = -999
        case badUrl = -1000
        case timedOut = -1001
        case cannotFindHost = -1003
        case cannotConnectToHost = -1004
        case networkConnectionLost = -1005
        case notConnectedToInternet = -1009
        case cannotDecodeData = -1016
        case cannotParseResponse = -1017
        case cannotCreateFile = -3000
        case cannotWriteToFile = -3003
        case cannotRemoveFile = -3004
        case cannotMoveFile = -3005
        case cannotEncodeUrl = -1813770
        case cannotEncodeBody = -1813771
        case missingContentType = -1813772
        case unacceptedContentType = -1813773
        case unacceptedStatusCode = -1813774
        case zeroByteData = -1813775
        case cannotParseData = -1813776
        case bodyIsEmpty = -1813777
        case fileExist = -1813778
        case cannotReadFile = -1813779
    }
    
    /// Swift数据结果
    private var result: Result<Any, MNNetworkError> = .failure(.custom(code: MNNetworkErrorUnknown, msg: "unknown error"))
    
    /// 响应码
    public var code: MNRequestResult.Code {
        get { MNRequestResult.Code(rawValue: result.code) ?? .failed }
        set {
            if newValue == .succeed {
                if result.isSuccess == false {
                    result = .success(NSNull())
                }
            } else {
                result = .failure(.custom(code: newValue.rawValue, msg: result.msg))
            }
        }
    }
    
    /// 错误信息
    public var msg: String {
        get { result.msg }
        set { result = .failure(.custom(code: result.code, msg: newValue)) }
    }
    
    /// 响应数据
    public var data: Any! {
        get { result.data }
        set {
            if let responseObject = newValue {
                result = .success(responseObject)
            } else if let _ = result.data {
                result = .failure(.custom(code: MNNetworkErrorUnknown, msg: "request failed"))
            }
        }
    }
    
    /// HTTP响应码
    public var responseCode: Int { result.responseCode }
    
    /// 请求是否成功
    public var isSuccess: Bool { code == .succeed }
    
    /// 记录请求
    public weak var request: MNRequest!
    
    /// 调试信息
    public override var debugDescription: String { result.debugDescription }
    
    /// 构造请求结果
    /// - Parameter result: 请求结果
    public init(result: Result<Any, MNNetworkError>) {
        self.result = result
    }
    
    /// 构造请求结果
    /// - Parameter data: 响应数据
    public convenience init(data: Any) {
        self.init(result: .success(data))
    }
}
