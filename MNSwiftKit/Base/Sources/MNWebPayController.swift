//
//  MNWebPayController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/10.
//  网页支付解决方案

import UIKit
import WebKit
import Foundation

public struct MNWebPayment {
    // 自己的识符 补充支付宝支付链接
    public var scheme: String = ""
    // 微信标识符
    public var wxScheme: String = ""
    // 支付宝标识符
    public var aliScheme: String = ""
    // 支付宝标识参数
    public var aliSchemeKey = ""
    // 微信H5标识符
    public var wxH5Identifier: String = ""
    // 微信标识参数
    public var wxRedirect: String = ""
    // 微信回调标识
    public var wxAuthDomain: String = ""
    // 支付宝回调标识
    public var aliUrlKey: String = ""
    
    private init() {}
    
    public static let shared: MNWebPayment = MNWebPayment()
    
    /**
     "wxAuthDomain" : "app.kadianba.com:\/\/",
     "alSchemesKey" : "fromAppUrlScheme",
     "wxH5Identifier" : "https:\/\/wx.tenpay.com\/cgi-bin\/mmpayweb-bin\/checkmweb?",
     "alUrlKey" : "safepay",
     "wxRedirect" : "&redirect_url=",
     "wxSchemes" : "weixin:\/\/wap\/pay",
     "alSchemes" : "alipay:\/\/"
     */
}

/// 支付结束代理
public protocol MNWebPayEventHandler: NSObjectProtocol {
    /// 支付结束告知
    /// - Parameter controller: 网页支付控制器
    func webPayDidFinish(_ controller: MNWebPayController)
}

private func MNWebPayBase64Decoding(_ string: String) -> String {
    guard let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) else { return "" }
    return String(data: data, encoding: .utf8) ?? ""
}

private extension Notification.Name {
    /// 支付结束通知
    static let finishPayNotificationName = Notification.Name(rawValue: "com.mn.web.pay.finish")
}

public class MNWebPayController: MNWebViewController {
    
    /// 默认允许跳转
    private var allowsOpenURL: Bool = true
    /// 用户传值
    public var userInfo: Any?
    /// 结束回调
    public var completionHandler: ((MNWebPayController) -> Void)?
    /// 回调代理
    public weak var eventHandler: MNWebPayEventHandler?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func initialized() {
        super.initialized()
        allowsUpdateTitle = false
        reloadWhenAppear = false
        title = MNWebPayBase64Decoding("6K+35rGC5pSv5LuY5Lit")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        webView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(finishPayment), name: .finishPayNotificationName, object: nil)
    }
    
    // MAKR: - 跳转操作
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        if navigationAction.navigationType == .linkActivated, let contains = request.url?.host?.contains(MNWebPayBase64Decoding("5oiR55qE6Leo5Z+f5qCH6K+G56ym")), contains {
            decisionHandler(.cancel)
            // 对于跨域, 需要手动跳转
            UIApplication.shared.mn.open(request.url) { [weak self] isSuccess in
                guard let self = self else { return }
                guard isSuccess == false else { return }
                // 打开失败
                self.cancel(message: "打开应用失败")
            }
        } else if var url = request.url?.absoluteString {
            if url.contains(MNWebPayment.shared.wxScheme) {
                allowsOpenURL = false
                decisionHandler(.cancel)
                UIApplication.shared.mn.open(request.url) { [weak self] isSuccess in
                    guard let self = self else { return }
                    guard isSuccess == false else { return }
                    self.cancel(message: MNWebPayBase64Decoding("6Lez6L2s5b6u5L+h5aSx6LSl"))
                }
            } else if allowsOpenURL, url.contains(MNWebPayment.shared.wxH5Identifier) {
                allowsOpenURL = false
                let range = (url as NSString).range(of: MNWebPayment.shared.wxRedirect)
                if range.location != NSNotFound {
                    url = (url as NSString).substring(to: range.location) as String
                }
                var mutableRequest = request
                mutableRequest.url = URL(string: url)
                mutableRequest.allHTTPHeaderFields = request.allHTTPHeaderFields
                mutableRequest.setValue(MNWebPayment.shared.wxAuthDomain, forHTTPHeaderField: MNWebPayBase64Decoding("UmVmZXJlcg=="))
                webView.load(mutableRequest)
                decisionHandler(.cancel)
            } else if url.contains(MNWebPayment.shared.aliScheme) {
                // 先解码
                url = url.removingPercentEncoding ?? url
                // 取出域名后面的参数
                let components = url.components(separatedBy: "?")
                // 存入参数
                guard let jsonData = components.last!.data(using: .utf8) else {
                    decisionHandler(.cancel)
                    cancel(message: "操作失败")
                    return
                }
                guard var json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? [String:Any]  else {
                    decisionHandler(.cancel)
                    cancel(message: "操作失败")
                    return
                }
                json[MNWebPayment.shared.aliSchemeKey] = MNWebPayment.shared.scheme
                guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
                    decisionHandler(.cancel)
                    cancel(message: "操作失败")
                    return
                }
                url = components.first! + "?" + String(data: data, encoding: .utf8)!
                url = url.replacingOccurrences(of: "true", with: "1")
                url = url.replacingOccurrences(of: "false", with: "0")
                url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? url
                decisionHandler(.cancel)
                UIApplication.shared.mn.open(request.url) { [weak self] isSuccess in
                    guard let self = self else { return }
                    guard isSuccess == false else { return }
                    self.cancel(message: MNWebPayBase64Decoding("6Lez6L2s5pSv5LuY5a6d5aSx6LSl"))
                }
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    /// 取消支付
    /// - Parameter message: 提示信息
    private func cancel(message: String) {
        MNToast.showInfo(message) { [weak self] _ in
            guard let self = self else { return }
            self.mn.pop()
        }
    }
    
    /// 处理回调
    /// - Parameter url: 回调链接
    /// - Returns: 外界是否继续处理
    static func handOpen(url: URL) -> Bool {
        let url = url.absoluteString
        if url.contains(MNWebPayment.shared.wxAuthDomain) || url.contains(MNWebPayment.shared.aliUrlKey) {
            NotificationCenter.default.post(name: .finishPayNotificationName, object: url)
            return false
        }
        return true
    }
    
    /// 接收到支付结束通知
    @objc private func finishPayment() {
        if let completionHandler = completionHandler {
            completionHandler(self)
        }
        if let eventHandler = eventHandler {
            eventHandler.webPayDidFinish(self)
        }
    }
}

// MARK: - 导航控制
extension MNWebPayController {
    public override var navigationBarLeftButtonItem: UIView? { nil }
    public override var navigationBarRightButtonItem: UIView? { nil }
    public override func navigationBarShouldRenderBackItem() -> Bool { true }
}
