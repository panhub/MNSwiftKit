//
//  HTTPManager.swift
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
public class HTTPManager {
    /// 网络会话
    private let session = HTTPSession()
    /// 唯一实例化入口
    public static let `default` = HTTPManager()
    
    /// 禁止外部实例化
    private init() {
        session.completionQueue = DispatchQueue(label: "com.mn.http.session.completion.queue", qos: .userInitiated, attributes: .concurrent)
    }
    
    /// 加载请求
    /// - Parameter request: 请求体
    public func resume(request: HTTPRequest) {
        guard request.isRunning == false else { return }
        if request is HTTPDataRequest {
            load(request as! HTTPDataRequest)
        } else if request is HTTPUploadRequest {
            upload(request as! HTTPUploadRequest)
        } else if request is HTTPDownloadRequest {
            download(request as! HTTPDownloadRequest)
        } else if request is HTTPFileRequest {
            download(request as! HTTPFileRequest)
        }
    }
    
    /// 取消请求
    /// - Parameter request: 请求体
    public func cancel(request: HTTPRequest) {
        guard request.isRunning else { return }
        guard let task = request.task else { return }
        task.cancel()
    }
    
    /// 请求结束回调
    /// - Parameters:
    ///   - request: 请求体
    ///   - result: 请求结果
    private func finish(request: HTTPRequest, result: Result<Any, HTTPError>) {
        // 标记已不是第一次请求
        request.isFirstRunning = false
        // 判断是否需要重新请求并修改数据来源
        let code = result.code
        if request is HTTPDataRequest {
            let dataRequest = request as! HTTPDataRequest
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
            dataRequest.source = .network
        }
        // 判断是否需要回调
        if request.ignoringErrorCodes.contains(code) { return }
        // 回调结果
        request.loadFinish(result: result)
    }
}

// MARK: - 数据请求
extension HTTPManager {
    
    /// 加载数据请求
    /// - Parameter request: 数据请求
    public func load(_ request: HTTPDataRequest) {
        // 判断是否需要读取缓存
        if request.method == .get, request.cachePolicy == .returnCacheDontLoad, request.mn_retryEventCount <= 0, let cache = HTTPDatabase.default.cache(forKey: request.cacheForKey, timeInterval: request.cacheValidInterval) {
            request.source = .cache
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
        // 回调开始
        if request.mn_retryEventCount <= 0 {
            DispatchQueue.main.async { [weak request] in
                guard let request = request else { return }
                request.startHandler?()
            }
        }
        // 开启请求
        dataTask.resume()
    }
    
    /// 构建数据请求任务
    /// - Parameter request: 数据请求
    /// - Returns: 请求任务
    private func dataTask(_ request: HTTPDataRequest) -> URLSessionDataTask? {
        return session.dataTask(url: request.url, method: request.method.rawString, serializer: serializer(request), parser: parser(request), progress: request.progressHandler, completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        })
    }
}

// MARK: - 上传请求
extension HTTPManager {
    
    /// 加载上传请求
    /// - Parameter request: 上传请求
    public func upload(_ request: HTTPUploadRequest) {
        // 创建Task
        request.task = uploadTask(request)
        guard let uploadTask = request.task else { return }
        // 回调开始
        DispatchQueue.main.async { [weak request] in
            guard let request = request else { return }
            request.startHandler?()
        }
        // 开启请求
        uploadTask.resume()
    }
    
    /// 构建上传任务
    /// - Parameter request: 上传请求
    /// - Returns: 上传任务
    private func uploadTask(_ request: HTTPUploadRequest) -> URLSessionUploadTask? {
        return session.uploadTask(url: request.url, serializer: serializer(request), parser: parser(request), body: request.bodyHandler ?? {NSNull()}, progress: request.progressHandler, completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        })
    }
}

// MARK: - 下载请求
extension HTTPManager {
    
    /// 加载下载请求
    /// - Parameter request: 下载请求
    public func download(_ request: HTTPDownloadRequest) {
        // 创建Task
        request.task = downloadTask(request)
        guard let downloadTask = request.task else { return }
        // 回调开始
        DispatchQueue.main.async { [weak request] in
            guard let request = request else { return }
            request.startHandler?()
        }
        // 开启请求
        downloadTask.resume()
    }
    
    /// 构建下载任务
    /// - Parameter request: 下载请求
    /// - Returns: 下载任务
    private func downloadTask(_ request: HTTPDownloadRequest) -> URLSessionDownloadTask? {
        return session.downloadTask(url: request.url, serializer: serializer(request), parser: parser(request), location: request.locationHandler ?? { _, _ in URL(fileURLWithPath: "") }, progress: request.progressHandler, completion: { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        })
    }
    
