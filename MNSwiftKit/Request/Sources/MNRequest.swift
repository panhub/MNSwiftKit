//
//  MNRequest.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/1.
//  网络请求基类, 不可直接实例化使用

import Foundation

/// HTTP请求基类
open class MNRequest: NSObject {
    
    /// 请求开始回调
    public typealias StartHandler = ()->Void
    /// 请求结束回调
    public typealias CompletionHandler = (MNRequestResult)->Void
    
    /// 请求地址
    public var url: String = ""
    /// 请求参数 支持String, [String:String]
    public var param: Any?
    /// 回调队列
    public weak var queue: DispatchQueue?
    /// 请求超时时间
    public var timeoutInterval: TimeInterval = 10.0
    /// 字符串编码格式
    public var stringWritingEncoding: String.Encoding = .utf8
    /// 是否允许使用蜂窝网络
    public var allowsCellularAccess: Bool = true
    /// 忽略的错误码集合
    public var ignoringErrorCodes: [Int] = [MNNetworkErrorCancelled]
    /// Header信息
    public var headerFields: [String: String]?
    /// 服务端认证信息
    public var authHeaderField: [String: String]?
    /// 参数编码选项
    public var serializationOptions: MNNetworkParam.EncodeOptions = .all
    /// 字符串编码格式
    public var stringReadingEncoding: String.Encoding = .utf8
    /// 接受的响应码
    public var acceptableStatusCodes: IndexSet = IndexSet(integersIn: 200..<300)
    /// JSON格式编码选项
    public var jsonReadingOptions: JSONSerialization.ReadingOptions = []
    /// 数据类型
    public var serializationType: MNNetworkSerializationType = .json
    /// 数据解析回调
    public var analyticHandler: MNNetworkParser.AnalyticHandler?
    
    /// 请求产生的Task
    public var task: URLSessionTask?
    /// 是否是第一次请求
    public var isFirstRunning: Bool = true
    /// 是否在请求
    public var isRunning: Bool {
        guard let task = task else { return false }
        return task.state == .running
    }
    
    /// 开始回调
    public var startHandler: MNRequest.StartHandler?
    /// 进度回调
    public var progressHandler: MNNetworkSession.ProgressHandler?
    /// 结束回调
    public var completionHandler: MNRequest.CompletionHandler?
    
    public override init() {
        super.init()
    }
    
    /// 构造请求体
    /// - Parameter url: 链接字符串
    public init(url: String) {
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
    open func resume() {
        MNRequestManager.default.resume(self)
    }
    
    /// 取消请求
    open func cancel() {
        MNRequestManager.default.cancel(self)
    }
    
    /// 请求结束处理
    /// - Parameter result: 数据结果
    open func loadFinish(result: Result<Any, MNNetworkError>) {
        let httpResult = MNRequestResult(result: result)
        httpResult.request = self
        if let data = httpResult.data {
            didFinish(result: httpResult)
            didSuccess(responseData: data)
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
    open func didFinish(result: MNRequestResult) {}
    
    /// 请求成功
    /// - Parameter responseObject: 请求数据
    open func didSuccess(responseData: Any) {}
    
    /// 请求失败
    /// - Parameter result: 请求结果
    open func didFail(_ result: MNRequestResult) {}
}
