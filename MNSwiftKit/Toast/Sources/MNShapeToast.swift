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
        /// 线条
        case line
        /// 遮罩
        case mask
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
        activityLayer.strokeColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.lineCap = .round
        activityLayer.lineJoin = .round
        
        switch style {
        case .line:
            activityLayer.strokeEnd = 0.82
        case .mask:
            let mask = CALayer()
            mask.frame = activityLayer.bounds
            mask.contentsScale = UIScreen.main.scale
            mask.contents = ToastResource.image(named: "mask-light")?.cgImage
            activityLayer.mask = mask
            activityLayer.strokeEnd = 1.0
        }
        
        return activityLayer
    }()
}
    
extension MNShapeToast: MNToastBuilder {
    
    public var axisForToast: MNToast.Axis {
        
        .vertical(spacing: 7.0)
    }
    
    public var effectForToast: MNToast.Effect {
        
        .dark
    }
    
    public var positionForToast: MNToast.Position {
        
        .center
    }
    
    public var contentInsetForToast: UIEdgeInsets {
        
        .init(top: 12.0, left: 12.0, bottom: 11.0, right: 12.0)
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
        return [.font:UIFont.systemFont(ofSize: 15.0, weight: .regular), .paragraphStyle:paragraph, .foregroundColor:UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
    }
    
    public var fadeInForToast: Bool {
        
        true
    }
    
    public var fadeOutForToast: Bool {
        
        true
    }
    
    public var allowUserInteractionWhenDisplayed: Bool {
        
        true
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
