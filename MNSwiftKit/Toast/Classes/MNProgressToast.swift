//
//  MNProgressToast.swift
//  MNKit
//
//  Created by 冯盼 on 2021/9/10.
//  进度弹窗

import UIKit

public class MNProgressToast: NSObject, MNToastBuilder {
    
    private let percent: UILabel = UILabel()
    
    private let shape: CAShapeLayer = CAShapeLayer()
    
    private let complete: CAShapeLayer = CAShapeLayer()
    
    public lazy var activityView: UIView = {
        
        let activityView = UIView(frame: CGRect(origin: .zero, size: .init(width: 46.0, height: 46.0)))
        
        percent.frame = activityView.bounds
        percent.text = "0%"
        percent.numberOfLines = 1
        percent.textAlignment = .center
        percent.textColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        percent.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        activityView.addSubview(percent)
        
        let lineWidth: CGFloat = 2.0
        var path = UIBezierPath(arcCenter: CGPoint(x: activityView.bounds.width/2.0, y: activityView.bounds.height/2.0), radius: (activityView.bounds.width - lineWidth)/2.0, startAngle: -.pi/2.0, endAngle: .pi + .pi/2.0, clockwise: true)
        shape.frame = activityView.bounds
        shape.contentsScale = UIScreen.main.scale
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        shape.lineWidth = lineWidth
        shape.lineCap = .round
        shape.lineJoin = .round
        shape.path = path.cgPath
        shape.strokeEnd = 0.0
        activityView.layer.addSublayer(shape)
        
        let rect = activityView.bounds.inset(by: UIEdgeInsets(top: 12.0, left: 5.0, bottom: 12.0, right: 5.0))
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX + lineWidth/2.0, y: rect.minY + lineWidth/2.0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - lineWidth/2.0))
        path.addLine(to: CGPoint(x: rect.maxX - lineWidth/2.0, y: rect.minY + lineWidth/2.0))
        
        complete.frame = activityView.bounds
        complete.contentsScale = UIScreen.main.scale
        complete.fillColor = UIColor.clear.cgColor
        complete.strokeColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        complete.lineWidth = lineWidth
        complete.lineCap = .round
        complete.lineJoin = .round
        complete.path = path.cgPath
        complete.strokeStart = 0.17
        complete.strokeEnd = 0.17
        complete.isHidden = true
        activityView.layer.addSublayer(complete)
        
        return activityView
    }()
    
    
    public func contentColorForToast() -> ToastColor {
        .dark
    }
    
    public func positionForToast() -> ToastPosition {
        .center
    }
    
    public func contentInsetForToast() -> UIEdgeInsets {
        UIEdgeInsets(top: 13.0, left: 13.0, bottom: 13.0, right: 13.0)
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
    
    public func supportedUserInteraction() -> Bool {
        true
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
    
    public func toast(_ toast: MNToast, update progress: Double) {
        guard complete.isHidden else { return }
        let strokeEnd: Double = min(1.0, max(0.0, progress))
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shape.strokeEnd = strokeEnd
        CATransaction.commit()
        let behavior: NSDecimalNumberHandler = NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let result: NSDecimalNumber = NSDecimalNumber(value: strokeEnd).multiplying(by: NSDecimalNumber(value: 100.0), withBehavior: behavior)
        let value: Int = result.intValue
        percent.text = "\(value)%"
        guard value >= 100 else { return }
        complete.isHidden = false
        perform(#selector(success(_:)), with: toast, afterDelay: 0.5)
    }
    
    @objc private func success(_ toast: MNToast) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.percent.alpha = 0.0
        }
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.duration = 0.5
        animation.toValue = 0.95
        //这两个属性设定保证在动画执行之后不自动还原
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        complete.add(animation, forKey: nil)
        toast.perform(#selector(toast.close), with: nil, afterDelay: 1.2)
    }
    
    public func toastDidDisappear(_ toast: MNToast) {
        MNToast.cancelPreviousPerformRequests(withTarget: toast)
        MNProgressToast.cancelPreviousPerformRequests(withTarget: self)
    }
}
