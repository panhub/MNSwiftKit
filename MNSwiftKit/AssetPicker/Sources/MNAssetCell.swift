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
    /// 控件间隔
    private let spacing: CGFloat = 6.0
    /// 媒体资源模型
    private(set) var asset: MNAsset!
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
    /// 资源展示
    private let imageView = UIImageView(frame: .zero)
    /// 顶部阴影
    private let topShadow = UIImageView(frame: .zero)
    /// 底部阴影
    private let bottomShadow = UIImageView(frame: .zero)
    /// 云端标识
    private let cloudView = UIImageView(frame: .zero)
    /// 预览按钮
    private let previewControl = UIControl(frame: .zero)
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
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // 顶部阴影
        topShadow.contentMode = .scaleToFill
        topShadow.isUserInteractionEnabled = false
        topShadow.translatesAutoresizingMaskIntoConstraints = false
        topShadow.image = AssetPickerResource.image(named: "top_shadow")
        contentView.addSubview(topShadow)
        NSLayoutConstraint.activate([
            topShadow.heightAnchor.constraint(equalToConstant: 30.0),
            topShadow.topAnchor.constraint(equalTo: contentView.topAnchor),
            topShadow.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            topShadow.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // 云端标记
        cloudView.contentMode = .scaleAspectFit
        cloudView.translatesAutoresizingMaskIntoConstraints = false
        cloudView.image = AssetPickerResource.image(named: "cloud")?.mn.rendering(to: .white.withAlphaComponent(0.85))
        contentView.addSubview(cloudView)
        NSLayoutConstraint.activate([
            cloudView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0),
            cloudView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 6.0),
            cloudView.widthAnchor.constraint(equalToConstant: 17.0),
            cloudView.heightAnchor.constraint(equalToConstant: 17.0)
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
            previewImageView.rightAnchor.constraint(equalTo: previewControl.rightAnchor, constant: -6.0),
            previewImageView.centerYAnchor.constraint(equalTo: cloudView.centerYAnchor),
            previewImageView.heightAnchor.constraint(equalToConstant: 13.0),
            previewImageView.widthAnchor.constraint(equalTo: previewImageView.heightAnchor, multiplier: 180.0/121.0)
        ])
        
        // 底部阴影
        bottomShadow.image = AssetPickerResource.image(named: "bottom_shadow")
        bottomShadow.contentMode = .scaleToFill
        bottomShadow.backgroundColor = .clear
        bottomShadow.isUserInteractionEnabled = false
        bottomShadow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomShadow)
        NSLayoutConstraint.activate([
            bottomShadow.heightAnchor.constraint(equalToConstant: 30.0),
            bottomShadow.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bottomShadow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomShadow.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // 资源类型
        badgeView.contentMode = .scaleAspectFit
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.setImage(AssetPickerResource.image(named: "video")?.mn.rendering(to: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .normal)
        badgeView.setImage(AssetPickerResource.image(named: "livephoto")?.mn.rendering(to: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .highlighted)
        badgeView.setImage(AssetPickerResource.image(named: "gif")?.mn.rendering(to: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)), for: .selected)
        contentView.addSubview(badgeView)
        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalTo: cloudView.widthAnchor),
            badgeView.heightAnchor.constraint(equalTo: cloudView.heightAnchor),
            badgeView.leftAnchor.constraint(equalTo: cloudView.leftAnchor),
            badgeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0)
        ])
        
        // 时长
        durationLabel.numberOfLines = 1
        durationLabel.textAlignment = .left
        durationLabel.font = UIFont.systemFont(ofSize: 12.0)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.textColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        contentView.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.leftAnchor.constraint(equalTo: badgeView.rightAnchor, constant: 5.0),
            durationLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
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
            fileSizeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
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
        
        topShadow.isHidden = false
        bottomShadow.isHidden = false
        fileSizeLabel.isHidden = true
        durationLabel.isHidden = true
        cloudView.isHidden = asset.source != .cloud
        previewControl.isHidden = options.allowsPreview == false
        
        if options.showFileSize, asset.fileSize > 0 {
            updateFileSize()
        }
        
        switch asset.type {
        case .video:
            badgeView.state = .normal
            badgeView.isHidden = false
            if options.showFileSize == false || asset.fileSize <= 0 {
                durationLabel.text = asset.durationString
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
            previewControl.isHidden = true
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
            previewControl.isHidden = true
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
        durationLabel.isHidden = true
        fileSizeLabel.isHidden = false
        fileSizeLabel.text = asset.fileSizeString
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
        delegate.assetCellShouldPreview(self)
    }
}
