//
//  HTTPSession.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/21.
//  请求会话管理

import Foundation
import ObjectiveC.runtime

/// 请求进度回调
public typealias HTTPSessionProgressHandler = (_ progress: Progress)->Void
/// 下载位置回调
public typealias HTTPSessionLocationHandler = (_ response: URLResponse?, _ url: URL?)->URL
/// 上传内容回调 接收 URL Data String
public typealias HTTPSessionBodyHandler = ()->Any
/// 请求结束回调
public typealias HTTPSessionCompletionHandler = (Result<Any, HTTPError>)->Void

/// 任务实例化队列
fileprivate let DispatchTaskQueue: DispatchQueue = DispatchQueue(label: "com.mn.url.session.task.create.queue", qos: .userInteractive)

/// 定义公共通知
extension Notification.Name {
    public static let HTTPSessionDidFinishEvents = Notification.Name("com.mn.http.session.finish.events")
    public static let HTTPSessionDidBecomeInvalid = Notification.Name("com.mn.http.session.become.invalid")
}

public class HTTPSession: NSObject {
    /// 会话实例
    private var session: URLSession!
    /// 代理缓存
    private var proxies = [Int: HTTPProxy]()
    /// 结束回调队列
    public var completionQueue: DispatchQueue? = .main
    /// 信号量保证线程安全
    fileprivate let semaphore = DispatchSemaphore(value: 1)
    
    // 不允许直接实例化
    public override init() {
        super.init()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: queue)
        session.getTasksWithCompletionHandler { [weak self] dataTasks, uploadTasks, downloadTasks in
            // 初始化
            guard let self = self else { return }
            for dataTask in dataTasks {
                self.setProxy(for: dataTask)
            }
            for uploadTask in uploadTasks {
                self.setProxy(for: uploadTask)
            }
            for downloadTask in downloadTasks {
                self.setProxy(for: downloadTask)
            }
        }
    }
}

// MARK: - GET/POST/HEAD/DELETE
extension HTTPSession {
    
    /// GET请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - progress: 进度回调
    ///   - completion: 结束回调
    public func get(url: String, progress: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler?) {
        guard let dataTask = dataTask(url: url, method: "GET", progress: progress, completion: completion) else { return }
        dataTask.resume()
    }
    
    /// POST请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - progress: 进度回调
    ///   - completion: 结束回调
    public func post(url: String, progress: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler?) {
        guard let dataTask = dataTask(url: url, method: "POST", progress: progress, completion: completion) else { return }
        dataTask.resume()
    }
    
    /// HEAD请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - completion: 结束回调
    public func head(url: String, completion: HTTPSessionCompletionHandler?) {
        guard let dataTask = dataTask(url: url, method: "HEAD", completion: completion) else { return }
        dataTask.resume()
    }
    
    /// DELETE请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - completion: 结束回调
    public func delete(url: String, completion: HTTPSessionCompletionHandler?) {
        guard let dataTask = dataTask(url: url, method: "DELETE", completion: completion) else { return }
        dataTask.resume()
    }
}

// MARK: - 数据请求
extension HTTPSession {
    
    /// 数据请求任务
    /// - Parameters:
    ///   - url: 请求地址
    ///   - method: 请求方法
    ///   - serializer: 请求序列化器
    ///   - parser: 响应者解析器
    ///   - progress: 进度回调
    ///   - completion: 结束回调
    /// - Returns: 数据请求任务实例
    public func dataTask(url: String, method: String, serializer: HTTPSerializer = .default, parser: HTTPParser = .default, progress: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler?) -> URLSessionDataTask? {
        var request: URLRequest!
        do {
            request = try serializer.request(with: url, method: method.uppercased())
        } catch {
            let httpError: HTTPError = error.asHttpError ?? .custom(code: error._code, msg: error.localizedDescription)
            (completionQueue ?? .main).async {
                completion?(.failure(httpError))
            }
            return nil
        }
        var dataTask: URLSessionDataTask!
        DispatchTaskQueue.sync {
            dataTask = self.session.dataTask(with: request)
        }
        // 保存代理
        setProxy(for: dataTask, parser: parser, location: nil, upload: (method.uppercased() == "GET" ? nil : progress), download: (method.uppercased() == "GET" ? progress : nil), completion: completion)
        return dataTask
    }
    
