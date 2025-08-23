//
//  MNModalAnimator.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/17.
//  进栈模式下模态样式

import UIKit

public class MNModalAnimator: MNTransitionAnimator {
    // 持续时间
    public override var duration: TimeInterval { 0.33 }
    // 进栈
    public override func enterTransitionAnimation() {
        // 添加控制器
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(translationX: 0.0, y: containerView.frame.height)
        containerView.insertSubview(toView, aboveSubview: fromView)
        // 背景
        let backgroundColor = containerView.backgroundColor
        containerView.backgroundColor = fromController.preferredTransitionBackgroundColor ?? .white
        // 动画
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        } completion: { [weak self] finish in
            guard let self = self else { return }
            self.fromView.transform = .identity
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
        // 背景
        let backgroundColor = containerView.backgroundColor
        containerView.backgroundColor = toController.preferredTransitionBackgroundColor ?? .white
        let transform = CGAffineTransform(translationX: 0.0, y: containerView.frame.height)
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = transform
        } completion: { [weak self] finish in
            guard let self = self else { return }
            self.fromView.transform = .identity
            self.containerView.backgroundColor = backgroundColor
            self.completeTransitionAnimation()
        }
    }
}
