//
//  MNStateView.swift
//  MNKit
//
//  Created by 冯盼 on 2022/2/7.
//  媒体资源缩略图-状态视图

import UIKit

class MNStateView: UIImageView {
    
    enum StateResizing: Int {
        case normal
        case highlighted
        case selected
    }
    
    private let imageView = UIImageView(frame: .zero)
    
    private var configuration: [StateResizing : UIImage] = [StateResizing : UIImage]()
    
    var state: StateResizing = .normal {
        didSet {
            image = configuration[state]
        }
    }
    
    func setImage(_ image: UIImage?, for state: StateResizing) {
        if let image = image {
            configuration[state] = image
        } else {
            configuration.removeValue(forKey: state)
        }
        self.image = configuration[self.state]
    }
}
