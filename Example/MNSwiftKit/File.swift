//
//  File.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/3.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import AVFoundation
import CoreMedia
import UIKit

// MARK: - 智能媒体裁剪器
class SmartMediaCropper {
    
    // MARK: - 配置枚举
    enum ExportMode {
        case videoWithAudio  // 视频+音频
        case videoOnly       // 仅视频
        case audioOnly       // 仅音频
        case automatic       // 自动选择
    }
    
    enum ExportFileType {
        // 视频格式
        case mp4
        case mov
        case m4v
        case avi
        
        // 音频格式
        case m4a
        case mp3
        case wav
        case aac
        case flac
        case alac
        
        // 自定义
        case custom(String)
        
        var uti: String {
            switch self {
            case .mp4: return AVFileType.mp4.rawValue
            case .mov: return AVFileType.mov.rawValue
            case .m4v: return AVFileType.m4v.rawValue
            case .avi: return AVFileType.avi.rawValue
            case .m4a: return AVFileType.m4a.rawValue
            case .mp3: return AVFileType.mp3.rawValue
            case .wav: return AVFileType.wav.rawValue
            case .aac: return AVFileType.ac3.rawValue
            case .flac: return AVFileType.flac.rawValue
            case .alac: return AVFileType.alac.rawValue
            case .custom(let uti): return uti
            }
        }
        
        var isVideoFormat: Bool {
            switch self {
            case .mp4, .mov, .m4v, .avi: return true
            default: return false
            }
        }
        
        var isAudioFormat: Bool {
            return !isVideoFormat
        }
    }
    
    enum QualityPreset {
        case lowest
        case low
        case medium
        case high
        case highest
        case original
        
        var bitrateMultiplier: Double {
            switch self {
            case .lowest: return 0.25
            case .low: return 0.5
            case .medium: return 0.75
            case .high: return 1.0
            case .highest: return 1.5
            case .original: return 1.0
            }
        }
    }
    
    // MARK: - 配置结构体
    struct ExportConfiguration {
        let fileType: ExportFileType
        let exportMode: ExportMode
        let quality: QualityPreset
        let cropRect: CGRect?
        let timeRange: CMTimeRange?
        let outputSize: CGSize?
        
        var shouldCropVideo: Bool {
            return cropRect != nil
        }
    }
    
    // MARK: - 私有属性
    private var assetReader: AVAssetReader?
    private var assetWriter: AVAssetWriter?
    private var videoComposition: AVMutableVideoComposition?
    private var isCancelled = false
    
    // MARK: - 公开接口
    func cropMedia(sourceURL: URL,
                   outputURL: URL,
                   configuration: ExportConfiguration,
                   progressHandler: ((Double) -> Void)? = nil,
                   completion: @escaping (Result<URL, Error>) -> Void) {
        
        isCancelled = false
        
        // 异步执行
        DispatchQueue.global(qos: .userInitiated).async {
            self.performCropping(sourceURL: sourceURL,
                                outputURL: outputURL,
                                configuration: configuration,
                                progressHandler: progressHandler,
                                completion: completion)
        }
    }
    
    func cancel() {
        isCancelled = true
        assetReader?.cancelReading()
        assetWriter?.cancelWriting()
    }
    
