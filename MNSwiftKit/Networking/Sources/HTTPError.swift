//
//  MNNetworking.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/19.
//  请求错误定义

import Foundation

//=== Foundation
/**未知错误*/
public let HTTPErrorUnknown: Int = NSURLErrorUnknown
/**取消 -999*/
public let HTTPErrorCancelled: Int = NSURLErrorCancelled
/**网络中断*/
public let HTTPErrorNetworkConnectionLost: Int = NSURLErrorNetworkConnectionLost
/**无网络连接*/
public let HTTPErrorNotConnectedToInternet: Int = NSURLErrorNotConnectedToInternet
//=== Query
/**链接无效*/
public let HTTPErrorBadUrl: Int = NSURLErrorBadURL
/**链接拼接失败*/
public let HTTPErrorCannotEncodeUrl: Int = -1813770
/**请求体编码失败*/
public let HTTPErrorCannotEncodeBody: Int = -1813780
//=== Response
/**无法解析服务端响应体*/
public let HTTPErrorBadServerResponse: Int = NSURLErrorCannotParseResponse
/**未知ContentType*/
public let HTTPErrorMissingContentType: Int = -1813790
/**不接受的ContentType*/
public let HTTPErrorUnsupportedContentType: Int = -1813800
/**不接受的StatusCode*/
public let HTTPErrorUnsupportedStatusCode: Int = -1813810
//=== Parse
/**空数据*/
public let HTTPErrorZeroByteData: Int = -1813820
/**不能解析数据*/
public let HTTPErrorCannotParseData: Int = -1813830
//=== Upload
/**未知上传内容体*/
public let HTTPErrorBodyEmpty: Int = -1813840
//=== Download I/O
/**文件已存在*/
public let HTTPErrorFileExists: Int = -1813850
/**读取文件失败*/
public let HTTPErrorCannotReadFile: Int = -1813860
/**无法保存文件*/
public let HTTPErrorCannotWriteToFile: Int = NSURLErrorCannotWriteToFile
/**删除文件失败*/
public let HTTPErrorCannotRemoveFile: Int = NSURLErrorCannotRemoveFile
/**创建文件失败*/
public let HTTPErrorCannotCreateFile: Int = NSURLErrorCannotCreateFile
/**移动文件失败*/
public let HTTPErrorCannotMoveFile: Int = NSURLErrorCannotMoveFile

/**错误信息*/
public enum HTTPError: Swift.Error {
    
    public enum RequestSerializationReason {
        case badUrl(String)
        case cannotEncodeUrl(String)
        case cannotEncodeBody
    }
    
    public enum ResponseParseReason {
        case missingMimeType
        case cannotParseResponse(response: URLResponse?)
        case unacceptedContentType(mimeType: String, accept: Set<String>)
        case unacceptedStatusCode(Int)
        case underlyingError(Error)
    }
    
    public enum DataParseReason {
        case zeroByteData
        case cannotDecodeData
        case underlyingError(Error)
    }
    
    public enum UploadFailureReason {
        case bodyIsEmpty
    }
    
    public enum SSLChallengeReason {
        case underlyingError(Error)
    }

    // I/O
    public enum DownloadFailureReason {
        case fileExists(path: String, error: Error)
        case cannotReadFile(path: String, error: Error)
        case cannotCreateFile(path: String, error: Error)
        case cannotMoveFile(path: String, error: Error)
        case cannotWriteToFile(path: String, error: Error)
        case cannotRemoveFile(path: String, error: Error)
    }
    
    case requestSerializationFailure(RequestSerializationReason)
    case responseParseFailure(ResponseParseReason)
    case dataParseFailure(DataParseReason)
    case uploadFailure(UploadFailureReason)
    case downloadFailure(DownloadFailureReason)
    case httpsChallengeFailure(SSLChallengeReason)
    case custom(code: Int, msg: String)
}

extension Swift.Error {
    
    public var httpError: HTTPError? { self as? HTTPError }
}

extension HTTPError {
    
    /// 错误码
    public var errCode: Int {
        switch self {
        case .requestSerializationFailure(let reason):
            return reason.errCode
        case .responseParseFailure(let reason):
            return reason.errCode
        case .dataParseFailure(let reason):
            return reason.errCode
        case .uploadFailure(let reason):
            return reason.errCode
        case .downloadFailure(let reason):
            return reason.errCode
        case .httpsChallengeFailure(let reason):
            return reason.errCode
        case .custom(let code, _):
            return code
        }
    }
    
