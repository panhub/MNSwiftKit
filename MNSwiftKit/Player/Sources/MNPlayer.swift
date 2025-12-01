//
//  MNPlayer.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/25.
//  本地文件播放器

import UIKit
import Foundation
import AudioToolbox
import AVFoundation
import ObjectiveC.runtime

/// 播放器代理
@objc public protocol MNPlayerDelegate: NSObjectProtocol {
    
    /// 解码结束
    /// - Parameter player: 播放器
    @objc optional func playerDidEndDecode(_ player: MNPlayer)
    
    /// 播放时间回调
    /// - Parameter player: 播放器
    @objc optional func playerDidPlayTimeInterval(_ player: MNPlayer)
    
    /// 播放状态改变
    /// - Parameter player: 播放器
    @objc optional func playerDidChangeStatus(_ player: MNPlayer)
    
    /// 已经播放结束
    /// - Parameter player: 播放器
    @objc optional func playerDidPlayToEndTime(_ player: MNPlayer)
    
    /// 已加载时间
    /// - Parameter player: 播放器
    @objc optional func playerDidLoadTimeRanges(_ player: MNPlayer)
    
    /// 无缓冲内容
    /// - Parameter player: 播放器
    @objc optional func playerLikelyBufferEmpty(_ player: MNPlayer)
    
    /// 已缓冲可以播放
    /// - Parameter player: 播放器
    @objc optional func playerLikelyToKeepUp(_ player: MNPlayer)
    
    /// 准备播放
    /// - Parameter player: 播放器
    @objc optional func playerPreparePlayItem(_ player: MNPlayer)
    
    /// 想要播放下一项内容
    /// - Parameter player: 播放器
    /// - Returns: 是否允许继续播放下一项
    @objc optional func playerShouldPlayNextItem(_ player: MNPlayer) -> Bool
    
    /// 已经解码文件, 询问是否可以播放
    /// - Parameter player: 播放器
    /// - Returns: 是否可以播放
    @objc optional func playerShouldStartPlaying(_ player: MNPlayer) -> Bool
    
    /// 询问从哪里开始播放
    /// - Parameter player: 播放器
    /// - Returns: 开始播放的位置
    @objc optional func playerShouldPlayToBeginTime(_ player: MNPlayer) -> TimeInterval
    
    /// 播放失败
    /// - Parameters:
    ///   - player: 播放器
    ///   - error: 错误信息
    @objc optional func player(_ player: MNPlayer, didPlayFail error: Error)
}

/// 音视频播放器
public class MNPlayer: NSObject {
    
    /// 播放状态
    public enum Status: Int {
        /// 空闲
        case idle
        /// 失败
        case failed
        /// 正在播放
        case playing
        /// 暂停
        case pause
        /// 结束
        case finished
    }
    
    /// 当前状态
    public private(set) var status: Status = .idle {
        didSet {
            guard let delegate = delegate else { return }
            delegate.playerDidChangeStatus?(self)
        }
    }
    
    /// 是否在播放
    public var isPlaying: Bool { status == .playing }
    
    /// 当前播放地址
    public var url: URL? {
        guard let _ = player.currentItem else { return nil }
        return urls[playIndex]
    }
    
    /// 当前播放索引
    public private(set) var playIndex: Int = 0
    
    /// 当前播放的实例
    public var playItem: AVPlayerItem? { player.currentItem }
    
    /// 语音会话类型
    public var sessionCategory: AVAudioSession.Category = .playAndRecord
    
    /// 文件时长
    public var duration: TimeInterval {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else { return 0.0 }
        return TimeInterval(max(0.0, CMTimeGetSeconds(currentItem.duration)))
    }
    
    /// 当前播放时长
    public var timeInterval: TimeInterval {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else { return 0.0 }
        return TimeInterval(max(0.0, CMTimeGetSeconds(currentItem.currentTime())))
    }
    
    /// 播放进度
    public var progress: Float {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else { return 0.0 }
        if status == .finished { return 1.0 }
        let duration = CMTimeGetSeconds(currentItem.duration)
        let current = CMTimeGetSeconds(currentItem.currentTime())
        let progress = current/duration
        if progress.isNaN { return 0.0 }
        return Float(max(0.0, min(progress, 1.0)))
    }
    
