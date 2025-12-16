//
//  MNToast+Extension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/14.
//  Window中Toast

import UIKit
import Foundation
import CoreFoundation

public extension MNToast {
    
    /// 是否正在显示
    @objc class var isAppearing: Bool {
        guard let window = window else { return false }
        return window.mn.isToastAppearing
    }
    
    /// 获取当前窗口
    @objc class var window: UIWindow? {
        if #available(iOS 15.0, *) {
            return window(in: UIApplication.shared.delegate?.window??.windowScene?.windows.reversed())
        } else {
            return window(in: UIApplication.shared.windows.reversed())
        }
    }
    
    /// 在窗口集合中寻找当前窗口
    /// - Parameter windows: 窗口集合
    /// - Returns: 当前窗口
    private static func window(in windows: [UIWindow]?) -> UIWindow! {
        guard let windows = windows else { return nil }
        for window in windows {
            let isOnMainScreen = window.screen == .main
            let isVisible = (window.isHidden == false && window.alpha > 0.01)
            if isOnMainScreen, isVisible, window.isKeyWindow {
                return window
            }
        }
        return nil
    }
}

extension MNToast {
    
    /// Toast配置
    public class Configuration {
        
        /// 唯一实例化入口
        public static let shared = MNToast.Configuration()
        
        private init() {}
        
        /// 效果
        public var effect: MNToast.Effect = .dark
        
        /// 展示位置
        public var position: MNToast.Position = .center
        
        /// 布局方向
        public var axis: MNToast.Axis = .vertical(spacing: 8.0)
        
        /// 圆角大小
        public var cornerRadius: CGFloat = 8.0
        
        /// 键盘弹起时, 与键盘的距离
        public var spacingToKeyboard: CGFloat = 20.0
        
        /// 显示时是否允许交互
        public var allowUserInteraction: Bool = false
        
        /// 内容四周约束
        public var contentInset: UIEdgeInsets = .init(top: 13.0, left: 13.0, bottom: 13.0, right: 13.0)
        
        /// 字体
        public var font: UIFont = .systemFont(ofSize: 15.0, weight: .regular)
        
        /// 文字颜色
        public var textColor: UIColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.95, alpha: 1.0)
        
        /// 活动视图颜色
        public var activityColor: UIColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.95, alpha: 0.86)
        
        /// 状态文字最大宽度
        public var greatestFiniteStatusWidth: CGFloat = 200.0
    }
}

extension MNToast {
    
    /// 显示系统活动视图Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func showActivity(_ status: String?, style: MNActivityToast.Style = .large, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        show(builder: MNActivityToast(style: style), at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示消息Toast
    /// - Parameters:
    ///   - msg: 消息内容
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func showMsg(_ msg: String, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        show(builder: MNMsgToast(), at: position, status: msg, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示提示Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func showInfo(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        show(builder: MNInfoToast(), at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示旋转Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func showRotation(_ status: String?, style: MNRotationToast.Style = .gradient, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        show(builder: MNRotationToast(style: style), at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示进度Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - value: 进度值
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func showProgress(_ status: String? = nil, style: MNProgressToast.Style = .circular, value: (any BinaryFloatingPoint)? = nil, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        show(builder: MNProgressToast(style: style), at: position, status: status, progress: value, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示成功Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func showSuccess(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        show(builder: MNSuccessToast(), at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示失败Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func showError(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        show(builder: MNErrorToast(), at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 在当前窗口显示Toast
    /// - Parameters:
    ///   - builder: Toast构建者
    ///   - position: 展示位置
    ///   - status: 状态描述
    ///   - progress: 进度值
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func show(builder: MNToastBuilder, at position: MNToast.Position, status: String?, progress: (any BinaryFloatingPoint)?, cancellation: Bool = false, delay timeInterval: TimeInterval?, close handler: ((_ cancellation: Bool)->Void)?) {
        let executeHandler: ()->Void = {
            guard let window = MNToast.window else { return }
            MNToast.show(builder: builder, in: window, at: position, status: status, progress: progress, cancellation: cancellation, delay: timeInterval, close: handler)
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
    
    /// 取消Toast
    /// - Parameters:
    ///   - timeInterval: 等待时长
    ///   - handler: 关闭后回调(是否是手动取消)
    public class func close(delay timeInterval: TimeInterval = 0.0, completion handler: ((_ cancellation: Bool)->Void)? = nil) {
        let executeHandler: ()->Void = {
            guard let window = MNToast.window else { return }
            window.mn.closeToast(delay: timeInterval, completion: handler)
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
}
