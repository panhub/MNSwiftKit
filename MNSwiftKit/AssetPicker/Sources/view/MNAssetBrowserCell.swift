//
//  MNAssetBrowserCell.swift
//  MNKit
//
//  Created by 冯盼 on 2021/10/8.
//  资源浏览器表格

import UIKit
import Photos
import PhotosUI
//#if canImport(MNSwiftKit_Slider)
//import MNSwiftKit_Slider
//#endif
//#if canImport(MNSwiftKit_Player)
//import MNSwiftKit_Player
//#endif
//#if canImport(MNSwiftKit_Layout)
//import MNSwiftKit_Layout
//#endif
//#if canImport(MNSwiftKit_Definition)
//import MNSwiftKit_Definition
//#endif

/// 资源浏览器表格
class MNAssetBrowserCell: UICollectionViewCell {
    
    /// 当前状态
    private enum State {
        case idle, loading, downloading, prepared, displaying
    }
    
    /// 视频控制栏高度
    static let ToolBarHeight: CGFloat = MN_BOTTOM_SAFE_HEIGHT + 60.0
    
    /// 资源模型
    private(set) var asset: MNAsset!
    /// 当前状态
    private var state: State = .idle
    /// 是否允许自动播放
    var isAllowsAutoPlaying: Bool = false
    /// 缩放比例
    var maximumZoomScale: CGFloat {
        get { scrollView.maximumZoomScale }
        set {
            scrollView.maximumZoomScale = max(1.0, newValue)
        }
    }
    /// LivePhoto标记
    private var liveBadgeView: UIImageView!
    /// 滑动支持
    lazy var scrollView: MNAssetScrollView = {
        let scrollView = MNAssetScrollView(frame: bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return scrollView
    }()
    /// 播放视频
    private lazy var playView: MNPlayView = {
        let playView = MNPlayView(frame: scrollView.contentView.bounds)
        playView.backgroundColor = .clear
        playView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return playView
    }()
    /// 展示LivePhoto
    private lazy var livePhotoView: UIView? = {
        guard #available(iOS 9.1, *) else { return nil }
        let livePhotoView = PHLivePhotoView(frame: scrollView.contentView.bounds)
        livePhotoView.clipsToBounds = true
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        livePhotoView.delegate = self
        liveBadgeView = UIImageView(frame: CGRect(x: 11.0, y: 11.0, width: 27.0, height: 27.0))
        liveBadgeView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        liveBadgeView.contentMode = .scaleToFill
        //liveBadgeView.image = PHLivePhotoView.livePhotoBadgeImage(options: [.liveOff])
        liveBadgeView.image = PHLivePhotoView.livePhotoBadgeImage()
        livePhotoView.addSubview(liveBadgeView)
        return livePhotoView
    }()
    /// 展示图片
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: scrollView.contentView.bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imageView
    }()
    /// 加载进度条
    private lazy var progressView: MNAssetProgressView = {
        let progressView = MNAssetProgressView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        progressView.center = CGPoint(x: contentView.bounds.width/2.0, y: contentView.bounds.height/2.0)
        progressView.isHidden = true
        progressView.layer.cornerRadius = progressView.bounds.width/2.0
        progressView.clipsToBounds = true
        return progressView
    }()
    /// 播放器控制栏
    private lazy var toolBar: UIImageView = {
        let toolBar = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: contentView.bounds.width, height: MNAssetBrowserCell.ToolBarHeight))
        toolBar.mn_layout.maxY = contentView.bounds.height
        toolBar.image = PickerResourceLoader.image(named: "bottom")
        toolBar.isUserInteractionEnabled = true
        toolBar.contentMode = .scaleToFill
        return toolBar
    }()
    /// 播放按钮
    private lazy var playButton: UIButton = {
        var playButton: UIButton
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 5.0, bottom: -5.0, trailing: -5.0)
            playButton = UIButton(configuration: configuration)
            playButton.configurationUpdateHandler = { button in
                switch button.state {
                case .normal:
                    button.configuration?.background.image = PickerResourceLoader.image(named: "browser_play")
                case .selected:
                    button.configuration?.background.image = PickerResourceLoader.image(named: "browser_pause")
                default: break
                }
            }
        } else {
            playButton = UIButton(type: .custom)
            playButton.adjustsImageWhenHighlighted = false
            playButton.setBackgroundImage(PickerResourceLoader.image(named: "browser_play"), for: .normal)
            playButton.setBackgroundImage(PickerResourceLoader.image(named: "browser_pause"), for: .selected)
        }
        playButton.frame = CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0)
        playButton.mn_layout.minX = 10.0
        playButton.mn_layout.midY = (toolBar.bounds.height - MN_BOTTOM_SAFE_HEIGHT)/2.0
        playButton.addTarget(self, action: #selector(playButtonTouchUpInside), for: .touchUpInside)
        return playButton
    }()
    /// 时间
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: .zero)
        timeLabel.text = "00:00"
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        timeLabel.sizeToFit()
        timeLabel.mn_layout.width = ceil(timeLabel.frame.width) + 25.0
        timeLabel.mn_layout.midY = playButton.frame.midY
        timeLabel.mn_layout.minX = playButton.frame.maxX
        return timeLabel
    }()
    /// 时长
    private lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: .zero)
        durationLabel.text = "00:00"
        durationLabel.font = timeLabel.font
        durationLabel.textColor = timeLabel.textColor
        durationLabel.textAlignment = .right
        durationLabel.sizeToFit()
        durationLabel.mn_layout.width = ceil(durationLabel.frame.width) + 12.5
        durationLabel.mn_layout.maxX = toolBar.frame.width - 15.0
        durationLabel.mn_layout.midY = playButton.frame.midY
        return durationLabel
    }()
    /// 进度控制
    private lazy var slider: MNSlider = {
        let slider = MNSlider(frame: CGRect(x: timeLabel.frame.maxX, y: 0.0, width: durationLabel.frame.minX - timeLabel.frame.maxX, height: 15.0))
        slider.mn_layout.midY = playButton.frame.midY
        slider.delegate = self
        slider.trackHeight = 3.0
        slider.progressColor = .white
        slider.trackColor = .white.withAlphaComponent(0.35)
        return slider
    }()
    /// 视频播放器
    private lazy var player: MNPlayer = {
        let player = MNPlayer()
        player.delegate = self
        player.layer = playView.layer
        player.observeTime = CMTime(value: 1, timescale: 40)
        return player
    }()
    /// 封面图更新回调
    private lazy var coverUpdateHandler: (MNAsset, UIImage?)->Void = {
        let coverUpdateHandler: (MNAsset, UIImage?)->Void = { [weak self] asset, thumbnail in
            guard let self = self, let model = self.asset, asset == model else { return }
            switch self.state {
            case .loading, .prepared:
                guard var image = thumbnail else { break }
                if let content = asset.content, let img = content as? UIImage { image = img }
                if let images = image.images, images.count > 1 { image = images.first! }
                self.updateImage(image)
                if asset.type == .video {
                    self.playView.coverView.image = image
                    self.playView.coverView.isHidden = false
                } else {
                    self.imageView.image = image
                }
                if asset.progress > 0.0, asset.progress < 1.0 {
                    self.progressView.isHidden = false
                    self.progressView.setProgress(asset.progress)
                }
                // 获取内容
                if self.state == .loading {
                    self.state = .downloading
                }
                asset.cancelDownload()
                MNAssetHelper.fetchContent(asset, progress: self.progressUpdateHandler, completion: self.contentUpdateHandler)
            default: break
            }
        }
        return coverUpdateHandler
    }()
    /// 进度更新回调
    private lazy var progressUpdateHandler: (Double, Error?, MNAsset)->Void = {
        let progressUpdateHandler: (Double, Error?, MNAsset)->Void = { [weak self] progress, error, asset in
            guard let self = self, let model = self.asset, asset == model else { return }
            switch self.state {
            case .downloading, .prepared:
                if error != nil || progress <= 0.0 {
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
    private lazy var contentUpdateHandler: (MNAsset)->Void = {
        let contentUpdateHandler: (MNAsset)->Void = { [weak self] asset in
            guard let self = self, let model = self.asset, asset == model else { return }
            self.progressView.isHidden = true
            switch self.state {
            case .downloading:
                self.state = .prepared
            case .prepared:
                self.beginDisplaying()
            default: break
            }
        }
        return contentUpdateHandler
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
        
        contentView.addSubview(scrollView)
        scrollView.contentView.addSubview(playView)
        if #available(iOS 9.1, *), let livePhotoView = livePhotoView {
            scrollView.contentView.addSubview(livePhotoView)
        }
        scrollView.contentView.addSubview(imageView)
        contentView.addSubview(progressView)
        
        toolBar.addSubview(playButton)
        toolBar.addSubview(timeLabel)
        toolBar.addSubview(durationLabel)
        toolBar.addSubview(slider)
        contentView.addSubview(toolBar)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 更新
extension MNAssetBrowserCell {
    
    /// 更新资源
    /// - Parameter asset: 资源模型
    func updateAsset(_ asset: MNAsset) {
        self.asset = asset
        imageView.image = nil
        imageView.isHidden = asset.type == .video
        playView.isHidden = asset.type != .video
        progressView.isHidden = true
        playButton.isSelected = false
        toolBar.isHidden = playView.isHidden
        livePhotoView?.isHidden = true
        if toolBar.isHidden == false {
            slider.setValue(0.0, animated: false)
            timeLabel.text = "00:00"
            durationLabel.text = "00:00"
            toolBar.mn_layout.maxY = toolBar.superview!.bounds.height
        }
        // 获取缩略图
        state = .loading
        asset.cancelRequest()
        MNAssetHelper.fetchCover(asset, completion: coverUpdateHandler)
    }
    
    /// 预备展示
    func prepareDisplaying() {
        switch state {
        case .loading, .downloading:
            state = .prepared
        case .prepared:
            beginDisplaying()
        default: break
        }
    }
    
    /// 开始展示
    private func beginDisplaying() {
        guard let content = asset?.content else { return }
        state = .displaying
        if asset.type == .video {
            player.add([URL(fileURLWithPath: content as! String)])
            if isAllowsAutoPlaying {
                player.play()
            }
        } else if asset.type == .livePhoto {
            if #available(iOS 9.1, *), let livePhotoView = livePhotoView as? PHLivePhotoView {
                livePhotoView.livePhoto = content as? PHLivePhoto
                if let _ = livePhotoView.livePhoto {
                    imageView.isHidden = true
                    livePhotoView.isHidden = false
                    if isAllowsAutoPlaying {
                        livePhotoView.startPlayback(with: .full)
                    }
                }
            }
        } else {
            guard let image = content as? UIImage else { return }
            updateImage(image)
            imageView.image = image
        }
    }
    
    /// 结束展示
    func endDisplaying() {
        state = .idle
        if asset.type == .video {
            player.removeAll()
            playView.coverView.image = nil
        } else if asset.type == .livePhoto {
            if #available(iOS 9.1, *), let livePhotoView = livePhotoView as? PHLivePhotoView, let _ = livePhotoView.livePhoto {
                livePhotoView.stopPlayback()
                livePhotoView.livePhoto = nil
            }
        }
        if let asset = asset {
            asset.cancelRequest()
            asset.cancelDownload()
        }
    }
    
    /// 暂停展示
    func pauseDisplaying() {
        guard let _ = asset else { return }
        if asset.type == .video {
            if player.status == .playing {
                player.pause()
            }
        } else if asset.type == .livePhoto {
            if #available(iOS 9.1, *), let livePhotoView = livePhotoView as? PHLivePhotoView, let _ = livePhotoView.livePhoto {
                livePhotoView.stopPlayback()
                // 解决滑动过程中播放的问题
                livePhotoView.playbackGestureRecognizer.isEnabled = false
                livePhotoView.playbackGestureRecognizer.isEnabled = true
            }
        }
    }
    
    /// 更新图片
    /// - Parameter image: 图片
    private func updateImage(_ image: UIImage) {
        scrollView.zoomScale = 1.0
        scrollView.contentOffset = .zero
        scrollView.contentView.mn_layout.size = image.size.mn_picker.scaleFit(toSize: CGSize(width: scrollView.frame.width, height: scrollView.frame.height - 1.0))
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: max(scrollView.contentView.bounds.height, scrollView.bounds.height))
        scrollView.contentView.center = CGPoint(x: scrollView.bounds.maxX/2.0, y: scrollView.bounds.maxY/2.0)
        if (scrollView.contentView.bounds.height > scrollView.bounds.height) {
            scrollView.contentView.mn_layout.minY = 0.0
            scrollView.contentOffset = CGPoint(x: 0.0, y: (scrollView.contentView.bounds.height - scrollView.bounds.height)/2.0)
        }
    }
    
    /// 更新控制栏是否可见
    /// - Parameters:
    ///   - isVisible: 是否可见
    ///   - isAnimated: 是否动态展示
    func updateToolBar(_ isVisible: Bool, animated isAnimated: Bool) {
        guard toolBar.isHidden == false else { return }
        UIView.animate(withDuration: isAnimated ? 0.3 : 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.toolBar.mn_layout.minY = self.contentView.bounds.height - (isVisible ? self.toolBar.bounds.height : 0.0)
        }, completion: nil)
    }
}

