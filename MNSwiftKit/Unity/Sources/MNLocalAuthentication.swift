//
//  MNLocalAuthentication.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/2/9.
//  本地身份验证

import Foundation
import LocalAuthentication

public class MNLocalAuthentication {
    
    /// 开始验证
    /// - Parameters:
    ///   - reason: 验证原因(应简短扼要, TouchID验证时显示, FaceID验证时仅在提供了"fallbackTitle"且不为空字符串时显示)
    ///   - cancelTitle: 取消按钮标题(available(iOS 10.0), 不提供或提供空字符串则使用默认标题)
    ///   - fallbackTitle: 切换验证策略的按钮标题(不提供时使用默认"输入密码", 空字符串则隐藏按钮)
    ///   - fallbackHandler: 当验证策略改变时回调
    ///   - replyHandler: 验证结果回调(是否通过验证, 验证结果描述)
    public class func evaluate(reason: String, cancelTitle: String? = nil, fallbackTitle: String? = nil, fallback fallbackHandler: (()->Void)? = nil, reply replyHandler: @escaping (Bool, String)->Void) {
        guard isSupportedAuthentication else {
            if let fallbackHandler = fallbackHandler {
                fallbackHandler()
            } else {
                var code: LAError.Code = .touchIDNotAvailable
                if #available(iOS 11.0, *) {
                    code = .biometryNotAvailable
                }
                replyHandler(false, code.desc)
            }
            return
        }
        // 开始身份验证
        let context: LAContext = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.localizedFallbackTitle = fallbackTitle
            if #available(iOS 10.0, *) {
                context.localizedCancelTitle = cancelTitle
            }
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { result, error in
                DispatchQueue.main.async {
                    if result {
                        replyHandler(true, "Success")
                    } else if let error = error {
                        // 判断是否自动解锁密码
                        if let code = MNLocalAuthentication.errorCode(with: error) {
                            switch code {
                            case .userFallback:
                                // 回退按钮点击
                                if let fallbackHandler = fallbackHandler {
                                    fallbackHandler()
                                } else {
                                    replyHandler(false, code.desc)
                                }
                            case .touchIDLockout:
                                // 再次触发以输入密码
                                MNLocalAuthentication.evaluate(reason: reason, cancelTitle: cancelTitle, fallbackTitle: fallbackTitle, fallback: fallbackHandler, reply: replyHandler)
                            default:
                                if #available(iOS 11.0, *), code == .biometryLockout {
                                    // 再次触发以输入密码
                                    MNLocalAuthentication.evaluate(reason: reason, cancelTitle: cancelTitle, fallbackTitle: fallbackTitle, fallback: fallbackHandler, reply: replyHandler)
                                } else {
                                    replyHandler(false, code.desc)
                                }
                            }
                        } else {
                            replyHandler(false, (error as NSError).userInfo[NSLocalizedDescriptionKey] as? String ?? "发生未知错误")
                        }
                    } else {
                        replyHandler(false, "发生未知错误")
                    }
                }
            }
        } else {
            // 通常TouchID被锁定
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { result, error in
                var msg: String = "Success"
                if let error = error {
                    msg = MNLocalAuthentication.reason(error: error as NSError)
                }
                DispatchQueue.main.async {
                    replyHandler(result, msg)
                }
            }
        }
    }
}

extension MNLocalAuthentication {
    
    /// 是否支持本地生物验证
    public static var isSupportedAuthentication: Bool {
        let context: LAContext = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) { return true }
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) { return true }
        return false
    }
    
    /// 是否支持FaceID验证
    public static var isSupportedFaceAuthentication: Bool {
        guard #available(iOS 11.0, *) else { return false }
        let context: LAContext = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return false }
        return context.biometryType == .faceID
    }
    
    /// 是否支持TouchID验证
    public static var isSupportedTouchAuthentication: Bool {
        let context: LAContext = LAContext()
        var supported = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if supported, #available(iOS 11.0, *) {
            return context.biometryType == .touchID
        }
        if supported == false {
            // TouchID锁定
            supported = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        }
        return supported
    }
}

fileprivate extension MNLocalAuthentication {
    
    static func reason(error: Error) -> String {
        guard let code = errorCode(with: error) else {
            return (error as NSError).userInfo[NSLocalizedDescriptionKey] as? String ?? "发生未知错误"
        }
        return code.desc
    }
    
    static func errorCode(with error: Error) -> LAError.Code? {
        let error = error as NSError
        guard error.domain == LAErrorDomain else { return nil }
        return LAError.Code(rawValue: error.code)
    }
}

fileprivate extension LAError.Code {
    
    var desc: String {
        switch self {
        case .authenticationFailed: return "身份验证失败"
        case .userCancel: return "已取消身份验证"
        case .userFallback: return "已选择回退选项"
        case .systemCancel: return "自动取消身份验证"
        case .passcodeNotSet: return "未设置密码, 无法验证"
        case .touchIDNotAvailable: return "身份验证程序不可用"
        case .touchIDNotEnrolled: return "用户未注册身份信息"
        case .touchIDLockout: return "验证程序被锁定"
        case .appCancel: return "已取消身份验证"
        case .invalidContext: return "上下文失效"
        case .notInteractive: return "被禁止的操作"
        default:
            if #available(iOS 11.0, *) {
                if self == .biometryNotAvailable { return "身份验证程序不可用" }
                if self == .biometryNotEnrolled { return "用户未注册身份信息" }
                if self == .biometryLockout { return "验证程序被锁定" }
            }
            return "发生未知错误"
        }
    }
}
