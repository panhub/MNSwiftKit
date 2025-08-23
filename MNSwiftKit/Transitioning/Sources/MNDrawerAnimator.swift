//
//  MNDrawerAnimator.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/17.
//  远近切换

import UIKit

public class MNDrawerAnimator: MNTransitionAnimator {
    // 进栈
    public override func enterTransitionAnimation() {
        // 添加控制器
        toView.transform = .identity
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(translationX: containerView.frame.width, y: 0.0)
        containerView.insertSubview(toView, aboveSubview: fromView)
        // 阴影
        toView.addTransitioningShadow()
        // 动画
        let backgroundColor = containerView.backgroundColor
        containerView.backgroundColor = fromController.preferredTransitionBackgroundColor ?? .white
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.fromView.transform = .identity
            self.toView.removeTransitioningShadow()
            self.containerView.backgroundColor = backgroundColor
            self.completeTransitionAnimation()
        }
    }
    // 出栈
    public override func leaveTransitionAnimation() {
        // 添加视图
        toView.transform = .identity
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        containerView.insertSubview(toView, belowSubview: fromView)
        // 添加阴影
        fromView.addTransitioningShadow()
        // 动画
        let backgroundColor = containerView.backgroundColor
        containerView.backgroundColor = toController.preferredTransitionBackgroundColor ?? .white
        let transform = CGAffineTransform(translationX: containerView.frame.width, y: 0.0)
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = transform
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.fromView.transform = .identity
            self.fromView.removeTransitioningShadow()
            self.containerView.backgroundColor = backgroundColor
            self.completeTransitionAnimation()
        }
    }
    // 交互转场
    public override func beginInteractiveTransition() {
        // 添加视图
        toView.transform = .identity
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        containerView.insertSubview(toView, belowSubview: fromView)
        // 添加阴影
        fromView.addTransitioningShadow()
        // 动画
        let backgroundColor = containerView.backgroundColor
        let transform = CGAffineTransform(translationX: containerView.frame.width, y: 0.0)
        containerView.backgroundColor = toController.preferredTransitionBackgroundColor ?? .white
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = transform
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = .identity
            self.fromView.removeTransitioningShadow()
            self.containerView.backgroundColor = backgroundColor
            self.completeTransitionAnimation()
        }
    }
}
