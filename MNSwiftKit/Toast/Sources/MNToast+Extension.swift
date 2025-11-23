//
//  MNToast+Extension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/14.
//  Window中Toast

import UIKit
import Foundation

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
        
        /// 内容四周约束
        public var contentInset: UIEdgeInsets = .init(top: 13.0, left: 13.0, bottom: 13.0, right: 13.0)
        
        /// 视图元素颜色
        public var color: UIColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
        /// 字体
        public var font: UIFont = .systemFont(ofSize: 15.0, weight: .regular)
        
        /// 状态文字最大宽度
        public var greatestFiniteStatusWidth: CGFloat = 200.0
        
        /// Toast显示时是否允许交互
        public var allowUserInteractionWhenDisplayed: Bool = true
    }
}

extension MNToast {
    
    /// 显示系统活动视图Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showActivity(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNActivityToast(), at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示消息Toast
    /// - Parameters:
    ///   - msg: 消息内容
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showMsg(_ msg: String, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNMsgToast(), at: position, status: msg, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示提示Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showInfo(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNInfoToast(), at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示圆形旋转Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showShape(_ status: String?, style: MNShapeToast.Style = .mask, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNShapeToast(style: style), at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示进度Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - value: 进度值
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showProgress(_ status: String?, style: MNProgressToast.Style = .line, progress value: (any BinaryFloatingPoint)? = nil, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNProgressToast(style: style), at: position, status: status, progress: value, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示成功Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showSuccess(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNSuccessToast(), at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示失败Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showFailure(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNFailureToast(), at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 在当前窗口显示Toast
    /// - Parameters:
    ///   - builder: Toast构建者
    ///   - position: 展示位置
    ///   - status: 状态描述
    ///   - progress: 进度值
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func show(builder: MNToastBuilder, at position: MNToast.Position, status: String?, progress: (any BinaryFloatingPoint)?, delay timeInterval: TimeInterval?, dismiss dismissHandler: (()->Void)?) {
        let executeHandler: ()->Void = {
            guard let window = MNToast.window else { return }
            MNToast.show(builder: builder, in: window, at: position, status: status, progress: progress, delay: timeInterval, dismiss: dismissHandler)
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
    ///   - dismissHandler: 消失回调
    public class func dismiss(after timeInterval: TimeInterval = 0.0, completion dismissHandler: (()->Void)? = nil) {
        let executeHandler: ()->Void = {
            guard let window = MNToast.window else { return }
            window.mn.dismissToast(after: timeInterval, completion: dismissHandler)
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
}
