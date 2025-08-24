//
//  MNAssetExportSession.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/12/8.
//  音/视频转码切割

import Foundation
import AVFoundation
import QuartzCore.CADisplayLink

/// 音/视频转码切割
public class MNAssetExportSession: NSObject {
    
    /// 输出格式
    public var outputFileType: AVFileType?
    /// 裁剪片段
    public var timeRange: CMTimeRange = .invalid
    /// 裁剪画面
    public var outputRect: CGRect?
    /// 预设质量
    public var presetName: String?
    /// 输出路径
    public var outputURL: URL?
    /// 输出分辨率outputRect有效时有效
    public var renderSize: CGSize?
    /// 是否针对网络使用进行优化
    public var shouldOptimizeForNetworkUse: Bool = true
    /// 是否输出视频内容
    public var isExportVideoTrack: Bool = true
    /// 是否输出音频内容
    public var isExportAudioTrack: Bool = true
    /// 获取资源信息
    public var asset: AVAsset { composition }
    /// 查询进度
    private weak var displayLink: CADisplayLink?
    /// 系统输出使用
    private weak var exportSession: AVAssetExportSession?
    /// 内部使用
    private let composition: AVMutableComposition = AVMutableComposition()
    /// 错误信息
    private(set) var error: AVError?
    /// 进度
    private(set) var progress: Float = 0.0
    /// 状态
    private(set) var status: AVAssetExportSession.Status = .unknown
    /// 进度回调
    private var progressHandler: ((Float)->Void)?
    /// 结束回调
    private var completionHandler: ((AVAssetExportSession.Status, AVError?)->Void)?
    
    fileprivate override init() {
        super.init()
    }
    
    deinit {
        exportSession = nil
        progressHandler = nil
        completionHandler = nil
        if let displayLink  = displayLink {
            displayLink.isPaused = true
            displayLink.remove(from: .main, forMode: .common)
        }
    }
    
    /// 异步导出资源
    /// - Parameters:
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 导出结束回调
    public func exportAsynchronously(progressHandler: ((Float)->Void)? = nil, completionHandler: ((AVAssetExportSession.Status, AVError?)->Void)?) {
        guard status != .waiting, status != .exporting else { return }
        error = nil
        progress = 0.0
        status = .waiting
        exportSession = nil
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        DispatchQueue(label: "com.av.asset.export").async {
            self.export()
        }
    }
    
