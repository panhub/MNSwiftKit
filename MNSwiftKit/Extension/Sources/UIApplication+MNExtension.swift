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

/// 加载评分方式
public enum MNOpenScoreMode {
    /// 当前页面加载
    case current
    /// 应用商店打开
    case store(_ appId: String)
}

extension NameSpaceWrapper where Base: UIApplication {
    
    /// 判断是否可打开链接
    /// - Parameter string: 资源定位
    /// - Returns: 是否可打开
    public func canOpen(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return base.canOpenURL(url)
    }
    
    /// 打开链接
    /// - Parameters:
    ///   - string: 指定链接
    ///   - completion: 结果回调是否成功打开
    public class func open(_ string: String, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
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
            Base.shared.open(url, options: [:], completionHandler: completion)
        } else {
            if Base.shared.canOpenURL(url) {
                let result = Base.shared.openURL(url)
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
    public class func openQQ(_ number: String, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let string = "mqq://im/chat?chat_type=wpa&uin=\(number)&version=1&src_type=web"
        open(string, completion: completion)
    }
    
    /// 打开QQ群组
    /// - Parameters:
    ///   - number: QQ群号
    ///   - key: 群标记
    ///   - completion: 结果回调是否成功打开
    public class func openQQGroup(_ number: String, key: String, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let string = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=\(number)&key=\(key)&card_type=group&source=external"
        open(string, completion: completion)
    }
    
    /// 打开评分
    /// - Parameters:
    ///   - mode: 打开方式
    ///   - completion: 结果回调
    public class func openScore(mode: MNOpenScoreMode = .current, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        switch mode {
        case .current:
            if #available(iOS 14.0, *), let windowScene = Base.shared.delegate?.window??.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            } else if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        case .store(let appId):
            guard appId.isEmpty == false else {
                completion?(false)
                break
            }
            let string = "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review"
            open(string, completion: completion)
        }
    }
}

extension NameSpaceWrapper where Base: UIApplication {
    
    /// 获取状态栏的方向
    public var statusBarOrientation: UIInterfaceOrientation {
        var orientation: UIInterfaceOrientation = .unknown
        if #available(iOS 13.0, *) {
            if let scene = base.delegate?.window??.windowScene {
                orientation = scene.interfaceOrientation
            }
        } else {
            orientation = base.statusBarOrientation
        }
        return orientation
    }
    
    /// 获取状态栏的样式
    public var statusBarStyle: UIStatusBarStyle {
        var style: UIStatusBarStyle = .default
        if #available(iOS 13.0, *) {
            if let statusBarManager = base.delegate?.window??.windowScene?.statusBarManager {
                style = statusBarManager.statusBarStyle
            }
        } else {
            style = base.statusBarStyle
        }
        return style
    }
    
    /// 获取状态栏是否隐藏
    public var isStatusBarHidden: Bool {
        var isHidden: Bool = false
        if #available(iOS 13.0, *) {
            if let statusBarManager = base.delegate?.window??.windowScene?.statusBarManager {
                isHidden = statusBarManager.isStatusBarHidden
            }
        } else {
            isHidden = base.isStatusBarHidden
        }
        return isHidden
    }
    
    /// 获取状态栏位置
    public var statusBarFrame: CGRect {
        var rect: CGRect = .zero
        if #available(iOS 13.0, *) {
            if let statusBarManager = base.delegate?.window??.windowScene?.statusBarManager {
                rect = statusBarManager.statusBarFrame
            }
        } else {
            rect = base.statusBarFrame
        }
        return rect
    }
}
