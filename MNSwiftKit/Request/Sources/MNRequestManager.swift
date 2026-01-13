//
//  MNRequestManager.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/1.
//  请求管理者 以单例模式存在

import UIKit
import Foundation
import ObjectiveC.runtime
#if SWIFT_PACKAGE
@_exported import MNNetworking
#endif

/// 请求管理者 以单例模式存在
public class MNRequestManager {
    /// 网络会话
    private let session = MNNetworkSession()
    /// 唯一实例化入口
    public static let `default` = MNRequestManager()
    
    /// 禁止外部实例化
    private init() {
        session.callbackQueue = DispatchQueue(label: "com.mn.http.session.completion.queue", qos: .userInitiated, attributes: .concurrent)
    }
    
    /// 加载请求
    /// - Parameter request: 请求体
    public func resume(_ request: MNRequest) {
        guard request.isRunning == false else { return }
        if request is MNDataRequest {
            load(request as! MNDataRequest)
        } else if request is MNUploadRequest {
            upload(request as! MNUploadRequest)
        } else if request is MNDownloadRequest {
            download(request as! MNDownloadRequest)
        } else if request is MNFileDataRequest {
            download(request as! MNFileDataRequest)
        }
    }
    
    /// 取消请求
    /// - Parameter request: 请求体
    public func cancel(_ request: MNRequest) {
        guard request.isRunning else { return }
        guard let task = request.task else { return }
        task.cancel()
    }
    
    /// 请求结束回调
    /// - Parameters:
    ///   - request: 请求体
    ///   - result: 请求结果
    private func finish(request: MNRequest, result: Result<Any, MNNetworkError>) {
        // 标记已不是第一次请求
        request.isFirstRunning = false
        // 判断是否需要重新请求并修改数据来源
        let code = result.code
        if request is MNDataRequest {
            let dataRequest = request as! MNDataRequest
            if let error = result.error, error.isCancelled == false, error.isSerializationError == false, error.isParseError == false, dataRequest.mn_retryEventCount < dataRequest.retyCount {
                // 重试
                DispatchQueue.main.asyncAfter(deadline: .now() + max(dataRequest.retryInterval, 0.1)) { [weak self] in
                    guard let self = self else { return }
                    dataRequest.mn_retryEventCount += 1
                    self.load(dataRequest)
                }
                return
            }
            dataRequest.mn_retryEventCount = 0
            dataRequest.dataSource = .network
        }
        // 判断是否需要回调
        if request.ignoringErrorCodes.contains(code) { return }
        // 回调结果
        request.loadFinish(result: result)
    }
}

// MARK: - 数据请求
extension MNRequestManager {
    
    /// 加载数据请求
    /// - Parameter request: 数据请求
    public func load(_ request: MNDataRequest) {
        // 判断是否需要读取缓存
        if request.method == .get, request.cachePolicy == .returnCacheDontLoad, request.mn_retryEventCount <= 0, let cache = MNRequestDatabase.default.cache(forKey: request.cacheForKey, ttl: request.cacheTTL) {
            request.dataSource = .cache
            request.isFirstRunning = false
            request.loadFinish(result: .success(cache))
#if DEBUG
            print("读取缓存成功===\(request.url)")
#endif
            return
        }
        // 创建Task
        request.task = dataTask(request)
        guard let dataTask = request.task else { return }
        // 开启请求
        dataTask.resume()
        guard request.mn_retryEventCount <= 0 else { return }
        // 回调开始
        (request.queue ?? .main).async { [weak request] in
            guard let request = request else { return }
            request.startHandler?()
        }
    }
    
    /// 构建数据请求任务
    /// - Parameter request: 数据请求
    /// - Returns: 请求任务
    private func dataTask(_ request: MNDataRequest) -> URLSessionDataTask? {
        return session.dataTask(url: request.url, method: request.method, serializer: serializer(request), parser: parser(request)) { [weak request] progress in
            guard let request = request else { return }
            guard let progressHandler = request.progressHandler else { return }
            (request.queue ?? .main).async {
                progressHandler(progress)
            }
        } completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        }
    }
}

