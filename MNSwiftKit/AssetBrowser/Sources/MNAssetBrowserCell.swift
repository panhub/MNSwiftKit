//
//  MNAssetBrowserCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/8.
//  资源浏览器表格

import UIKit
import Photos
import PhotosUI

protocol MNAssetBrowseResourceHandler: NSObjectProtocol {
    
    /// 获取封面事件
    /// - Parameter cell: 表格
    /// - Parameter asset: 资源模型
    /// - Parameter completionHandler: 结束回调
    func browserCell(_ cell: MNAssetBrowserCell, fetchCover asset: any MNAssetBrowseSupported, completion completionHandler: @escaping MNAssetBrowserCell.CoverUpdateHandler)
    
    /// 获取内容事件
    /// - Parameter cell: 表格
    /// - Parameter asset: 资源模型
    /// - Parameter progressHandler: 进度回调
    /// - Parameter completionHandler: 结束回调
    func browserCell(_ cell: MNAssetBrowserCell, fetchContent asset: any MNAssetBrowseSupported, progress progressHandler: @escaping MNAssetBrowserCell.ProgressUpdateHandler, completion completionHandler: @escaping MNAssetBrowserCell.ContentsUpdateHandler)
}

/// 资源浏览器表格
public class MNAssetBrowserCell: UICollectionViewCell {
    
    /// 内容更新回调
    public typealias ContentsUpdateHandler = (any MNAssetBrowseSupported)->Void
    
    /// 封面更新回调
    public typealias CoverUpdateHandler = (any MNAssetBrowseSupported, UIImage?)->Void
    
    /// 进度更新回调
    public typealias ProgressUpdateHandler = (any MNAssetBrowseSupported, Double, Error?)->Void
    
    /// 当前状态
    private enum State {
        case idle, loading, downloading, prepared, displaying
    }
    
    /// 视频控制栏高度
    static let ToolBarHeight: CGFloat = MN_BOTTOM_SAFE_HEIGHT + 60.0
    
    /// 当前状态
    private var state: State = .idle
    /// 是否允许自动播放
    var isAllowsAutoPlaying: Bool = false
    /// 资源模型
    private(set) var asset: (any MNAssetBrowseSupported)!
    /// 事件代理
    weak var delegate: MNAssetBrowseResourceHandler!
    /// 缩放比例
    var maximumZoomScale: CGFloat {
        get { scrollView.maximumZoomScale }
        set {
            scrollView.maximumZoomScale = max(1.0, newValue)
        }
    }
    /// 滑动支持
    let scrollView = MNAssetScrollView()
    /// 加载进度条
    private let progressView = MNAssetProgressView()
    /// 播放器控制栏
    private let toolBar = UIImageView()
    /// 播放按钮
    private let playButton = UIButton(type: .custom)
    /// 时间
    private let timeLabel = UILabel()
    /// 时长
    private let durationLabel = UILabel()
    /// 进度控制
    private let slider = MNSlider()
    /// 视频播放器
    private lazy var player: MNPlayer = {
        let player = MNPlayer()
        player.delegate = self
        player.layer = scrollView.playView.layer
        player.periodicFrequency = 30
        return player
    }()
    /// 封面图更新回调
    private lazy var coverUpdateHandler: CoverUpdateHandler = {
        let coverUpdateHandler: CoverUpdateHandler = { [weak self] asset, cover in
            guard let self = self, let item = self.asset, asset.identifier == item.identifier else { return }
            switch self.state {
            case .loading, .prepared:
                guard var image = cover else { break }
                if let contents = asset.contents, contents is UIImage {
                    image = contents as! UIImage
                }
                if let images = image.images, images.count > 1, let first = images.first {
                    image = first
                }
                self.scrollView.adapt(with: image)
                if asset.type == .video {
                    self.scrollView.playView.coverView.image = image
                    self.scrollView.playView.coverView.isHidden = false
                } else {
                    self.scrollView.imageView.image = image
                }
                if asset.progress > 0.0, asset.progress < 1.0 {
                    self.progressView.isHidden = false
                    self.progressView.setProgress(asset.progress)
                }
                // 获取内容
                if self.state == .loading {
                    self.state = .downloading
                }
                if let delegate = self.delegate {
                    delegate.browserCell(self, fetchContent: asset, progress: self.progressUpdateHandler, completion: self.contentsUpdateHandler)
                }
            default: break
            }
        }
        return coverUpdateHandler
    }()
    /// 进度更新回调
    private lazy var progressUpdateHandler: ProgressUpdateHandler = {
        let progressUpdateHandler: ProgressUpdateHandler = { [weak self] asset, progress, error in
            guard let self = self, let item = self.asset, asset.identifier == item.identifier else { return }
            switch self.state {
            case .downloading, .prepared:
                if progress <= 0.0 || error != nil {
                    self.progressView.isHidden = true
                    self.progressView.setProgress(0.0)
                } else {
                    if progress < 1.0 {
                        self.progressView.isHidden = false
                    }
                    self.progressView.setProgress(progress)
                }
            default: break
            }
        }
        return progressUpdateHandler
    }()
    /// 内容更新回调
    private lazy var contentsUpdateHandler: ContentsUpdateHandler = {
        let contentsUpdateHandler: ContentsUpdateHandler = { [weak self] asset in
            guard let self = self, let item = self.asset, asset.identifier == item.identifier else { return }
            self.progressView.isHidden = true
            switch self.state {
            case .downloading:
                self.state = .prepared
            case .prepared:
                self.beginDisplay()
            default: break
            }
        }
        return contentsUpdateHandler
    }()
    
