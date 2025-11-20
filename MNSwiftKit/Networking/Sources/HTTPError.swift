//
//  MNNetworking.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/19.
//  请求错误定义

import Foundation

///未知错误
public let HTTPErrorUnknown: Int = NSURLErrorUnknown
///取消 -999
public let HTTPErrorCancelled: Int = NSURLErrorCancelled
///网络中断
public let HTTPErrorNetworkConnectionLost: Int = NSURLErrorNetworkConnectionLost
///无网络连接
public let HTTPErrorNotConnectedToInternet: Int = NSURLErrorNotConnectedToInternet

///链接无效
public let HTTPErrorBadUrl: Int = NSURLErrorBadURL
///链接拼接失败
public let HTTPErrorCannotEncodeUrl: Int = -1813770
///请求体编码失败
public let HTTPErrorCannotEncodeBody: Int = -1813771

///无法解析服务端响应体
public let HTTPErrorBadServerResponse: Int = NSURLErrorCannotParseResponse
///未知ContentType
public let HTTPErrorMissingContentType: Int = -1813772
///不接受的ContentType
public let HTTPErrorUnsupportedContentType: Int = -1813773
///不接受的StatusCode
public let HTTPErrorUnsupportedStatusCode: Int = -1813774

///空数据
public let HTTPErrorZeroByteData: Int = -1813775
///不能解析数据
public let HTTPErrorCannotParseData: Int = -1813776

///未知上传内容
public let HTTPErrorBodyIsEmpty: Int = -1813777

///文件已存在
public let HTTPErrorFileExist: Int = -1813778
///读取文件失败
public let HTTPErrorCannotReadFile: Int = -1813779
///无法保存文件
public let HTTPErrorCannotWriteToFile: Int = NSURLErrorCannotWriteToFile
///删除文件失败
public let HTTPErrorCannotRemoveFile: Int = NSURLErrorCannotRemoveFile
///创建文件失败
public let HTTPErrorCannotCreateFile: Int = NSURLErrorCannotCreateFile
///移动文件失败
public let HTTPErrorCannotMoveFile: Int = NSURLErrorCannotMoveFile

///错误信息
public enum HTTPError: Swift.Error {
    
    /// 请求序列化错误
    public enum RequestSerializationReason {
        case badUrl(String)
        case cannotEncodeUrl(String)
        case cannotEncodeBody
    }
    
    /// 解析响应错误
    public enum ResponseParseReason {
        case missingMimeType
        case cannotParseResponse(URLResponse?)
        case unacceptedContentType(String, accepts: [String])
        case unacceptedStatusCode(Int)
        case underlyingError(Error)
    }
    
    /// 解析数据错误
    public enum DataParseReason {
        case zeroByteData
        case cannotDecodeData
        case underlyingError(Error)
    }
    
    /// 上传失败
    public enum UploadFailureReason {
        case bodyIsEmpty
    }
    
    /// SSL挑战失败
    public enum SSLChallengeReason {
        case underlyingError(Error)
    }

    /// I/O失败
    public enum DownloadFailureReason {
        case fileExist(URL, error: Error)
        case cannotReadFile(URL, error: Error)
        case cannotCreateFile(URL, error: Error)
        case cannotMoveFile(URL?, error: Error)
        case cannotWriteToFile(URL?, error: Error)
        case cannotRemoveFile(URL, error: Error)
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
    
    /// 转换错误类型
    public var asHttpError: HTTPError? { self as? HTTPError }
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
        default: return nil
        }
    }
    
    /// 是否是取消带来的错误
    public var isCancelled: Bool { errCode == HTTPErrorCancelled }
    
    /// 是否是请求编码时的错误
    public var isSerializationError: Bool {
        switch self {
        case .requestSerializationFailure: return true
        default: return false
        }
    }
    
    /// 是否是数据解析错误
    public var isParseError: Bool {
        switch self {
        case .dataParseFailure: return true
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

extension HTTPError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .requestSerializationFailure(let reason):
             return reason.desc
        case .responseParseFailure(let reason):
             return reason.desc
        case .dataParseFailure(let reason):
            return reason.desc
        case .uploadFailure(let reason):
            return reason.desc
        case .downloadFailure(let reason):
            return reason.desc
        case .httpsChallengeFailure(let reason):
            return reason.desc
        case .custom(let code, let msg):
            return "custom code:\(code) msg:\(msg)"
        }
    }
}

extension HTTPError.RequestSerializationReason {
    
