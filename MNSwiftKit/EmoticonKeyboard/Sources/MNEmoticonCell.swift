//
//  MNEmoticonCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情Cell

import UIKit

class MNEmoticonCell: UICollectionViewCell {
    /// Unicode表情
    let emotionLabel = UILabel()
    /// 表情控件
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        emotionLabel.numberOfLines = 1
        emotionLabel.textAlignment = .center
        emotionLabel.minimumScaleFactor = 0.1
        emotionLabel.adjustsFontSizeToFitWidth = true
        emotionLabel.font = .systemFont(ofSize: contentView.frame.width)
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emotionLabel)
        NSLayoutConstraint.activate([
            emotionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emotionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            emotionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emotionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新表情
    /// - Parameter emoticon: 表情模型
    func updateEmoticon(_ emoticon: MNEmoticon) {
        emotionLabel.text = emoticon.style == .unicode ? emoticon.img : nil
        imageView.image = emoticon.style == .unicode ? nil : emoticon.image
        imageView.isHidden = emoticon.style == .unicode
        emotionLabel.isHidden = imageView.isHidden == false
    }
}