    /// 构造资源浏览器表格
    /// - Parameter frame: 位置
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        contentView.frame = bounds
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        progressView.isHidden = true
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = progressView.bounds.width/2.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 40.0),
            progressView.heightAnchor.constraint(equalTo: progressView.widthAnchor, multiplier: 1.0),
            progressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        toolBar.contentMode = .scaleToFill
        toolBar.isUserInteractionEnabled = true
        toolBar.image = AssetBrowserResource.image(named: "mask")
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(toolBar)
        NSLayoutConstraint.activate([
            toolBar.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            toolBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: MNAssetBrowserCell.ToolBarHeight)
        ])
        
        let playImage = AssetBrowserResource.image(named: "play")
        let pauseImage = AssetBrowserResource.image(named: "pause")
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playButtonTouchUpInside), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            playButton.configuration = configuration
            playButton.configurationUpdateHandler = { button in
                switch button.state {
                case .normal:
                    button.configuration?.background.image = playImage
                case .selected:
                    button.configuration?.background.image = pauseImage
                case .highlighted:
                    button.configuration?.background.image = button.isSelected ? pauseImage : playImage
                default: break
                }
            }
        } else {
            playButton.adjustsImageWhenHighlighted = false
            playButton.setBackgroundImage(playImage, for: .normal)
            playButton.setBackgroundImage(pauseImage, for: .selected)
        }
        toolBar.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.leftAnchor.constraint(equalTo: toolBar.leftAnchor, constant: 10.0),
            playButton.widthAnchor.constraint(equalToConstant: 25.0),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor, multiplier: 1.0),
            playButton.centerYAnchor.constraint(equalTo: toolBar.topAnchor, constant: (MNAssetBrowserCell.ToolBarHeight - MN_BOTTOM_SAFE_HEIGHT)/2.0)
        ])
        
        timeLabel.text = "00:00"
        timeLabel.textColor = .white
        timeLabel.numberOfLines = 1
        timeLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        timeLabel.sizeToFit()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 10.0),
            timeLabel.widthAnchor.constraint(equalToConstant: ceil(timeLabel.frame.width) + 3.0),
            timeLabel.heightAnchor.constraint(equalToConstant: ceil(timeLabel.frame.height) + 1.0),
            timeLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor)
        ])
        
        durationLabel.font = timeLabel.font
        durationLabel.textColor = timeLabel.textColor
        durationLabel.numberOfLines = 1
        durationLabel.textAlignment = .right
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.rightAnchor.constraint(equalTo: toolBar.rightAnchor, constant: -15.0),
            durationLabel.widthAnchor.constraint(equalTo: timeLabel.widthAnchor),
            durationLabel.heightAnchor.constraint(equalTo: timeLabel.heightAnchor),
            durationLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor)
        ])
        
        slider.delegate = self
        slider.trackRadius = 2.0
        slider.trackHeight = 4.0
        slider.progressColor = .white
        slider.trackColor = .white.withAlphaComponent(0.3)
        slider.thumbRadius = 7.5
        slider.thumbSize = .init(width: 15.0, height: 15.0)
        slider.thumbColor = .white.withAlphaComponent(0.5)
        slider.thumbImageRadius = 3.5
        slider.thumbImageColor = .white
        slider.thumbImageInset = .init(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        slider.trackOnSides = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 4.0),
            slider.rightAnchor.constraint(equalTo: durationLabel.leftAnchor, constant: -4.0),
            slider.heightAnchor.constraint(equalToConstant: 15.0),
            slider.centerYAnchor.constraint(equalTo: playButton.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 更新
extension MNAssetBrowserCell {
    
    /// 更新资源
    /// - Parameter asset: 资源模型
    func update(asset: any MNAssetBrowseSupported) {
        self.asset = asset
        scrollView.imageView.image = nil
        scrollView.imageView.isHidden = asset.type == .video
        scrollView.playView.isHidden = scrollView.imageView.isHidden == false
        progressView.isHidden = true
        playButton.isSelected = false
        toolBar.isHidden = scrollView.playView.isHidden
        if let livePhotoView = scrollView.livePhotoView {
            livePhotoView.isHidden = true
        }
        if toolBar.isHidden {
            toolBar.transform = .init(translationX: 0.0, y: MNAssetBrowserCell.ToolBarHeight)
        } else {
            toolBar.transform = .identity
            timeLabel.text = "00:00"
            durationLabel.text = "00:00"
            slider.setValue(0.0, animated: false)
        }
        // 获取缩略图
        state = .loading
        if let delegate = delegate {
            delegate.browserCell(self, fetchCover: asset, completion: coverUpdateHandler)
        }
    }
    
    /// 预备展示
    func prepareDisplay() {
        switch state {
        case .loading, .downloading:
            state = .prepared
        case .prepared:
            beginDisplay()
        default: break
        }
    }
    
    /// 开始展示
    private func beginDisplay() {
        guard let asset = asset else { return }
        guard let contents = asset.contents else { return }
        state = .displaying
        switch asset.type {
        case .photo, .gif:
            // 图片
            guard let image = contents as? UIImage else { break }
            scrollView.adapt(with: image)
            scrollView.imageView.image = image
        case .livePhoto:
            //
            guard #available(iOS 9.1, *), let livePhotoView = scrollView.livePhotoView as? PHLivePhotoView, let livePhoto = contents as? PHLivePhoto else { break }
            livePhotoView.livePhoto = livePhoto
            scrollView.imageView.isHidden = true
            livePhotoView.isHidden = false
            if isAllowsAutoPlaying {
                livePhotoView.startPlayback(with: .full)
            }
        case .video:
            // 视频
            guard let videoPath = contents as? String else { break }
            player.add([URL(fileAtPath: videoPath)])
            if isAllowsAutoPlaying {
                player.play()
            }
        }
    }
    
    /// 结束展示
    func endDisplaying() {
        state = .idle
        guard let asset = asset else { return }
        switch asset.type {
        case .photo, .gif:
            // 图片
            scrollView.imageView.image = nil
        case .livePhoto:
            guard #available(iOS 9.1, *), let livePhotoView = scrollView.livePhotoView as? PHLivePhotoView, let _ = livePhotoView.livePhoto else { break }
            livePhotoView.stopPlayback()
            livePhotoView.livePhoto = nil
        case .video:
            player.removeAll()
            scrollView.playView.coverView.image = nil
        }
    }
    
    /// 暂停展示
    func pauseDisplaying() {
        guard let asset = asset else { return }
        switch asset.type {
        case .livePhoto:
            guard #available(iOS 9.1, *), let livePhotoView = scrollView.livePhotoView as? PHLivePhotoView, let _ = livePhotoView.livePhoto else { break }
            livePhotoView.stopPlayback()
            // 解决滑动过程中播放的问题
            livePhotoView.playbackGestureRecognizer.isEnabled = false
            livePhotoView.playbackGestureRecognizer.isEnabled = true
        case .video:
            guard player.status == .playing else { break }
            player.pause()
        default: break
        }
    }
    
    /// 更新控制栏是否可见
    /// - Parameters:
    ///   - visible: 是否可见
    ///   - animated: 是否动态展示
    func updateToolBar(visible: Bool, animated: Bool) {
        guard toolBar.isHidden == false else { return }
        updateToolBarVisible(visible, animated: animated)
    }
}

// MARK: - 播放控制
extension MNAssetBrowserCell {
    
    /// 设置播放控制栏是否可见
    /// - Parameters:
    ///   - visible: 是否可见
    ///   - animated: 是否动态展示
    private func updateToolBarVisible(_ visible: Bool, animated: Bool) {
        let animations: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.toolBar.transform = visible ? .identity : .init(translationX: 0.0, y: MNAssetBrowserCell.ToolBarHeight)
        }
        if animated {
            UIView.animate(withDuration: 0.28, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: animations)
        } else {
            animations()
        }
    }
    
    /// 播放按钮点击事件
    /// - Parameter sender: 播放按钮
    @objc func playButtonTouchUpInside(_ sender: UIButton) {
        switch player.status {
        case .failed: break
        case .playing:
            player.pause()
        default:
            player.play()
        }
    }
}

