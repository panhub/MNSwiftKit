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
    /// 时间中心点约束
    private var timeCenterXConstraint: NSLayoutConstraint!
    /// 视频尺寸
    private var naturalSize: CGSize = CGSize(width: 1920.0, height: 1080.0)
    /// 最小裁剪时长
    public var minTailorDuration: TimeInterval = 0.0
    /// 最大裁剪时长
    public var maxTailorDuration: TimeInterval = 0.0
    /// 时间显示
    private let timeLabel: UILabel = UILabel()
    /// 播放/暂停标记
    private let badgeView: UIImageView = UIImageView()
    /// 视频播放视图
    private let playView: MNPlayView = MNPlayView()
    /// 时间显示
    private let timeView: MNTailorTimeView = MNTailorTimeView()
    /// 播放/暂停控制
    private let playControl: UIControl = UIControl()
    /// 裁剪视图
    private let tailorView: MNTailorView = MNTailorView()
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
        let naturalSize = MNAssetExportSession.naturalSize(videoAtPath: videoPath)
        if naturalSize.width > 0.0, naturalSize.height > 0.0 {
            self.naturalSize = naturalSize
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
    }
    
    /// 创建子视图
    private func createSubview() {
        
        // 导航栏 适配资源选择器
        var statusBarHeight = 0.0
        var navigationViewHeight = 55.0
        if let window = UIWindow.mn.current, view.bounds == window.bounds {
            // 全屏展示
            statusBarHeight = MN_STATUS_BAR_HEIGHT
            navigationViewHeight = MN_NAV_BAR_HEIGHT
        }
        
        // 返回按钮
        let backImage = AssetPickerResource.image(named: "picker_back")
        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(self.backButtonTouchUpInside(_:)), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            backButton.configuration = configuration
            backButton.configurationUpdateHandler = { button in
                switch button.state {
                case .normal, .highlighted:
                    button.configuration?.background.image = backImage
                default: break
                }
            }
        } else {
            backButton.adjustsImageWhenHighlighted = false
            backButton.setBackgroundImage(backImage, for: .normal)
        }
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24.0),
            backButton.heightAnchor.constraint(equalToConstant: 24.0),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight + (navigationViewHeight - 24.0)/2.0)
        ])
        
        // 导航右按钮
        let doneImage = AssetPickerResource.image(named: "picker_crop_done")
        let doneButton = UIButton(type: .custom)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTouchUpInside(_:)), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            doneButton.configuration = configuration
            doneButton.configurationUpdateHandler = { button in
                switch button.state {
                case .normal, .highlighted:
                    button.configuration?.background.image = doneImage
                default: break
                }
            }
        } else {
            doneButton.adjustsImageWhenHighlighted = false
            doneButton.setBackgroundImage(doneImage, for: .normal)
        }
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 24.0),
            doneButton.heightAnchor.constraint(equalToConstant: 24.0),
            doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant:  statusBarHeight + (navigationViewHeight - 24.0)/2.0)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = "视频裁剪"
        titleLabel.numberOfLines = 1
        titleLabel.font = .systemFont(ofSize: 17.0, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = WhiteColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
        
        timeLabel.numberOfLines = 1
        timeLabel.textColor = WhiteColor
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 13.0, weight: .medium)
        timeLabel.text = "00:00/\(Date(timeIntervalSince1970: ceil(duration)).mn.playTime)"
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.heightAnchor.constraint(equalToConstant: 13.0),
            timeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -max(MN_BOTTOM_SAFE_HEIGHT, 17.0)),
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        playControl.isUserInteractionEnabled = false
        playControl.backgroundColor = BlackColor
        playControl.addTarget(self, action: #selector(playControlTouchUpInside(_:)), for: .touchUpInside)
        playControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playControl)
        NSLayoutConstraint.activate([
            playControl.widthAnchor.constraint(equalToConstant: 48.0),
            playControl.heightAnchor.constraint(equalToConstant: 48.0),
            playControl.leftAnchor.constraint(equalTo: backButton.leftAnchor),
            playControl.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -20.0)
        ])
        
        badgeView.contentMode = .scaleAspectFit
        badgeView.image = AssetPickerResource.image(named: "player_play")
        badgeView.highlightedImage = AssetPickerResource.image(named: "player_pause")
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        playControl.addSubview(badgeView)
        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalToConstant: 25.0),
            badgeView.heightAnchor.constraint(equalToConstant: 25.0),
            badgeView.centerXAnchor.constraint(equalTo: playControl.centerXAnchor),
            badgeView.centerYAnchor.constraint(equalTo: playControl.centerYAnchor)
        ])
        
        tailorView.delegate = self
        tailorView.videoPath = videoPath
        tailorView.backgroundColor = BlackColor
        tailorView.minTailorDuration = minTailorDuration
        tailorView.maxTailorDuration = maxTailorDuration
        tailorView.isUserInteractionEnabled = false
        tailorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tailorView)
        NSLayoutConstraint.activate([
            tailorView.topAnchor.constraint(equalTo: playControl.topAnchor),
            tailorView.leftAnchor.constraint(equalTo: playControl.rightAnchor, constant: 1.5),
            tailorView.rightAnchor.constraint(equalTo: doneButton.rightAnchor),
            tailorView.heightAnchor.constraint(equalTo: playControl.heightAnchor)
        ])
        
        playView.isTouchEnabled = false
        playView.videoGravity = .resizeAspect
        //playView.backgroundColor = BlackColor
        playView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playView)
        NSLayoutConstraint.activate([
            playView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20.0),
            playView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
            playView.bottomAnchor.constraint(equalTo: playControl.topAnchor, constant: -20.0),
            playView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0)
        ])
        
        indicatorView.color = WhiteColor
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: playView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: playView.centerYAnchor)
        ])
        
        timeView.isHidden = true
        timeView.textColor = WhiteColor
        timeView.backgroundColor = BlackColor.withAlphaComponent(0.83)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeView)
        timeCenterXConstraint = timeView.centerXAnchor.constraint(equalTo: tailorView.leftAnchor)
        NSLayoutConstraint.activate([
            timeCenterXConstraint,
            timeView.widthAnchor.constraint(equalToConstant: 40.0),
            timeView.heightAnchor.constraint(equalToConstant: 27.0),
            timeView.bottomAnchor.constraint(equalTo: tailorView.topAnchor)
        ])
        
        // 这里还没布局好视图, 先不加载截图
        if duration > 0.0, let cover = cover {
            playView.coverView.image = cover
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard view.mn.isFirstAssociated else { return }
        createSubview()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard mn.isFirstAssociated else { return }
        playControl.layer.mn.setRadius(5.0, by: [.topLeft, .bottomLeft])
        if let _ = playView.coverView.image {
            tailorView.reloadFrames()
        } else {
            failure("视频初始化失败")
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
    @objc func backButtonTouchUpInside(_ sender: UIButton) {
        if let delegate = delegate, delegate.responds(to: #selector(delegate.tailorControllerDidCancel)) {
            delegate.tailorControllerDidCancel?(self)
        } else {
            mn.pop()
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
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.tailorView.pointer.alpha = 0.0
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.tailorView.movePointerToBegin()
                self.player.seek(progress: self.tailorView.progress) { [weak self] _ in
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) {
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
        let outputPath: String = outputPath ?? "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)/videos/dr/\(NSNumber(value: Int64(Date().timeIntervalSince1970*1000.0)).stringValue).mp4"
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
            var outputURL: URL
            if #available(iOS 16.0, *) {
                outputURL = URL(filePath: outputPath)
            } else {
                outputURL = URL(fileURLWithPath: outputPath)
            }
            guard let exportSession = MNAssetExportSession(fileAtPath: videoPath, outputURL: outputURL) else {
                MNToast.showMsg("解析视频失败")
                return
            }
            exportSession.timeRange = exportSession.asset.mn.timeRange(withProgress: begin, to: end)
            MNToast.showProgress("正在导出", style: .circular, cancellation: true) { [weak exportSession] cancellation in
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
            /*
            guard let exportSession = MNMediaExportSession(fileAtPath: videoPath, outputURL: outputURL) else {
                MNToast.showMsg("解析视频失败")
                return
            }
            exportSession.timeRange = exportSession.asset.mn.timeRange(withProgress: begin, to: end)
            MNToast.showProgress("正在导出", style: .line)
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
            */
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
        timeView.update(time: duration*tailorView.begin)
        timeCenterXConstraint.constant = tailorView.tailorHandler.leftHandler.frame.maxX
    }
    
    func tailorViewLeftHandlerDidDragging(_ tailorView: MNTailorView) {
        let begin = tailorView.begin
        player.seek(progress: begin, completion: nil)
        timeView.update(time: duration*begin)
        timeCenterXConstraint.constant = tailorView.tailorHandler.leftHandler.frame.maxX
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
        timeView.update(time: duration*tailorView.end)
        timeCenterXConstraint.constant = tailorView.tailorHandler.rightHandler.frame.minX
    }
    
    func tailorViewRightHandlerDidDragging(_ tailorView: MNTailorView) {
        let end = tailorView.end
        player.seek(progress: end, completion: nil)
        timeView.update(time: duration*end)
        timeCenterXConstraint.constant = tailorView.tailorHandler.rightHandler.frame.minX
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
        timeView.update(time: tailorView.progress*duration)
        timeCenterXConstraint.constant = tailorView.pointer.frame.midX
    }
    
    func tailorViewPointerDidDragging(_ tailorView: MNTailorView) {
        let progress = tailorView.progress
        player.seek(progress: progress, completion: nil)
        timeView.update(time: progress*duration)
        timeCenterXConstraint.constant = tailorView.pointer.frame.midX
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
        timeView.update(time: duration*tailorView.begin)
        timeCenterXConstraint.constant = tailorView.tailorHandler.leftHandler.frame.maxX
    }
    
    func tailorViewDidDragging(_ tailorView: MNTailorView) {
        let begin = tailorView.begin
        player.seek(progress: begin, completion: nil)
        timeView.update(time: duration*begin)
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
