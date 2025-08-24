//
//  MNWebResponder.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/6.
//  提供默认的事件响应

import UIKit

/// 退出
public let MNWebViewExitScriptMessageName: String = "exit"
/// 返回
public let MNWebViewBackScriptMessageName: String = "back"
/// 刷新
public let MNWebViewReloadScriptMessageName: String = "reload"

open class MNWebResponder: NSObject {
    // 加载它的网页控制器
    public weak var webViewController: MNWebViewController!
}

extension MNWebResponder: MNWebScriptBridge {
    
    public var cmds: [String] {
        [MNWebViewExitScriptMessageName, MNWebViewBackScriptMessageName, MNWebViewReloadScriptMessageName]
    }

    public func call(cmd: String, body: Any) {
        guard let webViewController = webViewController else { return }
        switch cmd {
        case MNWebViewExitScriptMessageName:
            // 退出
            webViewController.close()
        case MNWebViewBackScriptMessageName:
            // 返回
            webViewController.back()
        case MNWebViewReloadScriptMessageName:
            // 重载
            webViewController.reload()
        default: break
        }
    }
}
