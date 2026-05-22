//
//  MNWebResponder.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/6.
//  提供默认的事件响应

import UIKit

/// 退出
public let MNWebViewExitScriptMessageName: String = "exit"
/// 关闭
public let MNWebViewCloseScriptMessageName: String = "close"
/// 返回
public let MNWebViewBackScriptMessageName: String = "back"
/// 刷新
public let MNWebViewReloadScriptMessageName: String = "reload"

open class MNWebResponder: NSObject {
    // 加载它的控制器
    public weak var viewController: UIViewController!
}

extension MNWebResponder: MNWebScriptBridge {
    
    public var cmds: [String] {
        [MNWebViewExitScriptMessageName, MNWebViewBackScriptMessageName, MNWebViewReloadScriptMessageName]
    }

    public func call(cmd: String, body: Any) {
        guard let viewController = viewController else { return }
        switch cmd {
        case MNWebViewExitScriptMessageName, MNWebViewCloseScriptMessageName:
            // 退出/关闭直接出栈
            let close = NSSelectorFromString("close")
            guard viewController.responds(to: close) else { break }
            viewController.perform(close)
        case MNWebViewBackScriptMessageName:
            // 返回
            let back = NSSelectorFromString("back")
            guard viewController.responds(to: back) else { break }
            viewController.perform(back)
        case MNWebViewReloadScriptMessageName:
            // 重载
            let reload = NSSelectorFromString("reload")
            guard viewController.responds(to: reload) else { break }
            viewController.perform(reload)
        default: break
        }
    }
}
