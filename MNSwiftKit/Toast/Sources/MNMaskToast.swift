//
//  MNMaskToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Mask弹窗

import UIKit

public class MNMaskToast: NSObject, MNToastBuilder {
    
    /// 画笔颜色
    public var strokeColor: UIColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    
    /// 指示图
    public lazy var activityView: UIView = {
        
        let activityView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 42.0, height: 42.0)))
        
        let lineWidth: CGFloat = 2.0
        
        let path = UIBezierPath(arcCenter: CGPoint(x: activityView.bounds.width/2.0, y: activityView.bounds.height/2.0), radius: (activityView.bounds.width - lineWidth)/2.0, startAngle: 0.0, endAngle: .pi*2.0, clockwise: true)
        let activityLayer = CAShapeLayer()
        activityLayer.frame = CGRect(origin: .zero, size: activityView.frame.size)
        activityLayer.contentsScale = UIScreen.main.scale
        activityLayer.fillColor = UIColor.clear.cgColor
        activityLayer.strokeColor = strokeColor.cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.lineCap = .round
        activityLayer.lineJoin = .round
        activityLayer.path = path.cgPath
        activityLayer.strokeEnd = 1.0
        
        let mask = CALayer()
        mask.frame = activityLayer.bounds
        mask.contentsScale = UIScreen.main.scale
        mask.contents = ToastResourceLoader.image(named: "mask")?.cgImage
        activityLayer.mask = mask
        
        activityView.layer.addSublayer(activityLayer)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 0.75
        animation.fromValue = 0.0
        animation.toValue = Double.pi*2.0
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.autoreverses = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)

        activityLayer.add(animation, forKey: "rotation")
        
        return activityView
    }()
    
    public convenience init(strokeColor: UIColor) {
        self.init()
        self.strokeColor = strokeColor
    }
    
    public func contentColorForToast() -> ToastColor {
        .dark
    }
    
    public func positionForToast() -> ToastPosition {
        .center
    }
    
    public func offsetYForToast() -> CGFloat {
        0.0
    }
    
    public func spacingForToast() -> CGFloat {
        8.0
    }
    
    public func contentInsetForToast() -> UIEdgeInsets {
        UIEdgeInsets(top: 13.0, left: 13.0, bottom: 13.0, right: 13.0)
    }
    
    public func attributesForToastDescription() -> [NSAttributedString.Key : Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:UIFont.systemFont(ofSize: 16.8, weight: .regular), .paragraphStyle:paragraph, .foregroundColor:UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
    }
    
    public func supportedUserInteraction() -> Bool {
        false
    }
    
    public func supportedAdjustsKeyboard() -> Bool {
        true
    }
    
    public func spacingForKeyboard() -> CGFloat {
        15.0
    }
    
    public func activityViewForToast() -> UIView? {
        activityView
    }
}
