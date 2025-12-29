//
//  MNPurchaseManager.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/7.
//  内购支持

import UIKit
import StoreKit
import Foundation

@objc public protocol MNPurchaseDelegate: NSObjectProtocol {
    
    /// 校验内购凭据
    /// - Parameters:
    ///   - receipt: 内购凭据
    ///   - resultHandler: 回调结果
    func purchaseManagerShouldCheckoutReceipt(_ receipt: MNPurchaseReceipt, resultHandler: @escaping (MNPurchaseResult.Code)->Void) -> Void
    
    /// 内购结束告知
    /// - Parameter result: 内购结果
    @objc optional func purchaseManagerDidFinishPurchasing(_ result: MNPurchaseResult) -> Void
}

/// 内购结果key
public let MNPurchaseResultNotificationKey: String = "com.mn.purchase.result"

/// 内购结束通知
public let MNPurchaseDidFinishNotification: NSNotification.Name = NSNotification.Name(rawValue: "com.mn.purchase.finish")

/// 内购管理者
public class MNPurchaseManager: NSObject {
    
    /// 记录任务情况
    private struct Task {
        /// 当前操作索引
        var index: Int = 0
        /// 需要操作的总数
        var count: Int = 0
        /// 操作结果码
        var code: MNPurchaseResult.Code = .failed
        
        /// 无任务
        nonisolated(unsafe) static let none = Task()
    }
    
    /// 唯一实例化入口
    nonisolated(unsafe) public static let `default`: MNPurchaseManager = MNPurchaseManager()
    /// 凭据校验最大次数 超过次数的收据会从本地删除 0则不限制
    public var maxCheckoutCount: Int = 3
    /// 利于苹果后台对收据的验证
    public var applicationUsername: String?
    /// 事件代理
    public weak var delegate: MNPurchaseDelegate?
    /// 记录是否已监听内购队列变化
    private var isObserver: Bool = false
    /// 内购队列
    private let paymentQueue: SKPaymentQueue = SKPaymentQueue.default()
    /// 此时内购请求
    private var request: MNPurchaseRequest!
    /// 操作
    private var task: Task = .none
    /// 内购凭据存储
    private let database: MNReceiptBase = MNReceiptBase()
    /// 处理队列
    private let queue: DispatchQueue = DispatchQueue(label: "com.mn.purchase.queue")
    
