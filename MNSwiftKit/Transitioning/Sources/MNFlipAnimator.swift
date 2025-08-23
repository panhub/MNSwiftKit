//
//  MNFlipAnimator.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/17.
//  翻转动画

import UIKit

public class MNFlipAnimator: MNTransitionAnimator {
    // 持续时间
    public override var duration: TimeInterval { 0.5 }
    // 进栈
    public override func enterTransitionAnimation() {
        // 添加控制器
        toView.frame = context.finalFrame(for: toController)
        containerView.insertSubview(toView, belowSubview: fromView)
        // 背景
        let backgroundColor = containerView.backgroundColor
        containerView.backgroundColor = fromController.preferredTransitionBackgroundColor ?? .black
        // 动画
        UIView.transition(with: containerView, duration: transitionDuration(using: context), options: .transitionFlipFromRight) { [weak self] in
            guard let self = self else { return }
            self.containerView.insertSubview(self.fromView, belowSubview: self.toView)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.containerView.backgroundColor = backgroundColor
            self.completeTransitionAnimation()
        }
    }
    // 出栈
    public override func leaveTransitionAnimation() {
        // 添加控制器
        toView.transform = .identity
        toView.frame = context.finalFrame(for: toController)
        containerView.insertSubview(toView, belowSubview: fromView)
        // 背景
        let backgroundColor = containerView.backgroundColor
        containerView.backgroundColor = toController.preferredTransitionBackgroundColor ?? .black
        // 动画
        UIView.transition(with: containerView, duration: transitionDuration(using: context), options: .transitionFlipFromLeft) { [weak self] in
            guard let self = self else { return }
            self.containerView.insertSubview(self.fromView, belowSubview: self.toView)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.containerView.backgroundColor = backgroundColor
            self.completeTransitionAnimation()
        }
    }
}
