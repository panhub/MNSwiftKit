//
//  UIView+MNTransitionHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/17.
//  转场辅助

import UIKit
import ObjectiveC.runtime

extension NameSpaceWrapper where Base: UIView {
    
    /// 转场截图
    public var transitioningSnapshotView: UIImageView {
        let alpha = base.alpha
        let isHidden = base.isHidden
        base.alpha = 1.0
        base.isHidden = false
        var image: UIImage?
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: base.bounds)
            image = renderer.image { context in
                self.base.layer.render(in: context.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, base.layer.contentsScale)
            if let context = UIGraphicsGetCurrentContext() {
                self.base.layer.render(in: context)
            }
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        base.alpha = alpha
        base.isHidden = isHidden
        let imageView = UIImageView(frame: base.frame)
        imageView.image = image
        return imageView
    }
    
    /// 添加转场阴影
    public func addTransitioningShadow() {
        base.layer.shadowOffset = .zero
        base.layer.shadowOpacity = 0.7
        base.layer.shadowColor = UIColor.black.cgColor
        base.layer.shadowPath = UIBezierPath(rect: base.layer.bounds).cgPath
    }
    
    /// 清除转场阴影
    public func removeTransitioningShadow() {
        base.layer.shadowPath = nil
        base.layer.shadowColor = nil
        base.layer.shadowOpacity = 0.0
    }
}

extension UIViewController {
    
    fileprivate struct MNTransitioningAssociated {
        
        nonisolated(unsafe) static var bottomBar = "com.mn.view.transition.bottom.bar.key"
        nonisolated(unsafe) static var bottomSnapshot = "com.mn.view.transition.bottom.snapshot.key"
    }
}

extension NameSpaceWrapper where Base: UIViewController {
    
    /// 转场标签栏
    public var transitioningBottomBar: UIView? {
        get { objc_getAssociatedObject(base, &UIViewController.MNTransitioningAssociated.bottomBar) as? UIView }
        set { objc_setAssociatedObject(base, &UIViewController.MNTransitioningAssociated.bottomBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 转场标签栏截图
    public var transitioningBottomSnapshot: UIView? {
        get { objc_getAssociatedObject(base, &UIViewController.MNTransitioningAssociated.bottomSnapshot) as? UIView }
        set { objc_setAssociatedObject(base, &UIViewController.MNTransitioningAssociated.bottomSnapshot, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

public protocol UIViewControllerTransitioning {
    /// 是否允许手动交互返回
    var preferredInteractiveTransition: Bool { get }
    /// 指定转场标签栏
    var preferredTransitionBottomBar: UIView? { get }
    /// 指定转场背景
    var preferredTransitionBackgroundColor: UIColor? { get }
    /// 定制进栈转场动画
    var preferredEnterTransitionAnimator: MNTransitionAnimator? { get }
    /// 定制出栈转场动画
    var preferredLeaveTransitionAnimator: MNTransitionAnimator? { get }
    /// 询问标签栏进栈转场
    func bottomBarShouldEnter() -> Bool
    /// 询问标签栏出栈转场
    func bottomBarShouldLeave() -> Bool
}

extension UIViewController: UIViewControllerTransitioning {
    /// 询问标签栏进栈转场
    @objc open func bottomBarShouldEnter() -> Bool { true }
    /// 询问标签栏出栈转场
    @objc open func bottomBarShouldLeave() -> Bool { true }
    /// 是否允许手动交互返回
    @objc open var preferredInteractiveTransition: Bool { true }
    /// 指定转场标签栏
    @objc open var preferredTransitionBottomBar: UIView? { nil }
    /// 指定转场背景
    @objc open var preferredTransitionBackgroundColor: UIColor? { .white }
    /// 定制进栈转场动画
    @objc open var preferredEnterTransitionAnimator: MNTransitionAnimator? { nil }
    /// 定制出栈转场动画
    @objc open var preferredLeaveTransitionAnimator: MNTransitionAnimator? { nil }
}