    /// 开启内购监听
    public func becomeTransactionObserver() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        guard isObserver == false else { return }
        isObserver = true
        paymentQueue.add(self)
    }
    
    private func start(_ request: MNPurchaseRequest, status statusHandler: MNPurchaseStatusHandler?, completion completionHandler: @escaping MNPurchaseCompletionHandler) {
        // 模拟器不支持应用内购买
#if arch(i386) || arch(x86_64) || targetEnvironment(simulator)
        DispatchQueue.main.async {
            completionHandler(MNPurchaseResult(code: .notAllowed, action: request.action, receipt: request.receipt))
        }
        return
#endif
        // 检查是否支持内购
        guard SKPaymentQueue.canMakePayments() else {
            DispatchQueue.main.async {
                completionHandler(MNPurchaseResult(code: .notAllowed, action: request.action, receipt: request.receipt))
            }
            return
        }
        // 检查是否在请求
        if let _ = self.request {
            DispatchQueue.main.async {
                completionHandler(MNPurchaseResult(code: .busying, action: request.action, receipt: request.receipt))
            }
            return
        }
        // 开启内购监听
        becomeTransactionObserver()
        // 是否指定了票据
        if let receipt = request.receipt {
            request.statusHandler = statusHandler
            request.completionHandler = completionHandler
            request.update(status: .checking)
            self.request = request
            task = .none
            task.count = 1
            queue.async { [weak self] in
                guard let self = self else { return }
                self.checkout(receipt)
            }
            return
        }
        // 是否有本地内购凭据未校验
        if let receipts = database.receipts {
            self.request = request.action == .checkout ? request : MNPurchaseRequest(action: .checkout)
            self.request.statusHandler = statusHandler
            self.request.completionHandler = completionHandler
            self.request.update(status: .checking)
            task = .none
            task.count = receipts.count
            for receipt in receipts {
                queue.async { [weak self] in
                    guard let self = self else { return }
                    receipt.isLocal = true
                    self.checkout(receipt)
                }
            }
            return
        }
        // 判断是否是校验本地订单请求
        if request.action == .checkout {
            DispatchQueue.main.async {
                completionHandler(MNPurchaseResult(code: .none, action: .checkout))
            }
            return
        }
        // 保存请求
        task = .none
        self.request = request
        request.statusHandler = statusHandler
        request.completionHandler = completionHandler
        request.update(status: .loading)
        // 开启请求
        if request.action == .restore {
            paymentQueue.restoreCompletedTransactions(withApplicationUsername: applicationUsername)
        } else {
            startRequestProducts()
        }
    }
    
    /// 结束内购(只有请求存在才会到这里处理)
    /// - Parameters:
    ///   - receipt: 内购凭据
    ///   - responseCode: 响应码
    private func finish(_ receipt: MNPurchaseReceipt!, code responseCode: MNPurchaseResult.Code) {
        guard let request = request else { return }
        var code = responseCode
        switch request.action {
        case .restore, .checkout:
            // 恢复购买或校验订单请求
            if (task.index + 1) < task.count {
                // 还没处理完
                task.index += 1
                if responseCode == .succeed {
                    task.code = .succeed
                }
                return
            }
            if task.code == .succeed {
                code = .succeed
            }
        default: break
        }
        let result = MNPurchaseResult(code: code, action: request.action)
        if let receipt = receipt, request.identifier == receipt.identifier {
            result.receipt = receipt
        }
        self.request = nil
        task = .none
        request.finish(result: result)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 代理回调结果
            self.delegate?.purchaseManagerDidFinishPurchasing?(result)
            // 通知回调结果
            NotificationCenter.default.post(name: MNPurchaseDidFinishNotification, object: self, userInfo: [MNPurchaseResultNotificationKey:result])
        }
    }
}

// MARK: - Restore
extension MNPurchaseManager {
    
    /// 开启恢复购买
    /// - Parameters:
    ///   - statusHandler: 状态回调
    ///   - completionHandler: 结束回调
    public func startRestore(status statusHandler: MNPurchaseStatusHandler?, completion completionHandler: @escaping MNPurchaseCompletionHandler) {
        start(MNPurchaseRequest(action: .restore), status: statusHandler, completion: completionHandler)
    }
}

// MARK: - Checkout
extension MNPurchaseManager {
    
    /// 外界开始校验凭据
    /// - Parameters:
    ///   - receipt: 凭据模型
    ///   - statusHandler: 状态回调
    ///   - completionHandler: 结束回调
    public func startCheckout(_ receipt: MNPurchaseReceipt, status statusHandler: MNPurchaseStatusHandler?, completion completionHandler: @escaping MNPurchaseCompletionHandler) {
        start(MNPurchaseRequest(receipt: receipt), status: statusHandler, completion: completionHandler)
    }
    
    /// 开始校验本地凭据
    /// - Parameters:
    ///   - statusHandler: 状态回调
    ///   - completionHandler: 结束回调
    public func startCheckout(status statusHandler: MNPurchaseStatusHandler?, completion completionHandler: @escaping MNPurchaseCompletionHandler) {
        start(MNPurchaseRequest(action: .checkout), status: statusHandler, completion: completionHandler)
    }
    
