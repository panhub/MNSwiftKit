//
//  MNEmoticonPacketCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情表格

import UIKit

class MNEmoticonPacketCell: UICollectionViewCell {
    /// 边界
    private let borderView = UIView()
    /// 图片控件
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        borderView.clipsToBounds = true
        borderView.layer.cornerRadius = 7.0
        borderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderView)
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            borderView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFit
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
        imageView.frame = contentView.bounds.inset(by: options.packetItemInset)
        borderView.backgroundColor = highlighted ? options.packetHighlightedColor : nil
    }
}
