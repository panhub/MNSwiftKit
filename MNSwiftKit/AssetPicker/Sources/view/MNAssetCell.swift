//
//  MNAssetCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/28.
//  资源列表

import UIKit

/// 资源表格代理
protocol MNAssetCellDelegate: NSObjectProtocol {
    
    /// 预览资源回调
    /// - Parameter cell: 资源表格
    func assetCellShouldPreviewAsset(_ cell: MNAssetCell) -> Void
}

/// 资源展示表格
class MNAssetCell: UICollectionViewCell {
    /// 控件间隔
    private let spacing: CGFloat = 6.0
    /// 媒体资源模型
    private(set) var asset: MNAsset!
    /// 事件代理
    weak var delegate: MNAssetCellDelegate?
    /// 配置信息
    var options: MNAssetPickerOptions! {
        didSet {
            if let options = options {
                indexLabel.backgroundColor = options.themeColor.withAlphaComponent(0.58)
            }
        }
    }
    /// 资源展示
    private let imageView = UIImageView(frame: .zero)
    /// 顶部阴影
    private let topShadow = UIImageView(frame: .zero)
    /// 底部阴影
    private let bottomShadow = UIImageView(frame: .zero)
    /// 云端标识
    private let cloudView = UIImageView(frame: .zero)
    /// 预览按钮
    private let previewButton = UIControl(frame: .zero)
    /// 资源类型
    private let badgeView = MNStateView(frame: .zero)
    /// 视频时长
    private let durationLabel = UILabel()
    /// 文件大小
    private let fileSizeLabel = UILabel()
    /// 选择索引
    private let indexLabel = UILabel()
    /// 无效标记
    private let unableView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        
        // 缩略图显示
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        // 顶部阴影
        topShadow.image = AssetPickerResource.image(named: "top_shadow")
        topShadow.contentMode = .scaleToFill
        topShadow.isUserInteractionEnabled = false
        topShadow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topShadow)
        topShadow.addConstraint(NSLayoutConstraint(item: topShadow, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0))
        contentView.addConstraints([
            NSLayoutConstraint(item: topShadow, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: topShadow, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: topShadow, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        // 底部阴影
        bottomShadow.image = AssetPickerResource.image(named: "bottom_shadow")
        bottomShadow.contentMode = .scaleToFill
        bottomShadow.backgroundColor = .clear
        bottomShadow.isUserInteractionEnabled = false
        bottomShadow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomShadow)
        bottomShadow.addConstraint(NSLayoutConstraint(item: bottomShadow, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0))
        contentView.addConstraints([
            NSLayoutConstraint(item: bottomShadow, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomShadow, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomShadow, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        ])
        
        // 云端标记
        cloudView.isUserInteractionEnabled = false
        cloudView.image = AssetPickerResource.image(named: "cloud")?.mn_picker.renderBy(color: .white.withAlphaComponent(0.85))
        cloudView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cloudView)
        cloudView.addConstraints([
            NSLayoutConstraint(item: cloudView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 17.0),
            NSLayoutConstraint(item: cloudView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 17.0)
        ])
        contentView.addConstraints([
            NSLayoutConstraint(item: cloudView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 6.0),
            NSLayoutConstraint(item: cloudView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 6.0)
        ])
        
        // 预览
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.addTarget(self, action: #selector(preview), for: .touchUpInside)
        contentView.addSubview(previewButton)
        previewButton.addConstraints([
            NSLayoutConstraint(item: previewButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0),
            NSLayoutConstraint(item: previewButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0)
        ])
        contentView.addConstraints([
            NSLayoutConstraint(item: previewButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: previewButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        let previewBadge = UIImageView(image: AssetPickerResource.image(named: "preview")?.mn_picker.renderBy(color: .white.withAlphaComponent(0.85)))
        previewBadge.translatesAutoresizingMaskIntoConstraints = false
        previewButton.addSubview(previewBadge)
        previewBadge.addConstraints([
            NSLayoutConstraint(item: previewBadge, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 13.0),
            NSLayoutConstraint(item: previewBadge, attribute: .width, relatedBy: .equal, toItem: previewBadge, attribute: .height, multiplier: 180.0/121.0, constant: 0.0)
        ])
        previewButton.addConstraint(NSLayoutConstraint(item: previewBadge, attribute: .right, relatedBy: .equal, toItem: previewButton, attribute: .right, multiplier: 1.0, constant: -6.0))
        contentView.addConstraint(NSLayoutConstraint(item: previewBadge, attribute: .centerY, relatedBy: .equal, toItem: cloudView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        // 资源类型
        badgeView.setImage(AssetPickerResource.image(named: "video")?.mn_picker.renderBy(color: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .normal)
        badgeView.setImage(AssetPickerResource.image(named: "livephoto")?.mn_picker.renderBy(color: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .highlighted)
        badgeView.setImage(AssetPickerResource.image(named: "gif")?.mn_picker.renderBy(color: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .selected)
        badgeView.contentMode = .scaleAspectFit
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(badgeView)
        contentView.addConstraints([
            NSLayoutConstraint(item: badgeView, attribute: .width, relatedBy: .equal, toItem: cloudView, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: badgeView, attribute: .height, relatedBy: .equal, toItem: cloudView, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: badgeView, attribute: .left, relatedBy: .equal, toItem: cloudView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: badgeView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -6.0)
        ])
        
        // 时长
        durationLabel.numberOfLines = 1
        durationLabel.textAlignment = .right
        durationLabel.isUserInteractionEnabled = false
        durationLabel.font = UIFont.systemFont(ofSize: 12.0)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.textColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        contentView.addSubview(durationLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: durationLabel, attribute: .left, relatedBy: .equal, toItem: badgeView, attribute: .right, multiplier: 1.0, constant: 5.0),
            NSLayoutConstraint(item: durationLabel, attribute: .centerY, relatedBy: .equal, toItem: badgeView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        // 文件大小
        fileSizeLabel.numberOfLines = 1
        fileSizeLabel.textAlignment = .right
        fileSizeLabel.isUserInteractionEnabled = false
        fileSizeLabel.font = UIFont.systemFont(ofSize: 12.0)
        fileSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        fileSizeLabel.textColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        contentView.addSubview(fileSizeLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: fileSizeLabel, attribute: .right, relatedBy: .equal, toItem: previewBadge, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: fileSizeLabel, attribute: .centerY, relatedBy: .equal, toItem: badgeView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        // 索引
        indexLabel.textColor = .white
        indexLabel.numberOfLines = 1
        indexLabel.textAlignment = .center
        indexLabel.backgroundColor = .clear
        indexLabel.isUserInteractionEnabled = false
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.font = UIFont(name: "Trebuchet MS Bold", size: 30.0)
        contentView.addSubview(indexLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: indexLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: indexLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: indexLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: indexLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        // 资源无效标记
        unableView.isHidden = true
        unableView.isUserInteractionEnabled = false
        unableView.backgroundColor = .white.withAlphaComponent(0.8)
        unableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(unableView)
        contentView.addConstraints([
            NSLayoutConstraint(item: unableView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: unableView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: unableView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: unableView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
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
        
        topShadow.isHidden = false
        bottomShadow.isHidden = false
        fileSizeLabel.isHidden = true
        durationLabel.isHidden = true
        cloudView.isHidden = asset.source != .cloud
        previewButton.isHidden = options.allowsPreview == false
        
        if options.showFileSize, asset.fileSize > 0 {
            updateFileSize()
        }
        
        switch asset.type {
        case .video:
            badgeView.state = .normal
            badgeView.isHidden = false
            if options.showFileSize == false || asset.fileSize <= 0 {
                durationLabel.text = asset.durationValue
                durationLabel.isHidden = false
            }
        case .livePhoto:
            badgeView.state = .highlighted
            badgeView.isHidden = false
        case .gif:
            badgeView.state = .selected
            badgeView.isHidden = false
        default:
            badgeView.isHidden = true
        }
        
        if asset.isEnabled {
            unableView.isHidden = true
        } else {
            unableView.isHidden = false
            indexLabel.isHidden = true
            cloudView.isHidden = true
            badgeView.isHidden = true
            topShadow.isHidden = true
            previewButton.isHidden = true
            fileSizeLabel.isHidden = true
            durationLabel.isHidden = true
            bottomShadow.isHidden = true
        }
        
        if asset.isSelected {
            indexLabel.text = "\(asset.index)"
            indexLabel.isHidden = false
            unableView.isHidden = true
            cloudView.isHidden = true
            badgeView.isHidden = true
            topShadow.isHidden = true
            previewButton.isHidden = true
            fileSizeLabel.isHidden = true
            durationLabel.isHidden = true
            bottomShadow.isHidden = true
        } else {
            indexLabel.isHidden = true
        }
        
        asset.coverUpdateHandler = { [weak self] asset in
            guard let self = self, let _ = self.asset, asset == self.asset else { return }
            self.imageView.image = asset.cover
        }
        
        asset.sourceUpdateHandler = { [weak self] asset in
            guard let self = self, let _ = self.asset, asset == self.asset else { return }
            self.cloudView.isHidden = asset.source != .cloud
        }
        
        asset.fileSizeUpdateHandler = { [weak self] asset in
            guard let self = self, self.options.showFileSize, let _ = self.asset, asset == self.asset, asset.fileSize > 0 else { return }
            self.updateFileSize()
        }
        
        MNAssetHelper.fetchProfile(asset, options: options)
    }
    
    /// 更新文件大小
    func updateFileSize() {
        fileSizeLabel.text = asset.fileSizeValue
        fileSizeLabel.isHidden = false
        durationLabel.isHidden = true
    }
    
    /// 结束展示
    func endDisplaying() {
        guard let asset = asset else { return }
        asset.cancelRequest()
    }
}

// MARK: - Event
private extension MNAssetCell {
    
    /// 预览按钮事件
    @objc func preview() {
        guard let delegate = delegate else { return }
        delegate.assetCellShouldPreviewAsset(self)
    }
}
