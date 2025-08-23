//
//  HTTPSerializer.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/19.
//  请求序列化

import UIKit
import Foundation

public class HTTPSerializer {
    /** 是否允许使用蜂窝网络*/
    public var allowsCellularAccess: Bool = true
    /** 超时时长*/
    public var timeoutInterval: TimeInterval = 10.0
    /** 字符串编码格式*/
    public var stringEncoding: String.Encoding = .utf8
    /** 上传内容的分割标记*/
    public var boundary: String?
    /** 上传内容的长度*/
    public var contentLength: Int = 0
    /**POST数据体 非上传数据*/
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
        guard string.count > 0 else { throw HTTPError.requestSerializationFailure(.badUrl(string)) }
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
        if method.uppercased() == "POST" {
            if let body = body {
                // POST数据
                let data: Data? = body is Data ? (body as! Data) : HTTPExtractParam(body, options: serializationOptions)?.data(using: stringEncoding)
                guard let httpBody = data, httpBody.isEmpty == false else { throw HTTPError.requestSerializationFailure(.cannotEncodeBody) }
                request.httpBody = httpBody
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                }
            } else if let boundary = boundary {
                // Upload数据
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("multipart/form-data;charset=utf-8;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                }
                if contentLength > 0, request.value(forHTTPHeaderField: "Content-Length") == nil {
                    request.setValue("\(contentLength)", forHTTPHeaderField: "Content-Length")
                }
            }
        }
        return request
    }
    
    // url编码
    private func percentEncod(_ url: String) -> String? {
        // 链接编码
        guard var string = (url.removingPercentEncoding ?? url).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return nil }
        // 参数编码
        guard let params = HTTPExtractParam(param, options: serializationOptions) else { return string }
        // 拼接参数
        string.append(string.contains("?") ? "&" : "?")
        string.append(params)
        return string
    }
}
