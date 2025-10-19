//
//  MNAssetSelectCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/4.
//  资源预览-选择表格

import UIKit

/// 资源预览-选择表格
class MNAssetSelectCell: UICollectionViewCell {
    /// 边框
    let borderView = UIView()
    /// 显示截图
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        borderView.clipsToBounds = true
        borderView.layer.borderWidth = 3.0
        borderView.backgroundColor = .clear
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderView)
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            borderView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新资源
    /// - Parameter asset: 资源模型
    func updateAsset(_ asset: MNAsset) {
        imageView.image = asset.cover
    }
    
    /// 更新是否选中
    /// - Parameter isSelected: 是否选中
    func updateSelected(_ isSelected: Bool) {
        borderView.isHidden = isSelected == false
    }
}
