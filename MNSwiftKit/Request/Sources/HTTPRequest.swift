//
//  HTTPRequest.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/1.
//  网络请求基类, 不可直接实例化使用

import Foundation
//#if canImport(MNSwiftKitNetworking)
//import MNSwiftKitNetworking
//#endif

/// 请求开始回调
public typealias HTTPRequestStartHandler = ()->Void
/// 请求结束回调
public typealias HTTPRequestCompletionHandler = (_ result: HTTPResult)->Void
/// 请求进度回调
public typealias HTTPRequestProgressHandler = HTTPSessionProgressHandler

/// HTTP请求基类
@objc open class HTTPRequest: NSObject {
    /// 请求地址
    @objc public var url: String = ""
    /// 请求参数 支持String, [String:String]
    @objc public var param: Any?
    /// 回调队列
    @objc public weak var queue: DispatchQueue?
    /// 请求超时时间
    @objc public var timeoutInterval: TimeInterval = 10.0
    /// 字符串编码格式
    public var stringWritingEncoding: String.Encoding = .utf8
    /// 是否允许使用蜂窝网络
    @objc public var allowsCellularAccess: Bool = true
    /// 忽略的错误码集合
    @objc public var ignoringErrorCodes: [Int] = [HTTPErrorCancelled]
    /// Header信息
    @objc public var headerFields: [String: String]?
    /// 服务端认证信息
    @objc public var authHeaderField: [String: String]?
    /// 参数编码选项
    public var serializationOptions: HTTPParam.EncodeOptions = .all
    /// 字符串编码格式
    public var stringReadingEncoding: String.Encoding = .utf8
    /// 接受的响应码
    @objc public var acceptableStatusCodes: IndexSet = IndexSet(integersIn: 200..<300)
    /// 接受的响应数据类型
    @objc public var acceptableContentTypes: Set<String>?
    /// JSON格式编码选项
    @objc public var jsonReadingOptions: JSONSerialization.ReadingOptions = []
    /// 数据解析方式
    @objc public var analyticMode: HTTPParser.AnalyticMode = .json
    /// 数据解析回调
    @objc public var analyticHandler: HTTPParser.AnalyticHandler?
    
    /// 请求产生的Task
    @objc public var task: URLSessionTask?
    /// 是否是第一次请求
    @objc public var isFirstLoading: Bool = true
    /// 是否在请求
    @objc public var isLoading: Bool {
        guard let task = task else { return false }
        return task.state == .running
    }
    
    /// 开始回调
    public var startHandler: HTTPRequestStartHandler?
    /// 结束回调
    public var completionHandler: HTTPRequestCompletionHandler?
    /// 进度回调
    public var progressHandler: HTTPRequestProgressHandler?
    
    @objc public override init() {
        super.init()
    }
    
    /// 依据链接初始化
    /// - Parameter url: 链接
    @objc public init(url: String) {
        super.init()
        self.url = url
    }
    
    deinit {
        task = nil
        startHandler = nil
        progressHandler = nil
        completionHandler = nil
    }
    
    /// 触发请求操作
    @objc open func resume() {
        HTTPManager.default.resume(request: self)
    }
    
    /// 取消请求
    @objc open func cancel() {
        HTTPManager.default.cancel(request: self)
    }
    
    /// 请求结束处理
    /// - Parameter result: 数据结果
    open func loadFinish(result: Result<Any, HTTPError>) {
        let httpResult = HTTPResult(result: result)
        httpResult.request = self
        if httpResult.isSuccess {
            didFinish(result: httpResult)
            if httpResult.isSuccess {
                didSuccess(responseObject: httpResult.object)
            }
        } else {
            didFail(httpResult)
        }
        // 回调结果 这里要强引用self 避免过早释放
        (queue ?? DispatchQueue.main).async {
            // 回调结果代码块
            self.completionHandler?(httpResult)
        }
    }
    
    /// 处理响应结果
    /// - Parameter result: 响应结果
    @objc open func didFinish(result: HTTPResult) {}
    
    /// 请求成功
    /// - Parameter responseObject: 请求数据
    @objc open func didSuccess(responseObject: Any) {}
    
    /// 请求失败
    /// - Parameter result: 请求结果
    @objc open func didFail(_ result: HTTPResult) {}
}
