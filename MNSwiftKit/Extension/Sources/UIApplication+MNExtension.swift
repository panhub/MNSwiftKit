//
//  UIApplication+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/14.
//

import UIKit
import StoreKit
import Foundation
import CoreGraphics

extension UIApplication {
    
    /// 加载方式
    public enum OpenMode {
        /// 内部加载
        case `internal`
        /// 跳转应用
        case external
    }
    
    /// 判断是否可打开链接
    /// - Parameter string: 资源定位
    /// - Returns: 是否可打开
    @objc public class func canOpen(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return canOpen(url)
    }
    
    /// 判断是否可打开链接
    /// - Parameter url: 资源定位器
    /// - Returns: 是否可打开
    public class func canOpen(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url)
    }
    
    /// 打开链接
    /// - Parameters:
    ///   - string: 指定链接
    ///   - completion: 结果回调是否成功打开
    @objc public class func open(_ string: String, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        guard let url = URL(string: string) else {
            completion?(false)
            return
        }
        open(url, completion: completion)
    }
    
    /// 打开链接
    /// - Parameters:
    ///   - url: 指定链接
    ///   - completion: 结果回调是否成功打开
    public class func open(_ url: URL, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
        } else {
            if UIApplication.shared.canOpenURL(url) {
                let result = UIApplication.shared.openURL(url)
                completion?(result)
            } else {
                completion?(false)
            }
        }
    }
    
    /// 打开QQ
    /// - Parameters:
    ///   - number: QQ号
    ///   - completion: 结果回调是否成功打开
    @objc public class func openQQ(_ number: String, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let string = "mqq://im/chat?chat_type=wpa&uin=\(number)&version=1&src_type=web"
        open(string, completion: completion)
    }
    
    /// 打开QQ群组
    /// - Parameters:
    ///   - number: QQ群号
    ///   - key: 群标记
    ///   - completion: 结果回调是否成功打开
    @objc public class func openQQGroup(_ number: String, key: String, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let string = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=\(number)&key=\(key)&card_type=group&source=external"
        open(string, completion: completion)
    }
    
    /// 打开评分
    /// - Parameters:
    ///   - mode: 以何种方式打开
    ///   - appId: 应用id
    ///   - completion: 结果回调
    public class func openScore(mode: OpenMode = .external, appId: String? = nil, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        UIWindow.current?.endEditing(true)
        switch mode {
        case .internal:
            if #available(iOS 14.0, *), let windowScene = UIApplication.shared.delegate?.window??.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            } else if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        case .external:
            guard let appId = appId, appId.isEmpty == false else {
                completion?(false)
                break
            }
            let string = "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review"
            open(string, completion: completion)
        }
    }
}

extension UIApplication {
    
    /// 获取状态栏的方向
    /// - Returns: 状态栏的方向
    @objc public class func statusBarOrientation() -> UIInterfaceOrientation {
        var orientation: UIInterfaceOrientation = .unknown
        if #available(iOS 13.0, *) {
            if let scene = UIApplication.shared.delegate?.window??.windowScene {
                orientation = scene.interfaceOrientation
            }
        } else {
            orientation = UIApplication.shared.statusBarOrientation
        }
        return orientation
    }
    
    /// 获取状态栏的样式
    /// - Returns: 状态栏样式
    @objc public class func statusBarStyle() -> UIStatusBarStyle {
        var style: UIStatusBarStyle = .default
        if #available(iOS 13.0, *) {
            if let statusBarManager = UIApplication.shared.delegate?.window??.windowScene?.statusBarManager {
                style = statusBarManager.statusBarStyle
            }
        } else {
            style = UIApplication.shared.statusBarStyle
        }
        return style
    }
    
    /// 获取状态栏是否隐藏
    /// - Returns: 状态栏是否隐藏
    @objc public class func isStatusBarHidden() -> Bool {
        var isHidden: Bool = false
        if #available(iOS 13.0, *) {
            if let statusBarManager = UIApplication.shared.delegate?.window??.windowScene?.statusBarManager {
                isHidden = statusBarManager.isStatusBarHidden
            }
        } else {
            isHidden = UIApplication.shared.isStatusBarHidden
        }
        return isHidden
    }
    
    /// 获取状态栏位置
    /// - Returns: 状态栏位置
    @objc public class func statusBarFrame() -> CGRect {
        var rect: CGRect = .zero
        if #available(iOS 13.0, *) {
            if let statusBarManager = UIApplication.shared.delegate?.window??.windowScene?.statusBarManager {
                rect = statusBarManager.statusBarFrame
            }
        } else {
            rect = UIApplication.shared.statusBarFrame
        }
        return rect
    }
}
