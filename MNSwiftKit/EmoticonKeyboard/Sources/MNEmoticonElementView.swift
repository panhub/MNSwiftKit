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
        
        clipsToBounds = true
        
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 6.0
        deleteButton.backgroundColor = .white
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.activate(image: EmoticonKeyboardResource.image(named: "emoticon_delete_ver"), height: 20.0)
        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.leftAnchor.constraint(equalTo: leftAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            deleteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -5.0)
        ])
        
        returnButton.text = options.returnKeyType.preferredTitle
        returnButton.textFont = options.returnKeyTitleFont
        returnButton.textColor = options.returnKeyTitleColor
        returnButton.backgroundColor = options.returnKeyColor
        returnButton.layer.cornerRadius = deleteButton.layer.cornerRadius
        returnButton.textInset = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 6.0)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(returnButton)
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: topAnchor),
            returnButton.leftAnchor.constraint(equalTo: deleteButton.rightAnchor, constant: 5.0),
            returnButton.bottomAnchor.constraint(equalTo: bottomAnchor),
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
