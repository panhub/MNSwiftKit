//
//  MNAssetCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/28.
//  资源列表

import UIKit

/// 资源表格代理
protocol MNAssetCellEventHandler: NSObjectProtocol {
    
    /// 预览资源回调
    /// - Parameter cell: 资源表格
    func assetCellShouldPreview(_ cell: MNAssetCell)
}

/// 资源展示表格
class MNAssetCell: UICollectionViewCell {
    /// 媒体资源模型
    private(set) var asset: MNAsset!
    /// 无效标记
    private let unableView = UIView()
    /// 选择索引
    private let indexLabel = UILabel()
    /// 文件大小
    private let fileSizeLabel = UILabel()
    /// 视频时长
    private let durationLabel = UILabel()
    /// 资源展示
    private let imageView = UIImageView(frame: .zero)
    /// 顶部阴影
    private let topMask = UIImageView(frame: .zero)
    /// 底部阴影
    private let bottomMask = UIImageView(frame: .zero)
    /// 预览按钮
    private let previewControl = UIControl(frame: .zero)
    /// 资源类型
    private let typeView = MNAssetTypeView(frame: .zero)
    /// 事件代理
    weak var delegate: MNAssetCellEventHandler?
    /// 配置信息
    var options: MNAssetPickerOptions! {
        didSet {
            if let options = options {
                indexLabel.backgroundColor = options.themeColor.withAlphaComponent(0.58)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        
        // 缩略图显示
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // 顶部阴影
        topMask.contentMode = .scaleToFill
        topMask.isUserInteractionEnabled = false
        topMask.translatesAutoresizingMaskIntoConstraints = false
        topMask.image = AssetPickerResource.image(named: "top_shadow")
        contentView.addSubview(topMask)
        NSLayoutConstraint.activate([
            topMask.heightAnchor.constraint(equalToConstant: 30.0),
            topMask.topAnchor.constraint(equalTo: contentView.topAnchor),
            topMask.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            topMask.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // 预览
        previewControl.translatesAutoresizingMaskIntoConstraints = false
        previewControl.addTarget(self, action: #selector(preview), for: .touchUpInside)
        contentView.addSubview(previewControl)
        NSLayoutConstraint.activate([
            previewControl.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewControl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            previewControl.widthAnchor.constraint(equalToConstant: 25.0),
            previewControl.heightAnchor.constraint(equalToConstant: 25.0)
        ])
        
        let previewImageView = UIImageView()
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.image = AssetPickerResource.image(named: "preview")?.mn.rendering(to: .white.withAlphaComponent(0.85))
        previewControl.addSubview(previewImageView)
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: previewControl.topAnchor, constant: 8.0),
            previewImageView.rightAnchor.constraint(equalTo: previewControl.rightAnchor, constant: -6.0),
            previewImageView.heightAnchor.constraint(equalToConstant: 13.0),
            previewImageView.widthAnchor.constraint(equalTo: previewImageView.heightAnchor, multiplier: 180.0/121.0)
        ])
        
        // 底部阴影
        bottomMask.image = AssetPickerResource.image(named: "bottom_shadow")
        bottomMask.contentMode = .scaleToFill
        bottomMask.backgroundColor = .clear
        bottomMask.isUserInteractionEnabled = false
        bottomMask.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomMask)
        NSLayoutConstraint.activate([
            bottomMask.heightAnchor.constraint(equalToConstant: 30.0),
            bottomMask.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bottomMask.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomMask.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // 资源类型
        typeView.contentMode = .scaleAspectFit
        typeView.translatesAutoresizingMaskIntoConstraints = false
        typeView.setImage(AssetPickerResource.image(named: "video")?.mn.rendering(to: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .video)
        typeView.setImage(AssetPickerResource.image(named: "livephoto")?.mn.rendering(to: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .livePhoto)
        typeView.setImage(AssetPickerResource.image(named: "gif")?.mn.rendering(to: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .gif)
        contentView.addSubview(typeView)
        NSLayoutConstraint.activate([
            typeView.widthAnchor.constraint(equalToConstant: 17.0),
            typeView.heightAnchor.constraint(equalToConstant: 17.0),
            typeView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 6.0),
            typeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3.0)
        ])
        
        // 时长
        durationLabel.numberOfLines = 1
        durationLabel.textAlignment = .left
        durationLabel.font = UIFont.systemFont(ofSize: 12.0)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.textColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        contentView.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.leftAnchor.constraint(equalTo: typeView.rightAnchor, constant: 5.0),
            durationLabel.centerYAnchor.constraint(equalTo: typeView.centerYAnchor)
        ])
        
        // 文件大小
        fileSizeLabel.numberOfLines = 1
        fileSizeLabel.textAlignment = .right
        fileSizeLabel.font = durationLabel.font
        fileSizeLabel.textColor = durationLabel.textColor
        fileSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fileSizeLabel)
        NSLayoutConstraint.activate([
            fileSizeLabel.rightAnchor.constraint(equalTo: previewImageView.rightAnchor),
            fileSizeLabel.centerYAnchor.constraint(equalTo: typeView.centerYAnchor)
        ])
        
        // 索引
        indexLabel.textColor = .white
        indexLabel.numberOfLines = 1
        indexLabel.textAlignment = .center
        indexLabel.backgroundColor = .clear
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.font = UIFont(name: "Trebuchet MS Bold", size: 30.0)
        contentView.addSubview(indexLabel)
        NSLayoutConstraint.activate([
            indexLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            indexLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            indexLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            indexLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // 资源无效标记
        unableView.isHidden = true
        unableView.isUserInteractionEnabled = false
        unableView.backgroundColor = .white.withAlphaComponent(0.8)
        unableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(unableView)
        NSLayoutConstraint.activate([
            unableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            unableView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            unableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            unableView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新资源模型
    /// - Parameter asset: 资源模型
    func updateAsset(_ asset: MNAsset) {
        self.asset = asset
        asset.container = imageView
        
        imageView.image = asset.cover
        
        topMask.isHidden = false
        typeView.isHidden = false
        bottomMask.isHidden = false
        durationLabel.isHidden = true
        previewControl.isHidden = options.allowsPreview == false
        
        if options.showFileSize, asset.fileSize > 0 {
            fileSizeLabel.text = asset.fileSizeString
            fileSizeLabel.isHidden = false
        } else {
            fileSizeLabel.isHidden = true
        }
        
        switch asset.type {
        case .photo:
            typeView.isHidden = true
        case .video:
            typeView.type = .video
            if asset.duration > 0.0, fileSizeLabel.isHidden {
                // 两者容易重叠
                durationLabel.text = asset.durationString
                durationLabel.isHidden = false
            }
        default:
            typeView.type = asset.type
        }
        
        if asset.isEnabled {
            unableView.isHidden = true
        } else {
            unableView.isHidden = false
            topMask.isHidden = true
            typeView.isHidden = true
            indexLabel.isHidden = true
            bottomMask.isHidden = true
            fileSizeLabel.isHidden = true
            durationLabel.isHidden = true
            previewControl.isHidden = true
        }
        
        if asset.isSelected {
            indexLabel.text = "\(asset.index)"
            indexLabel.isHidden = false
            topMask.isHidden = true
            typeView.isHidden = true
            unableView.isHidden = true
            bottomMask.isHidden = true
            fileSizeLabel.isHidden = true
            durationLabel.isHidden = true
            previewControl.isHidden = true
        } else {
            indexLabel.isHidden = true
        }
        
        asset.coverUpdateHandler = { [weak self] asset in
            guard let self = self, let _ = self.asset, asset == self.asset else { return }
            self.imageView.image = asset.cover
        }
        MNAssetHelper.fetchCover(asset, options: options)
        
        if options.showFileSize {
            asset.fileSizeUpdateHandler = { [weak self] asset in
                guard let self = self, let _ = self.asset, asset == self.asset, asset.fileSize > 0 else { return }
                self.durationLabel.isHidden = true
                self.fileSizeLabel.isHidden = false
                self.fileSizeLabel.text = asset.fileSizeString
            }
            MNAssetHelper.fetchFileSize(asset, on: options.queue)
        }
    }
}

// MARK: - Event
private extension MNAssetCell {
    
    /// 预览按钮事件
    @objc func preview() {
        guard let delegate = delegate else { return }
        delegate.assetCellShouldPreview(self)
    }
}
