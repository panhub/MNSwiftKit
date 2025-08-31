//
//  MNEmoticonCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情Cell

import UIKit

class MNEmoticonCell: UICollectionViewCell {
    
    /// 表情控件
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新表情
    /// - Parameter emoticon: 表情模型
    func updateEmoticon(_ emoticon: MNEmoticon) {
        imageView.image = emoticon.image
    }
}
