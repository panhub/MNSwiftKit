//
//  MNTailorViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/9/23.
//  视频裁剪控制器

import UIKit
import AVFoundation

@objc public protocol MNTailorViewControllerDelegate: NSObjectProtocol {
    
    /// 取消裁剪控制器
    @objc optional func tailorControllerDidCancel(_ tailorController: MNTailorViewController)
    
    /// 没有改变视频资源 请求复制
    /// - Parameter tailorController: 裁剪控制器
    /// - Returns: 是否复制视频
    @objc optional func tailorControllerShouldCopyVideo(_ tailorController: MNTailorViewController) -> Bool
    
    /// 裁剪结束回调
    /// - Parameters:
    ///   - tailorController: 裁剪控制器
    ///   - videoPath: 视频路径
    func tailorController(_ tailorController: MNTailorViewController, didOutputVideoAtPath videoPath: String)
}

public class MNTailorViewController: UIViewController {
    /// 事件代理
    public weak var delegate: MNTailorViewControllerDelegate?
    /// 视频导出路径
    public var outputPath: String?
    /// 视频绝对路径
    private var videoPath: String = ""
    /// 视频封面
    private var cover: UIImage!
    /// 视频时长
    private var duration: TimeInterval = 0.0
    /// 视频尺寸
    private var renderSize: CGSize = CGSize(width: 1920.0, height: 1080.0)
    /// 最小裁剪时长
    public var minTailorDuration: TimeInterval = 0.0
    /// 最大裁剪时长
    public var maxTailorDuration: TimeInterval = 0.0
    /// 关闭按钮
    private let closeButton = UIButton(type: .custom)
    /// 确定按钮
    private let doneButton = UIButton(type: .custom)
    /// 时间显示
    private let timeLabel: UILabel = UILabel()
    /// 播放/暂停标记
    private let badgeView: UIImageView = UIImageView(image: AssetPickerResource.image(named: "player_play"))
    /// 视频播放视图
    private let playView: MNPlayView = MNPlayView()
    /// 时间显示
    private let timeView: MNTailorTimeView = MNTailorTimeView()
    /// 动画时长
    private let AnimationDuration: TimeInterval = 0.2
    /// 播放/暂停控制
    private let playControl: UIControl = UIControl(frame: CGRect(x: 0.0, y: 0.0, width: 48.0, height: 48.0))
    /// 默认黑色
    private let BlackColor: UIColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
    /// 默认白色
    private let WhiteColor: UIColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    /// 状态栏显示
    public override var prefersStatusBarHidden: Bool { false }
    /// 白色状态栏
    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    /// 状态栏动态更新
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
    /// 裁剪视图
    private lazy var tailorView: MNTailorView = {
        let tailorView: MNTailorView = MNTailorView(frame: CGRect(x: playControl.frame.maxX + 1.5, y: playControl.frame.minY, width: doneButton.frame.maxX - playControl.frame.maxX - 1.5, height: playControl.frame.height))
        tailorView.delegate = self
        tailorView.videoPath = videoPath
        tailorView.minTailorDuration = minTailorDuration
        tailorView.maxTailorDuration = maxTailorDuration
        tailorView.layer.mn.setRadius(5.0, by: [.topRight, .bottomRight])
        return tailorView
    }()
    /// 加载指示图
    private let indicatorView: UIActivityIndicatorView = {
        var style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
        let indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: style)
        indicatorView.hidesWhenStopped = true
        indicatorView.isUserInteractionEnabled = false
        return indicatorView
    }()
    /// 播放器
    private lazy var player: MNPlayer = {
        let player = MNPlayer(urls: [URL(fileURLWithPath: videoPath)])
        player.delegate = self
        player.periodicFrequency = 30
        return player
    }()
    
    convenience init(url: URL) {
        self.init(videoPath: url.path)
    }
    
    convenience init(videoPath: String) {
        self.init(nibName: nil, bundle: nil)
        self.videoPath = videoPath
        modalPresentationStyle = .fullScreen
        self.duration = MNAssetExportSession.seconds(fileAtPath: videoPath)
        self.cover = MNAssetExportSession.generateImage(fileAtPath: videoPath)
        let renderSize = MNAssetExportSession.renderSize(fileAtPath: videoPath)
        if renderSize != .zero {
            self.renderSize = renderSize
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .black
        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        closeButton.mn.size = CGSize(width: 30.0, height: 30.0)
        closeButton.mn.minX = 15.0
        closeButton.mn.maxY = view.frame.height - max(15.0, MN_BOTTOM_SAFE_HEIGHT)
        closeButton.setBackgroundImage(AssetPickerResource.image(named: "player_close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
        
        doneButton.mn.size = CGSize(width: 28.0, height: 28.0)
        doneButton.mn.midY = closeButton.frame.midY
        doneButton.mn.maxX = view.frame.width - closeButton.frame.minX
        doneButton.isUserInteractionEnabled = false
        doneButton.setBackgroundImage(AssetPickerResource.image(named: "player_done"), for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTouchUpInside(_:)), for: .touchUpInside)
        view.addSubview(doneButton)
        
        timeLabel.frame = CGRect(x: closeButton.frame.maxX, y: closeButton.frame.minY, width: doneButton.frame.minX - closeButton.frame.maxX, height: closeButton.frame.height)
        timeLabel.numberOfLines = 1
        timeLabel.font = .systemFont(ofSize: 13.0, weight: .medium)
        timeLabel.textAlignment = .center
        timeLabel.textColor = WhiteColor
        view.addSubview(timeLabel)
        
        playControl.mn.minX = closeButton.frame.minX
        playControl.mn.maxY = closeButton.frame.minY - 20.0
        playControl.isUserInteractionEnabled = false
        playControl.backgroundColor = BlackColor
        playControl.layer.mn.setRadius(5.0, by: [.topLeft, .bottomLeft])
        playControl.addTarget(self, action: #selector(playControlTouchUpInside(_:)), for: .touchUpInside)
        view.addSubview(playControl)
        
        badgeView.mn.width = 25.0
        badgeView.mn.sizeFitToWidth()
        badgeView.isUserInteractionEnabled = false
        badgeView.highlightedImage = AssetPickerResource.image(named: "player_pause")
        badgeView.center = CGPoint(x: playControl.bounds.midX, y: playControl.bounds.midY)
        playControl.addSubview(badgeView)
        
        tailorView.isUserInteractionEnabled = false
        tailorView.backgroundColor = BlackColor
        view.addSubview(tailorView)
        
        // 播放尺寸
        let top: CGFloat = MN_STATUS_BAR_HEIGHT + MN_NAV_BAR_HEIGHT/2.0
        let width: CGFloat = view.frame.width
        let height: CGFloat = playControl.frame.minY - 20.0 - top
        var renderSize: CGSize = renderSize
        if renderSize.width >= renderSize.height {
            // 横向视频
            renderSize = renderSize.mn.multiplyTo(width: width)
            if floor(renderSize.height) > height {
                renderSize = self.renderSize.mn.multiplyTo(height: height)
            }
        } else {
            // 纵向视频
            renderSize = renderSize.mn.multiplyTo(height: height)
            if floor(renderSize.width) > width {
                renderSize = self.renderSize.mn.multiplyTo(width: width)
            }
        }
        renderSize.width = ceil(renderSize.width)
        renderSize.height = ceil(renderSize.height)
        playView.frame = CGRect(x: (view.frame.width - renderSize.width)/2.0, y: (height - renderSize.height)/2.0 + top, width: renderSize.width, height: renderSize.height)
        playView.mn.minX = (view.frame.width - renderSize.width)/2.0
        playView.isTouchEnabled = false
        playView.backgroundColor = BlackColor
        view.addSubview(playView)
        
        indicatorView.center = playView.center
        indicatorView.color = WhiteColor
        view.addSubview(indicatorView)
        
        timeView.isHidden = true
        timeView.mn.minX = tailorView.frame.minX
        timeView.mn.maxY = playControl.frame.minY
        timeView.textColor = WhiteColor
        timeView.backgroundColor = BlackColor.withAlphaComponent(0.83)
        view.addSubview(timeView)
        
        if duration > 0.0, let cover = cover {
            playView.coverView.image = cover
            timeLabel.text = "00:00/\(Date(timeIntervalSince1970: ceil(duration)).mn.playTime)"
            tailorView.reloadFrames()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.failure("初始化视频失败")
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard player.isPlaying else { return }
        player.pause()
    }
    
    private func failure(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.mn.pop()
        }))
    }
}

