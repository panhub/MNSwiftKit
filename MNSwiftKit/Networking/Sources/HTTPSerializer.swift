//
//  HTTPSerializer.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/19.
//  请求序列化

import UIKit
import Foundation

/// 请求序列化
public class HTTPSerializer {
    /** 是否允许使用蜂窝网络*/
    public var allowsCellularAccess: Bool = true
    /** 超时时长*/
    public var timeoutInterval: TimeInterval = 10.0
    /** 字符串编码格式*/
    public var stringEncoding: String.Encoding = .utf8
    /** 上传请求体边界字符串*/
    public var boundary: String?
    /**POST数据体*/
    public var body: Any?
    /**请求地址参数拼接 支持 String, [String: String]*/
    public var param: Any?
    /**参数编码选项*/
    public var serializationOptions: HTTPParam.EncodeOptions = .all
    /**缓存策略*/
    public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    /**Header信息*/
    public var headerFields: [String: String]?
    /**服务端认证信息*/
    public var authHeaderField: [String: String]?
    /**默认序列化实例*/
    public static let `default`: HTTPSerializer = HTTPSerializer()
    
    /// 获取请求实例
    /// - Parameters:
    ///   - string: 请求地址
    ///   - method: 请求方法
    /// - Returns: 请求实例
    public func request(with string: String, method: String) throws -> URLRequest {
        // 检查链接
        guard string.isEmpty == false else { throw HTTPError.requestSerializationFailure(.badUrl(string)) }
        // 拼接参数并编码
        guard let url = percentEncod(string) else { throw HTTPError.requestSerializationFailure(.cannotEncodeUrl(string)) }
        // 拼接参数并编码
        guard let URL = URL(string: url) else { throw HTTPError.requestSerializationFailure(.badUrl(string)) }
        // 创建请求体
        var request = URLRequest(url: URL)
        request.httpMethod = method
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        request.allHTTPHeaderFields = headerFields
        request.allowsCellularAccess = allowsCellularAccess
        // 添加认证信息
        if let (username, password) = authHeaderField?.first, let data = (username + ":" + password).data(using: stringEncoding) {
            request.setValue(data.base64EncodedString(), forHTTPHeaderField: "Authorization")
        }
        // 添加数据体
        switch method.uppercased() {
        case "PUT", "POST":
            if let boundary = boundary {
                // 上传请求
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("multipart/form-data;charset=utf-8;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                }
            }
            if let body = body {
                let data: Data? = body is Data ? (body as! Data) : HTTPParam.extract(body, options: serializationOptions)?.data(using: stringEncoding)
                guard let httpBody = data, httpBody.isEmpty == false else { throw HTTPError.requestSerializationFailure(.cannotEncodeBody) }
                request.httpBody = httpBody
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    // 默认设置为利用URL Encoded数据类型
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                }
            }
        default: break
        }
        return request
    }
    
    /// URL编码
    /// - Parameter url: 链接字符串
    /// - Returns: 编码后的字符串
    private func percentEncod(_ url: String) -> String? {
        // 链接编码
        guard var string = (url.removingPercentEncoding ?? url).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return nil }
        // 参数编码
        if let params = HTTPParam.extract(param, options: serializationOptions) {
            string.append(string.contains("?") ? "&" : "?")
            string.append(params)
        }
        return string
    }
}
