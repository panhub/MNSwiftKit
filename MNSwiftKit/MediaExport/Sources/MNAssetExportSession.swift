//
//  MNAssetExportSession.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/12/8.
//  音/视频转码切割

import Foundation
import AVFoundation

/// 媒体资源输出会话
public class MNAssetExportSession: NSObject {
    /// 获取资源信息
    public let asset: AVAsset
    /// 裁剪画面矩形
    public var cropRect: CGRect?
    /// 预设质量
    public var presetName: String?
    /// 输出文件路径
    /// - 支持的文件UTI: public.aiff-audio, com.apple.m4v-video, org.3gpp.adaptive-multi-rate-audio, com.apple.m4a-audio, com.microsoft.waveform-audio, com.apple.coreaudio-format, public.3gpp, public.mpeg-4, com.apple.quicktime-movie, public.aifc-audio
    /// - 支持的视频文件类型: .mp4, .m4v, .mov, .mobile3GPP
    /// - 支持的音频文件类型: .wav, .m4a, .caf, .amr, .aiff, .aifc
    /// - 以下文件UTI虽内部支持读写, 但由于本输出会话旨在输出广泛支持的开放格式音视频, 故不支持。
    /// - org.w3.webvtt: .vtt文件, 是一种现代的、基于纯文本的字幕和音轨描述文件格式。
    /// - com.scenarist.closed-caption: .scc文件, 是一种封闭式字幕文件, 主要用于存储视频中的字幕文本、时间码和显示位置等信息。
    /// - com.apple.immersive-video: .immersivevideo文件, 是一个苹果私有的封装格式, 主要用于 Apple Vision Pro 的“电视”应用中播放的专用内容。
    /// - com.apple.itunes-timed-text: .itt文件, 是苹果公司推出的一种支持丰富文本样式的XML字幕格式, 主要用于其自家的内容分发平台和专业视频编辑软件中。
    /// - org.3gpp.adaptive-multi-rate-audio: .amr文件, 系统仅支持解码, 编码需要第三方库, 故不支持编辑
    public var outputURL: URL!
    /// 输出分辨率outputRect有效时有效
    public var renderSize: CGSize?
    /// 裁剪片段
    public var timeRange: CMTimeRange?
    /// 输出格式
    public var outputFileType: AVFileType?
    /// 是否输出音频内容
    public var exportAudioTrack: Bool = true
    /// 是否输出视频内容
    public var exportVideoTrack: Bool = true
    /// 进度更新时间间隔
    public var progressUpdateInterval: TimeInterval = 0.15
    /// 是否针对网络使用进行优化
    public var shouldOptimizeForNetworkUse: Bool = true
    /// 系统输出
    private weak var exportSession: AVAssetExportSession?
    /// 查询进度
    private var timer: Timer!
    /// 错误信息
    public private(set) var error: Error?
    /// 进度
    public private(set) var progress: CGFloat = 0.0
    /// 状态
    public private(set) var status: AVAssetExportSession.Status = .unknown
    /// 进度回调
    private var progressHandler: ((CGFloat)->Void)?
    /// 结束回调
    private var completionHandler: ((AVAssetExportSession.Status, Error?)->Void)?
    
    /// 构造资源输出会话
    /// - Parameter asset: 媒体资源
    public init(asset: AVAsset) {
        self.asset = asset
    }
    
    /// 构造资源输出会话
    /// - Parameter filePath: 媒体资源路径
    public convenience init?(fileAtPath filePath: String) {
        guard let asset = AVURLAsset(fileAtPath: filePath) else { return nil }
        self.init(asset: asset)
    }
    
    /// 构造资源输出会话
    /// - Parameter url: 媒体资源定位器
    public convenience init(assetOfURL url: URL) {
        let asset = AVURLAsset(mediaOfURL: url)
        self.init(asset: asset)
    }
    
    deinit {
        exportSession = nil
        progressHandler = nil
        completionHandler = nil
        destroyTimer()
    }
    
    /// 异步导出资源
    /// - Parameters:
    ///   - progressHandler: 进度回调(主队列回调)
    ///   - completionHandler: 导出结束回调(主队列回调)
    public func exportAsynchronously(progressHandler: ((_ progress: CGFloat)->Void)? = nil, completionHandler: ((_ status: AVAssetExportSession.Status, _ error: Error?)->Void)?) {
        if status == .waiting || status == .exporting {
            DispatchQueue.main.async {
                completionHandler?(.failed, MNExportError.exporting)
            }
            return
        }
        error = nil
        exportSession = nil
        update(status: .waiting)
        update(progress: 0.0)
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        DispatchQueue(label: "com.mn.asset.export.session.queue", qos: .userInitiated).async {
            self.export()
        }
    }
    