// MARK: - 播放控制
extension MNAssetBrowserCell {
    
    /// 设置播放控制栏是否可见
    /// - Parameters:
    ///   - isVisible: 是否可见
    ///   - animated: 是否动态展示
    func makePlayToolBarVisible(_ isVisible: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0.0, delay: 0.0, options: [.curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.toolBar.mn_layout.minY = self.contentView.frame.height - (isVisible ? self.toolBar.frame.height : 0.0)
        }, completion: nil)
    }
    
    /// 播放按钮点击事件
    /// - Parameter sender: 播放按钮
    @objc func playButtonTouchUpInside(_ sender: UIButton) {
        guard player.status != .failed else { return }
        if player.status == .playing {
            player.pause()
        } else {
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
        guard let image = asset.content as? UIImage else { return asset.cover }
        guard let images = image.images, images.count > 1 else { return image }
        return images.first
    }
}

// MARK: - MNPlayerDelegate
extension MNAssetBrowserCell: MNPlayerDelegate {
    
    func playerDidEndDecode(_ player: MNPlayer) {
        durationLabel.text = Date(timeIntervalSince1970: TimeInterval(player.duration)).mn_picker.timeString
    }
    
    func playerDidChangeStatus(_ player: MNPlayer) {
        playButton.isSelected = player.status == .playing
        if player.status.rawValue > MNPlayer.Status.failed.rawValue {
            if playView.coverView.isHidden == false {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                    self?.playView.coverView.isHidden = true
                }
            }
        } else {
            playView.coverView.isHidden = false
        }
    }
    
    func playerDidPlayTimeInterval(_ player: MNPlayer) {
        slider.setValue(player.progress, animated: false)
        timeLabel.text = Date(timeIntervalSince1970: player.timeInterval).mn_picker.timeString
    }
    
    func player(_ player: MNPlayer, didPlayFail msg: String) {
        contentView.showInfoToast(msg)
    }
}

