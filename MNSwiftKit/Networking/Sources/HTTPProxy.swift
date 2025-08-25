//
//  HTTPProxy.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/21.
//  请求代理

import UIKit
import ObjectiveC.runtime

/// HTTP请求解析队列
fileprivate let DispatchSerializationQueue = DispatchQueue(label: "com.mn.url.session.serialization.queue", qos: .default, attributes: .concurrent)

fileprivate extension URLSessionTask {
    
    private struct MNHTTPAssociated {
        nonisolated(unsafe) static var challengeFailure = "com.mn.http.session.task.challenge.failure"
        nonisolated(unsafe) static var downloadFailure = "com.mn.http.session.task.download.failure"
        nonisolated(unsafe) static var fileIsDownloaded = "com.mn.http.session.task.file.downloaded"
    }
    
    var isDownloaded: Bool {
        get { objc_getAssociatedObject(self, &MNHTTPAssociated.fileIsDownloaded) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &MNHTTPAssociated.fileIsDownloaded, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    var isChallengeFailure: Bool {
        get { objc_getAssociatedObject(self, &MNHTTPAssociated.challengeFailure) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &MNHTTPAssociated.challengeFailure, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    var downloadError: HTTPError? {
        get { objc_getAssociatedObject(self, &MNHTTPAssociated.downloadFailure) as? HTTPError }
        set { objc_setAssociatedObject(self, &MNHTTPAssociated.downloadFailure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

public class HTTPProxy: NSObject {
    /// 下载的位置
    public var fileURL: URL?
    /// 服务端返回的数据
    private var data: Data = Data()
    /// 解析器
    public var parser: HTTPParser?
    /// 文件句柄
    private var fileHandle: FileHandle?
    /// 结束回调队列
    public weak var completionQueue: DispatchQueue?
    /// 上传进度回调
    public var uploadHandler: HTTPSessionProgressHandler?
    /// 下载位置回调
    public var locationHandler: HTTPSessionLocationHandler?
    /// 下载进度回调
    public var downloadHandler: HTTPSessionProgressHandler?
    /// 结束回调
    public var completionHandler: HTTPSessionCompletionHandler?
    /// 上传进度
    public let uploadProgress: Progress = Progress(parent: nil, userInfo: nil)
    /// 下载进度
    public let downloadProgress: Progress = Progress(parent: nil, userInfo: nil)
    
    /// 实例化请求任务代理
    /// - Parameter task: 请求任务
    public init(task: URLSessionTask) {
        super.init()
        for progress in [uploadProgress, downloadProgress] {
            progress.isPausable = true
            progress.isCancellable = true
            progress.totalUnitCount = NSURLSessionTransferSizeUnknown
            progress.cancellationHandler = { [weak task] in
                task?.cancel()
            }
            progress.pausingHandler = { [weak task] in
                task?.suspend()
            }
            if #available(iOS 9.0, *) {
                progress.resumingHandler = { [weak task] in
                    task?.resume()
                }
            }
            progress.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: .new, context: nil)
        }
    }
    
    deinit {
        for progress in [uploadProgress, downloadProgress] {
            progress.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let progress = object as? Progress else { return }
        if progress == uploadProgress {
            (completionQueue ?? .main).async {
                self.uploadHandler?(progress)
            }
        } else if progress == downloadProgress {
            (completionQueue ?? .main).async {
                self.downloadHandler?(progress)
            }
        }
    }
}

public extension HTTPProxy {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var credential: URLCredential?
        var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if HTTPSecurityPolicy.default.evaluate(server: challenge.protectionSpace.serverTrust!, domain: challenge.protectionSpace.host) {
                disposition = .useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                // 验证失败 标记失败 这里还不能获取错误信息
                disposition = .cancelAuthenticationChallenge
                task.isChallengeFailure = true
            }
        }
        completionHandler(disposition, credential)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void {
        uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend
        uploadProgress.completedUnitCount = task.countOfBytesSent
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // 若存在文件句柄则关闭
        if let fileHandle = fileHandle {
            if #available(iOS 13.0, *) {
                do {
                    try fileHandle.close()
                } catch {
#if DEBUG
                    print("关闭文件句柄时发生错误: \(error)\n-\(#file)-\(#function)-\(#line)")
#endif
                }
            } else {
                fileHandle.closeFile()
            }
        }
        // 检查错误
        var httpError: HTTPError?
        if task.isChallengeFailure {
            httpError = .httpsChallengeFailure(.underlyingError(error!))
        } else if let downloadError = task.downloadError {
            httpError = downloadError
        }
        if let httpError = httpError {
            if let fileURL = fileURL {
                try? FileManager.default.removeItem(at: fileURL)
            }
            (completionQueue ?? .main).async {
                self.completionHandler?(.failure(httpError))
            }
            return
        }
        // 检查文件已下载标记
        if task.isDownloaded {
            (completionQueue ?? .main).async {
                self.completionHandler?(.success(self.fileURL?.path ?? NSNull()))
            }
            return
        }
        // 解析数据并返回
        DispatchSerializationQueue.async {
            var result: Any?
            let parser = self.parser ?? .default
            do {
                result = try parser.parse(response: task.response, data: self.data, error: error)
            } catch {
                // 回调错误 下载失败则删除
                if let fileURL = self.fileURL, parser.downloadOptions.contains(.removeExistsFile) {
                    try? FileManager.default.removeItem(at: fileURL)
                }
                (self.completionQueue ?? .main).async {
                    self.completionHandler?(.failure(error.httpError!))
                }
                return
            }
            if let fileURL = self.fileURL, parser.analyticMode == .none {
                // 下载请求, 将下载路径返回
                if #available(iOS 16.0, *) {
                    result = fileURL.path(percentEncoded: false)
                } else {
                    result = fileURL.path
                }
            }
            // 回调结果
            (self.completionQueue ?? .main).async {
                self.completionHandler?(.success(result ?? NSNull()))
            }
        }
    }
}

public extension HTTPProxy {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let fileURL = fileURL {
            // 转换响应者
            guard let response = response as? HTTPURLResponse else {
                let httpError = HTTPError.responseParseFailure(.cannotParseResponse(response: response))
                dataTask.downloadError = httpError
                completionHandler(.cancel)
                return
            }
            // 创建文件处理者
            let fileHandle: FileHandle!
            do {
                fileHandle = try FileHandle(forWritingTo: fileURL)
            } catch {
                let msg: String = "已接收到响应, 读取本地文件失败, 主动取消请求\n-\(#file)-\(#function)-\(#line)"
                let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotWriteToFile, userInfo: [NSLocalizedDescriptionKey:"读取本地文件失败", NSLocalizedFailureReasonErrorKey:msg,NSDebugDescriptionErrorKey:msg,NSUnderlyingErrorKey:error])
                let httpError = HTTPError.downloadFailure(.cannotReadFile(path: fileURL.path, error: nsError as Error))
                dataTask.downloadError = httpError
                completionHandler(.cancel)
                return
            }
            // 计算已下载文件大小
            var fileSize: UInt64 = 0
            if #available(iOS 13.4, *) {
                do {
                    fileSize = try fileHandle.seekToEnd()
                } catch {
                    let msg: String = "已接收到响应, 读取本地文件失败, 主动取消请求\n-\(#file)-\(#function)-\(#line)"
                    let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotWriteToFile, userInfo: [NSLocalizedDescriptionKey:"读取本地文件失败", NSLocalizedFailureReasonErrorKey:msg,NSDebugDescriptionErrorKey:msg,NSUnderlyingErrorKey:error])
                    let httpError = HTTPError.downloadFailure(.cannotReadFile(path: fileURL.path, error: nsError as Error))
                    dataTask.downloadError = httpError
                    completionHandler(.cancel)
                    return
                }
            } else {
                fileSize = fileHandle.seekToEndOfFile()
            }
            // 检查响应码
            guard response.statusCode == 206 else {
                if response.statusCode == 416, fileSize > 0 {
                    // 416: Range超出边界, 若不为空文件则默认已下载完成
                    // 这种完全相信数据的方法并不安全, 最好还是与服务端协商校验文件MD5
                    dataTask.isDownloaded = true
                } else {
                    // 失败处理
                    let msg: String = "主动取消请求, 响应码不合法: \(response.statusCode)\n- 可能是文件变化导致Range超出边界;\n- 服务端不支持分片下载;\n-\(#file)-\(#function)-\(#line)"
                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorDataLengthExceedsMaximum, userInfo: [NSLocalizedDescriptionKey:"无法下载文件", NSLocalizedFailureReasonErrorKey:msg,NSDebugDescriptionErrorKey:msg])
                    let httpError = HTTPError.downloadFailure(.cannotWriteToFile(path: fileURL.path, error: error as Error))
                    dataTask.downloadError = httpError
                }
                completionHandler(.cancel)
                return
            }
            // 计算总文件大小与当前进度
            self.fileHandle = fileHandle
            let expectedContentLength = response.expectedContentLength
            downloadProgress.totalUnitCount = Int64(fileSize) + expectedContentLength
            downloadProgress.completedUnitCount = Int64(fileSize)
        } else {
            // 清空数据体
            data.removeAll()
        }
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let fileHandle = fileHandle {
            if #available(iOS 13.4, *) {
                do {
                    try fileHandle.write(contentsOf: data)
                } catch {
                    let msg: String = "主动终止请求, 写入数据失败, 已写入: \(downloadProgress.completedUnitCount)\n-\(#file)-\(#function)-\(#line)"
                    let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotWriteToFile, userInfo: [NSLocalizedDescriptionKey:"写入数据失败", NSLocalizedFailureReasonErrorKey:msg,NSDebugDescriptionErrorKey:msg,NSUnderlyingErrorKey:error])
                    let httpError = HTTPError.downloadFailure(.cannotWriteToFile(path: "", error: nsError as Error))
                    dataTask.downloadError = httpError
                    dataTask.cancel()
                    return
                }
            } else {
                fileHandle.write(data)
            }
            downloadProgress.completedUnitCount += Int64(data.count)
        } else {
            // 拼接数据
            self.data.append(data)
            downloadProgress.totalUnitCount = dataTask.countOfBytesExpectedToReceive
            downloadProgress.completedUnitCount = dataTask.countOfBytesReceived
        }
    }
}

