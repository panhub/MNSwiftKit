//
//  MNDataRequest.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/1.
//  数据请求者

import Foundation

/// 分页请求支持
public protocol MNPagingRequestSupported: NSObjectProtocol where Self: MNDataRequest {
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

/// 数据请求
open class MNDataRequest: MNRequest {
    /// 数据来源
    public enum DataSource {
        /// 网络数据
        case network
        /// 本地缓存
        case cache
    }
    /// 缓存策略
    public enum CachePolicy {
        /// 不使用缓存
        case never
        /// 优先请求, 失败后考虑使用缓存, 请求成功更新缓存
        case returnCacheElseLoad
        /// 优先使用缓存, 没有缓存或缓存过期则请求, 请求成功插入缓存
        case returnCacheDontLoad
    }
    /// POST数据体 非上传数据
    public var body: Any?
    /// 请求方式
    public var method: MNNetworkMethod = .get
    /// 重试次数 失败时重新请求 NSURLErrorCancelled 无效
    internal var retyCount: Int = 0
    /// 重试时间间隔 默认立即重试
    public var retryInterval: TimeInterval = 0.0
    /// 数据来源
    public var dataSource: DataSource = .network
    /// 缓存策略
    public var cachePolicy: CachePolicy = .never
    /// 缓存有效时长
    /// - 以秒为单位，0则无限期
    public var cacheTTL: TimeInterval = 0.0
    /// 请求产生的Task
    public var dataTask: URLSessionDataTask? { task as? URLSessionDataTask }
    
    /// 缓存时的key
    open var cacheForKey: String { url }
    
    /// 即将刷新数据
    open func prepareReload() {}
    
    /// 即将开始加载数据
    open func prepareLoadData() {}
    
    /// 请求数据
    /// - Parameters:
    ///   - start: 开始请求告知
    ///   - completion: 请求结束回调
    open func start(_ start: MNRequest.StartHandler? = nil, completion: MNRequest.CompletionHandler?) {
        prepareLoadData()
        startHandler = start
        completionHandler = completion
        resume()
    }
    
    /// 请求结束
    /// - Parameter result: 数据体
    final public override func loadFinish(result: Result<Any, MNNetworkError>) {
        // 判断是否需要读取缓存
        let httpResult = MNRequestResult(result: result)
        httpResult.request = self
        if result.isSuccess == false, method == .get, cachePolicy == .returnCacheElseLoad, let cache = MNRequestDatabase.default.cache(forKey: cacheForKey, ttl: cacheTTL) {
            dataSource = .cache
            httpResult.data = cache
        }
        // 定制自己的结果
        if httpResult.isSuccess {
            didFinish(result: httpResult)
            // 依据结果回调
            if let data = httpResult.data {
                // 判断是否缓存结果
                if method == .get, dataSource == .network, cachePolicy != .never, MNRequestDatabase.default.setCache(data, forKey: cacheForKey) {
#if DEBUG
                    print("已缓存数据")
#endif
                }
                // 回调成功函数
                didSuccess(responseData: data)
            }
        } else {
            didFail(httpResult)
        }
        // 回调结果
        (queue ?? .main).async {
            // 回调结果
            self.completionHandler?(httpResult)
        }
    }
}
