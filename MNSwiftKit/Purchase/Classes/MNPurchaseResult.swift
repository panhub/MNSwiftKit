//
//  MNPurchaseResult.swift
//  MNKit
//
//  Created by 冯盼 on 2022/11/7.
//  支付结果

import StoreKit
import Foundation

/// 内购结果
public class MNPurchaseResult: NSObject {
    
    /// 内购状态码
    @objc public enum Code: Int {
        case succeed = 1
        case failed = 0
        case unknown = -1
        case none = -2
        case busying = -3
        case notAllowed = -4
        case notAvailable = -5
        case receiptInvalid = -6
        case priceInvalid = -7
        case paymentInvalid = -8
        case timedOut = -9
        case cloudDenied = -10
        case cancelled = -999
        case notConnectedToInternet = -1009
    }
    
    /// 状态码
    public let code: Code
    /// 内购请求
    public let action: MNPurchaseRequest.Action
    /// 内购凭据集合
    public var receipt: MNPurchaseReceipt?
    /// 内购结果描述
    public var msg: String {
        var msg: String = "无法连接iTunesStore"
        switch code {
        case .succeed:
            switch action {
            case .purchase:
                msg = "支付成功"
            case .restore:
                msg = "恢复购买成功"
            case .checkout:
                msg = "订单校验成功"
            }
        case .failed:
            switch action {
            case .purchase:
                msg = "支付失败"
            case .restore:
                msg = "恢复购买失败"
            case .checkout:
                msg = "订单校验失败"
            }
        case .unknown:
            msg = "发生未知错误"
        case .none:
            switch action {
            case .purchase:
                msg = "未发现可购买项目"
            case .restore:
                msg = "未发现可恢复项目"
            case .checkout:
                msg = "未发现本地订单"
            }
        case .busying:
            msg = "请勿重复购买"
        case .notAllowed:
            msg = "不支持应用内购买"
        case .notAvailable:
            msg = "产品在商店中不可用"
        case .receiptInvalid:
            msg = "内购凭据无效"
        case .priceInvalid:
            msg = "产品价格不可用"
        case .paymentInvalid:
            msg = "无法识别产品参数"
        case .timedOut:
            msg = "连接iTunesStore超时"
        case .cloudDenied:
            msg = "不允许访问云服务信息"
        case .cancelled:
            switch action {
            case .purchase:
                msg = "已取消支付"
            case .restore:
                msg = "已取消恢复购买"
            case .checkout:
                msg = "已取消校验订单"
            }
        case .notConnectedToInternet:
            msg = "无连接网络"
        }
        return msg
    }
    
    /// 构造内购结果
    /// - Parameters:
    ///   - code: 结果码
    ///   - action: 请求类型
    ///   - receipt: 内购凭据
    public init(code: Code, action: MNPurchaseRequest.Action, receipt: MNPurchaseReceipt? = nil) {
        self.code = code
        self.action = action
        self.receipt = receipt
    }
}

extension MNPurchaseResult.Code {
    
    /// 构造内购错误码
    /// - Parameter error: 错误
    public init?(error: Error) {
        let code = error._code
        var rawValue: Int = LONG_MAX
        switch code {
        case SKError.unknown.rawValue:
            rawValue = MNPurchaseResult.Code.unknown.rawValue
        case SKError.paymentCancelled.rawValue:
            rawValue = MNPurchaseResult.Code.cancelled.rawValue
        case SKError.paymentNotAllowed.rawValue:
            rawValue = MNPurchaseResult.Code.notAllowed.rawValue
        case SKError.storeProductNotAvailable.rawValue:
            rawValue = MNPurchaseResult.Code.notAvailable.rawValue
        case SKError.paymentInvalid.rawValue:
            rawValue = MNPurchaseResult.Code.paymentInvalid.rawValue
        case NSURLErrorCancelled:
            rawValue = MNPurchaseResult.Code.cancelled.rawValue
        case NSURLErrorTimedOut:
            rawValue = MNPurchaseResult.Code.timedOut.rawValue
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost, NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost:
            rawValue = MNPurchaseResult.Code.notConnectedToInternet.rawValue
        default:
            if #available(iOS 9.3, *) {
                if code == SKError.cloudServicePermissionDenied.rawValue {
                    rawValue = MNPurchaseResult.Code.cloudDenied.rawValue
                    break
                }
                if code == SKError.cloudServiceNetworkConnectionFailed.rawValue {
                    rawValue = MNPurchaseResult.Code.notConnectedToInternet.rawValue
                    break
                }
            }
            if #available(iOS 12.2, *) {
                if code == SKError.overlayCancelled.rawValue {
                    rawValue = MNPurchaseResult.Code.cancelled.rawValue
                    break
                }
                if code == SKError.invalidOfferPrice.rawValue {
                    rawValue = MNPurchaseResult.Code.priceInvalid.rawValue
                    break
                }
            }
            if #available(iOS 14.0, *) {
                if code == SKError.overlayTimeout.rawValue {
                    rawValue = MNPurchaseResult.Code.timedOut.rawValue
                    break
                }
            }
#if DEBUG
            print("内购错误:\n\(error)")
#endif
        }
        self.init(rawValue: rawValue)
    }
}