    /// 缓冲进度
    public var buffer: Float {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else { return 0.0 }
        let ranges = currentItem.loadedTimeRanges
        guard ranges.count > 0 else { return 0.0 }
        let timeRange = ranges.last!.timeRangeValue
        let start = CMTimeGetSeconds(timeRange.start)
        let length = CMTimeGetSeconds(timeRange.duration)
        let total = start + length
        let duration = CMTimeGetSeconds(currentItem.duration)
        let progress = Float(total/duration)
        if progress.isNaN { return 0.0 }
        return min(1.0, max(0.0, progress))
    }
    
    /// 速率
    public var rate: Float {
        get { player.rate }
        set { player.rate = newValue }
    }
    
    /// 音量
    public var volume: Float {
        get { player.volume }
        set { player.volume = newValue }
    }
    
    /// 是否允许使用缓存
    public var isAllowsUsingCache: Bool = false
    
    /// 文件资源
    private var urls: [URL] = [URL]()
    
    /// 当前播放器有多少条资源
    public var count: Int { urls.count }
    
    /// 播放实例的缓存
    private var items: [String:AVPlayerItem] = [String:AVPlayerItem]()
    
    /// 内部播放器
    public let player: AVPlayer = AVPlayer()
    
    /// 监听者
    private var observer: Any?
    
    /// 代理
    public weak var delegate: MNPlayerDelegate?
    
