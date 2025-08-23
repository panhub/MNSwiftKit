//
//  MNSuccessToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  完成弹窗

import UIKit

public class MNSuccessToast: NSObject, MNToastBuilder {
    
    /// 动画层
    private let activityLayer = CAShapeLayer()
    
    /// 指示图
    public lazy var activityView: UIView = {
        
        let activityView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 55.0, height: 31.0)))
        
        let lineWidth: CGFloat = 2.5
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineWidth/2.0, y: lineWidth/2.0))
        path.addLine(to: CGPoint(x: activityView.bounds.midX, y: activityView.bounds.height - lineWidth/2.0))
        path.addLine(to: CGPoint(x: activityView.bounds.width - lineWidth/2.0, y: lineWidth/2.0))
        
        activityLayer.frame = activityView.bounds
        activityLayer.contentsScale = UIScreen.main.scale
        activityLayer.fillColor = UIColor.clear.cgColor
        activityLayer.strokeColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.lineCap = .round
        activityLayer.lineJoin = .round
        activityLayer.path = path.cgPath
        activityLayer.strokeStart = 0.2
        activityLayer.strokeEnd = 0.2
        activityView.layer.addSublayer(activityLayer)
        
        activityLayer.frame = activityView.bounds
        activityLayer.contentsScale = UIScreen.main.scale
        activityLayer.fillColor = UIColor.clear.cgColor
        activityLayer.strokeColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.lineCap = .round
        activityLayer.lineJoin = .round
        activityLayer.path = path.cgPath
        activityLayer.strokeEnd = 0.0
        activityView.layer.addSublayer(activityLayer)
        
        return activityView
    }()
    
    public func contentColorForToast() -> ToastColor {
        .dark
    }
    
    public func positionForToast() -> ToastPosition {
        .center
    }
    
    public func contentInsetForToast() -> UIEdgeInsets {
        UIEdgeInsets(top: 13.0, left: 13.0, bottom: 12.0, right: 13.0)
    }
    
    public func spacingForToast() -> CGFloat {
        8.0
    }
    
    public func activityViewForToast() -> UIView? {
        activityView
    }
    
    public func animationForToastDismiss() -> ToastAnimation {
        .fade
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
    
    public func toastDidAppear(_ toast: MNToast) {
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.duration = 0.5
        animation.toValue = 1.0
        //这两个属性设定保证在动画执行之后不自动还原
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        activityLayer.add(animation, forKey: nil)
        toast.perform(#selector(toast.close), with: nil, afterDelay: MNToast.duration(with: toast.text))
    }
    
    public func toastDidDisappear(_ toast: MNToast) {
        MNToast.cancelPreviousPerformRequests(withTarget: toast)
    }
}
