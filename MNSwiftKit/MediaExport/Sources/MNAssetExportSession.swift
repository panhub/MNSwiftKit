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
    /// 裁剪画面矩形
    public var cropRect: CGRect?
    /// 预设质量
    public var presetName: String?
    /// 输出路径
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
    /// - Parameter fileURL: 媒体资源定位器
    public convenience init(fileOfURL fileURL: URL) {
        let asset = AVURLAsset(mediaOfURL: fileURL)
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
    ///   - progressHandler: 进度回调(iOS18之前在主队列回调进度, 之后依赖于内部进度回调队列)
    ///   - completionHandler: 导出结束回调
    public func exportAsynchronously(progressHandler: ((_ progress: CGFloat)->Void)? = nil, completionHandler: ((_ status: AVAssetExportSession.Status, _ error: Error?)->Void)?) {
        if status == .waiting || status == .exporting {
            completionHandler?(.failed, MNExportError.unavailable)
            return
        }
        error = nil
        progress = 0.0
        exportSession = nil
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        DispatchQueue(label: "com.mn.asset.export.session.queue", qos: .userInitiated).async {
            self.export()
        }
    }
    
    /// 开始输出资源
    private func export() {
        
        guard let outputURL = outputURL, outputURL.isFileURL else {
            finish(error: .unknownOutputDirectory)
            return
        }
        
        // 检查文件类型
        guard let outputFileType = MNAssetExportSession.fileType(withExtension: outputURL.pathExtension) else {
            finish(error: .unknownFileType(outputURL.pathExtension))
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
        
        // 合成器
        let composition = AVMutableComposition()
        if exportVideoTrack, let videoTrack = asset.mn.track(with: .video) {
            guard composition.mn.append(track: videoTrack, range: timeRange) else {
                finish(error: .cannotExportTrack(.video))
                return
            }
        }
        if exportAudioTrack, let audioTrack = asset.mn.track(with: .audio) {
            guard composition.mn.append(track: audioTrack, range: timeRange) else {
                finish(error: .cannotExportTrack(.audio))
                return
            }
        }
        
        // 检查输出项
        guard composition.tracks.isEmpty == false else {
            finish(error: .trackIsEmpty)
            return
        }
        
        // 寻找合适的预设质量
        let presetName = compatiblePresetName(with: composition)
        
        // 检查设置是否可以输出
        guard compatibility(ofExportPreset: presetName, with: composition, outputFileType: outputFileType) else {
            finish(error: .cannotExportFile)
            return
        }
        
        // 开始输出
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: presetName) else {
            finish(error: .cannotExportFile)
            return
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
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            layerInstruction.setOpacity(1.0, at: .zero)
            layerInstruction.setTransform(videoTrack.mn.transform(for: cropRect, renderSize: renderSize), at: .zero)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
            instruction.layerInstructions = [layerInstruction]
            
            let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
            videoComposition.renderSize = renderSize
            videoComposition.instructions = [instruction]
            videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(videoTrack.mn.nominalFrameRate))
            
            exportSession.videoComposition = videoComposition
        }
        exportSession.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse
        self.exportSession = exportSession
        if #available(iOS 18.0, *) {
            //
            Task {
                for await state in exportSession.states(updateInterval: self.progressUpdateInterval) {
                    switch state {
                    case .pending:
                        self.status = .unknown
                    case .waiting:
                        self.status = .waiting
                    case .exporting(progress: let progress):
                        self.status = .exporting
                        let fractionCompleted = CGFloat(progress.fractionCompleted)
                        self.progress = fractionCompleted
                        if let progressHandler = self.progressHandler {
                            progressHandler(fractionCompleted)
                        }
                    default: break
                    }
                }
            }
            Task {
                do {
                    try await exportSession.export(to: outputURL, as: outputFileType)
                    self.progress = 1.0
                    if let progressHandler = self.progressHandler {
                        progressHandler(1.0)
                    }
                    self.status = .completed
                    if let completionHandler = self.completionHandler {
                        completionHandler(.completed, nil)
                    }
                } catch {
#if DEBUG
                    print("资源输出失败: \(error)")
#endif
                    self.status = .failed
                    self.error = MNExportError.underlyingError(error)
                    if let completionHandler = self.completionHandler {
                        completionHandler(.failed, self.error)
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
                    completionHandler(self.status, self.error)
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
        if let _ = asset.mn.track(with: .video) {
            presetNames.append(AVAssetExportPresetHighestQuality)
            presetNames.append(AVAssetExportPreset3840x2160)
            presetNames.append(AVAssetExportPreset1920x1080)
            presetNames.append(AVAssetExportPreset1280x720)
            presetNames.append(AVAssetExportPresetMediumQuality)
            presetNames.append(AVAssetExportPresetLowQuality)
        }
        if let _ = asset.mn.track(with: .audio) {
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
        self.error = error
        status = .failed
        completionHandler?(.failed, error)
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
        guard status == .exporting else { return }
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
