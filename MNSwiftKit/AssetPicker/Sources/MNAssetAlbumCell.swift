//
//  MNAssetAlbumCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/1/31.
//  资源选择器相册表格

import UIKit
import Photos

/// 资源选择器相册表格
class MNAssetAlbumCell: UITableViewCell {
    /// 相簿模型
    private(set) var album: MNAssetAlbum!
    /// 标题
    private let nameLabel: UILabel = UILabel()
    /// 数量
    private let countLabel: UILabel = UILabel()
    /// 封面
    private let coverView: UIImageView = UIImageView()
    /// 数量
    private let selectedView: UIImageView = UIImageView()
    
    /// 构造相册表格
    /// - Parameters:
    ///   - reuseIdentifier: 重用标识
    ///   - options: 选择器配置模型
    init(reuseIdentifier: String?, options: MNAssetPickerOptions) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        
        // 封面
        coverView.clipsToBounds = true
        coverView.isUserInteractionEnabled = false
        coverView.contentMode = .scaleAspectFill
        coverView.backgroundColor = UIColor(white: 0.0, alpha: 0.12)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(coverView)
        contentView.addConstraints([
            NSLayoutConstraint(item: coverView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: coverView, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: -20.0),
            NSLayoutConstraint(item: coverView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        coverView.addConstraint(NSLayoutConstraint(item: coverView, attribute: .width, relatedBy: .equal, toItem: coverView, attribute: .height, multiplier: 1.0, constant: 0.0))
        
        // 标题
        nameLabel.numberOfLines = 1
        nameLabel.isUserInteractionEnabled = false
        nameLabel.font = .systemFont(ofSize: 17.0, weight: .regular)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = options.mode == .light ? .darkText.withAlphaComponent(0.91) : .white.withAlphaComponent(0.86)
        //UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        contentView.addSubview(nameLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: nameLabel, attribute: .left, relatedBy: .equal, toItem: coverView, attribute: .right, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: nameLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        // 数量
        countLabel.numberOfLines = 1
        countLabel.isUserInteractionEnabled = false
        countLabel.font = .systemFont(ofSize: 15.0, weight: .regular)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.textColor = nameLabel.textColor//UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        contentView.addSubview(countLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: countLabel, attribute: .left, relatedBy: .equal, toItem: nameLabel, attribute: .right, multiplier: 1.0, constant: 5.0),
            NSLayoutConstraint(item: countLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        // 选择标记
        selectedView.isHidden = true
        selectedView.isUserInteractionEnabled = false
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.image = AssetPickerResource.image(named: "checkmark")?.mn.rendering(to: options.themeColor)
        contentView.addSubview(selectedView)
        selectedView.addConstraints([
            NSLayoutConstraint(item: selectedView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 23.0),
            NSLayoutConstraint(item: selectedView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 23.0)
        ])
        contentView.addConstraints([
            NSLayoutConstraint(item: selectedView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -25.0),
            NSLayoutConstraint(item: selectedView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension MNAssetAlbumCell {
    
    /// 更新相簿模型
    /// - Parameter album: 相簿模型
    func updateAlbum(_ album: MNAssetAlbum) {
        self.album = album
        let selections = album.assets.filter { $0.isSelected }
        nameLabel.text = album.name
        countLabel.text = "(\(selections.count)/\(album.count))"
        selectedView.isHidden = album.isSelected == false
        coverView.image = AssetPickerResource.image(named: "album")
        if let asset = album.assets.first {
            // 请求缩略图
            
        }
    }
}
