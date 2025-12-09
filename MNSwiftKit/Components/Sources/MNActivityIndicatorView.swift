//
//  MNActivityIndicatorView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/7/25.
//  活动指示图

import UIKit
import Foundation
import QuartzCore
import CoreGraphics

/// 指示器样式
@objc public enum MNActivityIndicatorStyle: Int {
    /// 暗色
    case dark
    /// 亮色
    case light
}

/// 活动指示图
public class MNActivityIndicatorView: UIView {
    /// 指示器样式
    @objc public var style: MNActivityIndicatorStyle = .dark
    /// 线条宽度
    @objc public var lineWidth: CGFloat = 1.0
    /// 颜色
    @objc public var color: UIColor = .black
    /// 动画时长
    @objc public var duration: TimeInterval = 0.75
    /// 放置 ShapeLayer
    private let contentView: UIView = UIView()
    /// 显示指示图
    private let indicator: CAShapeLayer = CAShapeLayer()
    /// 设置内部旋转角度
    @objc public var rotationAngle: CGFloat {
        get { 0.0 }
        set { contentView.transform = CGAffineTransform(rotationAngle: newValue) }
    }
    private var _hidesWhenStopped: Bool = false
    /// 是否停止动画时隐藏指示图
    @objc public var hidesWhenStopped: Bool {
        get { _hidesWhenStopped }
        set {
            _hidesWhenStopped = newValue
            if newValue {
                indicator.isHidden = isAnimating == false
            } else {
                indicator.isHidden = false
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
//        ])
    }
    
    /// 构造活动指示器
    /// - Parameter style: 指示器样式
    convenience init(style: MNActivityIndicatorStyle) {
        self.init(frame: .init(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        self.style = style
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if let _ = newSuperview {
            /// 制作指示图
            updateIndicatorLayer()
        }
        super.willMove(toSuperview: newSuperview)
    }
    
    /// 更新指示图层
    @objc public func updateIndicatorLayer() {
        
        contentView.transform = .identity
        contentView.autoresizingMask = []
        
        startAnimating()
        indicator.mask = nil
        indicator.removeAllAnimations()
        indicator.removeFromSuperlayer()
        
        let lineWidth: CGFloat = max(self.lineWidth, 1.0)
        let sideWidth: CGFloat = min(bounds.width, bounds.height)
        
        contentView.frame = CGRect(x: (bounds.width - sideWidth)/2.0, y: (bounds.height - sideWidth)/2.0, width: sideWidth, height: sideWidth)
        
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: sideWidth/2.0, y: sideWidth/2.0), radius: (sideWidth - lineWidth)/2.0, startAngle: 0.0, endAngle: .pi*2.0, clockwise: true)
        
        indicator.frame = contentView.bounds
        indicator.contentsScale = UIScreen.main.scale
        indicator.fillColor = UIColor.clear.cgColor
        indicator.strokeColor = color.cgColor
        indicator.lineWidth = lineWidth
        indicator.lineCap = .round
        indicator.lineJoin = .round
        indicator.path = bezierPath.cgPath
        indicator.strokeEnd = 1.0
        
        let mask = CALayer()
        mask.frame = indicator.bounds
        mask.contentsScale = UIScreen.main.scale
        mask.contents = ComponentResource.image(named: style == .dark ? "activity_dark" : "activity_light")?.cgImage
        indicator.mask = mask
        
        contentView.layer.addSublayer(indicator)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = duration
        animation.fromValue = 0.0
        animation.toValue = Double.pi*2.0
        animation.autoreverses = false
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.beginTime = CACurrentMediaTime()
        animation.timingFunction = CAMediaTimingFunction(name: .linear)

        indicator.add(animation, forKey: "com.mn.indicator.animation")
        
        stopAnimating()
    }
}

// MARK: - 暂停/继续动画
public extension MNActivityIndicatorView {
    
    /// 是否在动画
    @objc var isAnimating: Bool {
        indicator.speed == 1.0
    }
    
    /// 开始动画
    @objc func startAnimating() {
        indicator.isHidden = false
        guard indicator.speed == 0.0 else { return }
        let pauseTime = indicator.timeOffset
        indicator.speed = 1.0
        indicator.timeOffset = 0.0
        indicator.beginTime = 0.0
        let timeSincePause = indicator.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        indicator.beginTime = timeSincePause
    }
    
    /// 停止动画
    @objc func stopAnimating() {
        indicator.isHidden = hidesWhenStopped
        guard indicator.speed == 1.0 else { return }
        let pauseTime = indicator.convertTime(CACurrentMediaTime(), from: nil)
        indicator.speed = 0.0
        indicator.timeOffset = pauseTime
    }
}
