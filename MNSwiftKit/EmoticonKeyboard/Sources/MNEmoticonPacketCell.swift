//
//  MNEmoticonPacketCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情表格

import UIKit

class MNEmoticonPacketCell: UICollectionViewCell {
    /// 图片控件
    private let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.frame = contentView.bounds
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
    func updatePacket(_ packet: MNEmoticon.Packet, options: MNEmoticonKeyboard.Options, highlighted: Bool) {
        let imagePath = packet.directory.appendingPathComponent(packet.cover)
        if FileManager.default.fileExists(atPath: imagePath) {
            imageView.image = UIImage(contentsOfFile: imagePath)
        } else {
            imageView.image = EmoticonResource.image(named: packet.cover.deletingPathExtension)
        }
        imageView.backgroundColor = highlighted ? options.packetHighlightedColor : nil
        imageView.frame = contentView.bounds.inset(by: options.packetItemInset)
    }
}
