//
//  MNEmoticonElementView.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/29.
//  表情键盘的'Delete/Return'键

import UIKit

class MNEmoticonElementView: UIView {
    /// Return键
    private let returnButton: MNEmoticonButton = MNEmoticonButton(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    /// Delete键
    private let deleteButton: MNEmoticonButton = MNEmoticonButton(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    
    /// 依据键盘配置构造入口
    /// - Parameter options: 键盘配置
    init(options: MNEmoticonKeyboardOptions) {
        super.init(frame: .zero)
        
        if let image = MNEmoticonKeyboard.image(named: "delete-ver") {
            let height: CGFloat = 20.0
            let width: CGFloat = ceil(image.size.width/image.size.height*height)
            deleteButton.image = image
            deleteButton.imageMode = .scaleAspectFit
            deleteButton.imageInset = UIEdgeInsets(top: (deleteButton.frame.height - height)/2.0, left: (deleteButton.frame.width - width)/2.0, bottom: (deleteButton.frame.height - height)/2.0, right: (deleteButton.frame.width - width)/2.0)
        }
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 6.0
        deleteButton.backgroundColor = .white
        addSubview(deleteButton)
        
        returnButton.text = options.returnKeyType.preferredTitle
        returnButton.textFont = options.returnKeyTitleFont
        returnButton.textColor = options.returnKeyTitleColor
        returnButton.backgroundColor = options.returnKeyColor
        returnButton.clipsToBounds = true
        returnButton.layer.cornerRadius = 6.0
        returnButton.backgroundColor = .white
        returnButton.textInset = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
        addSubview(returnButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        let interval: CGFloat = 7.0
        let width: CGFloat = floor((frame.width - interval)/2.0)
        
        deleteButton.size = CGSize(width: width, height: frame.height)
        returnButton.size = CGSize(width: width, height: frame.height)
        returnButton.maxX = frame.width
    }
    
    func addTarget(_ target: Any, forReturnButtonTouchUpInside action: Selector) {
        returnButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func addTarget(_ target: Any, forDeleteButtonTouchUpInside action: Selector) {
        deleteButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
