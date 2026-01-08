//
//  MNFileDataRequest.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/12/19.
//  文件下载请求
//  利用句柄写入本地文件
//  暂停: 取消任务   继续: 开始任务

import UIKit
import Foundation

/// 文件下载请求
public class MNFileDataRequest: MNRequest {
    
    /// 请求产生的Task
    public var dataTask: URLSessionDataTask? { task as? URLSessionDataTask }
    /// 询问下载位置回调
    public var locationHandler: MNNetworkSession.LocationHandler!
    /// 下载选项
    public var downloadOptions: MNNetworkDownloadOptions = [.createIntermediateDirectories]
    
    public override init() {
        super.init()
        serializationType = .none
    }
    
    public override init(url: String) {
        super.init(url: url)
        serializationType = .none
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
    open func start(_ start: MNRequest.StartHandler? = nil, location: @escaping MNNetworkSession.LocationHandler, progress: MNNetworkSession.ProgressHandler? = nil, completion: MNRequest.CompletionHandler?) {
        startHandler = start
        locationHandler = location
        progressHandler = progress
        completionHandler = completion
        resume()
    }
}
