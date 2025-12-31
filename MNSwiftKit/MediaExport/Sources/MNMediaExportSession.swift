//
//  MNMediaExportSession.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/30.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  媒体资源输会话

import CoreMedia
import Foundation
import AVFoundation
#if SWIFT_PACKAGE
@_exported import MNNameSpace
#endif


/// 媒体资源输出会话
public class MNMediaExportSession: NSObject {
    
    /// 输出质量
    public enum Quality {
        /// 低质量
        case low
        /// 中等质量
        case medium
        /// 高质量
        case high
    }
    
    /// 获取资源信息
    public let asset: AVAsset
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
    public var outputURL: URL
    /// 裁剪画面矩形
    public var cropRect: CGRect?
    /// 预设质量
    public var presetName: String?
    /// 输出分辨率outputRect有效时有效
    public var renderSize: CGSize?
    /// 裁剪片段
    public var timeRange: CMTimeRange?
    /// 是否输出音频内容
    public var exportAudioTrack: Bool = true
    /// 是否输出视频内容
    public var exportVideoTrack: Bool = true
    /// 默认高质量输出策略
    public var quality: MNMediaExportSession.Quality = .medium
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
    /// - Parameters:
    ///   - asset: 媒体资源
    ///   - outputURL: 文件输出位置
    public init(asset: AVAsset, outputURL: URL) {
        self.asset = asset
        self.outputURL = outputURL
    }
    
    /// 构造资源输出会话
    /// - Parameters:
    ///   - filePath: 媒体资源路径
    ///   - outputURL: 文件输出位置
    public convenience init?(fileAtPath filePath: String, outputURL: URL) {
        guard let asset = AVURLAsset(fileAtPath: filePath) else { return nil }
        self.init(asset: asset, outputURL: outputURL)
    }
    
