//
//  UIView+Toast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  弹窗管理

import UIKit
import ObjectiveC.runtime

extension UIView {
    
    internal struct MNToastAssociated {
        
        /// 关联弹窗的Key
        nonisolated(unsafe) static var toast = "com.mn.view.toast"
    }
}

extension NameSpaceWrapper where Base: UIView {
    
    /// 是否存在toast弹窗
    public var isToastAppearing: Bool {
        toast != nil
    }
    
    /// tost弹窗
    public var toast: MNToast? {
        get { objc_getAssociatedObject(base, &UIView.MNToastAssociated.toast) as? MNToast }
        set { objc_setAssociatedObject(base, &UIView.MNToastAssociated.toast, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension NameSpaceWrapper where Base: UIView {
    
    /// 显示系统活动视图Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public func showActivityToast(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        MNToast.show(builder: MNActivityToast(), in: base, at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示消息Toast
    /// - Parameters:
    ///   - msg: 消息内容
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public func showMsgToast(_ msg: String, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        MNToast.show(builder: MNMsgToast(), in: base, at: position, status: msg, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示提示Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public func showInfoToast(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        MNToast.show(builder: MNInfoToast(), in: base, at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示圆形旋转Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public func showShapeToast(_ status: String?, style: MNShapeToast.Style = .mask, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        MNToast.show(builder: MNShapeToast(style: style), in: base, at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示进度Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - style: 样式
    ///   - value: 进度值
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public func showProgressToast(_ status: String?, style: MNProgressToast.Style = .line, progress value: (any BinaryFloatingPoint)? = nil, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        MNToast.show(builder: MNProgressToast(style: style), in: base, at: position, status: status, progress: value, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示成功Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public func showSuccessToast(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        MNToast.show(builder: MNSuccessToast(), in: base, at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 显示失败Toast
    /// - Parameters:
    ///   - status: 状态描述
    ///   - position: 展示位置
    ///   - timeInterval: 显示时长
    ///   - dismissHandler: 消失回调
    public func showFailureToast(_ status: String?, at position: MNToast.Position = MNToast.Configuration.shared.position, delay timeInterval: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        
        MNToast.show(builder: MNFailureToast(), in: base, at: position, status: status, progress: nil, delay: timeInterval, dismiss: dismissHandler)
    }
    
    /// 取消Toast
    /// - Parameters:
    ///   - timeInterval: 等待时长
    ///   - dismissHandler: 消失回调
    public func dismissToast(after timeInterval: TimeInterval = 0.0, completion dismissHandler: (()->Void)? = nil) {
        guard let toast = toast else { return }
        toast.dismissWhenAppear(delay: timeInterval, completion: dismissHandler)
    }
}
