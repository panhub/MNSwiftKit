//
//  UIView+MNTransitionHelper.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/17.
//  转场辅助

import UIKit
import ObjectiveC.runtime

public extension UIView {
    
    /// 转场截图
    @objc var transitioningSnapshotView: UIImageView {
        let alpha = alpha
        let isHidden = isHidden
        self.alpha = 1.0
        self.isHidden = false
        var image: UIImage?
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            image = renderer.image { [weak self] context in
                self?.layer.render(in: context.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, layer.contentsScale)
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
            }
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        self.alpha = alpha
        self.isHidden = isHidden
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        return imageView
    }
    
    /// 添加转场阴影
    @objc func addTransitioningShadow() -> Void {
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.7
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
    
    /// 清除转场阴影
    @objc func removeTransitioningShadow() -> Void {
        layer.shadowPath = nil
        layer.shadowColor = nil
        layer.shadowOpacity = 0.0
    }
}

extension UIViewController {
    
    private struct MNTransitioningAssociated {
        
        static var bottomBar = "com.mn.view.transition.bottom.bar.key"
        static var bottomSnapshot = "com.mn.view.transition.bottom.snapshot.key"
    }
    
    /// 转场标签栏
    @objc public var transitioningBottomBar: UIView? {
        get { return objc_getAssociatedObject(self, &MNTransitioningAssociated.bottomBar) as? UIView }
        set { objc_setAssociatedObject(self, &MNTransitioningAssociated.bottomBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 转场标签栏截图
    @objc public var transitioningBottomSnapshot: UIView? {
        get { return objc_getAssociatedObject(self, &MNTransitioningAssociated.bottomSnapshot) as? UIView }
        set { objc_setAssociatedObject(self, &MNTransitioningAssociated.bottomSnapshot, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
