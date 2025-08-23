//
//  HTTPUploadRequest.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/2.
//  上传请求体

import Foundation
#if canImport(MNSwiftKit_Networking)
import MNSwiftKit_Networking
#endif

/// 询问上传数据回调
public typealias HTTPRequestBodyHandler = HTTPSessionBodyHandler

/// 上传请求
@objc public class HTTPUploadRequest: HTTPRequest {
    /// 上传请求的文件内容边界
    @objc public var boundary: String?
    /// 询问下载位置回调
    var bodyHandler: HTTPRequestBodyHandler?
    /// 上传内容的长度
    @objc public var contentLength: Int = 0
    /// 上传请求方式
    @objc public var method: HTTPMethod = .get
    /// 请求产生的Task
    @objc public var uploadTask: URLSessionUploadTask? { task as? URLSessionUploadTask }
    
    deinit {
        bodyHandler = nil
    }
    
    
    /// 开始上传
    /// - Parameters:
    ///   - start: 开始回调
    ///   - body: 上传请求体
    ///   - progress: 进度回调
    ///   - completion: 结束回调
    @objc open func start(_ start: HTTPRequestStartHandler? = nil, body: @escaping HTTPRequestBodyHandler, progress: HTTPRequestProgressHandler? = nil, completion: HTTPRequestCompletionHandler? = nil) {
        startHandler = start
        bodyHandler = body
        progressHandler = progress
        completionHandler = completion
        resume()
    }
}
