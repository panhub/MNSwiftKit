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
    /// 错误信息
    public private(set) var error: Error?
    /// 进度
    public private(set) var progress: CGFloat = 0.0
    /// 状态
    public private(set) var status: AVAssetExportSession.Status = .unknown
    /// 视频输入
    private var videoInput: AVAssetWriterInput?
    /// 音频输入
    private var audioInput: AVAssetWriterInput?
    /// 视频输出
    private var videoOutput: AVAssetReaderOutput?
    /// 音频输出
    private var audioOutput: AVAssetReaderOutput?
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
            completionHandler?(.failed, MNExportError.unavailable)
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
            finish(error: .cannotWritFile(outputURL, fileType: outputFileType, underlyingError: error))
            return
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
            
            let videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
            
            videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [videoTrack], videoSettings: videoSettings)
            videoOutput.videoComposition = videoComposition
            videoOutput.alwaysCopiesSampleData = false
            
            guard reader.canAdd(videoOutput) else {
                finish(error: .cannotAddOutput(.video))
                return
            }
            reader.add(videoOutput)
            
            guard let outputSettings = videoOutputSettings(for: videoTrack, fileType: outputFileType, renderSize: renderSize) else {
                finish(error: .cannotExportSetting(.video, fileType: outputFileType))
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
            audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioSettings)
            audioOutput.alwaysCopiesSampleData = false
            
            guard reader.canAdd(audioOutput) else {
                finish(error: .cannotAddOutput(.audio))
                return
            }
            reader.add(audioOutput)
            
            // 创建 Audio Input
            guard let audioOutputSettings = audioOutputSettings(for: audioTrack, fileType: outputFileType) else {
                finish(error: .cannotExportSetting(.audio, fileType: outputFileType))
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
        
        
        
        
        
    }
    
    /// 结束任务
    private func finish(error: MNExportError?) {
        self.error = error
        status = .failed
        completionHandler?(.failed, error)
    }
    
    private func videoOutputSettings(for videoTrack: AVAssetTrack, fileType: AVFileType, renderSize: CGSize) -> [String:Any]? {
        // 分析源视频设置 avc1 avc1 hvc1 ap4h
        let sourceSettings = videoSettings(for: videoTrack)
        let sourceCodecType = sourceSettings?["codecType"] as? FourCharCode
        // 根据文件类型选择编码格式
        let codecType: AVVideoCodecType
        switch fileType {
        case .mp4, .m4v:
            // MP4/M4V 通常使用 H.264
            if #available(iOS 11.0, *) {
                codecType = .h264
            } else {
                codecType = .init(rawValue: AVVideoCodecH264)
            }
        case .mov:
            // MOV 支持更多格式，优先使用源格式或 H.264
            if #available(iOS 11.0, *), let sourceCodec = sourceCodecType, sourceCodec == kCMVideoCodecType_HEVC {
                codecType = .hevc
            } else if #available(iOS 11.0, *) {
                codecType = .h264
            } else {
                codecType = .init(rawValue: AVVideoCodecH264)
            }
        default: return nil
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
    }
    
    private func videoSettings(for videoTrack: AVAssetTrack) -> [String:Any] {
        var videoSettings: [String:Any] = [:]
        if let formatDescriptions = videoTrack.mn.formatDescriptions as? [CMFormatDescription] {
            for formatDescription in formatDescriptions {
                let mediaType = CMFormatDescriptionGetMediaType(formatDescription)
                guard mediaType == kCMMediaType_Video else { continue }
                // 获取编码类型
                let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
                videoSettings[AVVideoCodecKey] = codecType
                // 获取视频尺寸
                let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
                videoSettings[AVVideoWidthKey] = dimensions.width
                videoSettings[AVVideoHeightKey] = dimensions.height
                // 色彩空间 ColorPrimaries TransferFunction
                if let colorPrimariesValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_ColorPrimaries) as? String {
                    if #available(iOS 10.0, *) {
                        videoSettings[AVVideoColorPrimariesKey] = colorPrimariesValue
                    } else {
                        videoSettings["ColorPrimaries"] = colorPrimariesValue
                    }
                }
                if let transferFunctionValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_TransferFunction) as? String {
                    if #available(iOS 10.0, *) {
                        videoSettings[AVVideoTransferFunctionKey] = transferFunctionValue
                    } else {
                        videoSettings["TransferFunction"] = transferFunctionValue
                    }
                    // 是否是HDR
                    if transferFunctionValue.contains("PQ") || transferFunctionValue.contains("HLG") {
                        videoSettings["HDR"] = true
                    }
                }
                if let yCbCrMatrixValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_YCbCrMatrix) as? String {
                    if #available(iOS 10.0, *) {
                        videoSettings[AVVideoYCbCrMatrixKey] = yCbCrMatrixValue
                    } else {
                        videoSettings["YCbCrMatrix"] = yCbCrMatrixValue
                    }
                }
                // 是否有Alpha通道
                if #available(iOS 13.0, *), let yCbCrMatrixValue = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_ContainsAlphaChannel) as? Bool {
                    videoSettings["ContainsAlphaChannel"] = true
                }
                // 像素宽高比
                if let pixelAspectRatio = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_PixelAspectRatio) as? [String: Any] {
                    videoSettings[AVVideoPixelAspectRatioKey] = pixelAspectRatio
                    if let horizontalSpacing = pixelAspectRatio[kCVImageBufferPixelAspectRatioHorizontalSpacingKey as String] as? CGFloat, horizontalSpacing > 0.0, let verticalSpacing = pixelAspectRatio[kCVImageBufferPixelAspectRatioVerticalSpacingKey as String] as? CGFloat, verticalSpacing > 0.0 {
                        videoSettings[AVVideoPixelAspectRatioVerticalSpacingKey] = verticalSpacing
                        videoSettings[AVVideoPixelAspectRatioHorizontalSpacingKey] = horizontalSpacing
                    }
                }
                break
            }
        }
        return videoSettings
    }
    
    /// 原始编码类型
    private func codecType(for track: AVAssetTrack) -> AVVideoCodecType {
        if let formatDescriptions = track.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first {
            let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
            switch codecType {
            case kCMVideoCodecType_H264:
                if #available(iOS 11.0, *) {
                    return .h264
                }
                return .init(rawValue: AVVideoCodecH264)
            case kCMVideoCodecType_HEVC:
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
        }
        // 默认使用H.264编码
        if #available(iOS 11.0, *) {
            return .h264
        }
        return .init(rawValue: AVVideoCodecH264)
    }
    
    private func audioOutputSettings(for audioTrack: AVAssetTrack, fileType: AVFileType) -> [String:Any]? {
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
    }
    
    private func audioSettings(for audioTrack: AVAssetTrack) -> [String:Any]? {
        guard let formatDescriptions = audioTrack.mn.formatDescriptions as? [CMFormatDescription] else { return nil }
        var audioSettings: [String: Any] = [:]
        for formatDescription in formatDescriptions {
            let mediaType = CMFormatDescriptionGetMediaType(formatDescription)
            guard mediaType == kCMMediaType_Audio else { continue }
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
            break
        }
        return audioSettings
    }
}
