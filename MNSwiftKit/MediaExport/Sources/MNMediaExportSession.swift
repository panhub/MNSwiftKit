//
//  MNMediaExportSession.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/12/2.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  媒体资源输会话

import CoreMedia
import Foundation
import AVFoundation

/// 媒体资源输出会话
public class MNMediaExportSession: NSObject {
    
    /// 输出质量
    public enum Quality {
        /// 自动选择输出质量
        case auto
        /// 低质量
        case low
        /// 中等质量
        case medium
        /// 高质量
        case high
    }
    
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
    /// 默认高质量输出策略
    public var quality: MNMediaExportSession.Quality = .auto
    /// 是否针对网络使用进行优化
    public var shouldOptimizeForNetworkUse: Bool = true
    /// 错误信息
    public private(set) var error: Error?
    /// 进度
    public private(set) var progress: CGFloat = 0.0
    /// 状态
    public private(set) var status: AVAssetExportSession.Status = .unknown
    /// 视频输出进度
    private var videoExportProgress: CGFloat?
    /// 音频输出进度
    private var audioExportProgress: CGFloat?
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
        progressHandler = nil
        completionHandler = nil
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
        update(status: .waiting)
        update(progress: 0.0)
        videoExportProgress = nil
        audioExportProgress = nil
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        DispatchQueue(label: "com.mn.media.export.session.queue", qos: .userInitiated).async {
            self.export()
        }
    }
    
    /// 开始输出
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
        
        // 删除本地文件
        var outputPath: String
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
        
        // 合成器
        let composition = AVMutableComposition()
        if exportVideoTrack, let videoTrack = asset.mn.track(with: .video) {
            guard composition.mn.append(track: videoTrack, range: timeRange) else {
                finish(error: .cannotAppendTrack(.video))
                return
            }
        }
        if exportAudioTrack, let audioTrack = asset.mn.track(with: .audio) {
            guard composition.mn.append(track: audioTrack, range: timeRange) else {
                finish(error: .cannotAppendTrack(.audio))
                return
            }
        }
        
        // 检查是否可读
        guard composition.isReadable else {
            finish(error: .unreadable)
            return
        }
        
        // 检查是否可输出
        guard composition.isExportable else {
            finish(error: .unexportable)
            return
        }
        
        // 创建 AVAssetReader
        let reader: AVAssetReader
        do {
            reader = try AVAssetReader(asset: composition)
            reader.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        } catch {
            finish(error: .cannotReadAsset(error))
            return
        }
        
        // 创建 AVAssetWriter
        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: outputFileType)
        } catch {
            finish(error: .cannotWritToFile(outputURL, uti: outputFileType, error: error))
            return
        }
        if shouldOptimizeForNetworkUse, outputFileType != .m4v {
            writer.shouldOptimizeForNetworkUse = true
        }
        
        // 配置视频输入输出
        var videoInput: AVAssetWriterInput!
        var videoOutput: AVAssetReaderVideoCompositionOutput!
        if let videoTrack = composition.mn.track(with: .video) {
            var cropRect = CGRect(origin: .zero, size: videoTrack.mn.naturalSize)
            if let rect = self.cropRect {
                cropRect = cropRect.intersection(rect)
            }
            var renderSize = cropRect.size
            if let size = self.renderSize {
                renderSize = size
            }
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            layerInstruction.setOpacity(1.0, at: .zero)
            layerInstruction.setTransform(videoTrack.mn.transform(for: cropRect, renderSize: renderSize), at: .zero)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
            instruction.layerInstructions = [layerInstruction]
            
            let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
            videoComposition.renderSize = renderSize
            videoComposition.instructions = [instruction]
            let frameRate = videoTrack.mn.nominalFrameRate
            if frameRate > 0.0 {
                videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
            } else {
                videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            }
            //kCVPixelBufferWidthKey as String: Int(renderSize.width),
            //kCVPixelBufferHeightKey as String: Int(renderSize.height),
            // 通用视频格式
            let videoSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                kCVPixelBufferMetalCompatibilityKey as String: true,
                kCVPixelBufferOpenGLCompatibilityKey as String: true
            ]
            videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [videoTrack], videoSettings: videoSettings)
            videoOutput.videoComposition = videoComposition
            videoOutput.alwaysCopiesSampleData = false
            
            guard reader.canAdd(videoOutput) else {
                finish(error: .cannotAddOutput(.video))
                return
            }
            reader.add(videoOutput)
            
            guard let outputSettings = videoOutputSettings(for: videoTrack, fileType: outputFileType, renderSize: renderSize) else {
                finish(error: .cannotExportSetting(.video, uti: outputFileType))
                return
            }
            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
            videoInput.expectsMediaDataInRealTime = false
            
            guard writer.canAdd(videoInput) else {
                finish(error: .cannotAddInput(.video))
                return
            }
            writer.add(videoInput)
        }
        
        // 配置音频输入输出
        var audioInput: AVAssetWriterInput!
        var audioOutput: AVAssetReaderOutput!
        if let audioTrack = composition.mn.track(with: .audio) {
            // 创建 Audio Output
            let audioSettings = audioSettings(for: audioTrack)
            audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioSettings)
            audioOutput.alwaysCopiesSampleData = false
            
            guard reader.canAdd(audioOutput) else {
                finish(error: .cannotAddOutput(.audio))
                return
            }
            reader.add(audioOutput)
            
            // 创建 Audio Input
            guard let audioOutputSettings = audioOutputSettings(for: audioTrack, fileType: outputFileType) else {
                finish(error: .cannotExportSetting(.audio, uti: outputFileType))
                return
            }
            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)
            audioInput.expectsMediaDataInRealTime = false
            
            guard writer.canAdd(audioInput) else {
                finish(error: .cannotAddInput(.audio))
                return
            }
            writer.add(audioInput)
        }
        
        // 输出资源
        guard reader.startReading() else {
            finish(error: .cannotStartReading)
            return
        }
        
        guard writer.startWriting() else {
            reader.cancelReading()
            finish(error: .cannotStartWriting)
            return
        }
        writer.startSession(atSourceTime: .zero)
        
        update(status: .exporting)
        let seconds = CMTimeGetSeconds(composition.duration)
        let group = DispatchGroup()
        if let videoInput = videoInput, let videoOutput = videoOutput {
            group.enter()
            videoInput.requestMediaDataWhenReady(on: DispatchQueue(label: "com.mn.media.video.exporting")) {
                guard self.status == .exporting else {
                    videoInput.markAsFinished()
                    group.leave()
                    return
                }
                while videoInput.isReadyForMoreMediaData {
                    if let sampleBuffer = videoOutput.copyNextSampleBuffer() {
                        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        let value = CMTimeGetSeconds(presentationTime)/seconds
                        self.updateVideoProgress(value)
                        if let progressHandler = self.progressHandler {
                            let progress = self.progress
                            DispatchQueue.main.async {
                                progressHandler(progress)
                            }
                        }
                        if videoInput.append(sampleBuffer) == false {
                            // 操作失败了
                            videoInput.markAsFinished()
                            group.leave()
                            break
                        }
                    } else {
                        // 读取结束 这里也为了强引用reader
                        if let error = reader.error {
                            self.update(status: .failed)
#if DEBUG
                            print("读取视频数据失败: \(error)")
#endif
                        }
                        videoInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }
        }
        if let audioInput = audioInput, let audioOutput = audioOutput {
            group.enter()
            audioInput.requestMediaDataWhenReady(on: DispatchQueue(label: "com.mn.media.audio.exporting")) {
                guard self.status == .exporting else {
                    audioInput.markAsFinished()
                    group.leave()
                    return
                }
                while audioInput.isReadyForMoreMediaData {
                    if let sampleBuffer = audioOutput.copyNextSampleBuffer() {
                        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        let value = CMTimeGetSeconds(presentationTime)/seconds
                        self.updateAudioProgress(value)
                        if let progressHandler = self.progressHandler {
                            let progress = self.progress
                            DispatchQueue.main.async {
                                progressHandler(progress)
                            }
                        }
                        if audioInput.append(sampleBuffer) == false {
                            // 操作失败了
                            audioInput.markAsFinished()
                            group.leave()
                            break
                        }
                    } else {
                        // 读取结束 这里也为了强引用reader
                        if let error = reader.error {
                            self.update(status: .failed)
#if DEBUG
                            print("读取音频数据失败: \(error)")
#endif
                        }
                        audioInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }
        }
        group.notify(queue: .main) {
            if self.status == .cancelled {
                // 取消
                writer.cancelWriting()
                self.finish(error: .cancelled)
                return
            }
            if let error = reader.error {
                writer.cancelWriting()
                self.finish(error: .underlyingError(error))
                return
            }
            writer.finishWriting {
                DispatchQueue.main.async {
                    switch writer.status {
                    case .completed:
                        // 成功
                        self.update(progress: 1.0)
                        self.progressHandler?(1.0)
                        self.finish(error: nil)
                    default:
                        if let error = writer.error {
                            self.finish(error: .underlyingError(error))
                        } else {
                            self.finish(error: .unknown)
                        }
                    }
                }
            }
        }
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
        if let completionHandler = completionHandler {
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
    
    /// 更新音频输出进度
    /// - Parameter value: 进度值
    private func updateAudioProgress(_ value: CGFloat) {
        var progress: CGFloat
        objc_sync_enter(self)
        audioExportProgress = value
        if let videoExportProgress = videoExportProgress {
            progress = min(value, videoExportProgress)
        } else {
            progress = value
        }
        objc_sync_exit(self)
        update(progress: progress)
    }
    
    /// 更新视频输出进度
    /// - Parameter value: 进度值
    private func updateVideoProgress(_ value: CGFloat) {
        var progress: CGFloat
        objc_sync_enter(self)
        videoExportProgress = value
        if let audioExportProgress = audioExportProgress {
            progress = min(value, audioExportProgress)
        } else {
            progress = value
        }
        objc_sync_exit(self)
        update(progress: progress)
    }
    
    /// 取消输出任务
    public func cancel() {
        guard status == .exporting else { return }
        update(status: .cancelled)
    }
    
    private func preferredVideoOutputPreset(useH264 useH264CodecType: Bool, renderSize: CGSize, containsAlphaChannel: Bool) -> AVOutputSettingsPreset {
        let dimension = renderSize.width*renderSize.height
        var exportQuality: MNMediaExportSession.Quality = quality
        if exportQuality == .auto {
            if dimension <= 960*540 {
                exportQuality = .low
            } else if dimension <= 1920*1080 {
                exportQuality = .medium
            } else {
                exportQuality = .high
            }
        }
        switch exportQuality {
        case .low:
            // 低
            if dimension <= 640*480 {
                return .preset640x480
            }
            return .preset960x540
        case .medium:
            // 中
            if dimension <= 1280*720 {
                return .preset1280x720
            }
            if useH264CodecType {
                return .preset1920x1080
            } else if #available(iOS 13.0, *), containsAlphaChannel {
                return .hevc1920x1080WithAlpha
            } else if #available(iOS 11.0, *) {
                return .hevc1920x1080
            }
            return .preset1920x1080
        case .high:
            // 高
            if useH264CodecType {
                return .preset3840x2160
            } else if #available(iOS 13.0, *), containsAlphaChannel {
                return .hevc3840x2160WithAlpha
            } else if #available(iOS 11.0, *) {
                return .hevc3840x2160
            }
            return .preset3840x2160
        default: return .preset1920x1080
        }
    }
    
    private func videoOutputSettings(for videoTrack: AVAssetTrack, fileType: AVFileType, renderSize: CGSize) -> [String:Any]? {
        guard let formatDescriptions = videoTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first else { return nil }
        guard CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Video else { return nil }
        let subType = CMFormatDescriptionGetMediaSubType(formatDescription)
        // 是否有Alpha通道
        var containsAlphaChannel = false
        if #available(iOS 13.0, *), let containsAlphaChannelValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_ContainsAlphaChannel) as? Bool, containsAlphaChannelValue {
            containsAlphaChannel = true
        } else {
            let alphaSupportedFormats: [FourCharCode] = [
                kCVPixelFormatType_32BGRA,
                kCVPixelFormatType_32RGBA,
                kCVPixelFormatType_32ABGR,
                kCVPixelFormatType_32ARGB,
                kCVPixelFormatType_64ARGB,
                kCVPixelFormatType_128RGBAFloat,
                kCMVideoCodecType_AppleProRes4444,
                kCMVideoCodecType_AppleProRes4444XQ,
                kCMVideoCodecType_HEVCWithAlpha,
                kCMVideoCodecType_Animation
            ]
            if alphaSupportedFormats.contains(subType) {
                containsAlphaChannel = true
            }
        }
        // 选择编码方式
        var useH264CodecType = true
        if fileType != .m4v, #available(iOS 11.0, *), shouldOptimizeForNetworkUse == false {
            useH264CodecType = false
        }
        // 使用推荐
        let preset = preferredVideoOutputPreset(useH264: useH264CodecType, renderSize: renderSize, containsAlphaChannel: containsAlphaChannel)
        guard AVOutputSettingsAssistant.availableOutputSettingsPresets().contains(preset) else { return nil }
        guard let assistant = AVOutputSettingsAssistant(preset: preset) else { return nil }
        assistant.sourceVideoFormat = formatDescription
        //assistant.sourceVideoAverageFrameDuration = CMTimeCodeFormatDescriptionGetFrameDuration(formatDescription)
        // 也可以自定义一下压缩参数
        guard var videoSettings = assistant.videoSettings else { return nil }
        videoSettings[AVVideoWidthKey] = Int(renderSize.width)
        videoSettings[AVVideoHeightKey] = Int(renderSize.height)
        return videoSettings
        /*
        // 分析源视频设置 avc1 avc1 hvc1 ap4h
        let sourceSettings = videoSettings(for: videoTrack)
        
        var sourceCodecType: AVVideoCodecType
        if #available(iOS 11.0, *) {
            sourceCodecType = .h264
        } else {
            sourceCodecType = .init(rawValue: AVVideoCodecH264)
        }
        if let codecType = sourceSettings[AVVideoCodecKey] as? AVVideoCodecType {
            sourceCodecType = codecType
        }
        
        var sourceBitrate: Int
        if let bitrate = sourceSettings[AVVideoAverageBitRateKey] as? Int {
            sourceBitrate = bitrate
        } else {
            let estimatedDataRate = videoTrack.mn.estimatedDataRate
            sourceBitrate = Int(estimatedDataRate)
        }
         
        // 视频设置
        var videoSettings: [String: Any] = [:]
        videoSettings[AVVideoCodecKey] = codecType
        videoSettings[AVVideoWidthKey] = renderSize.width
        videoSettings[AVVideoHeightKey] = renderSize.height
        // 计算比特率（基于输出尺寸）
        let pixelsPerSecond: CGFloat
        if let sourceSettings = sourceSettings, let sourceFrameRate = sourceSettings["frameRate"] as? CGFloat, sourceFrameRate > 0.0 {
            pixelsPerSecond = renderSize.width*renderSize.height*sourceFrameRate
        } else {
            // 默认 30fps
            pixelsPerSecond = renderSize.width*renderSize.height*30.0
        }
        // 根据编码格式设置比特率
        var compressionProperties: [String: Any] = [:]
        var isH264CodecType = false
        if #available(iOS 11.0, *) {
            isH264CodecType = codecType == .h264
        } else {
            isH264CodecType = codecType.rawValue == AVVideoCodecH264
        }
        if isH264CodecType {
            // H.264 比特率设置
            compressionProperties[AVVideoAverageBitRateKey] = Int(pixelsPerSecond*0.15)  // 约 0.15 bits per pixel
            compressionProperties[AVVideoMaxKeyFrameIntervalKey] = 30
            // 尝试保持源视频的 Profile Level
            if let sourceSettings = sourceSettings, let sourceProfileLevel = sourceSettings["profileLevel"] as? String {
                compressionProperties[AVVideoProfileLevelKey] = sourceProfileLevel
            } else {
                compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel
            }
        } else {
            // HEVC/H.265 比特率设置
            compressionProperties[AVVideoAverageBitRateKey] = Int(pixelsPerSecond*0.1)  // HEVC 更高效
            compressionProperties[AVVideoMaxKeyFrameIntervalKey] = 30
            //compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelHEVCMainAutoLevel
        }
        // 保持颜色空间信息（如果源视频有）AVVideoPixelAspectRatioKey
        if #available(iOS 11.0, *), let sourceSettings = sourceSettings {
            var colorProperties: [String: Any] = [:]
            if let colorPrimaries = sourceSettings["colorPrimaries"] as? String {
                colorProperties[AVVideoColorPrimariesKey] = colorPrimaries
            }
            if let transferFunction = sourceSettings["transferFunction"] as? String {
                colorProperties[AVVideoTransferFunctionKey] = transferFunction
            }
            if let yCbCrMatrix = sourceSettings["yCbCrMatrix"] as? String {
                colorProperties[AVVideoYCbCrMatrixKey] = yCbCrMatrix
            }
            if colorProperties.isEmpty == false {
                compressionProperties[AVVideoColorPropertiesKey] = colorProperties
            }
        }
        videoSettings[AVVideoCompressionPropertiesKey] = compressionProperties
        return videoSettings
        */
        /**
         [
                 AVOutputSettingsPresetKey: AVOutputSettingsPreset.preset3840x2160,
                 AVFileTypeKey: AVFileType.m4v,
                 
                 // 视频编码设置
                 AVVideoCodecKey: AVVideoCodecType.hevc,
                 AVVideoWidthKey: 3840,
                 AVVideoHeightKey: 2160,
                 
                 // M4V 特有设置
                 "ShouldOptimizeForNetworkUse": false,
                 "Metadata": [
                     // iTunes 风格元数据
                     "com.apple.quicktime.artist": "你的作品名称",
                     "com.apple.quicktime.chapter": true
                 ],
                 
                 // 多轨道支持
                 "AudioTracks": [
                     ["LanguageCode": "eng", "Title": "英语"],
                     ["LanguageCode": "chi", "Title": "中文"]
                 ],
                 
                 // 字幕轨道
                 "SubtitleTracks": [
                     ["Format": "tx3g", "LanguageCode": "eng"],
                     ["Format": "tx3g", "LanguageCode": "chi"]
                 ]
             ]
         */
    }
    
    private func videoSettings(for videoTrack: AVAssetTrack) -> [String:Any] {
        var videoSettings: [String:Any] = [:]
        if let formatDescriptions = videoTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first {
            // 获取编码类型
            let subType = CMFormatDescriptionGetMediaSubType(formatDescription)
            videoSettings[AVVideoCodecKey] = videoCodecType(for: subType)
            // 获取视频尺寸
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            videoSettings[AVVideoWidthKey] = dimensions.width
            videoSettings[AVVideoHeightKey] = dimensions.height
            // 色彩空间 ColorPrimaries TransferFunction
            if #available(iOS 10.0, *), let colorPrimariesValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_ColorPrimaries) as? String {
                videoSettings[AVVideoColorPrimariesKey] = colorPrimariesValue
            }
            if #available(iOS 10.0, *), let transferFunctionValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_TransferFunction) as? String {
                videoSettings[AVVideoTransferFunctionKey] = transferFunctionValue
                // 是否是HDR
                if transferFunctionValue.contains("PQ") || transferFunctionValue.contains("HLG") {
                    videoSettings["HDR"] = true
                }
            }
            if #available(iOS 10.0, *), let yCbCrMatrixValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_YCbCrMatrix) as? String {
                videoSettings[AVVideoYCbCrMatrixKey] = yCbCrMatrixValue
            }
            // 是否有Alpha通道
            if #available(iOS 13.0, *), let containsAlphaChannelValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_ContainsAlphaChannel) as? Bool, containsAlphaChannelValue {
                videoSettings["ContainsAlphaChannel"] = true
            } else {
                let alphaSupportedFormats: [FourCharCode] = [
                    kCVPixelFormatType_32BGRA,
                    kCVPixelFormatType_32RGBA,
                    kCVPixelFormatType_32ABGR,
                    kCVPixelFormatType_32ARGB,
                    kCVPixelFormatType_64ARGB,
                    kCVPixelFormatType_128RGBAFloat,
                    kCMVideoCodecType_AppleProRes4444,
                    kCMVideoCodecType_AppleProRes4444XQ,
                    kCMVideoCodecType_HEVCWithAlpha,
                    kCMVideoCodecType_Animation
                ]
                if alphaSupportedFormats.contains(subType) {
                    videoSettings["ContainsAlphaChannel"] = true
                }
            }
            // 像素宽高比
            if let pixelAspectRatio = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_PixelAspectRatio) as? [String: Any] {
                videoSettings[AVVideoPixelAspectRatioKey] = pixelAspectRatio
                if let horizontalSpacing = pixelAspectRatio[kCVImageBufferPixelAspectRatioHorizontalSpacingKey as String] as? CGFloat, horizontalSpacing > 0.0, let verticalSpacing = pixelAspectRatio[kCVImageBufferPixelAspectRatioVerticalSpacingKey as String] as? CGFloat, verticalSpacing > 0.0 {
                    videoSettings[AVVideoPixelAspectRatioVerticalSpacingKey] = verticalSpacing
                    videoSettings[AVVideoPixelAspectRatioHorizontalSpacingKey] = horizontalSpacing
                }
            }
            // 比特率
            if let extensions = CMFormatDescriptionGetExtensions(formatDescription) as? [String:Any] {
                let bitrateKeys = ["BitRate", "AverageBitRate", "NominalBitRate", "bitsPerSecond", "DataRate", AVVideoAverageBitRateKey]
                for bitrateKey in bitrateKeys {
                    guard let bitrate = extensions[bitrateKey] as? NSNumber else { continue }
                    videoSettings[AVVideoAverageBitRateKey] = bitrate.intValue
                    break
                }
            }
        }
        return videoSettings
    }
    
    /// 原始编码类型
    private func videoCodecType(for codecType: FourCharCode) -> AVVideoCodecType {
        switch codecType {
        case kCMVideoCodecType_H264:
            // 在mp4封装下, 100%浏览器兼容，支持流式传输
            if #available(iOS 11.0, *) {
                return .h264
            }
            return .init(rawValue: AVVideoCodecH264)
        case kCMVideoCodecType_HEVC:
            // h265
            if #available(iOS 11.0, *) {
                return .hevc
            }
            return .init(rawValue: "hvc1")
        case kCMVideoCodecType_JPEG:
            if #available(iOS 11.0, *) {
                return .jpeg
            }
            return .init(rawValue: AVVideoCodecJPEG)
        case kCMVideoCodecType_AppleProRes4444:
            /// 支持 Alpha 通道
            if #available(iOS 11.0, *) {
                return .proRes4444
            }
            return .init(rawValue: "ap4h")
        case kCMVideoCodecType_AppleProRes422:
            if #available(iOS 11.0, *) {
                return .proRes422
            }
            return .init(rawValue: "proRes422")
        case kCMVideoCodecType_AppleProRes422HQ:
            if #available(iOS 13.0, *) {
                return .proRes422HQ
            }
            return .init(rawValue: "proRes422HQ")
        case kCMVideoCodecType_AppleProRes422LT:
            if #available(iOS 13.0, *) {
                return .proRes422LT
            }
            return .init(rawValue: "proRes422LT")
        case kCMVideoCodecType_AppleProRes422Proxy:
            if #available(iOS 13.0, *) {
                return .proRes422Proxy
            }
            return .init(rawValue: "proRes422Proxy")
        default: break
        }
        // 默认使用H.264编码
        if #available(iOS 11.0, *) {
            return .h264
        }
        return .init(rawValue: AVVideoCodecH264)
    }
    
    private func preferredAudioOutputPreset(for audioTrack: AVAssetTrack) -> AVOutputSettingsPreset {
        switch quality {
        case .auto:
            // 根据声道数选择
            let audioSettings = audioSettings(for: audioTrack)
            if let numberOfChannels = audioSettings[AVNumberOfChannelsKey] as? Int {
                return numberOfChannels > 2 ? .preset1920x1080 : .preset1280x720
            } else {
                return .preset1280x720
            }
        case .low:
            return .preset960x540
        case .medium:
            return .preset1280x720
        case .high:
            return .preset1920x1080
        }
    }
    
    private func audioOutputSettings(for audioTrack: AVAssetTrack, fileType: AVFileType) -> [String:Any]? {
        guard let formatDescriptions = audioTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first else { return nil }
        guard CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Audio else { return nil }
        // 寻找合适的预设
        let preset = preferredAudioOutputPreset(for: audioTrack)
        guard AVOutputSettingsAssistant.availableOutputSettingsPresets().contains(preset) else { return nil }
        guard let assistant = AVOutputSettingsAssistant(preset: preset) else { return nil }
        assistant.sourceAudioFormat = formatDescription
        // 也可以自定义一下压缩参数
        return assistant.audioSettings
        /*
        // 分析源音频设置
        let sourceSettings = audioSettings(for: audioTrack)
        let sourceFormatID = sourceSettings?["formatID"] as? AudioFormatID
        let sourceSampleRate = sourceSettings?["sampleRate"] as? Double ?? 44100.0
        let sourceChannels = sourceSettings?["channels"] as? Int ?? 2
        let sourceBitRate = sourceSettings?["bitRate"] as? Int
        // 根据文件类型选择编码格式
        let formatID: AudioFormatID
        switch fileType {
        case .mp4, .m4v, .mov:
            // 这些格式通常使用 AAC
            formatID = kAudioFormatMPEG4AAC
        case .caf, .wav, .aiff:
            formatID = kAudioFormatLinearPCM
        default:
            // 保持源格式
            if let sourceFormatID = sourceFormatID {
                formatID = sourceFormatID
            }
            return nil
        }
        // 音频设置
        var audioSettings: [String:Any] = [AVFormatIDKey:formatID]
        // 保持源采样率（如果合理）
        let sampleRate: Double
        if sourceSampleRate > 0 && sourceSampleRate <= 96000 {
            sampleRate = sourceSampleRate
        } else {
            sampleRate = 44100.0  // 默认采样率
        }
        audioSettings[AVSampleRateKey] = sampleRate
        // 保持源声道数
        let channels = min(max(sourceChannels, 1), 2)  // 限制在 1-2 声道
        audioSettings[AVNumberOfChannelsKey] = channels
        // 设置比特率
        if let sourceBitRate = sourceBitRate, sourceBitRate > 0 {
            // 使用源比特率
            audioSettings[AVEncoderBitRateKey] = sourceBitRate
        } else {
            // 根据采样率和声道数计算默认比特率
            let defaultBitRate: Int
            if sampleRate >= 48000 {
                defaultBitRate = channels == 2 ? 192000 : 96000  // 立体声 192kbps，单声道 96kbps
            } else {
                defaultBitRate = channels == 2 ? 128000 : 64000  // 立体声 128kbps，单声道 64kbps
            }
            audioSettings[AVEncoderBitRateKey] = defaultBitRate
        }
        // 设置音频质量（如果支持）
        if formatID == kAudioFormatMPEG4AAC {
            audioSettings[AVEncoderAudioQualityKey] = AVAudioQuality.high.rawValue
        }
        return audioSettings
        */
    }
    
    /// 读取音频轨道设置参数
    /// - Parameter audioTrack: 音频轨道
    /// - Returns: 设置参数
    private func audioSettings(for audioTrack: AVAssetTrack) -> [String:Any] {
        var audioSettings: [String: Any] = [:]
        if let formatDescriptions = audioTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first {
            // 音频格式ID
            let formatID = CMFormatDescriptionGetMediaSubType(formatDescription)
            if formatID == kAudioFormatLinearPCM, let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                // 如果是PCM格式，尽量保持原样
                audioSettings[AVFormatIDKey] = kAudioFormatLinearPCM
                // 采样率
                audioSettings[AVSampleRateKey] = asbd.pointee.mSampleRate
                // 声道数量
                audioSettings[AVNumberOfChannelsKey] = Int(asbd.pointee.mChannelsPerFrame)
                if asbd.pointee.mFormatFlags & kLinearPCMFormatFlagIsFloat != 0 {
                    // 浮点PCM
                    audioSettings[AVLinearPCMIsFloatKey] = true
                    audioSettings[AVLinearPCMBitDepthKey] = 32
                } else {
                    // 整数PCM
                    let bitDepth = asbd.pointee.mBitsPerChannel
                    audioSettings[AVLinearPCMIsFloatKey] = false
                    audioSettings[AVLinearPCMBitDepthKey] = bitDepth > 0 ? bitDepth : 16
                }
                // 声道布局
                var channelLayoutSize: Int = 0
                if let channelLayout = CMAudioFormatDescriptionGetChannelLayout(formatDescription, sizeOut: &channelLayoutSize) {
                    audioSettings[AVChannelLayoutKey] = Data(bytes: channelLayout, count: channelLayoutSize)
                }
            }
        }
        if audioSettings.isEmpty {
            // 安全默认16位整数PCM 大部分音频可使用
            audioSettings[AVFormatIDKey] = kAudioFormatLinearPCM // 解压为PCM
            audioSettings[AVSampleRateKey] = 44100.0 // 标准采样率
            audioSettings[AVNumberOfChannelsKey] = 2 // 立体声
            audioSettings[AVLinearPCMBitDepthKey] = 16 // CD音质
            audioSettings[AVLinearPCMIsFloatKey] = false // 非浮点型
            // 通用设置
            audioSettings[AVLinearPCMIsBigEndianKey] = false
            audioSettings[AVLinearPCMIsNonInterleaved] = false // 交错处理
        }
        return audioSettings
    }
}
