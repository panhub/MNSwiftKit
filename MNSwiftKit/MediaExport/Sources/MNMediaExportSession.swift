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
    /// 是否已取消导出操作
    public private(set) var isCancelled = false
    /// 视频输入
    private weak var videoInput: AVAssetWriterInput?
    /// 音频输入
    private weak var audioInput: AVAssetWriterInput?
    /// 视频输出
    private weak var videoOutput: AVAssetReaderOutput?
    /// 音频输出
    private weak var audioOutput: AVAssetReaderOutput?
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
    ///   - progressHandler: 进度回调(iOS18之前在主队列回调进度, 之后依赖于内部进度回调队列)
    ///   - completionHandler: 导出结束回调
    public func exportAsynchronously(progressHandler: ((_ progress: CGFloat)->Void)? = nil, completionHandler: ((_ status: AVAssetExportSession.Status, _ error: Error?)->Void)?) {
        if status == .waiting || status == .exporting {
            completionHandler?(.failed, MNExportError.exporting)
            return
        }
        error = nil
        progress = 0.0
        status = .waiting
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
            
            let videoSettings: [String: Any] = [
                kCVPixelBufferWidthKey as String: Int(renderSize.width),
                kCVPixelBufferHeightKey as String: Int(renderSize.height),
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
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
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
            //let audioSettings = audioSettings(for: audioTrack)
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
        
        status = .exporting
        let seconds = composition.duration.seconds
        let group = DispatchGroup()
        if let videoInput = videoInput, let videoOutput = videoOutput {
            group.enter()
            self.videoInput = videoInput
            self.videoOutput = videoOutput
            videoInput.requestMediaDataWhenReady(on: DispatchQueue(label: "com.mn.video.exporting", qos: .userInitiated)) {
                guard self.status == .exporting else {
                    videoInput.markAsFinished()
                    group.leave()
                    return
                }
                while videoInput.isReadyForMoreMediaData {
                    if let sampleBuffer = videoOutput.copyNextSampleBuffer() {
                        
                        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        let progress = presentationTime.seconds/seconds
                        print("===视频: \(progress)")
                        if videoInput.append(sampleBuffer) == false {
                            // 操作失败了
                            videoInput.markAsFinished()
                            group.leave()
                            break
                        }
                    } else {
                        // 读取结束
                        videoInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }
        }
        if let audioInput = audioInput, let audioOutput = audioOutput {
            group.enter()
            self.audioInput = audioInput
            self.audioOutput = audioOutput
            audioInput.requestMediaDataWhenReady(on: DispatchQueue(label: "com.mn.audio.exporting", qos: .userInitiated)) {
                guard self.status == .exporting else {
                    audioInput.markAsFinished()
                    group.leave()
                    return
                }
                while audioInput.isReadyForMoreMediaData {
                    if let sampleBuffer = audioOutput.copyNextSampleBuffer() {
                        
                        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        let progress = presentationTime.seconds/seconds
                        print("===音频: \(progress)")
                        if audioInput.append(sampleBuffer) == false {
                            // 操作失败了
                            audioInput.markAsFinished()
                            group.leave()
                            break
                        }
                    } else {
                        // 读取结束
                        audioInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }
        }
        group.notify(qos: .userInitiated, queue: .main) {
            if self.status == .cancelled {
                // 取消
                writer.cancelWriting()
                self.finish(error: .cancelled)
                return
            }
            writer.finishWriting {
                DispatchQueue.main.async {
                    switch writer.status {
                    case .completed:
                        // 成功
                        if let progressHandler = self.progressHandler {
                            progressHandler(1.0)
                        }
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
            if self.status != .cancelled {
                self.status = .failed
            }
        } else {
            self.status = .completed
        }
        if let completionHandler = completionHandler {
            completionHandler(self.status, error)
        }
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
        return assistant.videoSettings
        /*
        // 根据文件类型选择编码格式
        let codecType: AVVideoCodecType
        switch fileType {
        case .mp4:
            if shouldOptimizeForNetworkUse {
                // 首选H.264 (AVC), 100% 浏览器兼容，支持流式传输
                if #available(iOS 11.0, *) {
                    codecType = .h264
                } else {
                    codecType = .init(rawValue: AVVideoCodecH264)
                }
            } else if #available(iOS 11.0, *) {
                // 空间效率高, 同等画质, 甚至节省50%空间
                codecType = .hevc
            } else {
                // 安全默认值
                codecType = .init(rawValue: AVVideoCodecH264)
            }
        case .mov:
            // MOV 支持更多格式
            if #available(iOS 11.0, *), let sourceCodec = sourceCodecType, sourceCodec == kCMVideoCodecType_HEVC {
                codecType = .hevc
            } else if #available(iOS 11.0, *) {
                codecType = .h264
            } else {
                codecType = .init(rawValue: AVVideoCodecH264)
            }
        case .m4v:
            // Apple专有的视频容器格式, 带DRM保护或特殊元数据的MP4
        default: return nil
        }
        
        
        
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
            if let audioSettings = audioSettings(for: audioTrack), let numberOfChannels = audioSettings[AVNumberOfChannelsKey] as? Int {
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
    
    private func audioSettings(for audioTrack: AVAssetTrack) -> [String:Any]? {
        guard let formatDescriptions = audioTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first else { return nil }
        guard CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Audio else { return nil }
        var audioSettings: [String: Any] = [:]
        // 获取音频格式ID
        let formatID = CMFormatDescriptionGetMediaSubType(formatDescription)
        audioSettings[AVFormatIDKey] = formatID
        // 获取音频流基本描述
        if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
            // 采样率
            let sampleRate = asbd.pointee.mSampleRate
            // 声道数量
            let channels = asbd.pointee.mChannelsPerFrame
            // 位深
            let bitDepth = asbd.pointee.mBitsPerChannel
            // 计算比特率（仅对未压缩格式有效）
            if formatID == kAudioFormatLinearPCM {
                let channelBitRate = sampleRate*Double(bitDepth)
                let bitRate = Int(channelBitRate*Double(channels))
                audioSettings[AVEncoderBitRateKey] = bitRate
                audioSettings[AVEncoderBitRatePerChannelKey] = channelBitRate
            }
            audioSettings[AVSampleRateKey] = sampleRate
            audioSettings[AVNumberOfChannelsKey] = channels
            audioSettings[AVLinearPCMBitDepthKey] = bitDepth
        }
        // 声道布局
        var channelLayoutSize: Int = 0
        if let channelLayout = CMAudioFormatDescriptionGetChannelLayout(formatDescription, sizeOut: &channelLayoutSize) {
            audioSettings[AVChannelLayoutKey] = Data(bytes: channelLayout, count: channelLayoutSize)
        }
        return audioSettings
    }
}