    /// 文件数据请求任务
    /// - Parameters:
    ///   - url: 文件地址
    ///   - serializer: 请求序列化器
    ///   - parser: 响应者解析器
    ///   - location: 文件保存位置
    ///   - progress: 进度回调
    ///   - completion: 结束回调
    /// - Returns: 文件数据请求任务实例
    public func dataTask(url: String, serializer: HTTPSerializer = .default, parser:HTTPParser = .default, location: @escaping HTTPSessionLocationHandler, progress: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler?) -> URLSessionDataTask? {
        // 创建文件
        let fileURL = location(nil, nil)
        if parser.downloadOptions.contains(.removeExistsFile), FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                let httpError = HTTPError.downloadFailure(.fileExist(fileURL, error: error))
                (completionQueue ?? .main).async {
                    completion?(.failure(httpError))
                }
                return nil
            }
        }
        if parser.downloadOptions.contains(.createIntermediateDirectories), FileManager.default.fileExists(atPath: fileURL.deletingLastPathComponent().path) == false {
            do {
                try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            } catch {
                let httpError = HTTPError.downloadFailure(.cannotCreateFile(fileURL, error: error))
                (completionQueue ?? .main).async {
                    completion?(.failure(httpError))
                }
                return nil
            }
        }
        if FileManager.default.fileExists(atPath: fileURL.path) == false, FileManager.default.createFile(atPath: fileURL.path, contents: nil) == false {
            let msg: String = "创建文件失败, 文件路径可能不可用\n-\(#file)-\(#function)-\(#line)"
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: [NSLocalizedDescriptionKey:"创建文件失败", NSLocalizedFailureReasonErrorKey:msg,NSDebugDescriptionErrorKey:msg])
            let httpError = HTTPError.downloadFailure(.cannotCreateFile(fileURL, error: error as Error))
            (completionQueue ?? .main).async {
                completion?(.failure(httpError))
            }
            return nil
        }
        // 检测已下载
        var fileSize: Int64 = 0
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            fileSize = attributes[FileAttributeKey.size] as! Int64
        } catch {
            let msg: String = "无法确定Range, 无法开始下载\n-\(#file)-\(#function)-\(#line)"
            let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotWriteToFile, userInfo: [NSLocalizedDescriptionKey:"读取本地文件失败", NSLocalizedFailureReasonErrorKey:msg,NSDebugDescriptionErrorKey:msg,NSUnderlyingErrorKey:error])
            let httpError = HTTPError.downloadFailure(.cannotReadFile(fileURL, error: nsError as Error))
            (completionQueue ?? .main).async {
                completion?(.failure(httpError))
            }
            return nil
        }
        // 创建请求
        var request: URLRequest!
        do {
            request = try serializer.request(with: url, method: "GET")
        } catch {
            let httpError: HTTPError = error.asHttpError ?? .custom(code: error._code, msg: error.localizedDescription)
            (completionQueue ?? .main).async {
                completion?(.failure(httpError))
            }
            return nil
        }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("bytes=\(fileSize)-", forHTTPHeaderField: "Range")
        var dataTask: URLSessionDataTask!
        DispatchTaskQueue.sync {
            dataTask = self.session.dataTask(with: request)
        }
        // 保存代理
        setProxy(for: dataTask, parser: parser, fileUrl: fileURL, download: progress, completion: completion)
        return dataTask
    }
}

// MARK: - 下载请求
extension HTTPSession {
    