// MARK: - 上传请求
extension MNRequestManager {
    
    /// 加载上传请求
    /// - Parameter request: 上传请求
    public func upload(_ request: MNUploadRequest) {
        // 创建Task
        request.task = uploadTask(request)
        guard let uploadTask = request.task else { return }
        // 开启请求
        uploadTask.resume()
        // 回调开始
        (request.queue ?? .main).async { [weak request] in
            guard let request = request else { return }
            request.startHandler?()
        }
    }
    
    /// 构建上传任务
    /// - Parameter request: 上传请求
    /// - Returns: 上传任务
    private func uploadTask(_ request: MNUploadRequest) -> URLSessionUploadTask? {
        return session.uploadTask(url: request.url, serializer: serializer(request), parser: parser(request), body: request.bodyHandler ?? { NSNull() }) { [weak request] progress in
            guard let request = request else { return }
            guard let progressHandler = request.progressHandler else { return }
            (request.queue ?? .main).async {
                progressHandler(progress)
            }
        } completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        }
    }
}

// MARK: - 下载请求
extension MNRequestManager {
    
    /// 加载下载请求
    /// - Parameter request: 下载请求
    public func download(_ request: MNDownloadRequest) {
        // 创建Task
        request.task = downloadTask(request)
        guard let downloadTask = request.task else { return }
        // 开启请求
        downloadTask.resume()
        // 回调开始
        (request.queue ?? .main).async { [weak request] in
            guard let request = request else { return }
            request.startHandler?()
        }
    }
    
    /// 构建下载任务
    /// - Parameter request: 下载请求
    /// - Returns: 下载任务
    private func downloadTask(_ request: MNDownloadRequest) -> URLSessionDownloadTask? {
        return session.downloadTask(url: request.url, serializer: serializer(request), parser: parser(request), location: request.locationHandler ?? { _, _ in URL(fileURLWithPath: "") }) { [weak request] progress in
            guard let request = request else { return }
            guard let progressHandler = request.progressHandler else { return }
            (request.queue ?? .main).async {
                progressHandler(progress)
            }
        } completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        }
    }
    
    /// 取消下载
    /// - Parameters:
    ///   - request: 下载请求
    ///   - completionHandler: 结束回调
    public func pauseDownload(_ request: MNDownloadRequest, completion completionHandler: ((Data?) -> Void)? = nil) {
        // 询问下载实例
        guard let downloadTask = request.downloadTask else {
            (request.queue ?? .main).async {
                completionHandler?(nil)
            }
            return
        }
        // 判断是否下载中
        guard downloadTask.state == .running else {
            let resumeData = request.resumeData
            (request.queue ?? .main).async {
                completionHandler?(resumeData)
            }
            return
        }
        // 取消下载 会触发结束回调
        downloadTask.cancel { [weak request] resumeData in
            guard let request = request else { return }
            request.resumeData = resumeData
            (request.queue ?? .main).async {
                completionHandler?(resumeData)
            }
        }
    }
    
    /// 继续下载
    /// - Parameters:
    ///   - request: 下载请求
    ///   - completionHandler: 结束回调
    public func resumeDownload(_ request: MNDownloadRequest, completion completionHandler: ((Bool) -> Void)? = nil) -> Void {
        // 判断是否下载中
        guard request.isRunning == false else {
            (request.queue ?? .main).async {
                completionHandler?(false)
            }
            return
        }
        // 判断是否支持暂停下载
        guard let resumeData = request.resumeData else {
            (request.queue ?? .main).async {
                completionHandler?(false)
            }
            return
        }
        // 创建新的下载请求
        request.task = session.downloadTask(resumeData: resumeData, parser: parser(request), location: request.locationHandler ?? { _, _ in URL(fileURLWithPath: "") }, progress: { [weak request] progress in
            guard let request = request else { return }
            guard let progressHandler = request.progressHandler else { return }
            (request.queue ?? .main).async {
                progressHandler(progress)
            }
        }, completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        })
        guard let downloadTask = request.task else {
            (request.queue ?? .main).async {
                completionHandler?(false)
            }
            return
        }
        // 置空暂停标记
        request.resumeData = nil
        // 开启请求
        downloadTask.resume()
        // 回调成功
        (request.queue ?? .main).async {
            completionHandler?(true)
        }
    }
}

