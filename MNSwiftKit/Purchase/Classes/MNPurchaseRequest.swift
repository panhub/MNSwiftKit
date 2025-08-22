//
//  MNPurchaseRequest.swift
//  MNKit
//
//  Created by 冯盼 on 2022/11/7.
//  内购请求

import UIKit
import StoreKit

/// 内购结果回调
public typealias MNPurchaseCompletionHandler = (_ result: MNPurchaseResult)->Void

/// 内购状态回调
public typealias MNPurchaseStatusHandler = (_ status: MNPurchaseRequest.Status, _ description: String)->Void

/// 内购请求
public class MNPurchaseRequest: NSObject {
    
    /// 状态
    public enum Status {
        case idle, loading, purchasing, checking, completed
    }
    
    /// 类型
    public enum Action {
        case purchase, restore, checkout
    }
    
    /// 标识(当前时间戳 ms)
    public private(set) var identifier: String = ""
    /// 产品标识符
    public private(set) var product: String = ""
    /// 价格
    public var price: Double = 0.0
    /// 当前状态
    public var status: Status = .idle
    /// 对于指定凭据检查请求
    public private(set) var receipt: MNPurchaseReceipt?
    /// 请求类型
    public private(set) var action: Action = .purchase
    /// 记录外界附加信息
    public var userInfo: String?
    /// 状态回调
    public var statusHandler: MNPurchaseStatusHandler?
    /// 结束回调
    public var completionHandler: MNPurchaseCompletionHandler?
    /// 状态描述字符串
    public var statusDescription: String {
        switch status {
        case .idle: return "请稍后"
        case .loading:
            switch action {
            case .purchase: return "项目获取中"
            case .restore: return "正在查询可恢复项目"
            case .checkout: return "正在查询本地订单"
            }
        case .purchasing: return "正在支付"
        case .checking:
            switch action {
            case .purchase: return "正在校验订单"
            case .restore: return "正在恢复购买项目"
            case .checkout: return "正在校验本地订单"
            }
        case .completed: return "项目购买已结束"
        }
    }
    
    public override init() {
        super.init()
        self.identifier = NSDecimalNumber(value: Date().timeIntervalSince1970*1000.0).stringValue
    }
    
    /// 构造内购请求
    /// - Parameters:
    ///   - product: 产品标识
    ///   - userInfo: 绑定的用户信息
    public convenience init(product: String, userInfo: String? = nil) {
        self.init()
        self.userInfo = userInfo
        self.product = product
    }
    
    /// 构造指定动作请求
    /// - Parameter action: 动作目的
    public convenience init(action: Action) {
        self.init()
        self.action = action
    }
    
    /// 构造指定凭据校验请求
    /// - Parameter receipt: 凭据
    public convenience init(receipt: MNPurchaseReceipt) {
        self.init(action: .checkout)
        self.receipt = receipt
        self.identifier = receipt.identifier
    }
    
    /// 更新状态
    /// - Parameter status: 当前状态
    public func update(status: Status) {
        if status == self.status { return }
        self.status = status
        let description = statusDescription
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.statusHandler?(status, description)
        }
    }
    
    /// 结束内购
    /// - Parameter result: 内购结果
    public func finish(result: MNPurchaseResult) {
        status = .completed
        // 外界已释放, 这里要强引用
        DispatchQueue.main.async {
            self.completionHandler?(result)
        }
    }
}