    /// 校验结束
    /// - Parameters:
    ///   - receipt: 内购凭据
    ///   - code: 响应码
    private func finishCheckout(_ receipt: MNPurchaseReceipt, code: MNPurchaseResult.Code) {
        switch code {
        case .succeed, .receiptInvalid:
            // 删除本地订单并关闭交易事务
            if receipt.isRestore == false {
                database.delete(receipt.identifier)
                finishTransaction(identifier: receipt.transactionIdentifier)
            }
        case .notConnectedToInternet:
            // 不具备校验条件
#if DEBUG
            print("⚠️⚠️⚠️⚠️⚠️当前不具备校验收据条件⚠️⚠️⚠️⚠️⚠️")
#endif
        default:
            // 查看失败次数
            if let request = request, receipt.isRestore == false, (receipt.isLocal || receipt.identifier == request.identifier) {
                receipt.failCount += 1
                if maxCheckoutCount > 0, receipt.failCount >= maxCheckoutCount {
                    // 已达到最大校验次数 删除并关闭交易事务
                    database.delete(receipt.identifier)
                    finishTransaction(identifier: receipt.transactionIdentifier)
                } else {
                    // 更新本地凭据
                    database.update(receipt)
                }
            }
        }
#if DEBUG
        if code != .succeed, code != .notConnectedToInternet {
            print("⚠️⚠️⚠️⚠️⚠️ 校验内购票据失败 ⚠️⚠️⚠️⚠️⚠️")
        }
#endif
        if let request = request, (receipt.identifier == request.identifier || (request.action == .restore && receipt.isRestore) || (request.action == .checkout && receipt.isLocal)) {
            // 当前请求的票据需要回调结果
            finish(receipt, code: code)
        }
    }
    
    /// 校验本地订单
    /// - Parameter receipt: 订单凭据
    private func checkout(_ receipt: MNPurchaseReceipt) {
        // 回调校验订单
        if let delegate = delegate {
            let resultHandler: (MNPurchaseResult.Code)->Void = { [weak self] code in
                guard let self = self else { return }
                self.queue.async { [weak self] in
                    guard let self = self else { return }
                    self.finishCheckout(receipt, code: code)
                }
            }
            delegate.purchaseManagerShouldCheckoutReceipt(receipt, resultHandler: resultHandler)
        } else {
#if DEBUG
            print("⚠️⚠️⚠️⚠️⚠️ please responds selector \"purchaseManagerCheckoutReceipt(_:resultHandler:)\" ⚠️⚠️⚠️⚠️⚠️")
#endif
            finishCheckout(receipt, code: .notConnectedToInternet)
        }
    }
}

// MARK: - Purchasing
extension MNPurchaseManager {
    
    /// 开启内购
    /// - Parameters:
    ///   - productId: 产品标识
    ///   - userInfo: 用户信息
    ///   - statusHandler: 状态回调
    ///   - completionHandler: 结束回调
    public func startPurchasing(_ productId: String, userInfo: String? = nil, status statusHandler: MNPurchaseStatusHandler?, completion completionHandler: @escaping MNPurchaseCompletionHandler) {
        let request = MNPurchaseRequest(product: productId, userInfo: userInfo)
        start(request, status: statusHandler, completion: completionHandler)
    }
    
    /// 恢复购买操作
    /// - Parameters:
    ///   - statusHandler: 状态回调
    ///   - completionHandler: 结束回调
    public func resumePurchasing(status statusHandler: MNPurchaseStatusHandler?, completion completionHandler: @escaping MNPurchaseCompletionHandler) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let request = self.request else { return }
            switch request.status {
            case .loading, .purchasing, .checking:
                request.statusHandler = statusHandler
                request.completionHandler = completionHandler
                request.statusHandler?(request.status, request.statusDescription)
            default: break
            }
        }
    }
    
    /// 开始商品请求
    private func startRequestProducts() {
        let productsRequest = SKProductsRequest(productIdentifiers: [request.product])
        productsRequest.delegate = self
        productsRequest.mn_identifier = request.identifier
        productsRequest.start()
    }
}

// MARK: - Transaction
private extension MNPurchaseManager {
    
