//
//  MNTransitionDelegate.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/6/23.
//  导航转场代理

import UIKit
import ObjectiveC.runtime

extension UINavigationController {
    
    fileprivate struct MNTransitionAssociated {
        
        nonisolated(unsafe) static var delegate: String = "com.mn.navigation.transitioning.delegate"
    }
}


extension MNNameSpaceWrapper where Base: UINavigationController {
    
    /// 转场代理
    public var transitioningDelegate: MNTransitionDelegate? {
        get { objc_getAssociatedObject(base, &UINavigationController.MNTransitionAssociated.delegate) as? MNTransitionDelegate }
        set {
            objc_setAssociatedObject(base, &UINavigationController.MNTransitionAssociated.delegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let newValue = newValue else { return }
            // 解除旧导航绑定
            if let navigationController = newValue.navigationController {
                navigationController.delegate = newValue.delegate
                navigationController.mn.transitioningDelegate = nil
                newValue.delegate = nil
                newValue.navigationController = nil
            }
            // 绑定新的导航
            newValue.delegate = base.delegate
            newValue.navigationController = base
            base.delegate = newValue
            // 拦截交互手势
            if let recognizer = base.interactivePopGestureRecognizer {
                recognizer.delegate = newValue
                recognizer.removeTarget(nil, action: nil)
                if let panGestureRecognizer = recognizer as? UIPanGestureRecognizer {
                    panGestureRecognizer.maximumNumberOfTouches = 1
                }
                if let edgePanGestureRecognizer = recognizer as? UIScreenEdgePanGestureRecognizer {
                    edgePanGestureRecognizer.edges = .left
                }
                if #available(iOS 11.0, *) {
                    recognizer.name = "com.mn.navigation.interactive.pop"
                }
                recognizer.addTarget(newValue, action: #selector(newValue.handleNavigationTransition(_:)))
            }
        }
    }
}

public class MNTransitionDelegate: NSObject {
    /// 标签栏
    @objc public weak var bottomBar: UIView?
    /// 转场动画
    @objc public var transitionAnimation: MNTransitionAnimator.Animation = .normal
    /// 标签栏转场动画类型
    @objc public var bottomBarAnimation: MNTransitionAnimator.BottomBarAnimation = .adsorb
    /// 转发代理事件
    fileprivate weak var delegate: UINavigationControllerDelegate?
    /// 导航控制器
    fileprivate weak var navigationController: UINavigationController?
    /// 交互返回驱动
    fileprivate var interactiveTransitionDriver: UIPercentDrivenInteractiveTransition?
    
    /// 处理导航交互式Pop
    /// - Parameter recognizer: 交互手势
    @objc fileprivate func handleNavigationTransition(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            interactiveTransitionDriver = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
        case .changed:
            guard let interactiveTransitionDriver = interactiveTransitionDriver else { break }
            let x: CGFloat = recognizer.translation(in: recognizer.view).x
            let rate: CGFloat = max(0.01, min(1.0, x/recognizer.view!.bounds.width))
            interactiveTransitionDriver.update(rate)
        case .cancelled:
            guard let interactiveTransitionDriver = interactiveTransitionDriver else { break }
            interactiveTransitionDriver.cancel()
            self.interactiveTransitionDriver = nil
        case .ended:
            guard let interactiveTransitionDriver = interactiveTransitionDriver else { break }
            let percent = interactiveTransitionDriver.percentComplete
            if percent >= 0.3 {
                interactiveTransitionDriver.finish()
            } else {
                interactiveTransitionDriver.cancel()
            }
            self.interactiveTransitionDriver = nil
        default:
            self.interactiveTransitionDriver = nil
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension MNTransitionDelegate: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransitionDriver
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard operation != .none else { return nil }
        var animator: MNTransitionAnimator! = (operation == .push ? toVC.preferredEnterTransitionAnimator : fromVC.preferredLeaveTransitionAnimator)
        if animator == nil {
            animator = MNTransitionAnimator.animator(animation: transitionAnimation)
            animator.bottomBarAnimation = bottomBarAnimation
        }
        if animator.bottomBar == nil {
            animator.bottomBar = (operation == .push ? fromVC.preferredTransitionBottomBar : nil) ?? bottomBar
        }
        animator.operation = operation
        return animator
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if animated == false, let index = navigationController.viewControllers.firstIndex(of: viewController) {
            if index == 0 {
                // 恢复标签栏
                if let bottomBar = viewController.mn.transitioningBottomBar {
                    viewController.mn.transitioningBottomBar = nil
                    if viewController.bottomBarShouldEnter() {
                        bottomBar.isHidden = false
                    }
                }
                // 删除截图
                if let snapshotView = viewController.mn.transitioningBottomSnapshot {
                    viewController.mn.transitioningBottomSnapshot = nil
                    snapshotView.removeFromSuperview()
                }
            } else {
                // 保存标签栏
                guard let bottomBar = bottomBar else { return }
                guard let first = navigationController.viewControllers.first else { return }
                if first.mn.transitioningBottomBar == nil {
                    first.mn.transitioningBottomBar = bottomBar
                    if first.bottomBarShouldLeave() {
                        bottomBar.isHidden = true
                    }
                }
                if first.mn.transitioningBottomSnapshot == nil {
                    let snapshotView = bottomBar.mn.transitioningSnapshotView
                    first.mn.transitioningBottomSnapshot = snapshotView
                }
            }
        }
        delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard let mask = delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) else {
            return .portrait
        }
        return mask
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        guard let orientation = delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) else {
            return .portrait
        }
        return orientation
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNTransitionDelegate: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let nav = navigationController, nav.viewControllers.count > 1 else { return false }
        return nav.viewControllers.last!.preferredInteractiveTransition
    }
}
