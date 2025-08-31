//
//  MNEmoticonPreview.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/2/6.
//  表情预览视图

import UIKit

class MNEmoticonPreview: UIView {
    /// 描述空间
    private let textLabel: UILabel = UILabel()
    /// 图片控件
    private let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 57.0, height: 135.0))
        
        imageView.frame = CGRect(x: 12.0, y: 7.0, width: 33.0, height: 33.0)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        textLabel.frame = .init(x: 0.0, y: imageView.frame.maxY + 3.0, width: 0.0, height: 13.0)
        textLabel.font = .systemFont(ofSize: 13.0)
        textLabel.textColor = .darkText.withAlphaComponent(0.3)
        textLabel.numberOfLines = 1
        textLabel.textAlignment = .center
        addSubview(textLabel)
        
        let radius: CGFloat = 5.0
        let radius2: CGFloat = imageView.frame.minX
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.0, y: radius))
        bezierPath.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: .pi, endAngle: .pi + .pi/2.0, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: self.frame.width - radius, y: 0.0))
        bezierPath.addArc(withCenter: CGPoint(x: self.frame.width - radius, y: radius), radius: radius, startAngle: .pi + .pi/2.0, endAngle: .pi + .pi, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: self.frame.width, y: textLabel.frame.maxY + 3.0))
        bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width - radius2, y: textLabel.frame.maxY + 5.0 + radius2*2.0), controlPoint: CGPoint(x: self.frame.width - radius2, y: textLabel.frame.maxY + 5.0 + radius2*2.0 - 10.0))
        bezierPath.addLine(to: CGPoint(x: self.frame.width - radius2, y: self.frame.height - radius))
        bezierPath.addArc(withCenter: CGPoint(x: self.frame.width - radius2 - radius, y: self.frame.height - radius), radius: radius, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: radius + radius2, y: self.frame.height))
        bezierPath.addArc(withCenter: CGPoint(x: radius + radius2, y: self.frame.height - radius), radius: radius, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: radius2, y: textLabel.frame.maxY + 5.0 + radius2*2.0))
        bezierPath.addQuadCurve(to: CGPoint(x: 0.0, y: textLabel.frame.maxY + 3.0), controlPoint: CGPoint(x: radius2, y: textLabel.frame.maxY + 5.0 + radius2*2.0 - 10.0))
        bezierPath.close()
        
        let mask = CAShapeLayer()
        mask.path = bezierPath.cgPath
        mask.fillColor = UIColor.white.cgColor
        mask.strokeColor = UIColor.gray.withAlphaComponent(0.17).cgColor
        mask.lineWidth = 1.0
        mask.lineJoin = .round
        mask.lineCap = .round
        layer.insertSublayer(mask, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新表情
    /// - Parameter emoticon: 表情
    func updateEmoticon(_ emoticon: MNEmoticon) {
        imageView.image = emoticon.image
        textLabel.text = emoticon.desc.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        textLabel.sizeToFit()
        var rect = textLabel.frame
        rect.origin.x = imageView.center.x - textLabel.frame.width/2.0
        textLabel.frame = rect
    }
}
