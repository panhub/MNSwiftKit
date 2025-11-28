//
//  MNShapeToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Mask弹窗

import UIKit

/// 圆形旋转Toast样式构建者
public class MNShapeToast {
    
    /// 线条样式
    public enum Style {
        /// 纯色线条
        case line
        /// 渐变颜色线条
        case gradient
    }
    
    /// 进度弹框样式
    public let style: MNShapeToast.Style
    
    /// 构造圆形旋转Toast弹窗
    /// - Parameter style: 样式
    public init(style: MNShapeToast.Style) {
        self.style = style
    }
    
    lazy var activityLayer: CALayer = {
        
        let lineWidth: CGFloat = 2.2
        let borderSize: CGSize = .init(width: 40.0, height: 40.0)
        
        let path = UIBezierPath(arcCenter: CGPoint(x: borderSize.width/2.0, y: borderSize.height/2.0), radius: (borderSize.width - lineWidth)/2.0, startAngle: -.pi/2.0, endAngle: .pi/2.0*3.0, clockwise: true)
        let activityLayer = CAShapeLayer()
        activityLayer.frame = .init(origin: .zero, size: borderSize)
        activityLayer.path = path.cgPath
        activityLayer.fillColor = UIColor.clear.cgColor
        activityLayer.strokeColor = MNToast.Configuration.shared.color.withAlphaComponent(0.85).cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.lineCap = .round
        activityLayer.lineJoin = .round
        
        switch style {
        case .line:
            activityLayer.strokeStart = 0.09
            activityLayer.strokeEnd = 0.91
        case .gradient:
            let mask = CALayer()
            mask.frame = activityLayer.bounds
            mask.contentsScale = UIScreen.main.scale
            mask.contents = ToastResource.image(named: effectForToast == .dark ? "mask-light" : "mask-dark")?.cgImage
            activityLayer.mask = mask
            activityLayer.strokeEnd = 1.0
        }
        
        return activityLayer
    }()
}
    
extension MNShapeToast: MNToastBuilder {
    
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
        
        let activityView = UIView(frame: CGRect(origin: .zero, size: activityLayer.frame.size))
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
        return [.font:MNToast.Configuration.shared.font, .foregroundColor:MNToast.Configuration.shared.color, .paragraphStyle:paragraph]
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

extension MNShapeToast: MNToastAnimationHandler {
    
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