    /// 下载请求任务
    /// - Parameters:
    ///   - url: 下载地址
    ///   - serializer: 请求序列化器
    ///   - parser: 响应者解析器
    ///   - location: 文件保存位置回调
    ///   - progress: 下载进度回调
    ///   - completion: 结束回调
    /// - Returns: 下载任务实例
    public func downloadTask(url: String, serializer: HTTPSerializer = .default, parser:HTTPParser = .default, location: @escaping HTTPSessionLocationHandler, progress: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler?) -> URLSessionDownloadTask? {
        // 判断是否需要下载文件
        if parser.downloadOptions.contains(.removeExistsFile) == false {
            var filePath: String
            let fileURL = location(nil, nil)
            if #available(iOS 16.0, *) {
                filePath = fileURL.path(percentEncoded: false)
            } else {
                filePath = fileURL.path
            }
            if fileURL.isFileURL, FileManager.default.fileExists(atPath: filePath) {
                (completionQueue ?? .main).async {
                    completion?(.success(filePath))
                }
                return nil
            }
        }
        // 初始化下载请求
        let request: URLRequest!
        do {
            request = try serializer.request(with: url, method: "GET")
        } catch {
            let httpError: HTTPError = error.asHttpError ?? .custom(code: error._code, msg: error.localizedDescription)
            (completionQueue ?? .main).async {
                completion?(.failure(httpError))
            }
            return nil
        }
        var downloadTask: URLSessionDownloadTask!
        DispatchTaskQueue.sync {
            downloadTask = self.session.downloadTask(with: request)
        }
        // 设置代理
        setProxy(for: downloadTask, parser: parser, location: location, download: progress, completion: completion)
        return downloadTask
    }
    
    /// 继续下载任务
    /// - Parameters:
    ///   - resumeData: 文件标记
    ///   - parser: 响应者解析器
    ///   - location: 文件存放位置回调
    ///   - progress: 下载进度回调
    ///   - completion: 下载结束回调
    /// - Returns: 下载任务实例
    public func downloadTask(resumeData: Data, parser: HTTPParser = .default, location: @escaping HTTPSessionLocationHandler, progress: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler?) -> URLSessionDownloadTask? {
        var downloadTask: URLSessionDownloadTask!
        DispatchTaskQueue.sync {
            downloadTask = self.session.downloadTask(withResumeData: resumeData)
        }
        // 设置代理
        setProxy(for: downloadTask, parser: parser, location: location, download: progress, completion: completion)
        return downloadTask
    }
}

// MARK: - 上传请求
extension HTTPSession {
    
    /// 上传请求任务
    /// - Parameters:
    ///   - url: 上传地址
    ///   - method: 请求方式
    ///   - serializer: 请求序列化器
    ///   - parser: 响应者解析器
    ///   - body: 上传体
    ///   - progress: 上传进度
    ///   - completion: 上传结束回调
    /// - Returns: 上传任务实例
    public func uploadTask(url: String, method: String = "POST", serializer: HTTPSerializer = .default, parser:HTTPParser = .default, body: HTTPSessionBodyHandler, progress: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler?) -> URLSessionUploadTask? {
        // 创建请求
        var request: URLRequest!
        do {
            request = try serializer.request(with: url, method: method)
        } catch {
            let httpError: HTTPError = error.asHttpError ?? .custom(code: error._code, msg: error.localizedDescription)
            (completionQueue ?? .main).async {
                completion?(.failure(httpError))
            }
            return nil
        }
        // 询问body
        let obj = body()
        var uploadTask: URLSessionUploadTask?
        if let filePath = obj as? String, FileManager.default.fileExists(atPath: filePath) {
            DispatchTaskQueue.sync {
                uploadTask = self.session.uploadTask(with: request, fromFile: URL(fileURLWithPath: filePath))
            }
        } else if let fileURL = obj as? URL, fileURL.isFileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            DispatchTaskQueue.sync {
                uploadTask = self.session.uploadTask(with: request, fromFile: fileURL)
            }
        } else if let fileData = obj as? Data, fileData.count > 0 {
            DispatchTaskQueue.sync {
                uploadTask = self.session.uploadTask(with: request, from: fileData)
            }
        }
        guard let uploadTask = uploadTask else {
            (completionQueue ?? .main).async {
                completion?(.failure(.uploadFailure(.bodyIsEmpty)))
            }
            return nil
        }
        // 设置代理
        setProxy(for: uploadTask, parser: parser, upload: progress, completion: completion)
        return uploadTask
    }
}

// MARK: - 保存请求代理
extension HTTPSession {
    
