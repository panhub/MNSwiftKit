//
//  MNEmoticonCell.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情Cell

import UIKit

class MNEmoticonCell: UICollectionViewCell {
    /// 图片控件
    private let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateEmoji(_ emoji: MNEmoticon) {
        imageView.image = emoji.image
    }
}
