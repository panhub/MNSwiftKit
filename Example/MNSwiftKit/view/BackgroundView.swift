//
//  BackgroundView.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/14.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

@IBDesignable class BackgroundView: UIView {
    
    fileprivate let backgroundView = LineBackground()
    
    /// Line width
    @IBInspectable var lineWidth: CGFloat {
        get { backgroundView.lineWidth }
        set {
            backgroundView.lineWidth = newValue
            backgroundView.setNeedsDisplay()
        }
    }
    
    /// Line gap
    @IBInspectable var lineGap : CGFloat {
        get { backgroundView.lineGap }
        set {
            backgroundView.lineGap = newValue
            backgroundView.setNeedsDisplay()
        }
    }
    
    /// Line color
    @IBInspectable var lineColor : UIColor {
        get { backgroundView.lineColor }
        set {
            backgroundView.lineColor = newValue
            backgroundView.setNeedsDisplay()
        }
    }
    
    /// Rotate value, default is 0.
    @IBInspectable var rotate: CGFloat {
        get { backgroundView.rotate }
        set {
            backgroundView.rotate = newValue
            backgroundView.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        clipsToBounds = true
        backgroundColor = .white
        
        backgroundView.lineWidth = 4.0
        backgroundView.lineGap = 4.0
        backgroundView.rotate = .pi/4.0
        backgroundView.lineColor = .black.withAlphaComponent(0.025)
        addSubview(backgroundView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let drawLength = sqrt(bounds.width*bounds.width + bounds.height*bounds.height)
        backgroundView.frame  = CGRect(x: 0, y: 0, width: drawLength, height: drawLength)
        backgroundView.center = CGPoint(x: bounds.midX, y: bounds.minY)
        backgroundView.setNeedsDisplay()
    }
}

private class LineBackground : UIView {

    fileprivate var rotate: CGFloat = 0.0
    fileprivate var lineWidth: CGFloat = 5.0
    fileprivate var lineGap: CGFloat = 3.0
    fileprivate var lineColor: UIColor = .gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        guard bounds.isNull == false, bounds.isEmpty == false else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = bounds.width
        let height = bounds.height
        let drawLength = sqrt(width*width + height*height)
        let outerX = (drawLength - width)/2.0
        let outerY = (drawLength - height)/2.0
        
        context.translateBy(x: 0.5*drawLength, y: 0.5*drawLength)
        context.rotate(by: .pi/4.0)
        context.translateBy(x: -0.5*drawLength, y: -0.5*drawLength)
        
        context.setFillColor(lineColor.cgColor)
        
        var currentX = -outerX
        
        while currentX < drawLength {
            
            context.addRect(CGRect(x: currentX, y: -outerY, width: lineWidth, height: drawLength))
            currentX += lineWidth + lineGap
        }
        
        context.fillPath()
    }
}
