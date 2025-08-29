//
//  MNEmoticonPacketCell.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情表格

import UIKit

class MNEmoticonPacketCell: UICollectionViewCell {
    /// 图片控件
    private let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 5.0
        contentView.clipsToBounds = true
        
        let wh: CGFloat = 23.0
        let hm = (contentView.frame.width - wh)/2.0
        let vm = (contentView.frame.height - wh)/2.0
        
        imageView.frame = contentView.bounds.inset(by: UIEdgeInsets(top: vm, left: hm, bottom: vm, right: hm))
        imageView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新表情包
    /// - Parameters:
    ///   - packet: 表情包
    ///   - options: 配置信息
    ///   - highlighted: 是否高亮
    func updatePacket(_ packet: MNEmoticonPacket, options: MNEmoticonKeyboardOptions, highlighted: Bool) {
        imageView.image = packet.image
        contentView.backgroundColor = highlighted ? options.highlightedColor : .clear
    }
}
