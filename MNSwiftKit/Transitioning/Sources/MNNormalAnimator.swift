//
//  MNNormalAnimator.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/17.
//  仿系统转场动画

import UIKit

public class MNNormalAnimator: MNTransitionAnimator {
    // 持续时间
    public override var duration: TimeInterval { 0.3 }
    // 进栈
    public override func enterTransitionAnimation() {
        // 黑色背景
        let shadowView = UIView(frame: fromView.bounds)
        shadowView.isUserInteractionEnabled = true
        shadowView.backgroundColor = UIColor.clear
        containerView.insertSubview(shadowView, aboveSubview: fromView)
        // 添加控制器
        toView.mn.addTransitioningShadow()
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(translationX: containerView.frame.width, y: 0.0)
        containerView.insertSubview(toView, aboveSubview: shadowView)
        // 动画
        let transform = CGAffineTransform(translationX: -containerView.frame.width/2.0, y: 0.0)
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = transform
            shadowView.backgroundColor = .black.withAlphaComponent(0.2)
        } completion: { [weak self] finish in
            guard let self = self else { return }
            shadowView.removeFromSuperview()
            self.fromView.transform = .identity
            self.toView.mn.removeTransitioningShadow()
            self.completeTransitionAnimation()
        }
    }
    // 出栈
    public override func leaveTransitionAnimation() {
        // 黑色背景
        let shadowView = UIView(frame: containerView.bounds)
        shadowView.backgroundColor = .black.withAlphaComponent(0.2)
        containerView.insertSubview(shadowView, belowSubview: fromView)
        // 添加控制器
        toView.transform = .identity
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(translationX: -containerView.frame.width/2.0, y: 0.0)
        containerView.insertSubview(toView, belowSubview: shadowView)
        // 转场阴影
        fromView.mn.addTransitioningShadow()
        // 动画
        let transform = CGAffineTransform(translationX: containerView.frame.width, y: 0.0)
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = transform
            shadowView.backgroundColor = .clear
        } completion: { [weak self] finish in
            guard let self = self else { return }
            shadowView.removeFromSuperview()
            self.fromView.transform = .identity
            self.fromView.mn.removeTransitioningShadow()
            self.completeTransitionAnimation()
        }
    }
    // 交互开始
    public override func beginInteractiveTransition() {
        // 添加控制器
        toView.transform = .identity;
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(translationX: -containerView.frame.width/2.0, y: 0.0)
        containerView.insertSubview(toView, belowSubview: fromView)
        // 转场阴影
        fromView.mn.addTransitioningShadow()
        // 动画
        let transform = CGAffineTransform(translationX: containerView.frame.width, y: 0.0)
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = transform
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.toView.transform = .identity
            self.fromView.transform = .identity
            self.fromView.mn.removeTransitioningShadow()
            self.completeTransitionAnimation()
        }
    }
}