    /// 监听周期
    public var periodicFrequency: Int = 0 {
        willSet {
            guard let observer = observer else { return }
            player.removeTimeObserver(observer)
            self.observer = nil
        }
        didSet {
            guard periodicFrequency > 0 else { return }
            observer = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: CMTimeScale(periodicFrequency)), queue: DispatchQueue.main) { [weak self] time in
                guard let self = self else { return }
                guard let delegate = self.delegate else { return }
                delegate.playerDidPlayTimeInterval?(self)
            }
        }
    }
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime(notify:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorLogEntry(notify:)), name: .AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToEndTime(notify:)), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(silenceSecondaryAudioHint(notify:)), name: AVAudioSession.silenceSecondaryAudioHintNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(routeChange(notify:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruption(notify:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    deinit {
        delegate = nil
        removeAll()
        if let observer = observer { player.removeTimeObserver(observer) }
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 构造播放器
    /// - Parameter urls: 播放地址
    public convenience init(urls: [URL]) {
        self.init()
        for url in urls {
            guard url.isFileURL, FileManager.default.fileExists(atPath: url.path) else { continue }
            self.urls.append(url)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case #keyPath(AVPlayerItem.status):
            guard let change = change, let value = change[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: value) else { break }
            switch status {
            case .readyToPlay:
                guard self.status == .idle else { return }
                if let delegate = delegate {
                    delegate.playerDidEndDecode?(self)
                }
                var play = true
                if let delegate = delegate, let flag = delegate.playerShouldStartPlaying?(self) {
                    play = flag
                }
                if play {
                    guard sessionActive() else {
                        failed(.setCategoryFailed(sessionCategory.rawValue))
                        return
                    }
                    var seconds = 0.0
                    if let delegate = delegate, let time = delegate.playerShouldPlayToBeginTime?(self), time > 0.0 {
                        seconds = time
                    }
                    seek(seconds: seconds) { [weak self] finish in
                        guard let self = self else { return }
                        if finish {
                            self.player.play()
                            self.status = .playing
                        } else {
                            self.player.pause()
                            self.failed(.seekFailed("\(seconds)s"))
                        }
                    }
                } else {
                    player.pause()
                    self.status = .pause
                }
            case .failed:
                player.pause()
                if let error = player.error {
                    failed(.underlyingError(error))
                } else {
                    failed(.playFailed)
                }
            default: break
            }
        case #keyPath(AVPlayerItem.loadedTimeRanges):
            if let delegate = delegate {
                delegate.playerDidLoadTimeRanges?(self)
            }
        case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
            if let delegate = delegate {
                delegate.playerLikelyBufferEmpty?(self)
            }
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
            if let delegate = delegate {
                delegate.playerLikelyToKeepUp?(self)
            }
        default: break
        }
    }
}

// MARK: - 播放/暂停
extension MNPlayer {
    
    /// 即将开始播放
    public func prepare() {
        guard playIndex < urls.count else { return }
        replaceCurrentItemWithNil()
        objc_sync_enter(self)
        let playerItem = playerItem(for: urls[playIndex])
        addObserver(with: playerItem)
        player.replaceCurrentItem(with: playerItem)
        objc_sync_exit(self)
        if let delegate = delegate {
            delegate.playerPreparePlayItem?(self)
        }
    }
    
    /// 获取播放内容
    /// - Parameter url: 链接
    /// - Returns: 播放内容
    public func playerItem(for url: URL) -> AVPlayerItem {
        let key = url.isFileURL ? url.path : url.absoluteString
        var playerItem: AVPlayerItem! = items[key]
        if let _ = playerItem { return playerItem }
        playerItem = AVPlayerItem(url: url)
        for track in playerItem.tracks {
            guard let assetTrack = track.assetTrack else { continue }
            if assetTrack.mediaType == .audio {
                track.isEnabled = true
            }
        }
        if isAllowsUsingCache, key.isEmpty == false {
            items[key] = playerItem
        }
        return playerItem
    }
    
    /// 暂停
    public func pause() {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else { return }
        player.pause()
        status = .pause
    }
    
    /// 播放
    public func play() {
        guard isPlaying == false else { return }
        guard sessionActive() else {
            failed(.setCategoryFailed(sessionCategory.rawValue))
            return
        }
        guard let currentItem = player.currentItem else {
            prepare()
            return
        }
        guard currentItem.status == .readyToPlay else { return }
        if status == .finished {
            // 跳转开始部分
            var time = 0.0
            if let delegate = delegate, let begin = delegate.playerShouldPlayToBeginTime?(self), begin > 0.0 {
                time = begin
            }
            seek(seconds: time) { [weak self] _ in
                guard let self = self else { return }
                self.player.play()
                self.status = .playing
            }
        } else {
            player.play()
            status = .playing
        }
    }
    
    /// 往前
    public func forward() {
        guard urls.count > 1, playIndex > 0 else { return }
        playIndex -= 1
        prepare()
    }
    
    /// 播放下一个
    public func playNext() {
        guard playIndex < (urls.count - 1) else { return }
        playIndex += 1
        prepare()
    }
    
    /// 播放指定索引
    /// - Parameter index: 指定索引
    public func play(index: Int) {
        guard index < urls.count else { return }
        playIndex = index
        prepare()
    }
    
    /// 重新播放
    public func replay() {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else {
            prepare()
            return
        }
        guard sessionActive() else {
            failed(.setCategoryFailed(sessionCategory.rawValue))
            return
        }
        if status == .playing {
            pause()
        }
        var time = 0.0
        if let delegate = delegate, let begin = delegate.playerShouldPlayToBeginTime?(self), begin > 0.0 {
            time = begin
        }
        seek(seconds: time) { [weak self] _ in
            guard let self = self else { return }
            self.player.play()
            self.status = .playing
        }
    }
    
    /// 更新播放地址
    /// - Parameters:
    ///   - url: 文件地址
    ///   - index: 索引
    public func update(url: URL, index: Int) {
        guard index < urls.count else { return }
        let old = urls[index]
        let key = old.isFileURL ? old.path : old.absoluteString
        items.removeValue(forKey: key)
        urls.remove(at: index)
        urls.insert(url, at: index)
    }
}

// MARK: -
extension MNPlayer {
    
    /// 删除所有播放内容
    public func removeAll() {
        guard urls.isEmpty == false else { return }
        replaceCurrentItemWithNil()
        urls.removeAll()
        items.removeAll()
        playIndex = 0
        status = .idle
    }
    
    /// 判断是否包含某个播放链接
    /// - Parameter url: 指定链接
    /// - Returns: 是否包含
    public func contains(_ url: URL) -> Bool {
        urls.contains { $0.path == url.path || $0.absoluteString == url.absoluteString }
    }
    
    /// 添加内容
    /// - Parameter urls: 播放链接
    public func add(_ urls: [URL]) {
        for url in urls {
            guard url.isFileURL, FileManager.default.fileExists(atPath: url.path) else { continue }
            self.urls.append(url)
        }
    }
    
    /// 插入播放链接
    /// - Parameters:
    ///   - url: 播放链接
    ///   - index: 指定位置
    public func insert(_ url: URL, at index: Int) {
        guard index <= urls.count else { return }
        guard url.isFileURL, FileManager.default.fileExists(atPath: url.path) else { return }
        urls.insert(url, at: index)
    }
}

// MARK: - Seek
extension MNPlayer {
    
    /// 跳转到指定位置
    /// - Parameters:
    ///   - value: 进度
    ///   - completion: 跳转结束
    public func seek<T>(progress value: T, completion: ((_ isSuccess: Bool)->Void)? = nil) where T: BinaryFloatingPoint {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else {
            completion?(false)
            return
        }
        let progress = Float64(value)
        let time = CMTimeMultiplyByFloat64(currentItem.duration, multiplier: progress)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completion ?? { _ in })
    }
    
    /// 跳转到指定秒数
    /// - Parameters:
    ///   - value: 秒数
    ///   - completion: 跳转结束回调
    public func seek<T>(seconds value: T, completion: ((_ isSuccess: Bool)->Void)? = nil) where T: BinaryFloatingPoint {
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else {
            completion?(false)
            return
        }
        let seconds = TimeInterval(value)
        let time = CMTime(seconds: seconds, preferredTimescale: currentItem.duration.timescale)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completion ?? { _ in })
    }
}

// MARK: - Notification
private extension MNPlayer {
    
    // 播放结束
    @objc func playToEndTime(notify: Notification) {
        guard let object = notify.object as? AVPlayerItem, let currentItem = player.currentItem else { return }
        guard object == currentItem else { return }
        var play = false
        if let delegate = delegate, let flag = delegate.playerShouldPlayNextItem?(self) {
            play = flag
        }
        if play {
            if playIndex >= (urls.count - 1) {
                // 最后一曲, 从第一曲开始
                self.play(index: 0)
            } else {
                // 下一曲
                playNext()
            }
        } else {
            status = .finished
            if let delegate = delegate {
                delegate.playerDidPlayToEndTime?(self)
            }
        }
    }
    
    @objc func failedToEndTime(notify: Notification) {
        guard let object = notify.object as? AVPlayerItem, let currentItem = player.currentItem else { return }
        guard object == currentItem else { return }
        player.pause()
        status = .failed
        if let userInfo = notify.userInfo, let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            failed(.underlyingError(error))
        } else {
            failed(.playFailed)
        }
    }
    
    @objc func errorLogEntry(notify: Notification) {
        guard let object = notify.object as? AVPlayerItem, let currentItem = player.currentItem else { return }
        guard object == currentItem else { return }
#if DEBUG
        if let error = currentItem.error {
            print(error)
        }
#endif
    }
    
    // 其他App独占事件
    @objc func silenceSecondaryAudioHint(notify: Notification) {
        guard let userInfo = notify.userInfo, let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt, let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else { return }
        if type == .begin {
            pause()
        }
    }
    
    // 耳机事件
    @objc func routeChange(notify: Notification) {
        guard let userInfo = notify.userInfo, let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt, let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
        if reason == .oldDeviceUnavailable {
            // 旧设备不可用
            guard let route = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription, route.outputs.count > 0, let output = route.outputs.first else { return }
            if output.portType == .headphones {
                // 暂停播放
                pause()
            }
        }
    }
    
    // 中断事件
    // https://www.jianshu.com/p/13274ee362f3
    @objc func sessionInterruption(notify: Notification) {
        guard let userInfo = notify.userInfo, let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt, let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        switch type {
        case .began:
#if DEBUG
            if #available(iOS 14.5, *) {
                if let reasonValue = userInfo[AVAudioSessionInterruptionReasonKey] as? UInt, let reason = AVAudioSession.InterruptionReason(rawValue: reasonValue) {
                    switch reason {
                    case .default:
                        print("因另一个会话被激活, 音/视频中断")
                    case .appWasSuspended:
                        print("因App被系统挂起, 音/视频中断")
                    case .builtInMicMuted:
                        print("因内置麦克风静音而中断 (例如iPad智能关闭套iPad's Smart Folio关闭)")
                    default: break
                    }
                }
            } else if #available(iOS 10.3, *) {
                if let suspended = userInfo[AVAudioSessionInterruptionWasSuspendedKey] as? Bool {
                    if suspended {
                        print("因App被系统挂起, 音/视频中断")
                    } else {
                        print("因另一个会话被激活, 音/视频中断")
                    }
                }
            }
#endif
            if status == .playing {
                pause()
            }
        case .ended:
            if let optionValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionValue)
                if options == .shouldResume {
                    player.play()
                    status = .playing
#if DEBUG
                    print("中断结束, 音/视频恢复播放")
#endif
                }
            }
        default: break
        }
    }
}

