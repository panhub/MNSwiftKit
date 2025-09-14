//
//  MNEmoticonPreview.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/2/6.
//  表情预览视图

import UIKit

class MNEmoticonPreview: UIView {
    /// 描述
    private let descLabel = UILabel()
    /// Unicode表情
    private let emotionLabel = UILabel()
    /// 图片表情
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 57.0, height: 135.0))
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 7.0),
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12.0),
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12.0),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0)
        ])
        
        emotionLabel.numberOfLines = 1
        emotionLabel.textAlignment = .center
        emotionLabel.minimumScaleFactor = 0.1
        emotionLabel.adjustsFontSizeToFitWidth = true
        emotionLabel.font = .systemFont(ofSize: 33.0)
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emotionLabel)
        NSLayoutConstraint.activate([
            emotionLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            emotionLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor),
            emotionLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            emotionLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor)
        ])
        
        descLabel.numberOfLines = 1
        descLabel.textAlignment = .center
        descLabel.minimumScaleFactor = 0.1
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.font = .systemFont(ofSize: 13.0)
        descLabel.textColor = .darkText.withAlphaComponent(0.3)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descLabel)
        NSLayoutConstraint.activate([
            descLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3.0),
            descLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 2.0),
            descLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -2.0),
            descLabel.heightAnchor.constraint(equalToConstant: 13.0)
        ])
        
        let radius1: CGFloat = 5.0
        let radius2: CGFloat = 12.0
        let descMaxY: CGFloat = 56.0
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.0, y: radius1))
        bezierPath.addArc(withCenter: CGPoint(x: radius1, y: radius1), radius: radius1, startAngle: .pi, endAngle: .pi + .pi/2.0, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: self.frame.width - radius1, y: 0.0))
        bezierPath.addArc(withCenter: CGPoint(x: self.frame.width - radius1, y: radius1), radius: radius1, startAngle: .pi + .pi/2.0, endAngle: .pi + .pi, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: self.frame.width, y: descMaxY + 3.0))
        bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width - radius2, y: descMaxY + 5.0 + radius2*2.0), controlPoint: CGPoint(x: self.frame.width - radius2, y: descMaxY + 5.0 + radius2*2.0 - 10.0))
        bezierPath.addLine(to: CGPoint(x: self.frame.width - radius2, y: self.frame.height - radius1))
        bezierPath.addArc(withCenter: CGPoint(x: self.frame.width - radius2 - radius1, y: self.frame.height - radius1), radius: radius1, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: radius1 + radius2, y: self.frame.height))
        bezierPath.addArc(withCenter: CGPoint(x: radius1 + radius2, y: self.frame.height - radius1), radius: radius1, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: radius2, y: descMaxY + 5.0 + radius2*2.0))
        bezierPath.addQuadCurve(to: CGPoint(x: 0.0, y: descMaxY + 3.0), controlPoint: CGPoint(x: radius2, y: descMaxY + 5.0 + radius2*2.0 - 10.0))
        bezierPath.close()
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = bezierPath.cgPath
        borderLayer.fillColor = UIColor.white.cgColor
        borderLayer.strokeColor = UIColor.gray.withAlphaComponent(0.17).cgColor
        borderLayer.lineWidth = 1.0
        borderLayer.lineJoin = .round
        borderLayer.lineCap = .round
        layer.insertSublayer(borderLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新表情
    /// - Parameter emoticon: 表情
    func updateEmoticon(_ emoticon: MNEmoticon) {
        emotionLabel.text = emoticon.style == .unicode ? emoticon.img : nil
        imageView.image = emoticon.style == .unicode ? nil : emoticon.image
        imageView.isHidden = emoticon.style == .unicode
        emotionLabel.isHidden = imageView.isHidden == false
        descLabel.text = emoticon.desc.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
    }
}
