//
//  HTTPFileRequest.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/12/19.
//  文件下载请求
//  利用句柄写入本地文件
//  暂停: 取消任务   继续: 开始任务

import UIKit
import Foundation
//#if canImport(MNSwiftKitNetworking)
//import MNSwiftKitNetworking
//#endif

/// 询问下载位置回调
public typealias HTTPFileLocationHandler = ()->URL

/// 文件下载请求
public class HTTPFileRequest: HTTPRequest {
    
    /// 请求产生的Task
    @objc public var dataTask: URLSessionDataTask? { task as? URLSessionDataTask }
    
    /// 询问下载位置回调
    public var locationHandler: HTTPFileLocationHandler?
    
    /// 下载选项
    public var downloadOptions: HTTPParser.DownloadOptions = [.createIntermediateDirectories]
    
    public override init() {
        super.init()
        analyticMode = .none
    }
    
    @objc public override init(url: String) {
        super.init(url: url)
        analyticMode = .none
    }
    
    deinit {
        locationHandler = nil
    }
    
    
    /// 开始下载
    /// - Parameters:
    ///   - start: 开始回调
    ///   - location: 下载位置回调
    ///   - progress: 进度回调
    ///   - completion: 结束回调
    @objc open func start(_ start: HTTPRequestStartHandler? = nil, location: @escaping HTTPFileLocationHandler, progress: HTTPRequestProgressHandler? = nil, completion: HTTPRequestCompletionHandler?) {
        startHandler = start
        locationHandler = location
        progressHandler = progress
        completionHandler = completion
        resume()
    }
}