// MARK: - Event
extension MNTailorViewController {
    
    /// 关闭按钮点击事件
    /// - Parameter sender: 按钮
    @objc func closeButtonTouchUpInside(_ sender: UIButton) {
        if let delegate = delegate, delegate.responds(to: #selector(delegate.tailorControllerDidCancel)) {
            delegate.tailorControllerDidCancel?(self)
        } else {
            self.mn.pop()
        }
    }
    
    /// 播放按钮点击事件
    /// - Parameter sender: 播放/暂停按钮
    @objc func playControlTouchUpInside(_ sender: UIButton) {
        guard tailorView.isDragging == false else { return }
        guard player.status.rawValue > MNPlayer.Status.failed.rawValue else { return }
        if player.isPlaying {
            // 暂停
            player.pause()
        } else if tailorView.isEnding {
            // 结束已达到结束状态
            playControl.isUserInteractionEnabled = false
            UIView.animate(withDuration: AnimationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.tailorView.pointer.alpha = 0.0
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.tailorView.movePointerToBegin()
                self.player.seek(progress: self.tailorView.progress) { [weak self] _ in
                    UIView.animate(withDuration: self?.AnimationDuration ?? 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) {
                        guard let self = self else { return }
                        self.tailorView.pointer.alpha = 1.0
                    } completion: { _ in
                        guard let self = self else { return }
                        self.player.play()
                        self.playControl.isUserInteractionEnabled = true
                    }
                }
            }
        } else {
            // 播放
            player.play()
        }
    }
    
