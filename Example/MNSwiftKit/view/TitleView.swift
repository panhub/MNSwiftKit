//
//  TitleView.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

@IBDesignable class TitleView: UIView {
    
    private let backgroundLabel = UILabel()
    
    private let foregroundLabel = UILabel()
    
    /// 文本颜色
    @IBInspectable var backgroundTextColor: UIColor = UIColor(mn_hex: 0x545454) {
        didSet {
            updateBackgroundText()
        }
    }
    
    /// 前置颜色（高亮色）
    @IBInspectable var foregroundTextColor: UIColor = UIColor(mn_hex: 0x4699D9) {
        didSet {
            updateForegroundText()
        }
    }
    
    /// 文本内容
    @IBInspectable var text: String = "MNSwiftKit" {
        didSet {
            updateBackgroundText()
            updateForegroundText()
        }
    }
    
    /// 高亮文字
    @IBInspectable var highlightText: String = "w" {
        didSet {
            updateBackgroundText()
            updateForegroundText()
        }
    }
    
    /// 字体
    var font: UIFont = UIFont(name: "Avenir-Light", size: 28.0)! {
        didSet {
            updateBackgroundText()
            updateForegroundText()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        
        backgroundLabel.numberOfLines = 1
        backgroundLabel.textAlignment = .center
        backgroundLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundLabel)
        NSLayoutConstraint.activate([
            backgroundLabel.topAnchor.constraint(equalTo: topAnchor),
            backgroundLabel.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundLabel.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        updateBackgroundText()
        
        foregroundLabel.numberOfLines = 1
        foregroundLabel.textAlignment = .center
        foregroundLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(foregroundLabel)
        NSLayoutConstraint.activate([
            foregroundLabel.topAnchor.constraint(equalTo: topAnchor),
            foregroundLabel.leftAnchor.constraint(equalTo: leftAnchor),
            foregroundLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            foregroundLabel.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        updateForegroundText()
    }
    
    private func updateBackgroundText() {
        let attributedText = NSMutableAttributedString(string: text, attributes: [.font:font, .foregroundColor:backgroundTextColor])
        let range = (text as NSString).range(of: highlightText)
        if range.location != NSNotFound {
            attributedText.addAttribute(.foregroundColor, value: UIColor.clear, range: range)
        }
        backgroundLabel.attributedText = attributedText
    }
    
    private func updateForegroundText() {
        let attributedText = NSMutableAttributedString(string: text, attributes: [.font:font, .foregroundColor:UIColor.clear])
        let range = (text as NSString).range(of: highlightText)
        if range.location != NSNotFound {
            attributedText.addAttribute(.foregroundColor, value: foregroundTextColor, range: range)
        }
        foregroundLabel.attributedText = attributedText
    }
}
