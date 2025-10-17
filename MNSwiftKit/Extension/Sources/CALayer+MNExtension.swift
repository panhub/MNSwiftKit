//
//  CALayer+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/17.
//

import UIKit
import Foundation
import QuartzCore

extension NameSpaceWrapper where Base: CALayer {
    
    /// 背景图片
    public var contents: UIImage? {
        set { base.contents = newValue?.cgImage }
        get {
            guard let contents = base.contents else { return nil }
            return UIImage(cgImage: contents as! CGImage)
        }
    }
    
    /// 暂停动画
    public func pauseAnimation() {
        guard base.speed == 1.0 else { return }
        let timeOffset = base.convertTime(CACurrentMediaTime(), from: nil)
        base.speed = 0.0
        base.timeOffset = timeOffset
    }
    
    /// 继续动画
    public func resumeAnimation() {
        guard base.speed == 0.0 else { return }
        let timeOffset = base.timeOffset
        base.speed = 1.0
        base.timeOffset = 0.0
        base.beginTime = 0.0
        let timeSincePause = base.convertTime(CACurrentMediaTime(), from: nil) - timeOffset
        base.beginTime = timeSincePause
    }
    
    /// 重置动画
    public func resetAnimation() {
        base.speed = 1.0
        base.timeOffset = 0.0
        base.beginTime = 0.0
    }
    
    /// 截图
    public var snapshotImage: UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: base.frame.size)
            return renderer.image { context in
                base.render(in: context.cgContext)
            }
        }
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, base.contentsScale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        base.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 设置圆角效果
    /// - Parameters:
    ///   - radius: 圆角大小
    ///   - corners: 圆角位置
    public func setRadius(_ radius: CGFloat, by corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: base.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        base.mask = layer
    }
}

extension CALayer {
    
    /// 摇晃方向
    @objc(CALayerShakeOrientation)
    public enum ShakeOrientation: Int {
        case horizontal
        case vertical
    }
}

extension NameSpaceWrapper where Base: CALayer {
    
    /// 摆动
    /// - Parameters:
    ///   - orientation: 方向
    ///   - duration: 时长
    ///   - extent: 摇摆的幅度
    ///   - completion: 结束回调
    public func swing(orientation: CALayer.ShakeOrientation = .horizontal, duration: TimeInterval = 0.8, extent: CGFloat = 6.0, completion: (()->Void)? = nil) {
        let spring: CGFloat = abs(extent)
        let animation = CAKeyframeAnimation(keyPath: orientation == .horizontal ? "transform.translation.x" : "transform.translation.y")
        animation.duration = duration
        animation.autoreverses = false
        animation.isRemovedOnCompletion = true
        //animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.values = [-spring/2.0, 0.0, spring/2.0, 0.0, -spring/2.0, -spring, -spring/2.0, 0.0, spring/2.0, spring, spring/3.0*2.0, spring/3.0, 0.0, -spring/3.0, -spring/3.0*2.0, -spring/3.0, 0.0, spring/3.0, spring/3.0*2.0, spring/3.0, 0.0, -spring/3.0, 0.0, spring/3.0, 0.0]
        base.removeAnimation(forKey: "com.mn.swing.animation")
        base.add(animation, forKey: "com.mn.swing.animation")
        guard let completion = completion else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + 0.1, execute: completion)
    }
    
    /// 摇动
    /// - Parameters:
    ///   - radian: 摇动弧度
    ///   - duration: 时长
    ///   - completion: 结束回调
    public func shake(radian: Double = 5.0/180.0*Double.pi, duration: TimeInterval = 0.35, completion: (()->Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.duration = duration
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.values = [-abs(radian), 0.0, abs(radian), 0.0]
        animation.autoreverses = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        base.removeAnimation(forKey: "com.mn.shake.animation")
        base.add(animation, forKey: "com.mn.shake.animation")
        guard let completion = completion else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + 0.1, execute: completion)
    }
}

extension NameSpaceWrapper where Base == CALayerContentsGravity {
    
    /// CALayerContentsGravity => UIView.ContentMode
    public var contentMode: UIView.ContentMode {
        switch base {
        case .center: return .center
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        case .resize: return .scaleToFill
        case .resizeAspect: return .scaleAspectFit
        case .resizeAspectFill: return .scaleAspectFill
        default: return .scaleToFill
        }
    }
}
 