    /// 取消下载
    /// - Parameters:
    ///   - request: 下载请求
    ///   - completionHandler: 结束回调
    public func cancel(download request: HTTPDownloadRequest, completion completionHandler: ((Data?) -> Void)? = nil) {
        // 询问下载实例
        guard let downloadTask = request.downloadTask else {
            completionHandler?(nil)
            return
        }
        // 判断是否下载中
        guard downloadTask.state == .running else {
            completionHandler?(request.resumeData)
            return
        }
        // 取消下载 会触发结束回调
        downloadTask.cancel { [weak request] data in
            if let request = request {
                request.resumeData = data
            }
            completionHandler?(data)
        }
    }
    
    /// 继续下载
    /// - Parameters:
    ///   - request: 下载请求
    ///   - completionHandler: 结束回调
    public func resume(download request: HTTPDownloadRequest, completion completionHandler: ((Bool) -> Void)? = nil) -> Void {
        // 判断是否下载中
        guard request.isRunning == false else {
            completionHandler?(false)
            return
        }
        // 判断是否支持暂停下载
        guard let resumeData = request.resumeData else {
            completionHandler?(false)
            return
        }
        // 创建新的下载请求
        request.task = session.downloadTask(resumeData: resumeData, parser: parser(request), location: request.locationHandler ?? { _, _ in URL(fileURLWithPath: "") }, progress: request.progressHandler) { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        }
        guard let downloadTask = request.task else {
            completionHandler?(false)
            return
        }
        // 置空暂停标记
        request.resumeData = nil
        // 开启请求
        downloadTask.resume()
        // 回调成功
        completionHandler?(true)
    }
}

// MARK: - 文件下载请求
extension HTTPManager {
    
    /// 加载文件下载请求
    /// - Parameter request: 文件下载请求
    public func download(_ request: HTTPFileRequest) {
        // 创建Task
        request.task = dataTask(request)
        guard let dataTask = request.task else { return }
        // 回调开始
        DispatchQueue.main.async { [weak request] in
            guard let request = request else { return }
            request.startHandler?()
        }
        // 开启请求
        dataTask.resume()
    }
    
    /// 构建文件下载任务
    /// - Parameter request: 文件下载请求
    /// - Returns: 文件下载任务
    private func dataTask(_ request: HTTPFileRequest) -> URLSessionDataTask? {
        return session.dataTask(url: request.url, serializer: serializer(request), parser: parser(request), location: { _, _ in
            return request.locationHandler?() ?? URL(fileURLWithPath: "")
        }, progress: request.progressHandler) { [weak self] result in
            guard let self = self else { return }
            self.finish(request: request, result: result)
        }
    }
}

// MARK: - 序列化
extension HTTPManager {
    
    /// 构建请求序列化器
    /// - Parameter request: 请求体
    /// - Returns: 序列化器
    private func serializer(_ request: HTTPRequest) -> HTTPSerializer {
        let serializer = HTTPSerializer()
        serializer.param = request.param
        serializer.headerFields = request.headerFields
        serializer.authHeaderField = request.authHeaderField
        serializer.timeoutInterval = request.timeoutInterval
        serializer.stringEncoding = request.stringWritingEncoding
        serializer.serializationOptions = request.serializationOptions
        serializer.allowsCellularAccess = request.allowsCellularAccess
        if request is HTTPDataRequest {
            let dataRequest = request as! HTTPDataRequest
            serializer.body = dataRequest.body
        } else if request is HTTPUploadRequest {
            let uploadRequest = request as! HTTPUploadRequest
            serializer.boundary = uploadRequest.boundary
        }
        return serializer
    }
    
    /// 构建数据解析器
    /// - Parameter request: 请求体
    /// - Returns: 解析器
    private func parser(_ request: HTTPRequest) -> HTTPParser {
        let parser = HTTPParser()
        parser.contentType = request.contentType
        parser.analyticHandler = request.analyticHandler
        parser.stringEncoding = request.stringReadingEncoding
        parser.jsonReadingOptions = request.jsonReadingOptions
        parser.acceptableStatusCodes = request.acceptableStatusCodes
        parser.acceptableContentTypes = request.acceptableContentTypes
        if request is HTTPFileRequest {
            let fileRequest = request as! HTTPFileRequest
            parser.downloadOptions = fileRequest.downloadOptions
        } else if request is HTTPDownloadRequest {
            let downloadRequest = request as! HTTPDownloadRequest
            parser.downloadOptions = downloadRequest.downloadOptions
        }
        return parser
    }
}

// MARK: - 标记请求重试次数
extension HTTPDataRequest {
    
    fileprivate struct RetryAssociated {
        
        nonisolated(unsafe) static var retryCount: Void?
    }
    
    /// 当前重试次数
    fileprivate var mn_retryEventCount: Int {
        get {
            objc_getAssociatedObject(self, &HTTPDataRequest.RetryAssociated.retryCount) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &HTTPDataRequest.RetryAssociated.retryCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