    private func export() {
        
        func finish(error: AVError?) {
            self.error = error
            status = .failed
            completionHandler?(.failed, error)
        }
        
        guard let outputURL = outputURL, outputURL.isFileURL else {
            finish(error: .urlError(.badUrl))
            return
        }
        
        guard composition.tracks.isEmpty == false else {
            finish(error: .trackError(.notFound))
            return
        }
        
        // 重新提取素材
        let videoTrack = composition.track(mediaType: .video)
        let audioTrack = composition.track(mediaType: .audio)
        let asset = AVMutableComposition()
        if isExportVideoTrack, let track = videoTrack {
            let timeRange = CMTIMERANGE_IS_VALID(timeRange) ? timeRange : CMTimeRange(start: .zero, duration: track.timeRange.duration)
            let compositionTrack = asset.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: .zero)
            } catch {
                finish(error: .trackError(.cannotInsert(.video)))
                return
            }
        }
        if isExportAudioTrack, let track = audioTrack {
            let timeRange = CMTIMERANGE_IS_VALID(timeRange) ? timeRange : CMTimeRange(start: .zero, duration: track.timeRange.duration)
            let compositionTrack = asset.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: .zero)
            } catch {
                finish(error: .trackError(.cannotInsert(.audio)))
                return
            }
        }
        
        // 检查输出项
        guard asset.tracks.isEmpty == false else {
            finish(error: .trackError(.notFound))
            return
        }
        
        // 删除本地文件
        try? FileManager.default.removeItem(at: outputURL)
        try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        
        // 寻找合适的预设质量<内部封装>
        func presetCompatible(with asset: AVAsset) -> String {
            let presets = AVAssetExportSession.exportPresets(compatibleWith: asset)
            if let presetName = presetName, presets.contains(presetName) {
                return presetName
            }
            var container = [String]()
            if isExportVideoTrack, let _ = composition.track(mediaType: .video) {
                container.append(AVAssetExportPresetHighestQuality)
                container.append(AVAssetExportPreset1280x720)
                container.append(AVAssetExportPresetMediumQuality)
                container.append(AVAssetExportPresetLowQuality)
            }
            if isExportAudioTrack, let _ = composition.track(mediaType: .audio) {
                container.append(AVAssetExportPresetAppleM4A)
            }
            if let preset = container.first(where: { presets.contains($0) }) {
                return preset
            }
            return AVAssetExportPresetPassthrough
        }
        
        // 开始输出
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetCompatible(with: asset)) else {
            finish(error: .exportError(.unsupported))
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = outputFileType ?? ((isExportVideoTrack && videoTrack != nil) ? .mp4 : .m4a)
        exportSession.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse
        if isExportVideoTrack, let track = videoTrack, let outputRect = outputRect, outputRect.isEmpty == false, CMTIMERANGE_IS_VALID(track.timeRange) {
            // 渲染尺寸
            var renderSize = outputRect.size
            if let size = self.renderSize {
                renderSize = size
                renderSize.width = floor(ceil(renderSize.width)/16.0)*16.0
                renderSize.height = floor(ceil(renderSize.height)/16.0)*16.0
            }
            // 配置画面设置
            let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
            videoLayerInstruction.setOpacity(1.0, at: .zero)
            videoLayerInstruction.setTransform(track.transform(withRect: outputRect, renderSize: renderSize), at: .zero)
            
            let videoInstruction = AVMutableVideoCompositionInstruction()
            videoInstruction.layerInstructions = [videoLayerInstruction]
            videoInstruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            
            let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
            videoComposition.renderSize = renderSize
            videoComposition.instructions = [videoInstruction]
            videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(track.nominalFrameRate))
            
            exportSession.videoComposition = videoComposition
        }
        self.exportSession = exportSession
        // 监听
        let displayLink = CADisplayLink(target: self, selector: #selector(tip(_:)))
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
        exportSession.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        // 开始输出
        exportSession.exportAsynchronously { [weak exportSession] in
            self.exportSession = nil
            exportSession?.removeObserver(self, forKeyPath: "status")
            if let displayLink = self.displayLink {
                displayLink.isPaused = true
                displayLink.remove(from: .main, forMode: .common)
            }
            if let error = exportSession?.error {
                self.error = .exportError(.underlyingError(error))
            }
            let status: AVAssetExportSession.Status = exportSession?.status ?? .failed
            self.status = status
            if status != .completed {
                try? FileManager.default.removeItem(at: outputURL)
            }
            self.completionHandler?(status, self.error)
        }
    }
    
    /// 取消输出任务
    public func cancel() {
        guard let exportSession = exportSession, exportSession.status == .exporting else { return }
        exportSession.cancelExport()
    }
    
    // MARK: - observe
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == "status" else { return }
        guard let status = change?[.newKey] as? Int else { return }
        self.status = AVAssetExportSession.Status(rawValue: status) ?? .unknown
        if status == AVAssetExportSession.Status.exporting.rawValue {
            // 开启轮询
            if let displayLink = displayLink {
                displayLink.isPaused = false
            }
        } else if status >= AVAssetExportSession.Status.completed.rawValue {
            // 停止轮询
            if let displayLink = displayLink {
                displayLink.isPaused = true
                displayLink.remove(from: .main, forMode: .common)
            }
            if status == AVAssetExportSession.Status.completed.rawValue, progress < 1.0 {
                progress = 1.0
                progressHandler?(progress)
            }
        }
    }
    
    @objc private func tip(_ displayLink: CADisplayLink) {
        guard let exportSession = exportSession, displayLink.isPaused == false else { return }
        progress = exportSession.progress
        progressHandler?(progress)
    }
}

// MARK: - convenience
extension MNAssetExportSession {
    
    /// 便捷构造入口
    /// - Parameter asset: 资源实例
    public convenience init(asset: AVAsset) {
        self.init()
        composition.append(asset: asset)
    }
    
    /// 便捷构造入口
    /// - Parameter filePath: 资源路径
    public convenience init?(fileAtPath filePath: String) {
        self.init(fileOfURL: URL(fileURLWithPath: filePath))
    }
    
    /// 便捷构造入口
    /// - Parameter fileURL: 资源地址
    public convenience init?(fileOfURL fileURL: URL) {
        guard fileURL.isFileURL, FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        self.init(asset: AVURLAsset(url: fileURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey:true]))
    }
}

// MARK: - append
extension MNAssetExportSession {
    
    /// 追加资源
    /// - Parameter url: 资源地址
    public func append(assetOfURL url: URL) {
        composition.append(assetOfURL: url)
    }
    
    /// 追加资源
    /// - Parameter asset: 资源实例
    public func append(asset: AVAsset) {
        composition.append(asset: asset)
    }
    
    /// 追加资源
    /// - Parameters:
    ///   - url: 资源地址
    ///   - mediaType: 媒体类型
    public func append(assetOfURL url: URL, mediaType: AVMediaType) {
        composition.append(assetOfURL: url, mediaType: mediaType)
    }
    
    /// 追加资源
    /// - Parameter track: 资源轨道
    public func append(track: AVAssetTrack) {
        composition.append(track: track)
    }
}
