//
//  HTTPDataRequest.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/1.
//  数据请求者

import Foundation
//#if canImport(MNSwiftKitNetworking)
//import MNSwiftKitNetworking
//#endif

/// 请求方式
@objc public enum HTTPMethod: Int {
    /// GET请求
    case get
    /// PUT请求
    case put
    /// POST请求
    case post
    /// HEAD头请求
    case head
    /// DELETE请求
    case delete
    
    
    /// 请求方法字符串
    public var rawString: String {
        switch self {
        case .get: return "GET"
        case .put: return "PUT"
        case .post: return "POST"
        case .head: return "HEAD"
        case .delete: return "DELETE"
        }
    }
}

/// 分页请求支持
@objc public protocol HTTPPagingSupported: NSObjectProtocol where Self: HTTPDataRequest {
    /// 页数
    var page: Int { set get }
    /// 是否还有更多数据
    var hasMore: Bool { set get }
    /// 是否空数据
    var isDataEmpty: Bool { get }
    /// 是否允许分页
    var isPagingEnabled: Bool { set get }
    
    /// 清理数据缓存
    func clearCache() -> Void
}

/// HTTP数据请求
@objc open class HTTPDataRequest: HTTPRequest {
    /// 数据来源
    @objc public enum DataSource: Int {
        case network // 网络数据
        case cache // 本地缓存
    }
    /// 缓存策略
    @objc public enum CachePolicy: Int {
        /// 不使用缓存
        case never
        /// 优先请求, 失败后考虑使用缓存
        case returnCacheElseLoad
        /// 优先使用缓存, 没有缓存或缓存过期则考虑加载
        case returnCacheDontLoad
    }
    /// POST数据体 非上传数据
    @objc public var body: Any?
    /// 请求方式
    @objc public var method: HTTPMethod = .get
    /// 重试次数 失败时重新请求 NSURLErrorCancelled 无效
    @objc public var retyCount: Int = 0
    /// 重试时间间隔 默认立即重试
    @objc public var retryInterval: TimeInterval = 0.0
    /// 数据来源
    @objc public var source: DataSource = .network
    /// 缓存策略
    @objc public var cachePolicy: CachePolicy = .never
    /// 缓存有效时长 单位秒 0则无限期 默认0
    @objc public var cacheValidInterval: Int = 0
    /// 缓存的key 支持定制
    @objc open var cacheForKey: String { url }
    /// 请求产生的Task
    @objc public var dataTask: URLSessionDataTask? { task as? URLSessionDataTask }
    
    /// 即将刷新数据
    @objc open func prepareReload() {}
    
    /// 即将开始加载数据
    @objc open func prepareLoadData() {}
    
    /// 请求数据
    /// - Parameters:
    ///   - start: 开始请求告知
    ///   - completion: 请求结束回调
    @objc open func start(_ start: HTTPRequestStartHandler? = nil, completion: HTTPRequestCompletionHandler?) {
        prepareLoadData()
        startHandler = start
        completionHandler = completion
        resume()
    }
    
    /// 请求结束
    /// - Parameter result: 数据体
    final public override func loadFinish(result: Result<Any, HTTPError>) {
        // 判断是否需要读取缓存
        let httpResult = HTTPResult(result: result)
        httpResult.request = self
        if result.isSuccess == false, method == .get, cachePolicy == .returnCacheElseLoad, let cache = HTTPDatabase.default.cache(forKey: cacheForKey, timeInterval: cacheValidInterval) {
            source = .cache
            httpResult.data = cache
        }
        // 定制自己的结果
        if httpResult.isSuccess {
            didFinish(result: httpResult)
            // 依据结果回调
            if httpResult.isSuccess {
                // 判断是否缓存结果
                let responseObject = httpResult.object
                if method == .get, source == .network, cachePolicy != .never, HTTPDatabase.default.setCache(responseObject, forKey: cacheForKey) {
#if DEBUG
                    print("已缓存数据")
#endif
                }
                // 回调成功函数
                didSuccess(responseObject: responseObject)
            }
        } else {
            didFail(httpResult)
        }
        // 回调结果
        (queue ?? DispatchQueue.main).async {
            // 回调结果
            self.completionHandler?(httpResult)
        }
    }
}