    // MARK: - 核心裁剪逻辑
    private func performCropping(sourceURL: URL,
                                outputURL: URL,
                                configuration: ExportConfiguration,
                                progressHandler: ((Double) -> Void)?,
                                completion: @escaping (Result<URL, Error>) -> Void) {
        
        let asset = AVAsset(url: sourceURL)
        
        do {
            // 1. 分析资源
            let analysis = analyzeAsset(asset)
            
            // 2. 确定最终导出模式
            let finalExportMode = determineExportMode(analysis: analysis,
                                                     fileType: configuration.fileType,
                                                     requestedMode: configuration.exportMode)
            
            print("Export Mode: \(finalExportMode)")
            print("Has Video: \(analysis.hasVideo)")
            print("Has Audio: \(analysis.hasAudio)")
            
            // 3. 创建读取器和写入器
            try setupReaderAndWriter(asset: asset,
                                    outputURL: outputURL,
                                    fileType: configuration.fileType,
                                    analysis: analysis,
                                    configuration: configuration,
                                    exportMode: finalExportMode)
            
            guard let assetReader = assetReader, let assetWriter = assetWriter else {
                throw NSError(domain: "SmartMediaCropper", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to setup reader/writer"])
            }
            
            // 4. 设置时间范围
            if let timeRange = configuration.timeRange {
                assetReader.timeRange = timeRange
            }
            
            // 5. 开始处理
            startProcessing(assetReader: assetReader,
                          assetWriter: assetWriter,
                          analysis: analysis,
                          configuration: configuration,
                          exportMode: finalExportMode,
                          progressHandler: progressHandler,
                          completion: completion)
            
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 资源分析
    private struct AssetAnalysis {
        let hasVideo: Bool
        let hasAudio: Bool
        let videoTrack: AVAssetTrack?
        let audioTrack: AVAssetTrack?
        let duration: CMTime
        let naturalSize: CGSize
        let frameRate: Float
        let videoCodec: AVVideoCodecType
        let hasAlpha: Bool
        let isHDR: Bool
        let audioFormat: AudioFormatID
        let sampleRate: Double
        let channelCount: Int
    }
    
    private func analyzeAsset(_ asset: AVAsset) -> AssetAnalysis {
        let videoTrack = asset.tracks(withMediaType: .video).first
        let audioTrack = asset.tracks(withMediaType: .audio).first
        
        var analysis = AssetAnalysis(
            hasVideo: videoTrack != nil,
            hasAudio: audioTrack != nil,
            videoTrack: videoTrack,
            audioTrack: audioTrack,
            duration: asset.duration,
            naturalSize: videoTrack?.naturalSize ?? .zero,
            frameRate: videoTrack?.nominalFrameRate ?? 30,
            videoCodec: .h264,
            hasAlpha: false,
            isHDR: false,
            audioFormat: kAudioFormatMPEG4AAC,
            sampleRate: 44100,
            channelCount: 2
        )
        
        // 分析视频轨道
        if let videoTrack = videoTrack,
           let formatDescriptions = videoTrack.formatDescriptions as? [CMFormatDescription] {
            
            for formatDescription in formatDescriptions {
                let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
                analysis.videoCodec = mapCodecType(codecType)
                
                if let extensions = CMFormatDescriptionGetExtensions(formatDescription) as? [String: Any] {
                    analysis.hasAlpha = (extensions[kCVImageBufferContainsAlphaChannel as String] as? Bool) ?? false
                    
                    if let transfer = extensions[kCVImageBufferTransferFunctionKey as String] as? String {
                        analysis.isHDR = transfer.contains("PQ") || transfer.contains("HLG")
                    }
                }
            }
        }
        
        // 分析音频轨道
        if let audioTrack = audioTrack,
           let formatDescriptions = audioTrack.formatDescriptions as? [CMFormatDescription] {
            
            for formatDescription in formatDescriptions {
                if CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Audio {
                    analysis.audioFormat = CMFormatDescriptionGetMediaSubType(formatDescription)
                    
                    var asbd = AudioStreamBasicDescription()
                    if CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription, &asbd) {
                        analysis.sampleRate = asbd.mSampleRate
                        analysis.channelCount = Int(asbd.mChannelsPerFrame)
                    }
                    break
                }
            }
        }
        
        return analysis
    }
    
    private func mapCodecType(_ codec: FourCharCode) -> AVVideoCodecType {
        switch codec {
        case kCMVideoCodecType_HEVC: return .hevc
        case kCMVideoCodecType_AppleProRes4444: return .proRes4444
        case kCMVideoCodecType_AppleProRes422: return .proRes422
        default: return .h264
        }
    }
    
    // MARK: - 导出模式确定
    private func determineExportMode(analysis: AssetAnalysis,
                                    fileType: ExportFileType,
                                    requestedMode: ExportMode) -> ExportMode {
        
        switch requestedMode {
        case .automatic:
            return autoDetermineMode(analysis: analysis, fileType: fileType)
        case .videoOnly:
            return analysis.hasVideo ? .videoOnly : .audioOnly
        case .audioOnly:
            return analysis.hasAudio ? .audioOnly : .videoOnly
        case .videoWithAudio:
            return analysis.hasVideo ? .videoWithAudio : .audioOnly
        }
    }
    
    private func autoDetermineMode(analysis: AssetAnalysis, fileType: ExportFileType) -> ExportMode {
        if fileType.isAudioFormat {
            return analysis.hasAudio ? .audioOnly : .videoOnly
        } else if fileType.isVideoFormat {
            if analysis.hasVideo && analysis.hasAudio {
                return .videoWithAudio
            } else if analysis.hasVideo {
                return .videoOnly
            } else {
                return .audioOnly
            }
        }
        return analysis.hasVideo ? .videoWithAudio : .audioOnly
    }
    
    // MARK: - 设置读取器和写入器
    private func setupReaderAndWriter(asset: AVAsset,
                                     outputURL: URL,
                                     fileType: ExportFileType,
                                     analysis: AssetAnalysis,
                                     configuration: ExportConfiguration,
                                     exportMode: ExportMode) throws {
        
        // 创建读取器
        assetReader = try AVAssetReader(asset: asset)
        
        // 创建写入器
        assetWriter = try AVAssetWriter(outputURL: outputURL,
                                       fileType: AVFileType(rawValue: fileType.uti))
        
        guard let assetReader = assetReader, let assetWriter = assetWriter else {
            throw NSError(domain: "SmartMediaCropper", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create reader/writer"])
        }
        
        // 设置视频（如果需要）
        if (exportMode == .videoOnly || exportMode == .videoWithAudio) && analysis.hasVideo {
            try setupVideoProcessing(assetReader: assetReader,
                                   assetWriter: assetWriter,
                                   videoTrack: analysis.videoTrack!,
                                   analysis: analysis,
                                   configuration: configuration,
                                   exportMode: exportMode)
        }
        
        // 设置音频（如果需要）
        if (exportMode == .audioOnly || exportMode == .videoWithAudio) && analysis.hasAudio {
            try setupAudioProcessing(assetReader: assetReader,
                                   assetWriter: assetWriter,
                                   audioTrack: analysis.audioTrack!,
                                   analysis: analysis,
                                   fileType: fileType,
                                   configuration: configuration,
                                   exportMode: exportMode)
        }
    }
    
    // MARK: - 视频处理设置
    private func setupVideoProcessing(assetReader: AVAssetReader,
                                     assetWriter: AVAssetWriter,
                                     videoTrack: AVAssetTrack,
                                     analysis: AssetAnalysis,
                                     configuration: ExportConfiguration,
                                     exportMode: ExportMode) throws {
        
        // 计算输出尺寸
        let outputSize: CGSize
        if let cropRect = configuration.cropRect {
            outputSize = CGSize(width: cropRect.width, height: cropRect.height)
        } else if let specifiedSize = configuration.outputSize {
            outputSize = specifiedSize
        } else {
            outputSize = analysis.naturalSize
        }
        
        // 创建视频组合（如果需要裁剪或变换）
        if configuration.shouldCropVideo, let cropRect = configuration.cropRect {
            let videoComposition = createVideoComposition(for: videoTrack,
                                                         cropRect: cropRect,
                                                         outputSize: outputSize)
            self.videoComposition = videoComposition
        }
        
        // 生成视频设置
        let videoSettings = generateVideoSettings(for: analysis,
                                                 fileType: configuration.fileType,
                                                 quality: configuration.quality,
                                                 outputSize: outputSize)
        
        let videoOutputSettings = generateVideoOutputSettings(for: analysis,
                                                             outputSize: outputSize)
        
        // 创建视频输出
        if let videoComposition = self.videoComposition {
            // 使用视频组合输出
            let videoOutput = AVAssetReaderVideoCompositionOutput(
                videoTracks: [videoTrack],
                videoSettings: videoOutputSettings
            )
            videoOutput.videoComposition = videoComposition
            videoOutput.alwaysCopiesSampleData = false
            
            if assetReader.canAdd(videoOutput) {
                assetReader.add(videoOutput)
            }
        } else {
            // 使用普通轨道输出
            let videoOutput = AVAssetReaderTrackOutput(track: videoTrack,
                                                      outputSettings: videoOutputSettings)
            videoOutput.alwaysCopiesSampleData = false
            
            if assetReader.canAdd(videoOutput) {
                assetReader.add(videoOutput)
            }
        }
        
        // 创建视频输入
        let videoInput = AVAssetWriterInput(mediaType: .video,
                                           outputSettings: videoSettings)
        videoInput.expectsMediaDataInRealTime = false
        
        // 创建像素缓冲适配器
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            kCVPixelBufferWidthKey as String: Int(outputSize.width),
            kCVPixelBufferHeightKey as String: Int(outputSize.height)
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: pixelBufferAttributes
        )
        
        if assetWriter.canAdd(videoInput) {
            assetWriter.add(videoInput)
        }
    }
    
    // MARK: - 音频处理设置
    private func setupAudioProcessing(assetReader: AVAssetReader,
                                     assetWriter: AVAssetWriter,
                                     audioTrack: AVAssetTrack,
                                     analysis: AssetAnalysis,
                                     fileType: ExportFileType,
                                     configuration: ExportConfiguration,
                                     exportMode: ExportMode) throws {
        
        // 生成音频设置
        let audioSettings = generateAudioSettings(for: analysis,
                                                 fileType: fileType,
                                                 exportMode: exportMode,
                                                 quality: configuration.quality)
        
        let audioOutputSettings = generateAudioOutputSettings(for: analysis)
        
        // 创建音频输出
        let audioOutput = AVAssetReaderTrackOutput(track: audioTrack,
                                                  outputSettings: audioOutputSettings)
        audioOutput.alwaysCopiesSampleData = false
        
        if assetReader.canAdd(audioOutput) {
            assetReader.add(audioOutput)
        }
        
        // 创建音频输入
        let audioInput = AVAssetWriterInput(mediaType: .audio,
                                           outputSettings: audioSettings)
        audioInput.expectsMediaDataInRealTime = false
        
        if assetWriter.canAdd(audioInput) {
            assetWriter.add(audioInput)
        }
    }
    
    // MARK: - 视频组合创建
    private func createVideoComposition(for videoTrack: AVAssetTrack,
                                       cropRect: CGRect,
                                       outputSize: CGSize) -> AVMutableVideoComposition {
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = outputSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: videoTrack.timeRange.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // 计算裁剪变换
        let transform = calculateCropTransform(for: videoTrack,
                                              cropRect: cropRect,
                                              outputSize: outputSize)
        
        layerInstruction.setTransform(transform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
    
    private func calculateCropTransform(for track: AVAssetTrack,
                                       cropRect: CGRect,
                                       outputSize: CGSize) -> CGAffineTransform {
        
        let naturalSize = track.naturalSize
        let preferredTransform = track.preferredTransform
        
        // 计算缩放比例
        let scaleX = outputSize.width / cropRect.width
        let scaleY = outputSize.height / cropRect.height
        
        var transform = CGAffineTransform.identity
        
        // 应用缩放
        transform = transform.scaledBy(x: scaleX, y: scaleY)
        
        // 应用裁剪偏移
        let offsetX = -cropRect.origin.x * scaleX
        let offsetY = -cropRect.origin.y * scaleY
        transform = transform.translatedBy(x: offsetX, y: offsetY)
        
        // 应用原始变换
        transform = transform.concatenating(preferredTransform)
        
        return transform
    }
    
    // MARK: - 设置生成器
    private func generateVideoSettings(for analysis: AssetAnalysis,
                                      fileType: ExportFileType,
                                      quality: QualityPreset,
                                      outputSize: CGSize) -> [String: Any] {
        
        var videoSettings: [String: Any] = [
            AVVideoCodecKey: analysis.videoCodec,
            AVVideoWidthKey: Int(outputSize.width),
            AVVideoHeightKey: Int(outputSize.height)
        ]
        
        // 计算比特率
        let targetBitrate = calculateVideoBitrate(for: analysis,
                                                 outputSize: outputSize,
                                                 quality: quality)
        
        var compressionProperties: [String: Any] = [
            AVVideoAverageBitRateKey: targetBitrate,
            AVVideoMaxKeyFrameIntervalKey: 30
        ]
        
        if analysis.videoCodec == .h264 {
            compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel
        } else if analysis.videoCodec == .hevc {
            compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelHEVCMainAutoLevel
        }
        
        videoSettings[AVVideoCompressionPropertiesKey] = compressionProperties
        
        return videoSettings
    }
    
    private func calculateVideoBitrate(for analysis: AssetAnalysis,
                                      outputSize: CGSize,
                                      quality: QualityPreset) -> Int {
        
        if quality == .original {
            let originalArea = analysis.naturalSize.width * analysis.naturalSize.height
            let outputArea = outputSize.width * outputSize.height
            let areaRatio = outputArea / originalArea
            
            return Int(Float(analysis.videoTrack?.estimatedDataRate ?? 0) * Float(areaRatio))
        }
        
        // 智能比特率计算
        let megapixels = (outputSize.width * outputSize.height) / 1_000_000
        let frameRate = analysis.frameRate
        
        var baseBitrate: Double = 5.0 * megapixels * Double(frameRate / 30.0)
        baseBitrate *= quality.bitrateMultiplier
        
        return Int(baseBitrate * 1_000_000)
    }
    
    private func generateVideoOutputSettings(for analysis: AssetAnalysis,
                                            outputSize: CGSize) -> [String: Any] {
        
        return [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            kCVPixelBufferWidthKey as String: Int(outputSize.width),
            kCVPixelBufferHeightKey as String: Int(outputSize.height)
        ]
    }
    
    private func generateAudioSettings(for analysis: AssetAnalysis,
                                      fileType: ExportFileType,
                                      exportMode: ExportMode,
                                      quality: QualityPreset) -> [String: Any] {
        
        var audioSettings: [String: Any] = [:]
        
        // 确定音频格式
        let audioFormat: AudioFormatID
        if fileType.isAudioFormat {
            switch fileType {
            case .mp3: audioFormat = kAudioFormatMPEGLayer3
            case .wav: audioFormat = kAudioFormatLinearPCM
            case .flac: audioFormat = kAudioFormatFLAC
            case .alac: audioFormat = kAudioFormatAppleLossless
            default: audioFormat = kAudioFormatMPEG4AAC
            }
        } else {
            audioFormat = kAudioFormatMPEG4AAC
        }
        
        audioSettings[AVFormatIDKey] = audioFormat
        audioSettings[AVSampleRateKey] = analysis.sampleRate
        audioSettings[AVNumberOfChannelsKey] = analysis.channelCount
        
        // 比特率设置
        let bitrate = calculateAudioBitrate(for: analysis,
                                           fileType: fileType,
                                           audioFormat: audioFormat,
                                           quality: quality)
        
        if audioFormat == kAudioFormatMPEG4AAC || audioFormat == kAudioFormatMPEGLayer3 {
            audioSettings[AVEncoderBitRateKey] = bitrate
        } else if audioFormat == kAudioFormatLinearPCM {
            audioSettings[AVLinearPCMBitDepthKey] = 16
            audioSettings[AVLinearPCMIsFloatKey] = false
        }
        
        return audioSettings
    }
    
    private func calculateAudioBitrate(for analysis: AssetAnalysis,
                                      fileType: ExportFileType,
                                      audioFormat: AudioFormatID,
                                      quality: QualityPreset) -> Int {
        
        if quality == .original {
            return Int(analysis.audioTrack?.estimatedDataRate ?? 128000)
        }
        
        var baseBitrate: Int
        switch quality {
        case .lowest: baseBitrate = 64000
        case .low: baseBitrate = 96000
        case .medium: baseBitrate = 128000
        case .high: baseBitrate = 192000
        case .highest: baseBitrate = 320000
        default: baseBitrate = 128000
        }
        
        // 根据声道数调整
        if analysis.channelCount > 2 {
            baseBitrate = baseBitrate * analysis.channelCount / 2
        }
        
        return baseBitrate
    }
    
    private func generateAudioOutputSettings(for analysis: AssetAnalysis) -> [String: Any] {
        
        return [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: analysis.sampleRate,
            AVNumberOfChannelsKey: analysis.channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
    }
    
    // MARK: - 处理流程
    private func startProcessing(assetReader: AVAssetReader,
                               assetWriter: AVAssetWriter,
                               analysis: AssetAnalysis,
                               configuration: ExportConfiguration,
                               exportMode: ExportMode,
                               progressHandler: ((Double) -> Void)?,
                               completion: @escaping (Result<URL, Error>) -> Void) {
        
        // 开始读取和写入
        guard assetReader.startReading() else {
            DispatchQueue.main.async {
                completion(.failure(assetReader.error ?? NSError(domain: "SmartMediaCropper", code: -2,
                                                              userInfo: [NSLocalizedDescriptionKey: "Failed to start reading"])))
            }
            return
        }
        
        guard assetWriter.startWriting() else {
            DispatchQueue.main.async {
                completion(.failure(assetWriter.error ?? NSError(domain: "SmartMediaCropper", code: -3,
                                                              userInfo: [NSLocalizedDescriptionKey: "Failed to start writing"])))
            }
            return
        }
        
        assetWriter.startSession(atSourceTime: .zero)
        
        // 获取输入和输出
        let videoOutput = assetReader.outputs.first(where: { $0.mediaType == .video })
        let audioOutput = assetReader.outputs.first(where: { $0.mediaType == .audio })
        
        let videoInput = assetWriter.inputs.first(where: { $0.mediaType == .video })
        let audioInput = assetWriter.inputs.first(where: { $0.mediaType == .audio })
        
        // 创建处理队列
        let videoQueue = DispatchQueue(label: "com.smartmediacropper.video")
        let audioQueue = DispatchQueue(label: "com.smartmediacropper.audio")
        
        let group = DispatchGroup()
        var videoFinished = false
        var audioFinished = false
        
        let totalDuration = configuration.timeRange?.duration ?? analysis.duration
        let totalSeconds = CMTimeGetSeconds(totalDuration)
        
        // 处理视频（如果需要）
        if let videoInput = videoInput, let videoOutput = videoOutput {
            group.enter()
            
            videoInput.requestMediaDataWhenReady(on: videoQueue) { [weak self] in
                guard let self = self, !self.isCancelled else { return }
                
                while videoInput.isReadyForMoreMediaData {
                    if let sampleBuffer = videoOutput.copyNextSampleBuffer() {
                        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        
                        // 更新进度
                        if totalSeconds > 0 {
                            let progress = CMTimeGetSeconds(presentationTime) / totalSeconds
                            DispatchQueue.main.async {
                                progressHandler?(min(progress, 1.0))
                            }
                        }
                        
                        // 如果使用像素缓冲适配器
                        if let pixelBufferAdaptor = videoInput.getPixelBufferAdaptor(),
                           let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                            
                            let success = pixelBufferAdaptor.append(pixelBuffer,
                                                                   withPresentationTime: presentationTime)
                            if !success {
                                print("Failed to append pixel buffer")
                            }
                        } else {
                            let success = videoInput.append(sampleBuffer)
                            if !success {
                                print("Failed to append video sample")
                            }
                        }
                    } else {
                        videoInput.markAsFinished()
                        videoFinished = true
                        if audioFinished {
                            group.leave()
                        }
                        break
                    }
                }
            }
        } else {
            videoFinished = true
        }
        
        // 处理音频（如果需要）
        if let audioInput = audioInput, let audioOutput = audioOutput {
            group.enter()
            
            audioInput.requestMediaDataWhenReady(on: audioQueue) { [weak self] in
                guard let self = self, !self.isCancelled else { return }
                
                while audioInput.isReadyForMoreMediaData {
                    if let sampleBuffer = audioOutput.copyNextSampleBuffer() {
                        let success = audioInput.append(sampleBuffer)
                        if !success {
                            print("Failed to append audio sample")
                        }
                    } else {
                        audioInput.markAsFinished()
                        audioFinished = true
                        if videoFinished {
                            group.leave()
                        }
                        break
                    }
                }
            }
        } else {
            audioFinished = true
        }
        
        // 完成处理
        group.notify(queue: .global(qos: .userInitiated)) {
            if self.isCancelled {
                assetWriter.cancelWriting()
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "SmartMediaCropper", code: -4,
                                              userInfo: [NSLocalizedDescriptionKey: "Processing cancelled"])))
                }
                return
            }
            
            assetWriter.finishWriting {
                DispatchQueue.main.async {
                    switch assetWriter.status {
                    case .completed:
                        completion(.success(assetWriter.outputURL))
                    case .failed:
                        if let error = assetWriter.error {
                            completion(.failure(error))
                        }
                    case .cancelled:
                        completion(.failure(NSError(domain: "SmartMediaCropper", code: -5,
                                                  userInfo: [NSLocalizedDescriptionKey: "Processing cancelled"])))
                    default:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - 扩展：获取像素缓冲适配器
extension AVAssetWriterInput {
    func getPixelBufferAdaptor() -> AVAssetWriterInputPixelBufferAdaptor? {
        if let pixelBufferAdaptor = self.value(forKey: "pixelBufferAdaptor") as? AVAssetWriterInputPixelBufferAdaptor {
            return pixelBufferAdaptor
        }
        return nil
    }
}

// MARK: - 使用示例
extension SmartMediaCropper {
    
    // MARK: - 便捷方法
    static func cropVideo(sourceURL: URL,
                         outputURL: URL,
                         cropRect: CGRect,
                         startTime: TimeInterval,
                         endTime: TimeInterval,
                         progress: ((Double) -> Void)? = nil,
                         completion: @escaping (Result<URL, Error>) -> Void) {
        
        let cropper = SmartMediaCropper()
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 600),
                                   end: CMTime(seconds: endTime, preferredTimescale: 600))
        
        let configuration = ExportConfiguration(
            fileType: .mp4,
            exportMode: .videoWithAudio,
            quality: .high,
            cropRect: cropRect,
            timeRange: timeRange,
            outputSize: nil
        )
        
        cropper.cropMedia(sourceURL: sourceURL,
                         outputURL: outputURL,
                         configuration: configuration,
                         progressHandler: progress,
                         completion: completion)
    }
    
    static func extractAudio(sourceURL: URL,
                           outputURL: URL,
                           fileType: ExportFileType = .m4a,
                           quality: QualityPreset = .high,
                           timeRange: CMTimeRange? = nil,
                           progress: ((Double) -> Void)? = nil,
                           completion: @escaping (Result<URL, Error>) -> Void) {
        
        let cropper = SmartMediaCropper()
        
        let configuration = ExportConfiguration(
            fileType: fileType,
            exportMode: .audioOnly,
            quality: quality,
            cropRect: nil,
            timeRange: timeRange,
            outputSize: nil
        )
        
        cropper.cropMedia(sourceURL: sourceURL,
                         outputURL: outputURL,
                         configuration: configuration,
                         progressHandler: progress,
                         completion: completion)
    }
    
    static func resizeVideo(sourceURL: URL,
                          outputURL: URL,
                          targetSize: CGSize,
                          progress: ((Double) -> Void)? = nil,
                          completion: @escaping (Result<URL, Error>) -> Void) {
        
        let cropper = SmartMediaCropper()
        
        let configuration = ExportConfiguration(
            fileType: .mp4,
            exportMode: .videoWithAudio,
            quality: .high,
            cropRect: nil,
            timeRange: nil,
            outputSize: targetSize
        )
        
        cropper.cropMedia(sourceURL: sourceURL,
                         outputURL: outputURL,
                         configuration: configuration,
                         progressHandler: progress,
                         completion: completion)
    }
}

// MARK: - 使用示例代码
class ViewController: UIViewController {
    
    let cropper = SmartMediaCropper()
    
    func exampleUsage() {
        let sourceURL = URL(fileURLWithPath: "path/to/source/video.mp4")
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // 示例1：裁剪视频
        let outputURL1 = documentsPath.appendingPathComponent("cropped_video.mp4")
        let cropRect = CGRect(x: 100, y: 100, width: 720, height: 720)
        
        SmartMediaCropper.cropVideo(
            sourceURL: sourceURL,
            outputURL: outputURL1,
            cropRect: cropRect,
            startTime: 2.0,
            endTime: 10.0,
            progress: { progress in
                print("裁剪进度: \(Int(progress * 100))%")
            },
            completion: { result in
                switch result {
                case .success(let url):
                    print("视频裁剪完成: \(url.path)")
                case .failure(let error):
                    print("裁剪失败: \(error)")
                }
            }
        )
        
        // 示例2：提取音频
        let outputURL2 = documentsPath.appendingPathComponent("extracted_audio.m4a")
        
        SmartMediaCropper.extractAudio(
            sourceURL: sourceURL,
            outputURL: outputURL2,
            fileType: .m4a,
            quality: .high,
            progress: { progress in
                print("音频提取进度: \(Int(progress * 100))%")
            },
            completion: { result in
                switch result {
                case .success(let url):
                    print("音频提取完成: \(url.path)")
                case .failure(let error):
                    print("提取失败: \(error)")
                }
            }
        )
        
        // 示例3：使用完整配置
        let outputURL3 = documentsPath.appendingPathComponent("custom_output.mp4")
        let timeRange = CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 600),
                                   end: CMTime(seconds: 5, preferredTimescale: 600))
        
        let configuration = SmartMediaCropper.ExportConfiguration(
            fileType: .mp4,
            exportMode: .videoWithAudio,
            quality: .highest,
            cropRect: CGRect(x: 0, y: 0, width: 1080, height: 1080),
            timeRange: timeRange,
            outputSize: CGSize(width: 540, height: 540)
        )
        
        cropper.cropMedia(
            sourceURL: sourceURL,
            outputURL: outputURL3,
            configuration: configuration,
            progressHandler: { progress in
                print("处理进度: \(Int(progress * 100))%")
            },
            completion: { result in
                switch result {
                case .success(let url):
                    print("处理完成: \(url.path)")
                case .failure(let error):
                    print("处理失败: \(error)")
                }
            }
        )
    }
    
    func cancelProcessing() {
        cropper.cancel()
    }
}