    /// 开始输出资源
    private func export() {
        
        guard let outputURL = outputURL, outputURL.isFileURL else {
            finish(error: .unknownExportDirectory)
            return
        }
        
        // 检查文件类型
        guard let outputFileType = MNAssetExportSession.fileType(withExtension: outputURL.pathExtension) else {
            finish(error: .unknownFileType(outputURL.pathExtension))
            return
        }
        
        // 合成器
        let composition = AVMutableComposition()
        if exportVideoTrack, let videoTrack = asset.mn.track(with: AVMediaType.video) {
            guard composition.mn.append(track: videoTrack, range: timeRange) else {
                finish(error: .cannotAppendTrack(AVMediaType.video))
                return
            }
        }
        if exportAudioTrack, let audioTrack = asset.mn.track(with: AVMediaType.audio) {
            guard composition.mn.append(track: audioTrack, range: timeRange) else {
                finish(error: .cannotAppendTrack(AVMediaType.audio))
                return
            }
        }
        
        // 检查输出项
        guard composition.isExportable else {
            finish(error: .unexportable)
            return
        }
        
        // 寻找合适的预设质量
        let presetName = compatiblePresetName(with: composition)
        
        // 检查设置是否可以输出
        guard compatibility(ofExportPreset: presetName, with: composition, outputFileType: outputFileType) else {
            finish(error: .cannotExportFile(outputURL, fileType: outputFileType))
            return
        }
        
        // 删除本地文件
        var outputPath: String = ""
        if #available(iOS 16.0, *) {
            outputPath = outputURL.path(percentEncoded: false)
        } else {
            outputPath = outputURL.path
        }
        if FileManager.default.fileExists(atPath: outputPath) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
#if DEBUG
                print("删除旧文件失败: \(error)")
#endif
                finish(error: .fileDoesExist(outputURL))
                return
            }
        }
        let outputDirectory = (outputPath as NSString).deletingLastPathComponent
        if FileManager.default.fileExists(atPath: outputDirectory) == false {
            do {
                try FileManager.default.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("创建输出目录失败: \(error)")
#endif
                finish(error: .cannotCreateDirectory(error))
                return
            }
        }
        
        // 开始输出
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: presetName) else {
            finish(error: .cannotExportFile(outputURL, fileType: outputFileType))
            return
        }
        self.exportSession = exportSession
        if shouldOptimizeForNetworkUse, outputFileType != .m4v {
            exportSession.shouldOptimizeForNetworkUse = true
        }
        if let videoTrack = composition.mn.track(with: AVMediaType.video) {
            var createVideoComposition = false
            if let cropRect = cropRect, cropRect.isEmpty == false, cropRect.isNull == false {
                createVideoComposition = true
            } else if let renderSize = renderSize, min(renderSize.width, renderSize.height) > 0.0 {
                createVideoComposition = true
            }
            if createVideoComposition {
                var cropRect = CGRect(origin: CGPoint.zero, size: videoTrack.mn.naturalSize)
                if let rect = self.cropRect {
                    cropRect = cropRect.intersection(rect)
                }
                var renderSize = cropRect.size
                if let size = self.renderSize {
                    renderSize = size
                }
                // 渲染尺寸最好是偶数, 避免出错
                renderSize.width = CGFloat((Int(renderSize.width) + 1) & ~1)
                renderSize.height = CGFloat((Int(renderSize.height) + 1) & ~1)
                // 配置画面设置
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                layerInstruction.setOpacity(1.0, at: CMTime.zero)
                layerInstruction.setTransform(videoTrack.mn.transform(for: cropRect, renderSize: renderSize), at: CMTime.zero)
                
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRange(start: CMTime.zero, duration: composition.duration)
                instruction.layerInstructions = [layerInstruction]
                
                let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
                videoComposition.renderSize = renderSize
                videoComposition.instructions = [instruction]
                let minFrameDuration = videoTrack.mn.minFrameDuration
                if minFrameDuration.isValid, minFrameDuration.isIndefinite == false {
                    videoComposition.frameDuration = minFrameDuration
                } else {
                    // 默认30帧输出
                    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
                }
                exportSession.videoComposition = videoComposition
            }
        }
        if #available(iOS 18.0, *) {
            //
            Task {
                for await state in exportSession.states(updateInterval: self.progressUpdateInterval) {
                    switch state {
                    case .waiting:
                        self.update(status: .waiting)
                    case .exporting(progress: let progress):
                        self.update(status: .exporting)
                        let fractionCompleted = CGFloat(progress.fractionCompleted)
                        self.update(progress: fractionCompleted)
                        if let progressHandler = self.progressHandler {
                            DispatchQueue.main.async {
                                progressHandler(fractionCompleted)
                            }
                        }
                    default: break
                    }
                }
            }
            Task {
                do {
                    try await exportSession.export(to: outputURL, as: outputFileType)
                    self.update(progress: 1.0)
                    if let progressHandler = self.progressHandler {
                        DispatchQueue.main.async {
                            progressHandler(1.0)
                        }
                    }
                    self.update(status: .completed)
                    if let completionHandler = self.completionHandler {
                        DispatchQueue.main.async {
                            completionHandler(.completed, nil)
                        }
                    }
                } catch {
#if DEBUG
                    print("资源输出失败: \(error)")
#endif
                    self.update(status: .failed)
                    self.error = MNExportError.underlyingError(error)
                    if let error = self.error, let completionHandler = self.completionHandler {
                        DispatchQueue.main.async {
                            completionHandler(.failed, error)
                        }
                    }
                }
            }
        } else {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = outputFileType
            exportSession.addObserver(self, forKeyPath: #keyPath(AVAssetExportSession.status), options: .new, context: nil)
            // 输出资源
            exportSession.exportAsynchronously {
                if let completionHandler = self.completionHandler {
                    let error = self.error
                    let status = self.status
                    DispatchQueue.main.async {
                        completionHandler(status, error)
                    }
                }
            }
        }
    }
    
    /// 查找可用的输出预设名称(质量从高到低)
    /// - Parameter asset: 待输出资源
    /// - Returns: 可用预设名称
    private func compatiblePresetName(with asset: AVAsset) -> String {
        let compatiblePresetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
        if let presetName = presetName, compatiblePresetNames.contains(presetName) {
            return presetName
        }
        var presetNames: [String] = []
        if let _ = asset.mn.track(with: AVMediaType.video) {
            presetNames.append(AVAssetExportPresetHighestQuality)
            presetNames.append(AVAssetExportPreset3840x2160)
            presetNames.append(AVAssetExportPreset1920x1080)
            presetNames.append(AVAssetExportPreset1280x720)
            presetNames.append(AVAssetExportPresetMediumQuality)
            presetNames.append(AVAssetExportPresetLowQuality)
        }
        if let _ = asset.mn.track(with: AVMediaType.audio) {
            presetNames.append(AVAssetExportPresetAppleM4A)
        }
        if let presetName = presetNames.first(where: { compatiblePresetNames.contains($0) }) {
            return presetName
        }
        return AVAssetExportPresetPassthrough
    }
    
    /// 检查输出条件是否可用
    /// - Parameters:
    ///   - presetName: 预设输出名称
    ///   - asset: 待输出资源
    ///   - outputFileType: 文件类型
    /// - Returns: 是否可输出
    private func compatibility(ofExportPreset presetName: String, with asset: AVAsset, outputFileType: AVFileType) -> Bool {
        var compatible = false
        let semaphore = DispatchSemaphore(value: 0)
        AVAssetExportSession.determineCompatibility(ofExportPreset: presetName, with: asset, outputFileType: outputFileType) { flag in
            compatible = flag
            semaphore.signal()
        }
        semaphore.wait()
        return compatible
    }
    
    /// 结束任务
    private func finish(error: MNExportError?) {
        if let error = error {
            self.error = error
            if status != .cancelled {
                update(status: .failed)
            }
        } else {
            update(status: .completed)
        }
        if let completionHandler = self.completionHandler {
            let status = status
            DispatchQueue.main.async {
                completionHandler(status, error)
            }
        }
    }
    
    /// 更新当前输出状态
    /// - Parameter status: 状态
    private func update(status: AVAssetExportSession.Status) {
        objc_sync_enter(self)
        self.status = status
        objc_sync_exit(self)
    }
    
    /// 更新当前输出进度
    /// - Parameter progress: 进度值
    private func update(progress: CGFloat) {
        objc_sync_enter(self)
        self.progress = progress
        objc_sync_exit(self)
    }
    
    /// 取消输出任务
    public func cancel() {
        guard let exportSession = exportSession, exportSession.status == .exporting else { return }
        exportSession.cancelExport()
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change, let rawValue = change[.newKey] as? Int else { return }
        guard let status = AVAssetExportSession.Status(rawValue: rawValue) else { return }
        update(status: status)
        switch status {
        case .exporting:
            // 开启轮询
            destroyTimer()
            timer = Timer(timeInterval: progressUpdateInterval, target: self, selector: #selector(timerStrike), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
        case .completed, .failed, .cancelled:
            // 结束轮询
            destroyTimer()
            if let exportSession = exportSession {
                self.exportSession = nil
                if let error = exportSession.error {
                    self.error = MNExportError.underlyingError(error)
                }
                exportSession.removeObserver(self, forKeyPath: #keyPath(AVAssetExportSession.status))
            }
            if status == .completed {
                update(progress: 1.0)
                if let progressHandler = progressHandler {
                    DispatchQueue.main.async {
                        progressHandler(1.0)
                    }
                }
            }
        default: break
        }
    }
}

// MARK: - 定时器
extension MNAssetExportSession {
    
    /// 定时器事件
    @objc private func timerStrike() {
        guard status == .exporting else { return }
        guard let exportSession = exportSession else { return }
        update(progress: CGFloat(exportSession.progress))
        progressHandler?(progress)
    }
    
    /// 销毁定时器
    private func destroyTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }
}