    /// 确定按钮点击事件
    /// - Parameter sender: 按钮
    @objc func doneButtonTouchUpInside(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
        }
        let begin = tailorView.begin
        let end = tailorView.end
        let videoPath = videoPath
        let outputPath: String = outputPath ?? "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)/videos/\(NSNumber(value: Int64(Date().timeIntervalSince1970*1000.0)).stringValue).mp4"
        if (end - begin) >= 0.99 {
            // 询问是否可以复制视频
            guard (delegate?.tailorControllerShouldCopyVideo?(self) ?? true) == true else { return }
            // 原视频 拷贝视频即可
            MNToast.showActivity("视频导出中")
            DispatchQueue.global().async { [weak self] in
                let url: URL = URL(fileAtPath: outputPath)
                do {
                    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
                } catch {
#if DEBUG
                    print("创建文件夹失败:\(error)")
#endif
                    DispatchQueue.main.async {
                        MNToast.showMsg("创建文件夹失败")
                    }
                    return
                }
                do {
                    try FileManager.default.copyItem(atPath: videoPath, toPath: outputPath)
                } catch {
#if DEBUG
                    print("拷贝视频失败:\(error)")
#endif
                    DispatchQueue.main.async {
                        MNToast.showMsg("拷贝视频失败")
                    }
                    return
                }
                // 回调结果
                MNToast.close { _ in
                    guard let self = self else { return }
                    self.delegate?.tailorController(self, didOutputVideoAtPath: outputPath)
                }
            }
        } else {
            /*
            guard let exporter = MNAssetExporter(fileAtPath: videoPath) else {
                MNToast.showMsg("解析视频失败")
                return
            }
            MNToast.showProgress("正在导出", style: .fill)
            exporter.outputURL = URL(fileURLWithPath: exportingPath)
            exporter.timeRange = exporter.asset.progressRange(from: begin, to: end)
            //exporter.presetName = AVAssetExportPresetMediumQuality
            exporter.exportAsynchronously { value in
                MNToast.showProgress(nil, style: .fill, value: value)
            } completionHandler: { [weak self] status, error in
                if status == .completed {
                    MNToast.close {
                        guard let self = self else { return }
                        self.delegate?.tailorController(self, didOutputVideoAtPath: exportingPath)
                    }
                } else if let error = error {
                    MNToast.showMsg(error.localizedDescription)
                } else {
                    MNToast.showMsg("视频导出失败")
                }
            }
             */
            guard let exportSession = MNAssetExportSession(fileAtPath: videoPath) else {
                MNToast.showMsg("解析视频失败")
                return
            }
            let z = MNAssetExportSession.renderSize(fileAtPath: videoPath)
            let w = ceil(z.height/2.0)
            //let x = 0.0
            let x = ceil((z.width - w)/2.0)
            //let x = z.width - w
            let cropRect = CGRect(origin: .init(x: x, y: z.height - w), size: .init(width: w, height: w))
            
            let playerLayer = playView.layer as! AVPlayerLayer
            let playerVideoRect = playerLayer.videoRect
            
            let cropInPlayerW = ceil(playView.frame.height/2.0)
            let cropInPlayerX = ceil((playView.frame.width - cropInPlayerW)/2.0)
            let cropInPlayer = CGRect(origin: .init(x: cropInPlayerX, y: playView.frame.height - cropInPlayerW), size: .init(width: cropInPlayerW, height: cropInPlayerW))
            
            let scaleX = z.width / playerVideoRect.width
            let scaleY = z.height / playerVideoRect.height

            let cropX = (cropInPlayer.origin.x - playerVideoRect.origin.x) * scaleX
            let cropY = (cropInPlayer.origin.y - playerVideoRect.origin.y) * scaleY
            let cropW = cropInPlayer.width * scaleX
            let cropH = cropInPlayer.height * scaleY
            
            let croppRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
            
            exportSession.cropRect = cropRect
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.renderSize = .init(width: 1080.0, height: 1080.0)
            exportSession.timeRange = exportSession.asset.mn.timeRange(withProgress: begin, to: end)
            if #available(iOS 16.0, *) {
                exportSession.outputURL = URL(filePath: outputPath)
            } else {
                exportSession.outputURL = URL(fileURLWithPath: outputPath)
            }
            MNToast.showProgress("正在导出", style: .line, cancellation: true) { [weak exportSession] cancellation in
                guard cancellation else { return }
                guard let exportSession = exportSession else { return }
                exportSession.cancel()
             }
            exportSession.exportAsynchronously { value in
                MNToast.showProgress(value: value)
            } completionHandler: { [weak self] status, error in
                if status == .completed {
                    MNToast.close { _ in
                        guard let self = self else { return }
                        self.delegate?.tailorController(self, didOutputVideoAtPath: outputPath)
                    }
                } else if let error = error {
                    MNToast.showMsg(error.localizedDescription)
                } else {
                    MNToast.showMsg("视频导出失败")
                }
            }
        }
    }
}