    /// 保存任务代理
    /// - Parameters:
    ///   - task: 任务实例
    ///   - parser: 响应者解析器
    ///   - fileUrl: 文件地址
    ///   - location: 文件保存询问回调
    ///   - upload: 上传进度回调
    ///   - download: 下载进度回调
    ///   - completion: 任务结束回调
     fileprivate func setProxy(for task: URLSessionTask, parser: HTTPParser? = nil, fileUrl: URL? = nil, location: HTTPSessionLocationHandler? = nil, upload: HTTPSessionProgressHandler? = nil, download: HTTPSessionProgressHandler? = nil, completion: HTTPSessionCompletionHandler? = nil) {
        let proxy = HTTPProxy(task: task)
        proxy.parser = parser
        proxy.fileURL = fileUrl
        proxy.uploadHandler = upload
        proxy.locationHandler = location
        proxy.downloadHandler = download
        proxy.completionHandler = completion
        proxy.completionQueue = completionQueue
        setProxy(proxy, forKey: task.taskIdentifier)
    }
}

// MARK: - 代理存取
extension HTTPSession {
    
    /// 获取任务代理
    /// - Parameter identifier: 存储标识
    /// - Returns: 任务代理
    private func proxy(forKey identifier: Int) -> HTTPProxy? {
        semaphore.wait()
        let proxy = proxies[identifier]
        semaphore.signal()
        return proxy
    }
    
    /// 设置任务代理
    /// - Parameters:
    ///   - proxy: 任务代理
    ///   - identifier: 存储标识
    private func setProxy(_ proxy: HTTPProxy, forKey identifier: Int) {
        semaphore.wait()
        proxies[identifier] = proxy
        semaphore.signal()
    }
    
    /// 删除任务代理
    /// - Parameter identifier: 存储标识
    private func removeProxy(forKey identifier: Int) {
        semaphore.wait()
        proxies.removeValue(forKey: identifier)
        semaphore.signal()
    }
}

// MARK: - URLSessionDelegate
extension HTTPSession: URLSessionDelegate {
    /**
     当前session失效时, 该代理方法被调用;
     如果使用finishTasksAndInvalidate函数使该session失效,
     那么session首先会先完成最后一个task, 然后再调用URLSession:didBecomeInvalidWithError:代理方法;
     如果使用invalidateAndCancel方法来使session失效, 那么该session会立即调用此代理方法;
     @param session 失效session
     @param error 错误信息
     */
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        NotificationCenter.default.post(name: .HTTPSessionDidBecomeInvalid, object: session)
    }
    /**
     Session中所有已经入队的消息被发送出去
     @param session 会话
     */
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        NotificationCenter.default.post(name: .HTTPSessionDidFinishEvents, object: session)
    }
}

