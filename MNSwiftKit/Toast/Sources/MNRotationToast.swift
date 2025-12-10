//
//  MNRotationToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Mask弹窗

import UIKit

/// 旋转Toast样式构建者
public class MNRotationToast {
    
    /// 线条样式
    public enum Style {
        /// 纯色线条
        case line
        /// 一对儿
        case pair
        /// 渐变颜色线条
        case gradient
    }
    
    /// 进度Toast样式
    public let style: MNRotationToast.Style
    
    /// 构造旋转Toast
    /// - Parameter style: 样式
    public init(style: MNRotationToast.Style) {
        self.style = style
    }
    
    lazy var activityLayer: CAShapeLayer = {
        
        let lineWidth: CGFloat = 2.2
        let borderSize: CGSize = .init(width: 40.0, height: 40.0)
        
        let path = UIBezierPath(arcCenter: CGPoint(x: borderSize.width/2.0, y: borderSize.height/2.0), radius: (borderSize.width - lineWidth)/2.0, startAngle: -.pi/2.0, endAngle: .pi/2.0*3.0, clockwise: true)
        let activityLayer = CAShapeLayer()
        activityLayer.frame = .init(origin: .zero, size: borderSize)
        activityLayer.path = path.cgPath
        activityLayer.fillColor = UIColor.clear.cgColor
        activityLayer.strokeColor = MNToast.Configuration.shared.primaryColor.withAlphaComponent(0.88).cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.lineCap = .round
        activityLayer.lineJoin = .round
        
        switch style {
        case .line:
            activityLayer.strokeStart = 0.09
            activityLayer.strokeEnd = 0.91
        case .pair:
            activityLayer.strokeStart = 0.0
            activityLayer.strokeEnd = 0.12
        case .gradient:
            let mask = CALayer()
            mask.frame = activityLayer.bounds
            mask.contents = ToastResource.image(named: effectForToast == .dark ? "toast_mask_light" : "toast_mask_dark")?.cgImage
            activityLayer.mask = mask
            activityLayer.strokeEnd = 1.0
        }
        
        return activityLayer
    }()
}
    
extension MNRotationToast: MNToastBuilder {
    
    public var axisForToast: MNToast.Axis {
        
        MNToast.Configuration.shared.axis
    }
    
    public var effectForToast: MNToast.Effect {
        
        MNToast.Configuration.shared.effect
    }
    
    public var contentInsetForToast: UIEdgeInsets {
        
        MNToast.Configuration.shared.contentInset
    }
    
    public var activityViewForToast: UIView? {
        
        let activityView = UIView(frame: activityLayer.bounds)
        if style == .pair {
            // 双层
            let path = UIBezierPath(cgPath: activityLayer.path!)
            let trackLayer = CAShapeLayer()
            trackLayer.frame = activityView.bounds
            trackLayer.path = path.cgPath
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.strokeColor = activityLayer.strokeColor?.copy(alpha: 0.18)
            trackLayer.lineWidth = activityLayer.lineWidth
            activityView.layer.addSublayer(trackLayer)
        }
        activityView.layer.addSublayer(activityLayer)
        return activityView
    }
    
    public var attributesForToastStatus: [NSAttributedString.Key : Any] {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:MNToast.Configuration.shared.font, .foregroundColor:MNToast.Configuration.shared.primaryColor, .paragraphStyle:paragraph]
    }
    
    public var fadeInForToast: Bool {
        
        true
    }
    
    public var fadeOutForToast: Bool {
        
        true
    }
    
    public var allowUserInteraction: Bool {
        
        false
    }
}

extension MNRotationToast: MNToastAnimationSupported {
    
    public func startAnimating() {
        
        if let animationKeys = activityLayer.animationKeys(), animationKeys.isEmpty == false { return }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 0.8
        animation.toValue = Double.pi*2.0
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.autoreverses = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        activityLayer.add(animation, forKey: "com.mn.toast.animation.rotation")
    }
    
    public func stopAnimating() {
        
        activityLayer.removeAllAnimations()
    }
}