// MARK: - Private
extension MNPlayer {
    
    private func failed(_ error: MNPlayError) {
        status = .failed
        if let delegate = delegate {
            delegate.player?(self, didPlayFail: error)
        }
    }
    
    private func replaceCurrentItemWithNil() {
        guard let currentItem = player.currentItem else { return }
        if currentItem.status == .readyToPlay { player.pause() }
        removeObserver(with: currentItem)
        player.replaceCurrentItem(with: nil)
        status = .idle
        if let delegate = delegate {
            delegate.playerDidChangeStatus?(self)
        }
    }
    
    private func addObserver(with playerItem: AVPlayerItem?) {
        guard let item = playerItem, item.isObserved == false else { return }
        item.isObserved = true
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.old, .new], context: nil)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: [.old, .new], context: nil)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.old, .new], context: nil)
    }
    
    private func removeObserver(with playerItem: AVPlayerItem?) {
        guard let item = playerItem, item.isObserved else { return }
        item.isObserved = false
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
    }
    
    private func sessionActive() -> Bool {
        let category: AVAudioSession.Category = sessionCategory
        if AVAudioSession.sharedInstance().category != category {
            do {
                try AVAudioSession.sharedInstance().setCategory(category)
            } catch {
                return false
            }
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            return false
        }
        return true
    }
}