// MARK: - URLSessionTaskDelegate
extension HTTPSession: URLSessionTaskDelegate {
    /**
     服务器重定向时调用
     只会在default session或者ephemeral session中调用
     在background session中, session task会自动重定向
     @param session 当前会话
     @param task task
     @param response 响应
     @param request 请求对象
     @param completionHandler 回调处理
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    /**
     Task级别HTTPS认证挑战
     @Session级别认证挑战 不响应也会转向这个
     @param session 当前session
     @param task 当前task
     @param challenge 挑战类型
     @param completionHandler 回调挑战证书
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let proxy = proxy(forKey: task.taskIdentifier) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        proxy.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }
    
    /**
     因为认证挑战或者其他可恢复的服务器错误导致需要客户端重新发送一个含有body stream的request;
     如果task是由uploadTaskWithStreamedRequest:创建的,那么提供初始的request body stream时候会调用
     @param session 当前会话
     @param task 当前task
     @param completionHandler 回调
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        var inputStream: InputStream?
        if let bodyStream = task.originalRequest?.httpBodyStream, bodyStream.conforms(to: NSCopying.self) {
            inputStream = task.originalRequest!.httpBodyStream!.copy() as? InputStream
        }
        completionHandler(inputStream)
    }
    
    /**
     每次发送数据给服务器回调这个方法通知已经发送了多少, 总共要发送多少
     @param session 当前会话
     @param task 当前task
     @param bytesSent 已发送数据量
     @param totalBytesSent 总共要发送数据量
     @param totalBytesExpectedToSend 剩余数据量
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let proxy = proxy(forKey: task.taskIdentifier) else { return }
        proxy.urlSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
    
    /**
     Task执行结束
     @param session 当前会话
     @param task 当前task
     @param error 错误信息
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let proxy = proxy(forKey: task.taskIdentifier) else { return }
        removeProxy(forKey: task.taskIdentifier)
        proxy.urlSession(session, task: task, didCompleteWithError: error)
    }
}

// MARK: - URLSessionDataDelegate
extension HTTPSession: URLSessionDataDelegate {
    /**
     该data task获取到了服务器端传回的最初始回复(response);
     其中的completionHandler传入一个类型为NSURLSessionResponseDisposition的变量;
     通过回调completionHandler决定该传输任务接下来该做什么;
     NSURLSessionResponseAllow 该task正常进行;
     NSURLSessionResponseCancel 该task会被取消;
     NSURLSessionResponseBecomeDownload 会调用URLSession:dataTask:didBecomeDownloadTask:方法
     来新建一个download task以代替当前的data task
     NSURLSessionResponseBecomeStream 转成一个StreamTask
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let proxy = proxy(forKey: dataTask.taskIdentifier) {
            proxy.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
        } else {
            completionHandler(.allow)
        }
    }
    
    /**
     didReceiveResponse:completionHandler设置为NSURLSessionResponseBecomeDownload, 则会调用
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        guard let proxy = proxy(forKey: dataTask.taskIdentifier) else { return }
        removeProxy(forKey: dataTask.taskIdentifier)
        setProxy(proxy, forKey: downloadTask.taskIdentifier)
    }
    
    /**
     didReceiveResponse:completionHandler设置为NSURLSessionResponseBecomeStream, 则会调用
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        guard let proxy = proxy(forKey: dataTask.taskIdentifier) else { return }
        removeProxy(forKey: dataTask.taskIdentifier)
        setProxy(proxy, forKey: dataTask.taskIdentifier)
    }
    
    // 当我们获取到数据就会调用，会被反复调用，请求到的数据就在这被拼装完整
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let proxy = proxy(forKey: dataTask.taskIdentifier) else { return }
        proxy.urlSession(session, dataTask: dataTask, didReceive: data)
    }
    
    /*
     当task接收到所有期望的数据后, session会调用此代理方法
     询问data task或upload task, 是否缓存response
     如果你没有实现该方法, 那么就会使用创建session时使用的configuration对象决定缓存策略
     阻止缓存特定的URL或者修改NSCacheURLResponse对象相关的userInfo字典可使用
     缓存准则:
     1, 该request是HTTP或HTTPS URL的请求(或者你自定义的网络协议且确保该协议支持缓存)
     2, 确保request请求是成功的(返回的status code为200-299)
     3, 返回的response是来自服务器端的, 而非缓存中本身就有的
     4, 提供的NSURLRequest对象的缓存策略要允许进行缓存
     5, 服务器返回的response中与缓存相关的header要允许缓存
     5, 该response的大小不能比提供的缓存空间大太多(超过5%)
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }
}

// MARK: - URLSessionDownloadDelegate
extension HTTPSession: URLSessionDownloadDelegate {
    /**
     周期性地通知下载进度
     @param session 当前session
     @param downloadTask 下载任务实例
     @param bytesWritten 上次调用该方法后，接收到的数据字节数
     @param totalBytesWritten 目前已经接收到的数据字节数
     @param totalBytesExpectedToWrite 期望收到的文件总字节数(由Content-Length header提供, 如果没有提供, 默认是NSURLSessionTransferSizeUnknown)
     */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let proxy = proxy(forKey: downloadTask.taskIdentifier) else { return }
        proxy.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    /**
    当下载被取消或者失败后重新恢复下载时调用
     如果下载任务被取消或者失败了, 可以请求一个resumeData对象;
     比如在userInfo字典中通过NSURLSessionDownloadTaskResumeData这个键来获取到resumeData;
     使用它来提供足够的信息以重新开始下载任务;
     随后可以使用resumeData作为downloadTaskWithResumeData:或downloadTaskWithResumeData:completionHandler:的参数;
     当调用这些方法时,将开始一个新的下载任务;
     一旦继续下载任务, session会调用此代理方法;
     其中的downloadTask参数表示的就是新的下载任务, 这也意味着下载重新开始了;
    */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        guard let proxy = proxy(forKey: downloadTask.taskIdentifier) else { return }
        proxy.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
    }
    
    /**
     下载完成回调
     */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let proxy = proxy(forKey: downloadTask.taskIdentifier) else { return }
        proxy.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
}
