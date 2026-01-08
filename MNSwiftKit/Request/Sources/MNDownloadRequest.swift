//
//  MNDownloadRequest.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/2.
//  下载请求体

import Foundation

/// 下载请求
public class MNDownloadRequest: MNRequest {
    
    /**
     断点下载
     - 不是下载数据本身, 而是已经下载好的数据相关信息
     - 如: 文件名, 存储位置, 已经下载好的数据的长度等
     */
    public var resumeData: Data?
    /// 询问下载位置回调 可能会触发多次回调 下载前检查文件是否存在
    public var locationHandler: MNNetworkSession.LocationHandler?
    /// 下载选项
    public var downloadOptions: MNNetworkDownloadOptions = [.createIntermediateDirectories, .removeExistsFile]
    /// 请求产生的Task
    public var downloadTask: URLSessionDownloadTask? { task as? URLSessionDownloadTask }
    
    public override init() {
        super.init()
        serializationType = .none
    }
    
    public override init(url: String) {
        super.init(url: url)
        serializationType = .none
    }
    
    deinit {
        resumeData = nil
        locationHandler = nil
    }
    
    
    /// 开启下载请求
    /// - Parameters:
    ///   - start: 开始回调
    ///   - location: 下载位置
    ///   - progress: 进度回调
    ///   - completion: 结束回调
    open func start(_ start: MNRequest.StartHandler? = nil, location: @escaping MNNetworkSession.LocationHandler, progress: MNNetworkSession.ProgressHandler? = nil, completion: MNRequest.CompletionHandler?) {
        resumeData = nil
        startHandler = start
        locationHandler = location
        progressHandler = progress
        completionHandler = completion
        resume()
    }
    
    /// 暂停下载
    /// - Parameter completion: 重新启动所需信息
    open func pause(completion: ((Data?) -> Void)? = nil) {
        MNRequestManager.default.pauseDownload(self, completion: completion)
    }
    
    /// 继续下载
    /// - Parameter completion: 操作完成回调
    open func resume(completion: ((Bool) -> Void)?) {
        MNRequestManager.default.resumeDownload(self, completion: completion)
    }
}
