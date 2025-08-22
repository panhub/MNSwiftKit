//
//  CALayer+MNAnimation.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/9.
//

import Foundation
import QuartzCore

extension CALayer {
    
    public var rotation: Double {
        set {
            setValue(newValue, forKey: "transform.rotation")
        }
        get {
            value(forKey: "transform.rotation") as? Double ?? 0.0
        }
    }
    
    public var rotationX: Double {
        set {
            setValue(newValue, forKey: "transform.rotation.x")
        }
        get {
            value(forKey: "transform.rotation.x") as? Double ?? 0.0
        }
    }
    
    public var rotationY: Double {
        set {
            setValue(newValue, forKey: "transform.rotation.y")
        }
        get {
            value(forKey: "transform.rotation.y") as? Double ?? 0.0
        }
    }
    
    public var rotationZ: Double {
        set {
            setValue(newValue, forKey: "transform.rotation.z")
        }
        get {
            value(forKey: "transform.rotation.z") as? Double ?? 0.0
        }
    }
    
    public var scale: CGFloat {
        set {
            setValue(newValue, forKey: "transform.scale")
        }
        get {
            value(forKey: "transform.scale") as? CGFloat ?? 0.0
        }
    }
    
    public var scaleX: CGFloat {
        set {
            setValue(newValue, forKey: "transform.scale.x")
        }
        get {
            value(forKey: "transform.scale.x") as? CGFloat ?? 0.0
        }
    }
    
    public var scaleY: CGFloat {
        set {
            setValue(newValue, forKey: "transform.scale.y")
        }
        get {
            value(forKey: "transform.scale.y") as? CGFloat ?? 0.0
        }
    }
    
    public var scaleZ: CGFloat {
        set {
            setValue(newValue, forKey: "transform.scale.z")
        }
        get {
            value(forKey: "transform.scale.z") as? CGFloat ?? 0.0
        }
    }
    
    public var translationX: CGFloat {
        set {
            setValue(newValue, forKey: "transform.translation.x")
        }
        get {
            value(forKey: "transform.translation.x") as? CGFloat ?? 0.0
        }
    }
    
    public var translationY: CGFloat {
        set {
            setValue(newValue, forKey: "transform.translation.y")
        }
        get {
            value(forKey: "transform.translation.y") as? CGFloat ?? 0.0
        }
    }
    
    public var translationZ: CGFloat {
        set {
            setValue(newValue, forKey: "transform.translation.z")
        }
        get {
            value(forKey: "transform.translation.z") as? CGFloat ?? 0.0
        }
    }
}

extension CALayer {
    
    /// 禁止动画效果
    @objc public class func performWithoutAnimation(_ actionsWithoutAnimation: ()->Void) -> Void {
        animate(withDuration: 0.0, animations: actionsWithoutAnimation)
    }
    
    /// 动画回调
    @objc public class func animate(withDuration duration: TimeInterval, animations: () -> Void, completion: (() -> Void)? = nil) -> Void {
        CATransaction.begin()
        CATransaction.setDisableActions(duration <= 0.0)
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        animations()
        CATransaction.commit()
    }
    
    /// 转场动画
    @objc public func transition(withDuration duration: TimeInterval, type: CATransitionType, subtype: CATransitionSubtype? = nil, animations: (CALayer)-> Void, completion: (() -> Void)? = nil) {
        let transition = CATransition()
        transition.type = type
        transition.subtype = subtype
        transition.duration = duration
        transition.autoreverses = false
        transition.timingFunction = CAMediaTimingFunction(name: .linear)
        transition.isRemovedOnCompletion = false
        transition.fillMode = .forwards
        animations(self)
        add(transition, forKey: nil)
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1, execute: completion)
        }
    }
}
