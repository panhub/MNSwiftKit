//
//  MNProgressToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  进度Toast

import UIKit

/// 进度Toast构建者
public class MNProgressToast {
    
    /// 进度条样式
    public enum Style {
        /// 填充至100%
        case fill
        /// 线条至100%
        case line
    }
    
    /// 进度弹框样式
    public let style: MNProgressToast.Style
    
    /// 构造进度Toast弹窗
    /// - Parameter style: 样式
    public init(style: MNProgressToast.Style) {
        self.style = style
    }
    
    lazy var activityLayer: CAShapeLayer = {
        
        let borderSize: CGSize = .init(width: 40.0, height: 40.0)
        let lineWidth: CGFloat = style == .line ? 2.2 : borderSize.width/2.0
        
        let path = UIBezierPath(arcCenter: .init(x: borderSize.width/2.0, y: borderSize.height/2.0), radius: (borderSize.width - lineWidth)/2.0, startAngle: -.pi/2.0, endAngle: .pi/2.0*3.0, clockwise: true)
        
        let activityLayer = CAShapeLayer()
        activityLayer.frame = .init(origin: .zero, size: borderSize)
        activityLayer.path = path.cgPath
        activityLayer.fillColor = UIColor.clear.cgColor
        activityLayer.lineWidth = lineWidth
        activityLayer.strokeEnd = 0.0
        if style == .line {
            activityLayer.lineCap = .round
            activityLayer.lineJoin = .round
            activityLayer.strokeColor = MNToast.Configuration.shared.color.cgColor
        } else {
            activityLayer.strokeColor = MNToast.Configuration.shared.color.withAlphaComponent(0.8).cgColor
        }
        
        return activityLayer
    }()
}

extension MNProgressToast: MNToastBuilder {
    
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
        
        let lineWidth: CGFloat = 2.2
        let borderSize: CGSize = activityLayer.frame.size
        
        let path = UIBezierPath(arcCenter: .init(x: borderSize.width/2.0, y: borderSize.height/2.0), radius: (borderSize.width - lineWidth)/2.0, startAngle: 0.0, endAngle: .pi*2.0, clockwise: true)
        
        let trackLayer = CAShapeLayer()
        trackLayer.frame = .init(origin: .zero, size: borderSize)
        trackLayer.path = path.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = activityLayer.strokeColor?.copy(alpha: 0.05)
        trackLayer.lineWidth = lineWidth
        trackLayer.strokeEnd = 1.0
        
        let activityView = UIView(frame: CGRect(origin: .zero, size: borderSize))
        activityView.layer.addSublayer(trackLayer)
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
    
    public var allowUserInteractionWhenDisplayed: Bool {
        
        MNToast.Configuration.shared.allowUserInteractionWhenDisplayed
    }
}

extension MNProgressToast: MNToastProgressUpdater {
    
    public func toastProgressDidUpdate(_ value: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        activityLayer.strokeEnd = max(0.0, min(value, 1.0))
        CATransaction.commit()
    }
}
