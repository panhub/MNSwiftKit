//
//  AppleLoginHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/5/4.
//  Apple登录辅助工具

import UIKit
import Foundation
import AuthenticationServices

/// 苹果登录错误
public enum AppleLoginError: Swift.Error {
    
    /// 不支持Apple登录
    case unavailable
    
    /// token不存在
    case tokenNotExist
    
    /// 凭证不存在
    case credentialNotExist
    
    /// 验证失败
    case authenticationFailure(Error)
}

extension AppleLoginError {
    
    /// 错误码
    public var code: Int {
        switch self {
        case .unavailable: return -3301
        case .tokenNotExist: return -3302
        case .credentialNotExist: return -3303
        case .authenticationFailure(let error): return error._code
        }
    }
    
    /// 错误描述
    public var msg: String {
        switch self {
        case .unavailable: return "系统不支持Apple登录"
        case .tokenNotExist: return "获取token失败"
        case .credentialNotExist: return "获取登录凭证失败"
        case .authenticationFailure(let error):
            if #available(iOS 13.0, *) {
                let code: ASAuthorizationError.Code = ASAuthorizationError.Code(rawValue: error._code) ?? .unknown
                switch code {
                case .unknown: return "发生未知错误"
                case .canceled: return "已取消授权"
                case .invalidResponse: return "授权响应无效"
                case .notHandled: return "无法处理授权"
                case .failed: return "授权请求失败"
                case .notInteractive: return "非交互式授权请求"
                case .matchedExcludedCredential: return "公钥请求失败"
                default: return "授权失败"
                }
            }
            return "授权失败"
        }
    }
}

public typealias AppleLoginFailureHandler = (_ error: AppleLoginError)->Void
public typealias AppleLoginSuccessHandler = (_ user: String, _ token: String, _ email: String)->Void

/// Apple登录辅助工具
public class AppleLoginHelper: NSObject {
    /// 记录展示窗口
    private weak var window: ASPresentationAnchor!
    /// 失败回调
    private var failureHandler: AppleLoginFailureHandler?
    /// 成功回调
    private var successHandler: AppleLoginSuccessHandler?
    
    public override init() {
        super.init()
    }
    
    /// 便捷入口
    /// - Parameter window: 展示窗口
    public convenience init(window: ASPresentationAnchor!) {
        self.init()
        self.window = window
    }
    
    public func login(in window: ASPresentationAnchor? = nil, success successHandler: @escaping AppleLoginSuccessHandler, failure failureHandler: AppleLoginFailureHandler?) {
        if #available(iOS 13.0, *) {
            self.window = window
            self.failureHandler = failureHandler
            self.successHandler = successHandler
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            let controller = ASAuthorizationController.init(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        } else {
            failureHandler?(.unavailable)
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0,*)
extension AppleLoginHelper: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = window { return window }
        var windows: [UIWindow]?
        if #available(iOS 15.0, *) {
            windows = UIApplication.shared.delegate?.window??.windowScene?.windows.reversed()
        } else {
            windows = UIApplication.shared.windows.reversed()
        }
        guard let windows = windows else {
            fatalError("获取窗口失败: presentationAnchor(for:)")
        }
        for window in windows {
            let isOnMainScreen = window.screen == UIScreen.main
            let isVisible = (window.isHidden == false && window.alpha > 0.01)
            if isOnMainScreen, isVisible, window.isKeyWindow {
                return window
            }
        }
        fatalError("获取窗口失败: presentationAnchor(for:)")
    }
}

// MARK: - ASAuthorizationControllerDelegate
@available(iOS 13.0,*)
extension AppleLoginHelper: ASAuthorizationControllerDelegate {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if authorization.credential is ASAuthorizationAppleIDCredential {
            let credential = authorization.credential as! ASAuthorizationAppleIDCredential
            let user = credential.user
            guard let identityToken = credential.identityToken else {
                failureHandler?(.tokenNotExist)
                return
            }
            guard let token = String(data: identityToken, encoding: .utf8) else {
                failureHandler?(.tokenNotExist)
                return
            }
            let email = credential.email ?? ""
            successHandler?(user, token, email)
        } else if authorization.credential is ASPasswordCredential {
            // 使用现有的iCloud密钥链凭证登录
            failureHandler?(.credentialNotExist)
        } else {
            failureHandler?(.credentialNotExist)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        failureHandler?(.authenticationFailure(error))
    }
}
