//
//  CALayer+MNAnimation.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/9.
//

import Foundation
import QuartzCore

extension NameSpaceWrapper where Base: CALayer {
    
    public var rotation: Double {
        set {
            base.setValue(newValue, forKey: .mn.rotation)
        }
        get {
            base.value(forKey: .mn.rotation) as? Double ?? 0.0
        }
    }
    
    public var rotationX: Double {
        set {
            base.setValue(newValue, forKey: .mn.rotationX)
        }
        get {
            base.value(forKey: .mn.rotationX) as? Double ?? 0.0
        }
    }
    
    public var rotationY: Double {
        set {
            base.setValue(newValue, forKey: .mn.rotationY)
        }
        get {
            base.value(forKey: .mn.rotationY) as? Double ?? 0.0
        }
    }
    
    public var rotationZ: Double {
        set {
            base.setValue(newValue, forKey: .mn.rotationZ)
        }
        get {
            base.value(forKey: .mn.rotationZ) as? Double ?? 0.0
        }
    }
    
    public var scale: CGFloat {
        set {
            base.setValue(newValue, forKey: .mn.scale)
        }
        get {
            base.value(forKey: .mn.scale) as? CGFloat ?? 0.0
        }
    }
    
    public var scaleX: CGFloat {
        set {
            base.setValue(newValue, forKey: .mn.scaleX)
        }
        get {
            base.value(forKey: .mn.scaleX) as? CGFloat ?? 0.0
        }
    }
    
    public var scaleY: CGFloat {
        set {
            base.setValue(newValue, forKey: .mn.scaleY)
        }
        get {
            base.value(forKey: .mn.scaleY) as? CGFloat ?? 0.0
        }
    }
    
    public var scaleZ: CGFloat {
        set {
            base.setValue(newValue, forKey: .mn.scaleZ)
        }
        get {
            base.value(forKey: .mn.scaleZ) as? CGFloat ?? 0.0
        }
    }
    
    public var translationX: CGFloat {
        set {
            base.setValue(newValue, forKey: .mn.translationX)
        }
        get {
            base.value(forKey: .mn.translationX) as? CGFloat ?? 0.0
        }
    }
    
    public var translationY: CGFloat {
        set {
            base.setValue(newValue, forKey: .mn.translationY)
        }
        get {
            base.value(forKey: .mn.translationY) as? CGFloat ?? 0.0
        }
    }
    
    public var translationZ: CGFloat {
        set {
            base.setValue(newValue, forKey: .mn.translationZ)
        }
        get {
            base.value(forKey: .mn.translationZ) as? CGFloat ?? 0.0
        }
    }
    
    /// 禁止动画效果
    /// - Parameter actionsWithoutAnimation: 动画事件回调
    public class func performWithoutAnimation(_ actionsWithoutAnimation: ()->Void) {
        animate(withDuration: 0.0, animations: actionsWithoutAnimation)
    }
    
    /// 动画
    /// - Parameters:
    ///   - duration: 动画时间
    ///   - animations: 动画事件回调
    ///   - completion: 动画结束回调
    public class func animate(withDuration duration: TimeInterval, animations: () -> Void, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setDisableActions(duration <= 0.0)
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        animations()
        CATransaction.commit()
    }
    
    /// 转场动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - type: 动画类型
    ///   - subtype: 动画类型
    ///   - animations: 动画事件
    ///   - completion: 动画结束回调
    public func transition(withDuration duration: TimeInterval, type: CATransitionType, subtype: CATransitionSubtype? = nil, animations: (CALayer)-> Void, completion: (() -> Void)? = nil) {
        let transition = CATransition()
        transition.type = type
        transition.subtype = subtype
        transition.duration = duration
        transition.autoreverses = false
        transition.timingFunction = CAMediaTimingFunction(name: .linear)
        transition.isRemovedOnCompletion = false
        transition.fillMode = .forwards
        animations(base)
        base.add(transition, forKey: nil)
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1, execute: completion)
        }
    }
}
