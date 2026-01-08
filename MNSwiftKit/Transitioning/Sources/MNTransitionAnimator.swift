//
//  MNTransitionAnimator.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/16.
//  转场动画控制者

import UIKit
import Foundation

open class MNTransitionAnimator: NSObject {
    /// 转场样式
    public enum Animation: Int {
        case normal, drawer, modal, flip
    }
    /// 标签栏转场类型
    public enum BottomBarAnimation {
        case none, adsorb, move
    }
    /// 转场时间
    open var duration: TimeInterval { 0.3 }
    /// 转场方向
    open var operation: UINavigationController.Operation = .push
    /// 标签栏转场类型
    open var bottomBarAnimation: BottomBarAnimation = .adsorb
    /// 是否交互转场
    private var isInteractive: Bool = false
    /// 标签栏
    open weak var bottomBar: UIView?
    /// 起始控制器视图
    public private(set) var fromView: UIView!
    /// 起始控制器
    public private(set) var fromController: UIViewController!
    /// 目标控制器视图
    public private(set) var toView: UIView!
    /// 目标控制器
    public private(set) var toController: UIViewController!
    /// 转场视图
    public private(set) var containerView: UIView!
    /// 转场上下文
    public private(set) var context: UIViewControllerContextTransitioning!
    /// 转场类
    private static let Animations: [String] = ["MNNormalAnimator", "MNDrawerAnimator", "MNModalAnimator", "MNFlipAnimator"]
    
    required public override init() {
        super.init()
    }
    
    /// 获取转场实例
    public class func animator(animation: Animation = .normal) -> MNTransitionAnimator {
        // 获取命名空间
        let nameSpace = NSStringFromClass(MNTransitionAnimator.self).components(separatedBy: ".").first!
        // 转换为类
        let cls = NSClassFromString("\(nameSpace).\(MNTransitionAnimator.Animations[animation.rawValue])")! as! MNTransitionAnimator.Type
        return cls.init()
    }
    
    /// 初始化转场参数
    open func beginTransition(using transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
        isInteractive = transitionContext.isInteractive
        containerView = transitionContext.containerView
        fromController = transitionContext.viewController(forKey: .from)
        toController = transitionContext.viewController(forKey: .to)
        fromView = fromController.view
        toView = toController.view
    }
}

// MARK: - 转场代理
extension MNTransitionAnimator: UIViewControllerAnimatedTransitioning {
    /// 转场时长
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { duration }
    /// 转场开始
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        beginTransition(using: transitionContext)
        // 预备标签栏转场
        prepareBottomBarTransition()
        // 交互转场
        if isInteractive {
            beginInteractiveTransition()
            return
        }
        // 开始标签栏转场
        bottomBarTransitionAnimation()
        // 开始控制器转场
        switch operation {
        case .push:
            // 进栈转场
            enterTransitionAnimation()
        case .pop:
            // 出栈转场
            leaveTransitionAnimation()
        default: break
        }
    }
    /// 结束转场
    open func animationEnded(_ transitionCompleted: Bool) {
        if isInteractive {
            // 交互转场结束
            if transitionCompleted, bottomBarAnimation == .move {
                // 交互转场结束 开启标签栏转场
                bottomBarTransitionAnimation()
            } else {
                // 结束标签栏转场
                completeBottomBarTransition(transitionCompleted)
            }
        } else {
            switch bottomBarAnimation {
            case .none, .adsorb:
                completeBottomBarTransition(transitionCompleted)
            default: break
            }
        }
    }
}

// MARK: - 定制转场动画
extension MNTransitionAnimator {
    
    /// 进入新界面时动画
    @objc open func enterTransitionAnimation() {}
    
    /// 页面离开时动画
    @objc open func leaveTransitionAnimation() {}
    
