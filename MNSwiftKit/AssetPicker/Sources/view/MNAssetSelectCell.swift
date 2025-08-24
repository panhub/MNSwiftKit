//
//  MNAssetSelectCell.swift
//  MNKit
//
//  Created by 冯盼 on 2022/2/4.
//  资源预览-选择表格

import UIKit

/// 资源预览-选择表格
class MNAssetSelectCell: UICollectionViewCell {
    /// 边框
    let borderView: UIView = UIView()
    /// 显示截图
    private let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)
        
        borderView.frame = contentView.bounds
        borderView.clipsToBounds = true
        borderView.layer.borderWidth = 3.0
        borderView.backgroundColor = .clear
        borderView.isUserInteractionEnabled = false
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(borderView)
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
