//
//  MNNetworkSerializer.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/19.
//  请求序列化

import UIKit
import Foundation

/// 网络请求方式
public enum MNNetworkMethod: String {
    /// GET请求
    case get = "GET"
    /// PUT请求
    case put = "PUT"
    /// POST请求
    case post = "POST"
    /// HEAD头请求
    case head = "HEAD"
    /// DELETE请求
    case delete = "DELETE"
}

/// 请求序列化
public class MNNetworkSerializer {
    /// 是否允许使用蜂窝网络
    public var allowsCellularAccess: Bool = true
    /// 超时时长
    public var timeoutInterval: TimeInterval = 10.0
    /// 字符串编码格式
    public var stringEncoding: String.Encoding = .utf8
    /// 上传请求体边界字符串
    public var boundary: String?
    ///POST数据体
    public var body: Any?
    ///请求地址参数拼接 支持 String, [String: String]
    public var param: Any?
    ///参数编码选项
    public var serializationOptions: MNNetworkParam.EncodeOptions = .all
    ///缓存策略
    public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ///Header信息
    public var headerFields: [String: String]?
    ///服务端认证信息
    public var authHeaderField: [String: String]?
    ///默认序列化实例
    nonisolated(unsafe) public static let `default`: MNNetworkSerializer = MNNetworkSerializer()
    
    public init() {}
    
    /// 获取请求实例
    /// - Parameters:
    ///   - string: 请求地址
    ///   - method: 请求方法
    /// - Returns: 请求实例
    public func request(with string: String, method: MNNetworkMethod) throws -> URLRequest {
        // 检查链接
        guard string.isEmpty == false else { throw MNNetworkError.requestSerializationFailure(.badUrl(string)) }
        // 拼接参数并编码
        guard let url = percentEncod(string) else { throw MNNetworkError.requestSerializationFailure(.cannotEncodeUrl(string)) }
        // 拼接参数并编码
        guard let URL = URL(string: url) else { throw MNNetworkError.requestSerializationFailure(.badUrl(string)) }
        // 创建请求体
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        request.allHTTPHeaderFields = headerFields
        request.allowsCellularAccess = allowsCellularAccess
        // 添加认证信息
        if let (username, password) = authHeaderField?.first, let data = (username + ":" + password).data(using: stringEncoding) {
            request.setValue(data.base64EncodedString(), forHTTPHeaderField: "Authorization")
        }
        // 添加数据体
        if method == .put || method == .post {
            // 这里要先处理boundary, 有可能是文件上传, 要先设置Content-Type
            if let boundary = boundary {
                // 上传请求
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("multipart/form-data;charset=utf-8;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                }
            }
            if let body = body {
                let data: Data? = body is Data ? (body as! Data) : MNNetworkParam.extract(body, options: serializationOptions)?.data(using: stringEncoding)
                guard let httpBody = data, httpBody.isEmpty == false else { throw MNNetworkError.requestSerializationFailure(.cannotEncodeBody) }
                request.httpBody = httpBody
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    // 默认设置为利用URL Encoded数据类型
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                }
            }
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
        if let params = MNNetworkParam.extract(param, options: serializationOptions) {
            string.append(string.contains("?") ? "&" : "?")
            string.append(params)
        }
        return string
    }
}
