//
//  UIView+Toast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  弹窗管理

import UIKit
import ObjectiveC.runtime

// MARK: - 获取弹窗
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

// MARK: - 显示弹窗
extension NameSpaceWrapper where Base: UIView {
    
    
    public func showActivityToast(_ status: String?) {
        MNToast.show(builder: MNActivityToast(), in: base, status: status, progress: nil, dismiss: nil)
    }
    
    public func showMsgToast(_ msg: String) {
        MNToast.show(builder: MNMsgToast(), in: base, status: msg, progress: nil, dismiss: nil)
    }
    
//    @objc public func showMaskToast(_ status: String) {
//        showToast(MNMaskToast(), status: status)
//    }
//    
//    @objc public func showProgressToast(_ status: String) {
//        showToast(MNProgressToast(), status: status)
//    }
//    
//    @objc public func showMsgToast(_ msg: String, dismiss handler: (()->Void)? = nil) {
//        showToast(MNMsgToast(), status: msg, dismiss: handler)
//    }
//    
//    @objc public func showInfoToast(_ status: String, dismiss handler: (()->Void)? = nil) {
//        showToast(MNInfoToast(), status: status, dismiss: handler)
//    }
//    
//    @objc public func showSuccessToast(_ msg: String, dismiss handler: (()->Void)? = nil) {
//        showToast(MNSuccessToast(), status: msg, dismiss: handler)
//    }
//    
//    @objc public func showFailureToast(_ msg: String, dismiss handler: (()->Void)? = nil) {
//        showToast(MNFailureToast(), status: msg, dismiss: handler)
//    }
//    
//    @objc public func showToast(_ builder: MNToastBuilder, status: String? = nil, dismiss handler: (()->Void)? = nil) {
//        if let toast = toast {
//            toast.dismiss(animation: .none)
//        }
//        let toast = MNToast(builder: builder)
//        toast.text = status
//        toast.show(in: self, dismiss: handler)
//    }
//    
//    @objc public func showInfo(_ status: String, completion: (()->Void)? = nil) {
//        
//    }
}

//// MARK: - 更新弹窗
//extension UIView {
//    
//    /// 更新弹窗
//    /// - Parameter status: 状态提示
//    @objc public func updateToast(status: String?) {
//        guard let toast = toast else { return }
//        toast.text = status
//    }
//    
//    /// 更新弹窗
//    /// - Parameter progress: 进度
//    @objc public func updateToast(progress: Double) {
//        guard let toast = toast else { return }
//        toast.updateProgress(progress)
//    }
//}

//// MARK: - 关闭弹窗
//extension UIView {
//    
//    /// 关闭弹窗
//    @objc public func closeToast() {
//        closeToast(dismiss: nil)
//    }
//    
//    /// 关闭弹窗
//    /// - Parameter handler: 结束回调
//    @objc public func closeToast(dismiss handler: (()->Void)?) {
//        guard let toast = toast else { return }
//        toast.dismissHandler = handler
//        toast.close()
//    }
//}