public extension HTTPProxy {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Void {
        downloadProgress.totalUnitCount = totalBytesExpectedToWrite
        downloadProgress.completedUnitCount = totalBytesWritten
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) -> Void {
        downloadProgress.totalUnitCount = expectedTotalBytes;
        downloadProgress.completedUnitCount = fileOffset;
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) -> Void {
        
        fileURL = nil
        
        let fileURL: URL? = locationHandler?(downloadTask.response, location)
        guard let fileURL = fileURL, fileURL.isFileURL else {
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotMoveFile, userInfo: [NSLocalizedDescriptionKey:"文件路径不合法", NSLocalizedFailureReasonErrorKey:"文件路径回调可能未实现或返回的路径不可用",NSDebugDescriptionErrorKey:"文件路径不合法, 文件路径回调可能未实现或返回的路径不可用"])
            let httpError = HTTPError.downloadFailure(.cannotMoveFile(path: fileURL?.path ?? "", error: error as Error))
            downloadTask.downloadError = httpError
            return
        }
        
        // 检查文件
        let parser = self.parser ?? .default
        if parser.downloadOptions.contains(.removeExistsFile) {
            // 文件存在则删除
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    let httpError = HTTPError.downloadFailure(.cannotRemoveFile(path: fileURL.path, error: error))
                    downloadTask.downloadError = httpError
                    return
                }
            }
        } else {
            // 文件存在则使用旧文件
            if FileManager.default.fileExists(atPath: fileURL.path) {
                self.fileURL = fileURL
                return
            }
        }
        
        // 检查路径
        if parser.downloadOptions.contains(.createIntermediateDirectories), FileManager.default.fileExists(atPath: fileURL.deletingLastPathComponent().path) == false {
            // 创建文件夹
            do {
                try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            } catch {
                let httpError = HTTPError.downloadFailure(.cannotCreateFile(path: fileURL.path, error: error))
                downloadTask.downloadError = httpError
                return
            }
        }
        
        // 移动文件
        do {
            try FileManager.default.moveItem(at: location, to: fileURL)
        } catch {
            let httpError = HTTPError.downloadFailure(.cannotMoveFile(path: fileURL.path, error: error))
            downloadTask.downloadError = httpError
            return
        }
        
        // 保存文件位置
        self.fileURL = fileURL
    }
}