// MARK: - 文件下载请求
extension MNRequestManager {
    
    /// 加载文件下载请求
    /// - Parameter request: 文件下载请求
    public func download(_ request: MNFileDataRequest) {
        // 创建Task
        request.task = dataTask(request)
        guard let dataTask = request.task else { return }
        // 开启请求
        dataTask.resume()
        // 回调开始
        (request.queue ?? .main).async { [weak request] in
            guard let request = request else { return }
            request.startHandler?()
        }
    }
    
    /// 构建文件下载任务
    /// - Parameter request: 文件下载请求
    /// - Returns: 文件下载任务
    private func dataTask(_ request: MNFileDataRequest) -> URLSessionDataTask? {
        return session.dataTask(url: request.url, serializer: serializer(request), parser: parser(request), location: request.locationHandler ?? { _, _ in URL(fileURLWithPath: "") }) { [weak request] progress in
            guard let request = request else { return }
            guard let progressHandler = request.progressHandler else { return }
            (request.queue ?? .main).async {
                progressHandler(progress)
            }
        } completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        }
    }
}

// MARK: - 序列化
extension MNRequestManager {
    
    /// 构建请求序列化器
    /// - Parameter request: 请求体
    /// - Returns: 序列化器
    private func serializer(_ request: MNRequest) -> MNNetworkSerializer {
        let serializer = MNNetworkSerializer()
        serializer.param = request.param
        serializer.headerFields = request.headerFields
        serializer.authHeaderField = request.authHeaderField
        serializer.timeoutInterval = request.timeoutInterval
        serializer.stringEncoding = request.stringWritingEncoding
        serializer.serializationOptions = request.serializationOptions
        serializer.allowsCellularAccess = request.allowsCellularAccess
        if request is MNDataRequest {
            let dataRequest = request as! MNDataRequest
            serializer.body = dataRequest.body
        } else if request is MNUploadRequest {
            let uploadRequest = request as! MNUploadRequest
            serializer.boundary = uploadRequest.boundary
        }
        return serializer
    }
    
    /// 构建数据解析器
    /// - Parameter request: 请求体
    /// - Returns: 解析器
    private func parser(_ request: MNRequest) -> MNNetworkParser {
        let parser = MNNetworkParser()
        parser.analyticHandler = request.analyticHandler
        parser.stringEncoding = request.stringReadingEncoding
        parser.serializationType = request.serializationType
        parser.jsonReadingOptions = request.jsonReadingOptions
        parser.acceptableStatusCodes = request.acceptableStatusCodes
        if request is MNFileDataRequest {
            let fileRequest = request as! MNFileDataRequest
            parser.downloadOptions = fileRequest.downloadOptions
        } else if request is MNDownloadRequest {
            let downloadRequest = request as! MNDownloadRequest
            parser.downloadOptions = downloadRequest.downloadOptions
        }
        return parser
    }
}

// MARK: - 标记请求重试次数
extension MNDataRequest {
    
    fileprivate struct RetryAssociated {
        
        nonisolated(unsafe) static var retryCount: Void?
    }
    
    /// 当前重试次数
    fileprivate var mn_retryEventCount: Int {
        get {
            objc_getAssociatedObject(self, &MNDataRequest.RetryAssociated.retryCount) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &MNDataRequest.RetryAssociated.retryCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