// MARK: - MNSliderDelegate
extension MNAssetBrowserCell: MNSliderDelegate {
    
    func sliderShouldBeginDragging(_ slider: MNSlider) -> Bool {
        return player.status.rawValue > MNPlayer.Status.failed.rawValue
    }
    
    func sliderShouldBeginTouching(_ slider: MNSlider) -> Bool {
        return player.status.rawValue > MNPlayer.Status.failed.rawValue
    }
    
    func sliderWillBeginDragging(_ slider: MNSlider) {
        player.pause()
    }
    
    func sliderDidDragging(_ slider: MNSlider) {
        player.seek(progress: slider.value, completion: nil)
    }
    
    func sliderDidEndDragging(_ slider: MNSlider) {
        player.play()
    }
    
    func sliderWillBeginTouching(_ slider: MNSlider) {
        player.pause()
    }
    
    func sliderDidEndTouching(_ slider: MNSlider) {
        player.seek(progress: slider.value) { [weak self] finish in
            guard finish, let self = self else { return }
            self.player.play()
        }
    }
}

@available(iOS 9.1, *)
extension MNAssetBrowserCell: PHLivePhotoViewDelegate {
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, canBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) -> Bool {
        liveBadgeView.alpha == 1.0
    }
    
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.liveBadgeView.alpha = 0.0
        }
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.liveBadgeView.alpha = 1.0
        }
    }
}
