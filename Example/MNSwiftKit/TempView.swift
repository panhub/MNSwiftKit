//
//  TempView.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class TempView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.systemRed
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