    /// 内购或恢复内购项目完成
    /// - Parameter transaction: 内购事务
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        let transactionIdentifier = transaction.transactionIdentifier
        let productIdentifier = transaction.payment.productIdentifier
        let transactionDate = transaction.transactionDate?.timeIntervalSince1970 ?? 0.0
        let originalTransaction = transaction.original
        let originalTransactionIdentifier = originalTransaction?.transactionIdentifier
        let originalTransactionDate = originalTransaction?.transactionDate?.timeIntervalSince1970 ?? 0.0
        let transactionState = transaction.transactionState
        if transactionState == .restored {
            // 恢复购买就结束交易事务
            paymentQueue.finishTransaction(transaction)
        }
        // 创建内购凭据
        guard let receiptURL = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptURL) else {
            if let request = request, ((request.action == .restore && transactionState == .restored) || (request.action == .purchase && request.product == productIdentifier)) {
                // 当前请求的收据需要回调
#if DEBUG
            print("⚠️⚠️⚠️⚠️⚠️ 当前请求收据创建失败 ⚠️⚠️⚠️⚠️⚠️")
#endif
                finish(nil, code: .receiptInvalid)
            } else {
#if DEBUG
            print("⚠️⚠️⚠️⚠️⚠️ 自主请求收据创建失败 ⚠️⚠️⚠️⚠️⚠️")
#endif
            }
            return
        }
        // 关联内购凭据
        let receipt = MNPurchaseReceipt(receiptData: receiptData)
        receipt.product = productIdentifier
        receipt.transactionIdentifier = transactionIdentifier
        receipt.originalTransactionIdentifier = originalTransactionIdentifier
        receipt.transactionDate = transactionDate
        receipt.originalTransactionDate = originalTransactionDate
        receipt.isRestore = transactionState == .restored
        if let request = request {
            switch request.action {
            case .purchase:
                if (request.product == productIdentifier) {
                    // 当前订阅请求
                    receipt.price = request.price
                    receipt.identifier = request.identifier
                    receipt.userInfo = request.userInfo
                    request.update(status: .checking)
                    database.insert(receipt)
                }
            case .restore:
                if transactionState == .restored {
                    request.update(status: .checking)
                }
            default: break
            }
        }
        // 校验收据
        checkout(receipt)
    }
    
    /// 结束购买事务
    /// - Parameter transaction: 内购事务
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        let error = transaction.error
        let productIdentifier = transaction.payment.productIdentifier
        paymentQueue.finishTransaction(transaction)
        if let request = request, request.action == .purchase, request.product == productIdentifier {
            if let error = error {
                let code = MNPurchaseResult.Code(error: error) ?? .failed
                finish(nil, code: code)
            } else {
                finish(nil, code: .failed)
            }
        }
    }
    
    /// 关闭交易事务
    /// - Parameter identifier: 事务标识
    func finishTransaction(identifier: String?) {
        guard let identifier = identifier else { return }
        let transactions = paymentQueue.transactions.filter { ($0.transactionIdentifier ?? "") == identifier }
        for transaction in transactions {
            paymentQueue.finishTransaction(transaction)
        }
    }
    
    /// 结束未关闭的事务
    func finishUncompleteTransactions() {
        let transactions = paymentQueue.transactions.filter { $0.transactionState == .purchased || $0.transactionState == .restored }
        for transaction in transactions {
            paymentQueue.finishTransaction(transaction)
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension MNPurchaseManager: SKProductsRequestDelegate {
    
    public func productsRequest(_ res: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        guard let product = products.first else {
            finish(nil, code: .none)
            return
        }
        request.price = product.price.doubleValue
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        payment.applicationUsername = applicationUsername
        task = .none
        paymentQueue.add(payment)
    }
    
    public func request(_ res: SKRequest, didFailWithError error: Error) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.finish(nil, code: MNPurchaseResult.Code(error: error) ?? .failed)
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension MNPurchaseManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                // 购买中
                if let request = request, request.action == .purchase, request.product == transaction.payment.productIdentifier {
                    request.update(status: .purchasing)
                }
            case .restored, .purchased:
                self.queue.async { [weak self] in
                    guard let self = self else { return }
                    self.completeTransaction(transaction)
                }
            case .failed:
                self.queue.async { [weak self] in
                    guard let self = self else { return }
                    self.failedTransaction(transaction)
                }
            default: break
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let transactions = queue.transactions.filter { $0.transactionState == .restored }
        task = .none
        task.count = transactions.count
        if transactions.isEmpty {
            self.queue.async { [weak self] in
                guard let self = self else { return }
                self.finish(nil, code: .none)
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        task = .none
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.finish(nil, code: MNPurchaseResult.Code(error: error) ?? .failed)
        }
    }
}