// MARK: - MNTailorViewDelegate
extension MNTailorViewController: MNTailorViewDelegate {
    
    func tailorViewBeginLoadThumbnail(_ tailorView: MNTailorView) {
        indicatorView.startAnimating()
    }
    
    func tailorViewLoadThumbnailNotSatisfy(_ tailorView: MNTailorView) {
        indicatorView.stopAnimating()
        failure("视频不满足裁剪时长")
    }
    
    func tailorViewLoadThumbnailFailed(_ tailorView: MNTailorView) {
        indicatorView.stopAnimating()
        failure("无法解析视频文件")
    }
    
    func tailorViewDidEndLoadThumbnail(_ tailorView: MNTailorView) {
        playView.player = player.player
        player.play()
    }
    
    func tailorViewLeftHandlerBeginDragging(_ tailorView: MNTailorView) {
        tailorView.isPlaying = player.isPlaying
        player.pause()
        timeView.isHidden = false
        timeView.update(duration: duration*tailorView.begin)
        timeView.mn.midX = tailorView.tailorHandler.leftHandler.frame.maxX + tailorView.frame.minX
    }
    
    func tailorViewLeftHandlerDidDragging(_ tailorView: MNTailorView) {
        let begin = tailorView.begin
        player.seek(progress: begin, completion: nil)
        timeView.update(duration: duration*begin)
        timeView.mn.midX = tailorView.tailorHandler.leftHandler.frame.maxX + tailorView.frame.minX
    }
    
    func tailorViewLeftHandlerEndDragging(_ tailorView: MNTailorView) {
        timeView.isHidden = true
        player.seek(progress: tailorView.begin) { [weak self] finish in
            guard finish, let self = self, self.tailorView.isPlaying else { return }
            self.player.play()
        }
    }
    