// MARK: - 当前视图
extension MNAssetBrowserCell {
    
    /// 获取当前截图
    var currentImage: UIImage? {
        guard let asset = asset else { return nil }
        if asset.type == .video || asset.type == .livePhoto { return asset.cover }
        guard let image = asset.contents as? UIImage else { return asset.cover }
        guard let images = image.images, images.count > 1 else { return image }
        return images.first
    }
}

// MARK: - MNPlayerDelegate
extension MNAssetBrowserCell: MNPlayerDelegate {
    
    public func playerDidEndDecode(_ player: MNPlayer) {
        durationLabel.text = Date(timeIntervalSince1970: TimeInterval(player.duration)).mn.playTime
    }
    
    public func playerDidChangeStatus(_ player: MNPlayer) {
        playButton.isSelected = player.status == .playing
        if player.status.rawValue > MNPlayer.Status.failed.rawValue {
            if scrollView.playView.coverView.isHidden == false {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                    guard let self = self else { return }
                    self.scrollView.playView.coverView.isHidden = true
                }
            }
        } else {
            scrollView.playView.coverView.isHidden = false
        }
    }
    
    public func playerDidPlayTimeInterval(_ player: MNPlayer) {
        slider.setValue(player.progress, animated: false)
        timeLabel.text = Date(timeIntervalSince1970: player.timeInterval).mn.playTime
    }
}

// MARK: - MNSliderDelegate
extension MNAssetBrowserCell: MNSliderDelegate {
    
    public func sliderShouldBeginDragging(_ slider: MNSlider) -> Bool {
        return player.status.rawValue > MNPlayer.Status.failed.rawValue
    }
    
    public func sliderShouldBeginTouching(_ slider: MNSlider) -> Bool {
        return player.status.rawValue > MNPlayer.Status.failed.rawValue
    }
    
    public func sliderWillBeginDragging(_ slider: MNSlider) {
        player.pause()
    }
    
    public func sliderDidDragging(_ slider: MNSlider) {
        player.seek(progress: slider.value, completion: nil)
    }
    
    public func sliderDidEndDragging(_ slider: MNSlider) {
        player.play()
    }
    
    public func sliderWillBeginTouching(_ slider: MNSlider) {
        player.pause()
    }
    
    public func sliderDidEndTouching(_ slider: MNSlider) {
        player.seek(progress: slider.value) { [weak self] finish in
            guard finish, let self = self else { return }
            self.player.play()
        }
    }
}