    /// 构造资源输出会话
    /// - Parameters:
    ///   - url: 媒体资源定位器
    ///   - outputURL: 文件输出位置
    public convenience init(assetOfURL url: URL, outputURL: URL) {
        let asset = AVURLAsset(mediaOfURL: url)
        self.init(asset: asset, outputURL: outputURL)
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
        
        // 检查是否支持输出文件类型
        guard compatibility(export: composition, outputFileType: outputFileType) else {
            finish(error: .cannotExportFile(outputURL, fileType: outputFileType))
            return
        }
        
        // 确保本地文件可输出
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
        
        // 创建 AVAssetReader
        let reader: AVAssetReader
        do {
            reader = try AVAssetReader(asset: composition)
        } catch {
            finish(error: .cannotReadAsset(error))
            return
        }
        reader.timeRange = CMTimeRange(start: CMTime.zero, duration: composition.duration)
        
        // 创建 AVAssetWriter
        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: outputFileType)
        } catch {
            finish(error: .cannotWritToFile(outputURL, fileType: outputFileType, error: error))
            return
        }
        if shouldOptimizeForNetworkUse, outputFileType != .m4v {
            writer.shouldOptimizeForNetworkUse = true
        }
        
        // 配置视频输入输出
        var videoInput: AVAssetWriterInput!
        var videoOutput: AVAssetReaderVideoCompositionOutput!
        if let videoTrack = composition.mn.track(with: AVMediaType.video) {
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
            // 通用视频格式
            let videoSettings: [String: Any] = [
                //kCVPixelBufferWidthKey as String: Int(renderSize.width),
                //kCVPixelBufferHeightKey as String: Int(renderSize.height),
                kCVPixelBufferMetalCompatibilityKey as String: true,
                kCVPixelBufferOpenGLCompatibilityKey as String: true,
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]
            videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [videoTrack], videoSettings: videoSettings)
            videoOutput.videoComposition = videoComposition
            videoOutput.alwaysCopiesSampleData = false
            
            guard reader.canAdd(videoOutput) else {
                finish(error: .cannotAddOutput(AVMediaType.video))
                return
            }
            reader.add(videoOutput)
            
            guard let outputSettings = videoOutputSettings(for: videoTrack, fileType: outputFileType, renderSize: renderSize) else {
                finish(error: .unknownExportSetting(AVMediaType.video, fileType: outputFileType))
                return
            }
            videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
            videoInput.expectsMediaDataInRealTime = false
            
            guard writer.canAdd(videoInput) else {
                finish(error: .cannotAddInput(AVMediaType.video))
                return
            }
            writer.add(videoInput)
        }
        
        // 配置音频输入输出
        var audioInput: AVAssetWriterInput!
        var audioOutput: AVAssetReaderOutput!
        if let audioTrack = composition.mn.track(with: AVMediaType.audio) {
            // 创建 Audio Output
            let audioSettings = audioSettings(for: audioTrack)
            audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioSettings)
            audioOutput.alwaysCopiesSampleData = false
            
            guard reader.canAdd(audioOutput) else {
                finish(error: .cannotAddOutput(AVMediaType.audio))
                return
            }
            reader.add(audioOutput)
            
            // 创建 Audio Input
            guard let audioOutputSettings = audioOutputSettings(for: audioTrack, fileType: outputFileType) else {
                finish(error: .unknownExportSetting(AVMediaType.audio, fileType: outputFileType))
                return
            }
            audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
            audioInput.expectsMediaDataInRealTime = false
            
            guard writer.canAdd(audioInput) else {
                finish(error: .cannotAddInput(AVMediaType.audio))
                return
            }
            writer.add(audioInput)
        }
        
        // 输出资源
        guard reader.startReading() else {
            let error = reader.error ?? NSError(domain: AVFoundationErrorDomain, code: -1020, userInfo: [NSLocalizedDescriptionKey:"启动读取器失败"])
            finish(error: .cannotStartReading(error))
            return
        }
        
        guard writer.startWriting() else {
            reader.cancelReading()
            let error = writer.error ?? NSError(domain: AVFoundationErrorDomain, code: -1021, userInfo: [NSLocalizedDescriptionKey:"启动输入器失败"])
            finish(error: .cannotStartWriting(error))
            return
        }
        writer.startSession(atSourceTime: CMTime.zero)
        
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
    
    /// 判断是否支持输出资源
    /// - Parameters:
    ///   - asset: 资源
    ///   - fileType: 文件UTI类型
    /// - Returns: 是否支持输出
    private func compatibility(export asset: AVAsset, outputFileType fileType: AVFileType) -> Bool {
        if let _ = asset.mn.track(with: AVMediaType.video) {
            // 视频格式
            let videoFileTypes: [AVFileType] = [.mp4, .m4v, .mov, .mobile3GPP]
            return videoFileTypes.contains(fileType)
        }
        if let _ = asset.mn.track(with: AVMediaType.audio) {
            // 音频格式
            let audioFileTypes: [AVFileType] = [.wav, .m4a, .caf, .aiff, .aifc]
            return audioFileTypes.contains(fileType)
        }
        return false
    }
    
    /// 首选的视频轨道输出预设
    /// - Parameters:
    ///   - useH264CodecType: 是否使用H264编码
    ///   - renderSize: 视频渲染尺寸
    ///   - containsAlphaChannel: 是否包含透明度
    /// - Returns: 视频轨道输出预设
    private func preferredVideoOutputPreset(useH264 useH264CodecType: Bool, renderSize: CGSize, containsAlphaChannel: Bool) -> AVOutputSettingsPreset {
        let dimension = renderSize.width*renderSize.height
        switch quality {
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
        }
    }
    
    /// 视频输出参数
    /// - Parameters:
    ///   - videoTrack: 视频轨道
    ///   - fileType: 输出文件类型
    ///   - renderSize: 视频渲染尺寸
    /// - Returns: 视频输出参数
    private func videoOutputSettings(for videoTrack: AVAssetTrack, fileType: AVFileType, renderSize: CGSize) -> [String:Any]? {
        guard let formatDescriptions = videoTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first else { return nil }
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
        // 选择编码方式, 默认兼容性最好
        var useH264CodecType = true
        if fileType != .m4v, #available(iOS 11.0, *), shouldOptimizeForNetworkUse == false {
            // 使用压缩更好的hevc
            useH264CodecType = false
        }
        // 使用推荐
        let preset = preferredVideoOutputPreset(useH264: useH264CodecType, renderSize: renderSize, containsAlphaChannel: containsAlphaChannel)
        guard AVOutputSettingsAssistant.availableOutputSettingsPresets().contains(preset) else { return nil }
        guard let assistant = AVOutputSettingsAssistant(preset: preset) else { return nil }
        assistant.sourceVideoFormat = formatDescription
        let minFrameDuration = videoTrack.mn.minFrameDuration
        if minFrameDuration.isValid, minFrameDuration.isIndefinite == false {
            assistant.sourceVideoAverageFrameDuration = minFrameDuration
        } else {
            // 默认30帧输出
            assistant.sourceVideoAverageFrameDuration = CMTime(value: 1, timescale: 30)
        }
        guard var videoSettings = assistant.videoSettings else { return nil }
        videoSettings[AVVideoWidthKey] = Int(renderSize.width)
        videoSettings[AVVideoHeightKey] = Int(renderSize.height)
        if let codec = videoSettings[AVVideoCodecKey] as? String, codec == "avc1", var compressionProperties = videoSettings[AVVideoCompressionPropertiesKey] as? [String:Any] {
            //
            switch quality {
            case .low:
                compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264BaselineAutoLevel
            case .medium:
                compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264MainAutoLevel
            case .high:
                compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel
            }
        }
        return videoSettings
    }
    
    /// 音频输出参数
    /// - Parameters:
    ///   - audioTrack: 音频轨道
    ///   - fileType: 输出文件类型
    /// - Returns: 音频输出设置参数
    private func audioOutputSettings(for audioTrack: AVAssetTrack, fileType: AVFileType) -> [String:Any]? {
        var audioSettings: [String:Any] = [:]
        switch fileType {
        case .wav, .aiff, .aifc:
            // WAV: PCM未压缩音频数据 + 标准的WAV头部
            // AIFF: 苹果生态系统中的无损音频标准格式, 类似于 WAV 但具有更好的元数据支持
            // AIFC: AIFF的压缩版本, 支持多种压缩编码, 继承AIFF的丰富元数据支持, 在AIFF基础上增加了压缩支持, 常用于专业音频软件和游戏开发
            // AVLinearPCMIsFloatKey和AVLinearPCMBitDepthKey必须同时都设置, 不能有AVEncoderAudioQualityKey
            audioSettings[AVFormatIDKey] = kAudioFormatLinearPCM
            audioSettings[AVLinearPCMIsFloatKey] = false
            audioSettings[AVLinearPCMIsBigEndianKey] = fileType != .wav
            audioSettings[AVLinearPCMIsNonInterleaved] = false
            switch quality {
            case .low:
                audioSettings[AVSampleRateKey] = 22050.0
                audioSettings[AVNumberOfChannelsKey] = 1
                audioSettings[AVLinearPCMBitDepthKey] = 16
            case .medium:
                audioSettings[AVSampleRateKey] = 44100.0
                audioSettings[AVNumberOfChannelsKey] = 2
                audioSettings[AVLinearPCMBitDepthKey] = 16
            case .high:
                audioSettings[AVSampleRateKey] = 48000.0
                audioSettings[AVNumberOfChannelsKey] = 2
                audioSettings[AVLinearPCMBitDepthKey] = 24
            }
        case .caf:
            // CoreAudio框架原生支持的格式, 支持几乎所有的音频编码格式, 支持丰富的元数据, 常用于专业音频应用
            switch quality {
            case .low:
                // AAC 高效压缩 低比特率 语音音质
                audioSettings[AVFormatIDKey] = kAudioFormatMPEG4AAC
                audioSettings[AVSampleRateKey] = 22050.0
                audioSettings[AVNumberOfChannelsKey] = 1
                audioSettings[AVEncoderBitRateKey] = 64000
                //audioSettings[AVLinearPCMBitDepthKey] = 16
                audioSettings[AVEncoderAudioQualityKey] = AVAudioQuality.low.rawValue
            case .medium:
                // AAC 优质压缩 128kbps 标准比特率 CD音质
                audioSettings[AVFormatIDKey] = kAudioFormatMPEG4AAC_LD
                audioSettings[AVSampleRateKey] = 44100.0
                audioSettings[AVNumberOfChannelsKey] = 2
                audioSettings[AVEncoderBitRateKey] = 128000
                audioSettings[AVEncoderAudioQualityKey] = AVAudioQuality.medium.rawValue
            case .high:
                // Apple Lossless 无损 音乐保存
                audioSettings[AVFormatIDKey] = kAudioFormatAppleLossless
                audioSettings[AVSampleRateKey] = 48000.0
                audioSettings[AVNumberOfChannelsKey] = 2
                audioSettings[AVEncoderBitDepthHintKey] = 16
            }
        case .m4a:
            // 目前最常用、最通用的音频格式, 在苹果生态系统中是默认的音频格式。使用kAudioFormatMPEG4AAC编码, 压缩效率高
            audioSettings[AVFormatIDKey] = kAudioFormatMPEG4AAC
            switch quality {
            case .low:
                audioSettings[AVSampleRateKey] = 22050.0
                audioSettings[AVEncoderBitRateKey] = 64000
                audioSettings[AVNumberOfChannelsKey] = 1
                audioSettings[AVEncoderAudioQualityKey] = AVAudioQuality.low.rawValue
                audioSettings[AVEncoderBitRateStrategyKey] = AVAudioBitRateStrategy_Constant
            case .medium:
                audioSettings[AVSampleRateKey] = 44100.0
                audioSettings[AVEncoderBitRateKey] = 128000
                audioSettings[AVNumberOfChannelsKey] = 2
                audioSettings[AVEncoderAudioQualityKey] = AVAudioQuality.medium.rawValue
                audioSettings[AVEncoderBitRateStrategyKey] = AVAudioBitRateStrategy_VariableConstrained
            case .high:
                audioSettings[AVSampleRateKey] = 44100.0
                audioSettings[AVEncoderBitRateKey] = 192000
                audioSettings[AVNumberOfChannelsKey] = 2
                audioSettings[AVEncoderAudioQualityKey] = AVAudioQuality.high.rawValue
                audioSettings[AVEncoderBitRateStrategyKey] = AVAudioBitRateStrategy_VariableConstrained
            }
        default:
            // 视频中的音频
            if let preset = AVOutputSettingsAssistant.availableOutputSettingsPresets().first, let assistant = AVOutputSettingsAssistant(preset: preset), let formatDescriptions = audioTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first {
                assistant.sourceAudioFormat = formatDescription
                if let settings = assistant.audioSettings {
                    audioSettings.merge(settings) { $1 }
                }
            }
        }
        if audioSettings[AVChannelLayoutKey] == nil {
            var channelLayout = AudioChannelLayout()
            memset(&channelLayout, 0, MemoryLayout<AudioChannelLayout>.size)
            if let numberOfChannels = audioSettings[AVNumberOfChannelsKey] as? Int {
                channelLayout.mChannelLayoutTag = numberOfChannels == 1 ? kAudioChannelLayoutTag_Mono : kAudioChannelLayoutTag_Stereo
                audioSettings[AVChannelLayoutKey] = Data(bytes: &channelLayout, count: MemoryLayout<AudioChannelLayout>.size)
            }
        }
        return audioSettings.isEmpty ? nil : audioSettings
    }
    
    /// 读取音频轨道描述信息
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
            // AVLinearPCMIsFloatKey和AVLinearPCMBitDepthKey必须同时都设置
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
    
    /// 获取视频轨道描述信息
    /// - Parameter videoTrack: 视频轨道
    /// - Returns: 视频信息
    private func videoSettings(for videoTrack: AVAssetTrack) -> [String:Any] {
        var videoSettings: [String:Any] = [:]
        if let formatDescriptions = videoTrack.mn.formatDescriptions as? [CMFormatDescription], let formatDescription = formatDescriptions.first {
            // 获取编码类型
            let subType = CMFormatDescriptionGetMediaSubType(formatDescription)
            videoSettings[AVVideoCodecKey] = videoCodecType(for: subType).rawValue
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
    
    /// 视频编码类型
    /// - Parameter codecType: 编码类型code
    /// - Returns: 视频编码类型
    private func videoCodecType(for codecType: FourCharCode) -> AVVideoCodecType {
        switch codecType {
        case kCMVideoCodecType_HEVC:
            // h265
            if #available(iOS 11.0, *) {
                return .hevc
            }
        case kCMVideoCodecType_HEVCWithAlpha:
            // h265 支持 Alpha 通道
            if #available(iOS 13.0, *) {
                return .hevcWithAlpha
            }
        case kCMVideoCodecType_JPEG:
            if #available(iOS 11.0, *) {
                return .jpeg
            }
        case kCMVideoCodecType_JPEG_XL:
            if #available(iOS 18.0, *) {
                return .JPEGXL
            }
        case kCMVideoCodecType_AppleProRes4444:
            /// 支持 Alpha 通道
            if #available(iOS 11.0, *) {
                return .proRes4444
            }
        case kCMVideoCodecType_AppleProRes4444XQ:
            /// 支持 Alpha 通道
            if #available(iOS 18.0, *) {
                return .appleProRes4444XQ
            }
        case kCMVideoCodecType_AppleProRes422:
            if #available(iOS 11.0, *) {
                return .proRes422
            }
        case kCMVideoCodecType_AppleProRes422HQ:
            if #available(iOS 13.0, *) {
                return .proRes422HQ
            }
        case kCMVideoCodecType_AppleProRes422LT:
            if #available(iOS 13.0, *) {
                return .proRes422LT
            }
        case kCMVideoCodecType_AppleProRes422Proxy:
            if #available(iOS 13.0, *) {
                return .proRes422Proxy
            }
        default: break
        }
        // 默认使用H.264编码
        // 在mp4封装下, 100%浏览器兼容，支持流式传输
        if #available(iOS 11.0, *) {
            return .h264
        }
        return .init(rawValue: AVVideoCodecH264)
    }
}
