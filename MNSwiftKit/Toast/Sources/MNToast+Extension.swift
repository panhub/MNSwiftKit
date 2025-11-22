//
//  MNToast+Extension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/14.
//  Window弹窗

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
    
    /// 显示系统活动视图Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showActivity(_ status: String?, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNActivityToast(), status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示消息Toast
    /// - Parameters:
    ///   - status: 消息内容
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showMsg(_ status: String, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNMsgToast(), status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示提示Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showInfo(_ status: String?, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNInfoToast(), status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示圆形旋转Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showShape(_ status: String?, style: MNShapeToast.Style = .mask, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNShapeToast(style: style), status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示进度Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - value: 进度值
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showProgress(_ status: String?, style: MNProgressToast.Style = .line, progress value: (any BinaryFloatingPoint)? = nil, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNProgressToast(style: style), status: status, progress: value, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示成功Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showSuccess(_ status: String?, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNSuccessToast(), status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示失败Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func showFailure(_ status: String?, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        show(builder: MNFailureToast(), status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 在当前窗口显示Toast
    /// - Parameters:
    ///   - builder: Toast构建者
    ///   - status: 状态描述
    ///   - progress: 进度值
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public class func show(builder: MNToastBuilder, status: String?, progress: (any BinaryFloatingPoint)?, delay timeInterval: TimeInterval?, dismiss dismissHandler: (()->Void)?) {
        let executeHandler: ()->Void = {
            guard let window = MNToast.window else { return }
            MNToast.show(builder: builder, in: window, status: status, progress: progress, delay: timeInterval, dismiss: dismissHandler)
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