    /// 错误信息
    public var errMsg: String {
        switch self {
        case .requestSerializationFailure(let reason):
             return reason.errMsg
        case .responseParseFailure(let reason):
             return reason.errMsg
        case .dataParseFailure(let reason):
            return reason.errMsg
        case .uploadFailure(let reason):
            return reason.errMsg
        case .downloadFailure(let reason):
            return reason.errMsg
        case .httpsChallengeFailure(let reason):
            return reason.errMsg
        case .custom(_, let msg):
            return msg
        }
    }
    
    /// HTTP响应码
    public var responseCode: Int {
        switch self {
        case .responseParseFailure(let reason):
            return reason.responseCode
        default: return .min
        }
    }
    
    /// 测试输入
    public var debugMsg: String {
        switch self {
        case .requestSerializationFailure(let reason):
             return reason.debugMsg
        case .responseParseFailure(let reason):
             return reason.debugMsg
        case .dataParseFailure(let reason):
            return reason.debugMsg
        case .uploadFailure(let reason):
            return reason.debugMsg
        case .downloadFailure(let reason):
            return reason.debugMsg
        case .httpsChallengeFailure(let reason):
            return reason.debugMsg
        case .custom(let code, let msg):
            return "custom code:\(code) msg:\(msg)"
        }
    }
    
    /// 底层错误信息
    public var underlyingError: Error? {
        switch self {
        case .requestSerializationFailure(let reason):
            return reason.underlyingError
        case .responseParseFailure(let reason):
            return reason.underlyingError
        case .dataParseFailure(let reason):
            return reason.underlyingError
        case .uploadFailure(let reason):
            return reason.underlyingError
        case .downloadFailure(let reason):
            return reason.underlyingError
        case .httpsChallengeFailure(let reason):
            return reason.underlyingError
        default:
            return nil
        }
    }
    
    /// 是否是取消带来的错误
    public var isCancelled: Bool { errCode == HTTPErrorCancelled }
    
    /// 是否是请求编码时的错误
    public var isSerializationError: Bool {
        switch self {
        case .requestSerializationFailure(_):
            return true
        default:
            return false
        }
    }
    
    /// 是否是数据解析错误
    public var isParseError: Bool {
        switch self {
        case .dataParseFailure(_): return true
        default: return false
        }
    }
}

extension HTTPError: CustomNSError {
    
    public var errorCode: Int {
        errCode
    }
    
    public var errorUserInfo: [String : Any] {
        var userInfo: [String:Any] = [NSLocalizedDescriptionKey:errMsg]
        if let underlyingError = underlyingError {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        return userInfo
    }
}

extension HTTPError.RequestSerializationReason {
    
    public var errCode: Int {
        switch self {
        case .badUrl(_):
            return HTTPErrorBadUrl
        case .cannotEncodeUrl(_):
            return HTTPErrorCannotEncodeUrl
        case .cannotEncodeBody:
            return HTTPErrorCannotEncodeBody
        }
    }
    
    public var errMsg: String {
        switch self {
        case .badUrl(url: _):
            return "请求地址无效"
        case .cannotEncodeUrl(_):
            return "请求地址编码失败"
        case .cannotEncodeBody:
            return "数据编码失败"
        }
    }
    
    public var debugMsg: String {
        switch self {
        case .badUrl(let url):
            return "无效的请求地址=\(url)"
        case .cannotEncodeUrl(let url):
            return "错误的请求地址=\(url)"
        case .cannotEncodeBody:
            return "请求体编码失败"
        }
    }
    
    public var underlyingError: Error? { nil }
}

extension HTTPError.ResponseParseReason {
    
    public var errCode: Int {
        switch self {
        case .cannotParseResponse(_):
            return HTTPErrorBadServerResponse
        case .missingMimeType:
            return HTTPErrorMissingContentType
        case .unacceptedContentType( _, _):
            return HTTPErrorUnsupportedContentType
        case .unacceptedStatusCode(_):
            return HTTPErrorUnsupportedStatusCode
        case .underlyingError(let error):
            return (error as NSError).code
        }
    }
    
    public var responseCode: Int {
        switch self {
        case .unacceptedStatusCode(let code): return code
        default: return .min
        }
    }
    
    public var errMsg: String {
        switch self {
        case .cannotParseResponse(_):
            return "无法解析响应体"
        case .missingMimeType:
            return "未知响应类型"
        case .unacceptedContentType(_, _):
            return "不接受响应类型"
        case .unacceptedStatusCode(let code):
            return "不接受响应码\(code)"
        case .underlyingError(let error):
            return error.localizedDescription
        }
    }
    
