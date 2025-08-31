//
//  MNEmoticonElementView.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/29.
//  表情键盘的'Delete/Return'键

import UIKit

class MNEmoticonElementView: UIView {
    /// Return键
    private let returnButton: MNEmoticonButton = MNEmoticonButton()
    /// Delete键
    private let deleteButton: MNEmoticonButton = MNEmoticonButton()
    
    /// 依据键盘配置构造入口
    /// - Parameter options: 键盘配置
    init(options: MNEmoticonKeyboard.Options) {
        super.init(frame: .zero)
        
        if let image = EmoticonResource.image(named: "delete-ver") {
            let height: CGFloat = 20.0
            let width: CGFloat = ceil(image.size.width/image.size.height*height)
            deleteButton.image = image
            deleteButton.imageMode = .scaleAspectFit
            // TODO
            //deleteButton.imageInset = UIEdgeInsets(top: (deleteButton.frame.height - height)/2.0, left: (deleteButton.frame.width - width)/2.0, bottom: (deleteButton.frame.height - height)/2.0, right: (deleteButton.frame.width - width)/2.0)
        }
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 6.0
        deleteButton.backgroundColor = .white
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.leftAnchor.constraint(equalTo: leftAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            deleteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -4.0)
        ])
        
        returnButton.text = options.returnKeyType.preferredTitle
        returnButton.textFont = options.returnKeyTitleFont
        returnButton.textColor = options.returnKeyTitleColor
        returnButton.backgroundColor = options.returnKeyColor
        returnButton.clipsToBounds = true
        returnButton.layer.cornerRadius = 6.0
        returnButton.backgroundColor = .white
        returnButton.textInset = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(returnButton)
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: deleteButton.topAnchor),
            returnButton.leftAnchor.constraint(equalTo: deleteButton.rightAnchor, constant: 4.0),
            returnButton.bottomAnchor.constraint(equalTo: deleteButton.bottomAnchor),
            returnButton.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(_ target: Any, forReturnButtonTouchUpInside action: Selector) {
        returnButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func addTarget(_ target: Any, forDeleteButtonTouchUpInside action: Selector) {
        deleteButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
