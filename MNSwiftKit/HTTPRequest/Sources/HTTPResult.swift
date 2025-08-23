//
//  MNHTTPResult.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/1.
//  网络请求结果

import Foundation
#if canImport(MNSwiftKit_Networking)
import MNSwiftKit_Networking
#endif

/// 网络请求结果
extension Result where Success == Any, Failure == HTTPError {
    
    /// 错误体
    public var error: HTTPError? {
        switch self {
        case .failure(let error): return error
        default: return nil
        }
    }
    
    /// 响应码
    public var code: Int {
        switch self {
        case .failure(let error): return error.errCode
        default: return HTTPResultCode.succeed.rawValue
        }
    }
    
    /// 响应信息
    public var msg: String {
        switch self {
        case .failure(let error): return error.errMsg
        default: return "success"
        }
    }
    
    /// 测试输出
    public var debugMsg: String {
        switch self {
        case .failure(let error): return error.debugMsg
        default: return "success"
        }
    }
    
    /// 请求数据
    public var data: Any? {
        switch self {
        case .success(let object): return object
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

/// HTTP请求结果码
@objc public enum HTTPResultCode: Int {
    case failed = 0
    case unknown = -1
    case succeed = 1
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
    case cannotEncodeBody = -1813780
    case missingMimeType = -1813790
    case unacceptedContentType = -1813800
    case unacceptedStatusCode = -1813810
    case zeroByteData = -1813820
    case bodyEmpty = -1813840
    case fileExists = -1813850
    case cannotReadFile = -1813860
    // 项目定义
    case notLogin = 401 // 没有登录
    case offline = 402 // 设备掉线
}

@objc public class HTTPResult: NSObject {
    
    /// Swift数据结果
    private var result: Result<Any, HTTPError> = .failure(.custom(code: HTTPErrorUnknown, msg: "unknown error"))
    
    /// 响应码
    @objc public var code: HTTPResultCode {
        get { HTTPResultCode(rawValue: result.code) ?? .failed }
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
    @objc public var msg: String {
        get { result.msg }
        set { result = .failure(.custom(code: result.code, msg: newValue)) }
    }
    
    /// 请求的数据
    @objc public var data: Any? {
        get { result.data }
        set {
            if let responseObject = newValue {
                result = .success(responseObject)
            } else if let _ = result.data {
                result = .failure(.custom(code: HTTPErrorUnknown, msg: "request failed"))
            }
        }
    }
    
    /// HTTP响应码
    @objc public var responseCode: Int { result.responseCode }
    
    /// 直接获取数据<确定有值时再使用>
    @objc public var object: Any { data ?? NSNull() }
    
    /// 请求是否成功
    @objc public var isSuccess: Bool { code == .succeed }
    
    /// 测试信息
    @objc public var debugMsg: String { result.debugMsg }
    
    /// 记录请求
    @objc public weak var request: HTTPRequest!
    
    /// 构造请求结果
    /// - Parameter result: 数据内容
    public convenience init(result: Result<Any, HTTPError>) {
        self.init()
        self.result = result
    }
    
    /// 构造请求结果
    /// - Parameter responseObject: 数据内容
    @objc public convenience init(responseObject: Any) {
        self.init(result: .success(responseObject))
    }
}