    public var debugMsg: String {
        switch self {
        case .cannotParseResponse(let response):
            if let response = response {
                return "无法解析响应体: \(response)"
            }
            return "无法解析响应体"
        case .missingMimeType:
            return "未知ContentType"
        case .unacceptedContentType(let mimeType, let accept):
            return "不接受ContentType mimeType:\(mimeType) accept:\(accept)"
        case .unacceptedStatusCode(let code):
            return "响应码错误 code: \(code)"
        case .underlyingError(let error):
            return (error as NSError).localizedFailureReason ?? error.localizedDescription
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .underlyingError(let error):
            return error
        default:
            return nil
        }
    }
}

extension HTTPError.DataParseReason {
    
    public var errCode: Int {
        switch self {
        case .zeroByteData:
            return HTTPErrorZeroByteData
        case .cannotDecodeData:
            return HTTPErrorCannotParseData
        case .underlyingError(let error):
            return error._code
        }
    }
    
    public var errMsg: String {
        switch self {
        case .zeroByteData:
            return "数据为空"
        case .cannotDecodeData:
            return "数据解析失败"
        case .underlyingError(let error):
            return error.localizedDescription
        }
    }
    
    public var debugMsg: String {
        switch self {
        case .zeroByteData:
            return "数据为空"
        case .cannotDecodeData:
            return "数据解析失败"
        case .underlyingError(let error):
            return (error as NSError).localizedFailureReason ?? error.localizedDescription
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .underlyingError(let error):
            return error
        default:
            return nil
        }
    }
}

extension HTTPError.UploadFailureReason {
    
    public var errCode: Int { HTTPErrorBodyEmpty }
    
    public var errMsg: String {
        switch self {
        case .bodyIsEmpty:
            return "上传内容不能为空"
        }
    }
    
    public var debugMsg: String {
        switch self {
        case .bodyIsEmpty:
            return "body is empty"
        }
    }
    
    public var underlyingError: Error? { nil }
}

extension HTTPError.DownloadFailureReason {
    
    public var errCode: Int {
        switch self {
        case .fileExists(_, _):
            return HTTPErrorFileExists
        case .cannotReadFile(_, _):
            return HTTPErrorCannotReadFile
        case .cannotCreateFile(_, _):
            return HTTPErrorCannotCreateFile
        case .cannotMoveFile(_, _):
            return HTTPErrorCannotMoveFile
        case .cannotWriteToFile(_, _):
            return HTTPErrorCannotWriteToFile
        case .cannotRemoveFile(_, _):
            return HTTPErrorCannotRemoveFile
        }
    }
    
    public var errMsg: String {
        switch self {
        case .fileExists(_, _):
            return "文件已存在"
        case .cannotReadFile(_, _):
            return "读取文件数据失败"
        case .cannotCreateFile(_, _):
            return "创建文件失败"
        case .cannotMoveFile(_, _):
            return "文件移动失败"
        case .cannotWriteToFile(_, _):
            return "写入文件失败"
        case .cannotRemoveFile(_, _):
            return "无法删除旧文件"
        }
    }
    
    public var debugMsg: String {
        switch self {
        case .fileExists(let path, let error):
            return "文件已存在 path:\(path) error:\(error)"
        case .cannotReadFile(let path, let error):
            return "读取文件数据失败 path:\(path) error:\(error)"
        case .cannotCreateFile(let path, let error):
            return "创建目录失败 path:\(path) error:\(error)"
        case .cannotMoveFile(let path, let error):
            return "文件移动失败 path:\(path) error:\(error)"
        case .cannotWriteToFile(let path, let error):
            return "写入文件失败 path:\(path) error:\(error)"
        case .cannotRemoveFile(let path, let error):
            return "无法删除旧文件 path:\(path) error:\(error)"
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .fileExists(_, let error), .cannotReadFile(_, let error), .cannotCreateFile(_, let error), .cannotMoveFile(_, let error), .cannotRemoveFile(_, let error):
            return error
        default: return nil
        }
    }
}

extension HTTPError.SSLChallengeReason {
    
    public var errCode: Int {
        switch self {
        case .underlyingError(let error):
            return error._code
        }
    }
    
    public var errMsg: String {
        switch self {
        case .underlyingError(let error):
            return error.localizedDescription
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .underlyingError(let error):
            return error
        }
    }
    
    public var debugMsg: String {
        switch self {
        case .underlyingError(let error):
            return "HTTPS挑战失败:\(error)"
        }
    }
}
