//
//  MNSuccessToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  完成弹窗

import UIKit
import CoreFoundation

class MNSuccessToast {
    
    /// 对号
    lazy var activityLayer: CAShapeLayer = {
        
        let lineWidth: CGFloat = 2.2
        let borderSize: CGSize = .init(width: 50.0, height: 28.0)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineWidth/2.0, y: lineWidth/2.0))
        path.addLine(to: CGPoint(x: borderSize.width/2.0, y: borderSize.height - lineWidth/2.0))
        path.addLine(to: CGPoint(x: borderSize.width - lineWidth/2.0, y: lineWidth/2.0))
        
        let activityLayer = CAShapeLayer()
        activityLayer.frame = .init(origin: .zero, size: borderSize)
        activityLayer.path = path.cgPath
        activityLayer.fillColor = UIColor.clear.cgColor
        activityLayer.strokeColor = MNToast.Configuration.shared.color.cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.lineCap = .round
        activityLayer.lineJoin = .round
        activityLayer.strokeStart = 0.31
        activityLayer.strokeEnd = 0.31
        
        return activityLayer
    }()
}
    
extension MNSuccessToast: MNToastBuilder {
    
    var axisForToast: MNToast.Axis {
        
        MNToast.Configuration.shared.axis
    }
    
    var effectForToast: MNToast.Effect {
        
        MNToast.Configuration.shared.effect
    }
    
    var contentInsetForToast: UIEdgeInsets {
        
        MNToast.Configuration.shared.contentInset
    }
    
    var activityViewForToast: UIView? {
        
        let activityView = UIView(frame: CGRect(origin: .zero, size: activityLayer.frame.size))
        activityView.layer.addSublayer(activityLayer)
        return activityView
    }
    
    var attributesForToastStatus: [NSAttributedString.Key : Any] {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:MNToast.Configuration.shared.font, .foregroundColor:MNToast.Configuration.shared.color, .paragraphStyle:paragraph]
    }
    
    var fadeInForToast: Bool {
        
        true
    }
    
    var fadeOutForToast: Bool {
        
        true
    }
    
    var allowUserInteractionWhenDisplayed: Bool {
        
        false
    }
}

extension MNSuccessToast: MNToastAnimationHandler {
    
    func startAnimating() {
        
        if let animationKeys = activityLayer.animationKeys(), animationKeys.isEmpty == false { return }
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.fromValue = activityLayer.strokeStart
        animation.toValue = 1.0
        animation.duration = 0.55
        animation.fillMode = .forwards
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        activityLayer.add(animation, forKey: "com.mn.toast.animation.rotation")
    }
    
    func stopAnimating() {
        
        activityLayer.removeAllAnimations()
    }
}