// MARK: - 检测AVPlayerItem
private extension AVPlayerItem {
    
    struct MNAssociatedKey {
        
        nonisolated(unsafe) static var isObserved = "com.mn.player.item.observed"
    }
    
    var isObserved: Bool {
        get {
            guard let result = objc_getAssociatedObject(self, AVPlayerItem.MNAssociatedKey.isObserved) as? Bool else { return false }
            return result
        }
        set {
            objc_setAssociatedObject(self, AVPlayerItem.MNAssociatedKey.isObserved, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

// MARK: - 音效
extension MNPlayer: PlaySoundSupported {}

// MARK: - 播放音效支持
public protocol PlaySoundSupported {}
extension PlaySoundSupported {
    
    /// 播放震动音效
    func vibration() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// 播放系统音效
    /// - Parameters:
    ///   - path: 注册路径
    ///   - vibration: 是否震动
    ///   - completion: 结束回调
    func playSound(atPath path: String, vibration: Bool, completion: (() -> Void)? = nil) {
        guard FileManager.default.fileExists(atPath: path) else { return }
        var id: SystemSoundID = 0
        guard AudioServicesCreateSystemSoundID(URL(fileURLWithPath: path) as CFURL, &id) == noErr else { return }
        //guard AudioServicesAddSystemSoundCompletion(id, nil, nil, { _, _ in }, nil) == noErr else { return }
        playSound(id, vibration: vibration, completion: completion)
    }
    
    /// 播放系统音效
    /// - Parameters:
    ///   - id: 系统音效标识
    ///   - vibration: 是否震动
    ///   - completion: 结束回调
    func playSound(_ id: SystemSoundID, vibration: Bool, completion: (() -> Void)?) {
        if vibration, id != kSystemSoundID_Vibrate {
            AudioServicesPlayAlertSoundWithCompletion(id, completion)
        } else {
            AudioServicesPlaySystemSoundWithCompletion(id, completion)
        }
    }
}