    func tailorViewRightHandlerBeginDragging(_ tailorView: MNTailorView) {
        tailorView.isPlaying = player.isPlaying
        player.pause()
        timeView.isHidden = false
        timeView.update(duration: duration*tailorView.end)
        timeView.mn.midX = tailorView.tailorHandler.rightHandler.frame.minX + tailorView.frame.minX
    }
    
    func tailorViewRightHandlerDidDragging(_ tailorView: MNTailorView) {
        let end = tailorView.end
        player.seek(progress: end, completion: nil)
        timeView.update(duration: duration*end)
        timeView.mn.midX = tailorView.tailorHandler.rightHandler.frame.minX + tailorView.frame.minX
    }
    
    func tailorViewRightHandlerEndDragging(_ tailorView: MNTailorView) {
        timeView.isHidden = true
        player.seek(progress: tailorView.progress) { [weak self] finish in
            guard finish, let self = self, self.tailorView.isPlaying, self.tailorView.isEnding == false else { return }
            self.player.play()
        }
    }
    
    func tailorViewPointerBeginDragging(_ tailorView: MNTailorView) {
        tailorView.isPlaying = player.isPlaying
        player.pause()
        timeView.isHidden = false
        timeView.update(duration: tailorView.progress*duration)
        timeView.mn.midX = tailorView.pointer.frame.midX + tailorView.frame.minX
    }
    
    func tailorViewPointerDidDragging(_ tailorView: MNTailorView) {
        let progress = tailorView.progress
        player.seek(progress: progress, completion: nil)
        timeView.update(duration: progress*duration)
        timeView.mn.midX = tailorView.pointer.frame.midX + tailorView.frame.minX
    }
    
    func tailorViewPointerDidEndDragging(_ tailorView: MNTailorView) {
        timeView.isHidden = true
        player.seek(progress: tailorView.progress) { [weak self] finish in
            guard finish, let self = self, self.tailorView.isPlaying else { return }
            self.player.play()
        }
    }
    
    func tailorViewBeginDragging(_ tailorView: MNTailorView) {
        tailorView.isPlaying = player.isPlaying
        player.pause()
        timeView.isHidden = false
        timeView.update(duration: duration*tailorView.begin)
        timeView.mn.midX = tailorView.tailorHandler.leftHandler.frame.maxX + tailorView.frame.minX
    }
    
    func tailorViewDidDragging(_ tailorView: MNTailorView) {
        let begin = tailorView.begin
        player.seek(progress: begin, completion: nil)
        timeView.update(duration: duration*begin)
    }
    
    func tailorViewDidEndDragging(_ tailorView: MNTailorView) {
        timeView.isHidden = true
        player.seek(progress: tailorView.begin) { [weak self] finish in
            guard finish, let self = self, self.tailorView.isPlaying else { return }
            self.player.play()
        }
    }
    
    func tailorViewShouldEndPlaying(_ tailorView: MNTailorView) {
        guard player.status != .finished else { return }
        player.pause()
    }
}

// MARK: - MNPlayerDelegate
extension MNTailorViewController: MNPlayerDelegate {
    
    public func playerDidChangeStatus(_ player: MNPlayer) {
        if player.isPlaying {
            badgeView.isHighlighted = true
            if playView.coverView.alpha == 1.0 {
                indicatorView.stopAnimating()
                tailorView.isUserInteractionEnabled = true
                playControl.isUserInteractionEnabled = true
                doneButton.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.18, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.playView.coverView.alpha = 0.0
                }, completion: nil)
            }
        } else {
            badgeView.isHighlighted = false
        }
    }
    
    public func playerDidPlayTimeInterval(_ player: MNPlayer) {
        guard player.isPlaying else { return }
        tailorView.progress = Double(player.progress)
        guard let components = timeLabel.text?.components(separatedBy: "/"), components.count == 2 else { return }
        timeLabel.text = "\(Date(timeIntervalSince1970: ceil(player.timeInterval)).mn.playTime)/\(components.last!)"
    }
    
    public func player(_ player: MNPlayer, didPlayFail error: Error) {
        indicatorView.stopAnimating()
        failure(error.localizedDescription)
    }
}