    /// 标签栏即将开始转场
    private func prepareBottomBarTransition() {
        switch operation {
        case .push:
            // 进栈转场
            guard let bottomBar = bottomBar, let firstController = fromController.navigationController?.viewControllers.first, fromController == firstController else { break }
            let snapshotView = bottomBar.mn.transitioningSnapshotView
            fromController.mn.transitioningBottomBar = bottomBar
            fromController.mn.transitioningBottomSnapshot = snapshotView
            guard fromController.bottomBarShouldLeave() else { break }
            switch bottomBarAnimation {
            case .adsorb:
                // 吸附效果
                bottomBar.isHidden = true
                snapshotView.frame = fromView.bounds.inset(by: UIEdgeInsets(top: fromView.frame.height - snapshotView.frame.height, left: 0.0, bottom: 0.0, right: 0.0))
                fromView.addSubview(snapshotView)
            case .move:
                // 移动效果
                bottomBar.isHidden = true
                snapshotView.frame = containerView.bounds.inset(by: UIEdgeInsets(top: containerView.frame.height, left: 0.0, bottom: -snapshotView.frame.height, right: 0.0))
                snapshotView.transform = CGAffineTransform(translationX: 0.0, y: -snapshotView.frame.height)
                containerView.addSubview(snapshotView)
            default: break
            }
        case .pop:
            // 出栈转场
            guard toController.bottomBarShouldEnter() else { break }
            guard let snapshotView = toController.mn.transitioningBottomSnapshot else { break }
            snapshotView.transform = .identity
            switch bottomBarAnimation {
            case .adsorb:
                // 吸附效果
                snapshotView.frame = toView.bounds.inset(by: UIEdgeInsets(top: toView.frame.height - snapshotView.frame.height, left: 0.0, bottom: 0.0, right: 0.0))
                toView.addSubview(snapshotView)
            case .move:
                // 移动效果
                snapshotView.frame = containerView.bounds.inset(by: UIEdgeInsets(top: containerView.frame.height - snapshotView.frame.height, left: 0.0, bottom: 0.0, right: 0.0))
                snapshotView.transform = CGAffineTransform(translationX: 0.0, y: snapshotView.frame.height)
                containerView.addSubview(snapshotView)
            default: break
            }
        default: break
        }
    }
    
    /// 交互转场动画
    @objc open func beginInteractiveTransition() {
        // 添加视图
        toView.transform = .identity;
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        containerView.insertSubview(toView, belowSubview: fromView)
        // 添加阴影
        fromView.mn.addTransitioningShadow()
        // 动画
        let backgroundColor = containerView.backgroundColor
        let transform = CGAffineTransform(translationX: containerView.frame.width, y: 0.0)
        containerView.backgroundColor = toController.preferredTransitionBackgroundColor ?? .white
        UIView.animate(withDuration: transitionDuration(using: context)) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = transform
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = .identity
            self.fromView.mn.removeTransitioningShadow()
            self.containerView.backgroundColor = backgroundColor
            self.completeTransitionAnimation()
        }
    }
    
    /// 结束转场动画
    @objc open func completeTransitionAnimation() {
        context.completeTransition(context.transitionWasCancelled == false)
    }
    
    /// 标签栏转场动画
    private func bottomBarTransitionAnimation() {
        switch bottomBarAnimation {
        case .move:
            let viewController: UIViewController = operation == .push ? fromController : toController
            guard let snapshotView = viewController.mn.transitioningBottomSnapshot else { break }
            containerView.isUserInteractionEnabled = false
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut) {
                if let _ = snapshotView.superview {
                    snapshotView.transform = .identity
                }
            } completion: { _ in
                self.containerView.isUserInteractionEnabled = true
                self.completeBottomBarTransition()
            }
        default: break
        }
    }
    
    /// 结束标签栏转场
    private func completeBottomBarTransition(_ transitionCompleted: Bool = true) {
        switch operation {
        case .push:
            // 进栈结束
            if let snapshotView = fromController.mn.transitioningBottomSnapshot {
                snapshotView.removeFromSuperview()
                if transitionCompleted == false {
                    fromController.mn.transitioningBottomSnapshot = nil
                }
            }
            if transitionCompleted == false, let bottomBar = fromController.mn.transitioningBottomBar {
                fromController.mn.transitioningBottomBar = nil
                if fromController.bottomBarShouldLeave() {
                    bottomBar.isHidden = false
                }
            }
        case .pop:
            // 恢复标签栏
            if let snapshotView = toController.mn.transitioningBottomSnapshot {
                snapshotView.removeFromSuperview()
                if transitionCompleted {
                    toController.mn.transitioningBottomSnapshot = nil
                }
            }
            if transitionCompleted, let bottomBar = toController.mn.transitioningBottomBar {
                toController.mn.transitioningBottomBar = nil
                if toController.bottomBarShouldEnter() {
                    bottomBar.isHidden = false
                }
            }
        default: break
        }
    }
}
