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
    
    @IBInspectable var backgroundTextColor: UIColor = UIColor(hex: 0x545454) {
        didSet {
            updateBackgroundText()
        }
    }
    
    @IBInspectable var foregroundTextColor: UIColor = UIColor(hex: 0x4699D9) {
        didSet {
            updateForegroundText()
        }
    }
    
    @IBInspectable var text: String = "MNSwiftKit" {
        didSet {
            updateBackgroundText()
            updateForegroundText()
        }
    }
    
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
        attributedText.addAttribute(.foregroundColor, value: UIColor.clear, range: (text as NSString).range(of: "w"))
        backgroundLabel.attributedText = attributedText
    }
    
    private func updateForegroundText() {
        let attributedText = NSMutableAttributedString(string: text, attributes: [.font:font, .foregroundColor:UIColor.clear])
        attributedText.addAttribute(.foregroundColor, value: foregroundTextColor, range: (text as NSString).range(of: "w"))
        foregroundLabel.attributedText = attributedText
    }
}
