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
    /// 获取资源信息
    public let asset: AVAsset
    /// 输出格式
    public var outputFileType: AVFileType?
    /// 裁剪片段
    public var timeRange: CMTimeRange = .invalid
    /// 裁剪画面矩形
    public var cropRect: CGRect?
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
    /// 查询进度
    private var timer: Timer!
    /// 系统输出
    private weak var exportSession: AVAssetExportSession?
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
        guard let asset = AVURLAsset(for: filePath) else { return nil }
        self.init(asset: asset)
    }
    
    /// 构造资源输出会话
    /// - Parameter fileURL: 媒体资源定位器
    public convenience init(fileOfURL fileURL: URL) {
        let asset = AVURLAsset(for: fileURL)
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
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 导出结束回调
    public func exportAsynchronously(progressHandler: ((CGFloat)->Void)? = nil, completionHandler: ((AVAssetExportSession.Status, Error?)->Void)?) {
        if status == .waiting || status == .exporting { return }
        error = nil
        progress = 0.0
        exportSession = nil
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        DispatchQueue(label: "com.mn.asset.export.session.queue", qos: .userInitiated).async {
            self.export()
        }
    }
    
    /// 以配置输出
    private func export() {
        
        func finish(error: MNExportError?) {
            self.error = error
            status = .failed
            completionHandler?(.failed, error)
        }
        
        guard let outputURL = outputURL, outputURL.isFileURL else {
            finish(error: .unknownOutputDirectory)
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
                finish(error: .fileDoesExist(outputPath))
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
                finish(error: .cannotCreateDirectory(outputDirectory))
                return
            }
        }
        
        // 重新提取素材
        let videoTrack = asset.mn.track(with: .video)
        let audioTrack = asset.mn.track(with: .audio)
        let composition = AVMutableComposition()
        if isExportVideoTrack, let videoTrack = videoTrack {
            guard composition.mn.append(track: videoTrack, range: timeRange) else {
                finish(error: .cannotInsertTrack(.video))
                return
            }
        }
        if isExportAudioTrack, let audioTrack = audioTrack {
            guard composition.mn.append(track: audioTrack, range: timeRange) else {
                finish(error: .cannotInsertTrack(.audio))
                return
            }
        }
        
        // 检查输出项
        guard composition.tracks.isEmpty == false else {
            finish(error: .assetIsEmpty)
            return
        }
        
        // 寻找合适的预设质量<内部封装>
        func presetCompatible(with asset: AVAsset) -> String {
            let compatiblePresetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
            if let presetName = presetName, compatiblePresetNames.contains(presetName) {
                return presetName
            }
            var presetNames: [String] = []
            if isExportVideoTrack, let _ = videoTrack {
                presetNames.append(AVAssetExportPresetHighestQuality)
                presetNames.append(AVAssetExportPreset1280x720)
                presetNames.append(AVAssetExportPresetMediumQuality)
                presetNames.append(AVAssetExportPresetLowQuality)
            }
            if isExportAudioTrack, let _ = audioTrack {
                presetNames.append(AVAssetExportPresetAppleM4A)
            }
            if let presetName = presetNames.first(where: { compatiblePresetNames.contains($0) }) {
                return presetName
            }
            return AVAssetExportPresetPassthrough
        }
        
        // 开始输出
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: presetCompatible(with: composition)) else {
            finish(error: .cannotExportFile)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse
        if let outputFileType = outputFileType {
            exportSession.outputFileType = outputFileType
        } else if isExportVideoTrack, let _ = videoTrack {
            exportSession.outputFileType = .mp4
        } else {
            exportSession.outputFileType = .m4a
        }
        if let cropRect = cropRect, cropRect.isEmpty == false, cropRect.isNull == false, let videoTrack = composition.mn.track(with: .video) {
            // 渲染尺寸
            var renderSize = cropRect.size
            if let size = self.renderSize {
                renderSize = size
            }
            //renderSize.width = floor(ceil(renderSize.width)/16.0)*16.0
            //renderSize.height = floor(ceil(renderSize.height)/16.0)*16.0
            // 配置画面设置
            let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            videoLayerInstruction.setOpacity(1.0, at: .zero)
            let track = asset.mn.track(with: .video)!
            videoLayerInstruction.setTransform(track.mn.transform(for: cropRect, renderSize: renderSize), at: .zero)
            //videoLayerInstruction.setCropRectangle(cropRect, at: .zero)
            //videoLayerInstruction.setTransform(track.mn.preferredTransform, at: .zero)
            
            let videoInstruction = AVMutableVideoCompositionInstruction()
            videoInstruction.layerInstructions = [videoLayerInstruction]
            videoInstruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
            
            let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
            videoComposition.renderSize = renderSize
            videoComposition.instructions = [videoInstruction]
            videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(videoTrack.mn.nominalFrameRate))
            
            exportSession.videoComposition = videoComposition
        }
        exportSession.addObserver(self, forKeyPath: #keyPath(AVAssetExportSession.status), options: .new, context: nil)
        self.exportSession = exportSession
        // 开始输出
        exportSession.exportAsynchronously {
            self.completionHandler?(self.status, self.error)
        }
    }
    
    /// 取消输出任务
    public func cancel() {
        guard let exportSession = exportSession, exportSession.status == .exporting else { return }
        exportSession.cancelExport()
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == #keyPath(AVAssetExportSession.status) else { return }
        guard let rawValue = change?[.newKey] as? Int else { return }
        guard let status = AVAssetExportSession.Status(rawValue: rawValue) else { return }
        self.status = status
        switch status {
        case .exporting:
            // 开启轮询
            destroyTimer()
            timer = Timer(timeInterval: 0.2, target: self, selector: #selector(timerStrike), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
        case .completed, .failed, .cancelled:
            // 结束轮询
            destroyTimer()
            if let exportSession = exportSession {
                if let error = exportSession.error {
                    self.error = MNExportError.underlyingError(error)
                }
                exportSession.removeObserver(self, forKeyPath: #keyPath(AVAssetExportSession.status))
            }
            if status == .completed {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.progress = 1.0
                    if let progressHandler = self.progressHandler {
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
        guard let exportSession = exportSession else { return }
        progress = CGFloat(exportSession.progress)
        if let progressHandler = progressHandler {
            progressHandler(progress)
        }
    }
    
    /// 销毁定时器
    private func destroyTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }
}
