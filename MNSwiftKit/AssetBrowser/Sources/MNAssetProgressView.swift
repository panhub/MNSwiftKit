//
//  MNAssetProgressView.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/9.
//  进度显示

import UIKit

/// 资源加载进度视图
class MNAssetProgressView: UIView {
    
    /// 当前进度
    private var progress: CGFloat = 0.0
    
    /// 进度展示层
    private let progressLayer = CAShapeLayer()
    
    /// 构造进度视图
    /// - Parameter frame: 位置
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        backgroundColor = .black.withAlphaComponent(0.15)
        isUserInteractionEnabled = false
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = layer.borderColor
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = min(frame.width, frame.height)/2.0
        guard cornerRadius > layer.borderWidth else { return }
        layer.cornerRadius = cornerRadius
        
        let diameter: CGFloat = cornerRadius - layer.borderWidth
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: diameter/2.0, startAngle: -.pi/2.0, endAngle: .pi/2.0 + .pi, clockwise: true)
        progressLayer.path = bezierPath.cgPath
        progressLayer.lineWidth = diameter
        progressLayer.strokeEnd = progress
    }
}

// MARK: - 修改进度
extension MNAssetProgressView {
    
    /// 设置进度
    /// - Parameters:
    ///   - value: 进度值
    ///   - animated: 是否动态展示
    func setProgress(_ value: any BinaryFloatingPoint, animated: Bool = false) {
        progress = CGFloat(value)
        CATransaction.begin()
        CATransaction.setDisableActions(animated == false)
        progressLayer.strokeEnd = progress
        CATransaction.commit()
    }
}