    public var errCode: Int {
        switch self {
        case .badUrl:
            return HTTPErrorBadUrl
        case .cannotEncodeUrl:
            return HTTPErrorCannotEncodeUrl
        case .cannotEncodeBody:
            return HTTPErrorCannotEncodeBody
        }
    }
    
    public var errMsg: String {
        switch self {
        case .badUrl:
            return "请求地址无效"
        case .cannotEncodeUrl:
            return "请求地址编码失败"
        case .cannotEncodeBody:
            return "数据编码失败"
        }
    }
    
    public var desc: String {
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
        case .cannotParseResponse:
            return HTTPErrorBadServerResponse
        case .missingMimeType:
            return HTTPErrorMissingContentType
        case .unacceptedContentType:
            return HTTPErrorUnsupportedContentType
        case .unacceptedStatusCode:
            return HTTPErrorUnsupportedStatusCode
        case .underlyingError(let error):
            return error._code
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
        case .cannotParseResponse:
            return "无法解析响应体"
        case .missingMimeType:
            return "未知响应类型"
        case .unacceptedContentType:
            return "不接受响应类型"
        case .unacceptedStatusCode(let code):
            return "不接受响应码\(code)"
        case .underlyingError(let error):
            return error.localizedDescription
        }
    }
    
    public var desc: String {
        switch self {
        case .cannotParseResponse(let response):
            if let response = response {
                return "无法解析响应体: \(response)"
            }
            return "无法解析响应体"
        case .missingMimeType:
            return "未知ContentType"
        case .unacceptedContentType(let mimeType, let accepts):
            return "不接受ContentType mimeType:\(mimeType) accepts:\(accepts)"
        case .unacceptedStatusCode(let code):
            return "响应码错误 code: \(code)"
        case .underlyingError(let error):
            return (error as NSError).localizedFailureReason ?? error.localizedDescription
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .underlyingError(let error): return error
        default: return nil
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
    
    public var desc: String {
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
        case .underlyingError(let error): return error
        default: return nil
        }
    }
}

extension HTTPError.UploadFailureReason {
    
    public var errCode: Int {
        HTTPErrorBodyIsEmpty
    }
    
    public var errMsg: String {
        "上传内容为空"
    }
    
    public var desc: String {
        "body is empty"
    }
    
    public var underlyingError: Error? { nil }
}

extension HTTPError.DownloadFailureReason {
    
    public var errCode: Int {
        switch self {
        case .fileExist:
            return HTTPErrorFileExist
        case .cannotReadFile:
            return HTTPErrorCannotReadFile
        case .cannotCreateFile:
            return HTTPErrorCannotCreateFile
        case .cannotMoveFile:
            return HTTPErrorCannotMoveFile
        case .cannotWriteToFile:
            return HTTPErrorCannotWriteToFile
        case .cannotRemoveFile:
            return HTTPErrorCannotRemoveFile
        }
    }
    
    public var errMsg: String {
        switch self {
        case .fileExist:
            return "文件已存在"
        case .cannotReadFile:
            return "读取文件数据失败"
        case .cannotCreateFile:
            return "创建文件失败"
        case .cannotMoveFile:
            return "文件移动失败"
        case .cannotWriteToFile:
            return "写入文件失败"
        case .cannotRemoveFile:
            return "无法删除旧文件"
        }
    }
    
    public var desc: String {
        switch self {
        case .fileExist(let url, let error):
            return "文件已存在:\(url)\n\(error)"
        case .cannotReadFile(let url, let error):
            return "读取文件数据失败:\(url)\n\(error)"
        case .cannotCreateFile(let url, let error):
            return "创建目录失败:\(url)\n\(error)"
        case .cannotMoveFile(let url, let error):
            if let url = url {
                return "文件移动失败:\(url)\n\(error)"
            }
            return "文件移动失败:\(error)"
        case .cannotWriteToFile(let url, let error):
            if let url = url {
                return "写入文件失败:\(url)\n\(error)"
            }
            return "写入文件失败:\(error)"
        case .cannotRemoveFile(let url, let error):
            return "无法删除旧文件:\(url)\n\(error)"
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .fileExist(_, let error), .cannotReadFile(_, let error), .cannotCreateFile(_, let error), .cannotMoveFile(_, let error), .cannotRemoveFile(_, let error):
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
    
    public var desc: String {
        switch self {
        case .underlyingError(let error):
            return "HTTPS挑战失败:\(error)"
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .underlyingError(let error):
            return error
        }
    }
}
