//
//  UIView+Toast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  弹窗管理

import UIKit
import ObjectiveC.runtime
#if SWIFT_PACKAGE
@_exported import MNNameSpace
#endif

extension MNNameSpaceWrapper where Base: UIView {
    
    /// 是否存在toast弹窗
    public var isToastAppearing: Bool {
        toast != nil
    }
    
    /// tost弹窗
    public var toast: MNToast? {
        guard let subview = base.subviews.reversed().first(where: { $0 is MNToast }) else { return nil }
        return subview as? MNToast
    }
}

extension MNNameSpaceWrapper where Base: UIView {
    
    /// 显示系统活动视图Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - dismissHandler: 关闭后回调(是否是手动取消)
    public func showActivityToast(_ status: String?, style: MNActivityToast.Style = .large, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        MNToast.show(builder: MNActivityToast(style: style), in: base, at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示消息Toast
    /// - Parameters:
    ///   - msg: 消息内容
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public func showMsgToast(_ msg: String, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        MNToast.show(builder: MNMsgToast(), in: base, at: position, status: msg, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示提示Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public func showInfoToast(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        MNToast.show(builder: MNInfoToast(), in: base, at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示旋转Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public func showRotationToast(_ status: String?, style: MNRotationToast.Style = .gradient, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        MNToast.show(builder: MNRotationToast(style: style), in: base, at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
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
    public func showProgressToast(_ status: String? = nil, style: MNProgressToast.Style = .circular, value: (any BinaryFloatingPoint)? = nil, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        MNToast.show(builder: MNProgressToast(style: style), in: base, at: position, status: status, progress: value, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示成功Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public func showSuccessToast(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        MNToast.show(builder: MNSuccessToast(), in: base, at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 显示失败Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - cancellation: 是否支持手动取消
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 关闭后回调(是否是手动取消)
    public func showErrorToast(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, cancellation: Bool = false, delay timeInterval: TimeInterval? = nil, close handler: ((_ cancellation: Bool)->Void)? = nil) {
        
        MNToast.show(builder: MNErrorToast(), in: base, at: position, status: status, progress: nil, cancellation: cancellation, delay: timeInterval, close: handler)
    }
    
    /// 取消Toast
    /// - Parameters:
    ///   - timeInterval: 等待时长
    ///   - handler: 关闭后回调(是否是手动取消)
    public func closeToast(delay timeInterval: TimeInterval = 0.0, completion handler: ((_ cancellation: Bool)->Void)? = nil) {
        guard let toast = toast else { return }
        toast.closeWhenAppear(delay: timeInterval, completion: handler)
    }
}
