import AVFoundation
import VideoToolbox
import UIKit

class VideoCropper {
    
    // MARK: - 配置结构体
    
    struct CropConfig {
        var timeRange: CMTimeRange              // 时间范围（裁剪时长）
        var cropRect: CGRect?                   // 裁剪区域（nil表示不裁剪画面）
        var outputVideo: Bool = true            // 是否输出视频
        var outputAudio: Bool = true            // 是否输出音频
        var videoQuality: VideoQuality = .high  // 视频质量
        var outputURL: URL                      // 输出文件URL
    }
    
    enum VideoQuality {
        case low        // 低质量
        case medium     // 中等质量
        case high       // 高质量
        case custom(AVAssetWriterInput.PixelBufferAttributes) // 自定义
        
        func getPixelBufferAttributes() -> [String: Any] {
            switch self {
            case .low:
                return [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                    kCVPixelBufferWidthKey as String: 640,
                    kCVPixelBufferHeightKey as String: 480,
                    kCVPixelBufferIOSurfacePropertiesKey as String: [:]
                ]
            case .medium:
                return [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                    kCVPixelBufferWidthKey as String: 1280,
                    kCVPixelBufferHeightKey as String: 720,
                    kCVPixelBufferIOSurfacePropertiesKey as String: [:]
                ]
            case .high:
                return [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                    kCVPixelBufferIOSurfacePropertiesKey as String: [:]
                ]
            case .custom(let attrs):
                return attrs
            }
        }
    }
    
    // MARK: - 属性
    
    private let asset: AVAsset
    private let config: CropConfig
    
    // MARK: - 初始化
    
    init(asset: AVAsset, config: CropConfig) {
        self.asset = asset
        self.config = config
    }
    
    convenience init(assetURL: URL, config: CropConfig) {
        let asset = AVAsset(url: assetURL)
        self.init(asset: asset, config: config)
    }
    
    // MARK: - 主要方法
    
    /// 执行视频裁剪
    func crop(progressHandler: @escaping (Float) -> Void = { _ in },
              completion: @escaping (Result<URL, Error>) -> Void) {
        
        // 删除已存在的输出文件
        if FileManager.default.fileExists(atPath: config.outputURL.path) {
            try? FileManager.default.removeItem(at: config.outputURL)
        }
        
        // 异步执行
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // 准备读取器和写入器
                let reader = try self.setupAssetReader()
                let writer = try self.setupAssetWriter()
                
                // 开始读取和写入
                reader.startReading()
                writer.startWriting()
                writer.startSession(atSourceTime: self.config.timeRange.start)
                
                // 创建调度组来同步音视频处理
                let group = DispatchGroup()
                var videoError: Error?
                var audioError: Error?
                
                // 处理视频
                if self.config.outputVideo {
                    group.enter()
                    self.processVideo(reader: reader, writer: writer) { error in
                        videoError = error
                        group.leave()
                    } progressHandler: { progress in
                        DispatchQueue.main.async {
                            progressHandler(progress)
                        }
                    }
                }
                
                // 处理音频
                if self.config.outputAudio {
                    group.enter()
                    self.processAudio(reader: reader, writer: writer) { error in
                        audioError = error
                        group.leave()
                    }
                }
                
                // 等待所有处理完成
                group.notify(queue: .global(qos: .userInitiated)) {
                    // 检查错误
                    if let error = videoError ?? audioError {
                        writer.cancelWriting()
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    
                    // 完成写入
                    writer.finishWriting { [weak self] in
                        guard let self = self else { return }
                        
                        if writer.status == .completed {
                            DispatchQueue.main.async {
                                completion(.success(self.config.outputURL))
                            }
                        } else if let error = writer.error {
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(.failure(NSError(domain: "VideoCropper", code: -1, userInfo: [NSLocalizedDescriptionKey: "未知错误"])))
                            }
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - 设置AssetReader
    
    private func setupAssetReader() throws -> AVAssetReader {
        guard let reader = try? AVAssetReader(asset: asset) else {
            throw NSError(domain: "VideoCropper", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建AssetReader"])
        }
        
        // 设置时间范围
        reader.timeRange = config.timeRange
        
        return reader
    }
    
    // MARK: - 设置AssetWriter
    
    private func setupAssetWriter() throws -> AVAssetWriter {
        // 根据文件扩展名确定文件类型
        let fileType = getFileType(from: config.outputURL)
        
        guard let writer = try? AVAssetWriter(outputURL: config.outputURL, fileType: fileType) else {
            throw NSError(domain: "VideoCropper", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建AssetWriter"])
        }
        
        // 配置视频输入
        if config.outputVideo {
            let videoInput = try createVideoInput()
            if writer.canAdd(videoInput) {
                writer.add(videoInput)
            }
        }
        
        // 配置音频输入
        if config.outputAudio {
            if let audioInput = try? createAudioInput() {
                if writer.canAdd(audioInput) {
                    writer.add(audioInput)
                }
            }
        }
        
        return writer
    }
    
    // MARK: - 创建视频输入
    
    private func createVideoInput() throws -> AVAssetWriterInput {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            throw NSError(domain: "VideoCropper", code: -1, userInfo: [NSLocalizedDescriptionKey: "视频中没有视频轨道"])
        }
        
        // 获取原始视频尺寸
        let naturalSize = videoTrack.naturalSize
        let preferredTransform = videoTrack.preferredTransform
        
        // 计算实际显示尺寸（考虑旋转）
        let videoSize = getVideoSize(naturalSize: naturalSize, transform: preferredTransform)
        
        // 确定输出尺寸
        let outputSize: CGSize
        if let cropRect = config.cropRect {
            outputSize = cropRect.size
        } else {
            outputSize = videoSize
        }
        
        // 获取文件类型
        let fileType = getFileType(from: config.outputURL)
        
        // 分析源视频轨道信息并生成合适的编码设置
        let videoSettings = analyzeAndGetVideoSettings(
            outputSize: outputSize,
            sourceTrack: videoTrack,
            fileType: fileType
        )
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.transform = preferredTransform
        videoInput.expectsMediaDataInRealTime = false
        
        return videoInput
    }
    
    // MARK: - 创建音频输入
    
    private func createAudioInput() throws -> AVAssetWriterInput? {
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            return nil // 没有音频轨道，返回nil
        }
        
        // 获取文件类型
        let fileType = getFileType(from: config.outputURL)
        
        // 分析源音频轨道信息并生成合适的编码设置
        let audioSettings = analyzeAndGetAudioSettings(
            sourceTrack: audioTrack,
            fileType: fileType,
            isAudioOnly: !config.outputVideo
        )
        
        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        audioInput.expectsMediaDataInRealTime = false
        
        return audioInput
    }
    
    // MARK: - 处理视频数据
    
    private func processVideo(reader: AVAssetReader,
                             writer: AVAssetWriter,
                             completion: @escaping (Error?) -> Void,
                             progressHandler: @escaping (Float) -> Void) {
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(NSError(domain: "VideoCropper", code: -1, userInfo: [NSLocalizedDescriptionKey: "视频中没有视频轨道"]))
            return
        }
        
        guard let videoInput = writer.inputs.first(where: { $0.mediaType == .video }) as? AVAssetWriterInput else {
            completion(NSError(domain: "VideoCropper", code: -1, userInfo: [NSLocalizedDescriptionKey: "找不到视频输入"]))
            return
        }
        
        // 创建视频合成输出（用于裁剪画面）
        let videoComposition = createVideoComposition()
        
        // 获取合适的视频读取设置，优化性能和减少转换
        let videoReadSettings = getVideoReadSettings(sourceTrack: videoTrack)
        let videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [videoTrack], videoSettings: videoReadSettings)
        videoOutput.videoComposition = videoComposition
        videoOutput.alwaysCopiesSampleData = false
        
        if reader.canAdd(videoOutput) {
            reader.add(videoOutput)
        }
        
        // 在后台队列处理视频数据
        let videoQueue = DispatchQueue(label: "video.processing.queue")
        
        videoInput.requestMediaDataWhenReady(on: videoQueue) {
            while videoInput.isReadyForMoreMediaData {
                guard reader.status == .reading,
                      let sampleBuffer = videoOutput.copyNextSampleBuffer() else {
                    videoInput.markAsFinished()
                    completion(nil)
                    return
                }
                
                // 更新进度
                let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                let progress = Float(CMTimeSubtract(presentationTime, self.config.timeRange.start).seconds / self.config.timeRange.duration.seconds)
                progressHandler(min(progress, 1.0))
                
                // 写入数据
                if !videoInput.append(sampleBuffer) {
                    if let error = writer.error {
                        completion(error)
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - 处理音频数据
    
    private func processAudio(reader: AVAssetReader,
                             writer: AVAssetWriter,
                             completion: @escaping (Error?) -> Void) {
        
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            completion(nil) // 没有音频轨道，不算错误
            return
        }
        
        guard let audioInput = writer.inputs.first(where: { $0.mediaType == .audio }) as? AVAssetWriterInput else {
            completion(nil) // 没有音频输入，不算错误
            return
        }
        
        // 创建音频输出，使用优化的读取设置
        let audioReadSettings = getAudioReadSettings(sourceTrack: audioTrack)
        let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioReadSettings)
        audioOutput.alwaysCopiesSampleData = false
        
        if reader.canAdd(audioOutput) {
            reader.add(audioOutput)
        }
        
        // 在后台队列处理音频数据
        let audioQueue = DispatchQueue(label: "audio.processing.queue")
        
        audioInput.requestMediaDataWhenReady(on: audioQueue) {
            while audioInput.isReadyForMoreMediaData {
                guard reader.status == .reading,
                      let sampleBuffer = audioOutput.copyNextSampleBuffer() else {
                    audioInput.markAsFinished()
                    completion(nil)
                    return
                }
                
                // 写入数据
                if !audioInput.append(sampleBuffer) {
                    if let error = writer.error {
                        completion(error)
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - 创建视频合成（用于裁剪画面）
    
    private func createVideoComposition() -> AVVideoComposition {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            fatalError("没有视频轨道")
        }
        
        let naturalSize = videoTrack.naturalSize
        let preferredTransform = videoTrack.preferredTransform
        let videoSize = getVideoSize(naturalSize: naturalSize, transform: preferredTransform)
        
        // 确定裁剪区域
        let cropRect: CGRect
        if let configCropRect = config.cropRect {
            cropRect = configCropRect
        } else {
            cropRect = CGRect(origin: .zero, size: videoSize)
        }
        
        // 创建视频合成指令
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = config.timeRange
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // 计算变换矩阵（用于裁剪）
        let scaleX = cropRect.width / naturalSize.width
        let scaleY = cropRect.height / naturalSize.height
        let translateX = -cropRect.origin.x
        let translateY = -cropRect.origin.y
        
        var transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        transform = transform.translatedBy(x: translateX / scaleX, y: translateY / scaleY)
        transform = transform.concatenating(preferredTransform)
        
        layerInstruction.setTransform(transform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        
        // 创建视频合成
        let composition = AVMutableVideoComposition()
        composition.instructions = [instruction]
        composition.frameDuration = CMTime(value: 1, timescale: Int32(videoTrack.nominalFrameRate))
        composition.renderSize = cropRect.size
        
        return composition
    }
    
    // MARK: - 辅助方法
    
    /// 根据文件扩展名获取文件类型
    private func getFileType(from url: URL) -> AVFileType {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "mov":
            return .mov
        case "mp4", "m4v":
            return .mp4
        case "m4a":
            return .m4a
        case "3gp":
            return .mobile3GPP
        case "caf":
            return .caf
        case "aif", "aiff":
            return .aiff
        case "aifc":
            return .aifc
        case "wav":
            return .wav
        default:
            return .mp4 // 默认使用mp4
        }
    }
    
    /// 获取视频实际显示尺寸（考虑旋转）
    private func getVideoSize(naturalSize: CGSize, transform: CGAffineTransform) -> CGSize {
        let rect = CGRect(origin: .zero, size: naturalSize)
        let transformedRect = rect.applying(transform)
        return CGSize(width: abs(transformedRect.width), height: abs(transformedRect.height))
    }
    
    /// 分析源视频轨道信息并结合文件类型、质量、渲染尺寸生成合适的视频编码设置
    private func analyzeAndGetVideoSettings(outputSize: CGSize, sourceTrack: AVAssetTrack, fileType: AVFileType) -> [String: Any] {
        var settings: [String: Any] = [:]
        
        // 分析源视频轨道信息
        let sourceFrameRate = sourceTrack.nominalFrameRate > 0 ? sourceTrack.nominalFrameRate : 30.0
        let sourceNaturalSize = sourceTrack.naturalSize
        
        // 获取源视频的编码格式信息
        var sourceCodecType: AVVideoCodecType?
        var sourceBitrate: Int?
        
        if let formatDescriptions = sourceTrack.formatDescriptions as? [CMFormatDescription],
           let formatDescription = formatDescriptions.first {
            // 尝试获取源编码格式
            let mediaSubType = CMFormatDescriptionGetMediaSubType(formatDescription)
            // 将FourCharCode转换为AVVideoCodecType
            // 常见的编码类型：'avc1' = H.264 (0x61766331), 'hvc1' = HEVC (0x68766331), 'hev1' = HEVC (0x68657631)
            let h264Code = FourCharCodeFromString("avc1")
            let hevcCode1 = FourCharCodeFromString("hvc1")
            let hevcCode2 = FourCharCodeFromString("hev1")
            
            if mediaSubType == h264Code {
                sourceCodecType = AVVideoCodecType.h264
            } else if mediaSubType == hevcCode1 || mediaSubType == hevcCode2 {
                if #available(iOS 11.0, *) {
                    sourceCodecType = AVVideoCodecType.hevc
                }
            }
            
            // 尝试从格式描述扩展中获取比特率信息
            if let extensions = CMFormatDescriptionGetExtensions(formatDescription) as? [String: Any] {
                // 尝试多个可能的比特率键
                if let bitrate = extensions[kCMFormatDescriptionExtension_VerbatimBitrate as String] as? Int {
                    sourceBitrate = bitrate
                } else if let bitrate = extensions["BitsPerSecond"] as? Int {
                    sourceBitrate = bitrate
                } else if let bitrateDict = extensions[kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms as String] as? [String: Any],
                          let avcC = bitrateDict["avcC"] as? [String: Any],
                          let bitrate = avcC["bitrate"] as? Int {
                    sourceBitrate = bitrate
                }
            }
            
            // 如果无法从格式描述获取比特率，尝试从estimatedDataRate获取
            if sourceBitrate == nil {
                let estimatedDataRate = sourceTrack.estimatedDataRate
                if estimatedDataRate > 0 {
                    sourceBitrate = Int(estimatedDataRate)
                }
            }
        }
        
        // 根据文件类型选择合适的编码格式
        // MP4/MOV: 优先使用H.265(HEVC)以获得更好的压缩率，如果不支持则使用H.264
        let codecType: AVVideoCodecType
        if fileType == .mp4 || fileType == .mov {
            // 检查是否支持HEVC编码（iOS 11+）
            if #available(iOS 11.0, *) {
                // 检查设备是否支持HEVC编码
                let hevcSupported = AVAssetExportSession.allExportPresets().contains(AVAssetExportPresetHEVCHighestQuality)
                codecType = hevcSupported ? AVVideoCodecType.hevc : AVVideoCodecType.h264
            } else {
                codecType = AVVideoCodecType.h264
            }
        } else {
            // 其他格式使用H.264
            codecType = AVVideoCodecType.h264
        }
        
        settings[AVVideoCodecKey] = codecType
        settings[AVVideoWidthKey] = Int(outputSize.width)
        settings[AVVideoHeightKey] = Int(outputSize.height)
        
        // 计算像素数
        let pixelCount = outputSize.width * outputSize.height
        
        // 根据质量、输出尺寸和源视频信息智能计算比特率
        // 目标：高清晰度但文件小
        let baseBitrateMultiplier: Double
        switch config.videoQuality {
        case .low:
            baseBitrateMultiplier = 0.3  // 低质量：更激进的压缩
        case .medium:
            baseBitrateMultiplier = 0.6  // 中等质量：平衡压缩
        case .high:
            baseBitrateMultiplier = 1.0  // 高质量：保持清晰度
        case .custom:
            baseBitrateMultiplier = 1.0
        }
        
        // 根据输出尺寸调整比特率
        // 使用对数缩放，小尺寸视频相对需要更高的比特率密度
        let sizeFactor: Double
        if pixelCount < 640 * 480 {
            sizeFactor = 1.2  // 小尺寸：提高比特率密度
        } else if pixelCount < 1280 * 720 {
            sizeFactor = 1.0  // 中等尺寸：标准比特率
        } else if pixelCount < 1920 * 1080 {
            sizeFactor = 0.9  // 1080p：稍微降低比特率密度
        } else {
            sizeFactor = 0.8  // 4K及以上：进一步降低比特率密度
        }
        
        // 如果有源比特率信息，参考它来设置（但会根据输出尺寸调整）
        let calculatedBitrate: Int
        if let sourceBitrate = sourceBitrate, sourceBitrate > 0 {
            // 根据输出尺寸与源尺寸的比例调整比特率
            let sourcePixelCount = sourceNaturalSize.width * sourceNaturalSize.height
            let sizeRatio = pixelCount / sourcePixelCount
            let adjustedSourceBitrate = Double(sourceBitrate) * sizeRatio * baseBitrateMultiplier * sizeFactor
            calculatedBitrate = Int(adjustedSourceBitrate)
        } else {
            // 使用基于像素数的公式计算
            // HEVC比H.264效率高约30-50%，所以使用更低的比特率
            let codecEfficiencyFactor = (codecType == .hevc) ? 0.7 : 1.0
            calculatedBitrate = Int(pixelCount * baseBitrateMultiplier * sizeFactor * codecEfficiencyFactor)
        }
        
        // 设置合理的比特率范围（避免过高或过低）
        let minBitrate = Int(pixelCount * 0.1)  // 最低比特率
        let maxBitrate = Int(pixelCount * 3.0)  // 最高比特率
        let finalBitrate = max(minBitrate, min(maxBitrate, calculatedBitrate))
        
        // 根据帧率调整关键帧间隔（通常设置为帧率的2-3倍）
        let keyFrameInterval = max(30, Int(sourceFrameRate * 2))
        
        // 设置压缩属性
        var compressionProperties: [String: Any] = [
            AVVideoAverageBitRateKey: finalBitrate,
            AVVideoMaxKeyFrameIntervalKey: keyFrameInterval,
        ]
        
        // 根据编码格式设置Profile Level
        if codecType == .hevc {
            if #available(iOS 11.0, *) {
                // 使用VideoToolbox框架中的HEVC Profile Level常量
                compressionProperties[AVVideoProfileLevelKey] = kVTProfileLevel_HEVC_Main_AutoLevel
            }
        } else {
            // H.264: 根据输出尺寸选择合适的Profile
            if pixelCount <= 640 * 480 {
                compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264BaselineAutoLevel
            } else {
                compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel
            }
        }
        
        // 设置允许帧重排序（提高压缩效率）
        compressionProperties[AVVideoAllowFrameReorderingKey] = true
        
        // 设置H.264的熵编码模式（CABAC比CAVLC效率更高）
        if codecType == .h264 {
            compressionProperties[AVVideoH264EntropyModeKey] = AVVideoH264EntropyModeCABAC
        }
        
        settings[AVVideoCompressionPropertiesKey] = compressionProperties
        
        return settings
    }
    
    /// 分析源音频轨道信息并结合文件类型生成合适的音频编码设置
    private func analyzeAndGetAudioSettings(sourceTrack: AVAssetTrack, fileType: AVFileType, isAudioOnly: Bool) -> [String: Any] {
        var settings: [String: Any] = [:]
        
        // 分析源音频轨道信息
        var sourceSampleRate: Double = 44100.0
        var sourceChannels: Int = 2
        var sourceBitrate: Int?
        var sourceFormatID: AudioFormatID?
        
        if let formatDescriptions = sourceTrack.formatDescriptions as? [CMFormatDescription],
           let formatDescription = formatDescriptions.first {
            
            // 获取音频流基本描述
            if let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                let asbd = audioStreamBasicDescription.pointee
                sourceSampleRate = asbd.mSampleRate
                sourceChannels = Int(asbd.mChannelsPerFrame)
                sourceFormatID = asbd.mFormatID
            }
            
            // 尝试从扩展信息中获取比特率
            if let extensions = CMFormatDescriptionGetExtensions(formatDescription) as? [String: Any] {
                if let bitrate = extensions[kCMFormatDescriptionExtension_VerbatimBitrate as String] as? Int {
                    sourceBitrate = bitrate
                }
            }
        }
        
        // 根据文件类型选择合适的音频编码格式
        let audioFormatID: AudioFormatID
        switch fileType {
        case .m4a, .mp4, .mov, .m4v:
            // MP4系列：使用AAC编码（高效压缩）
            audioFormatID = kAudioFormatMPEG4AAC
        case .caf:
            // CAF：可以使用AAC或Apple Lossless
            audioFormatID = kAudioFormatMPEG4AAC
        case .aif, .aiff, .aifc:
            // AIFF系列：使用未压缩的PCM或AAC
            audioFormatID = isAudioOnly ? kAudioFormatLinearPCM : kAudioFormatMPEG4AAC
        case .wav:
            // WAV：通常使用PCM，但也可以使用AAC
            audioFormatID = isAudioOnly ? kAudioFormatLinearPCM : kAudioFormatMPEG4AAC
        default:
            // 默认使用AAC
            audioFormatID = kAudioFormatMPEG4AAC
        }
        
        settings[AVFormatIDKey] = audioFormatID
        
        // 设置采样率：优先使用源采样率，但根据质量适当调整
        let targetSampleRate: Double
        if audioFormatID == kAudioFormatLinearPCM {
            // PCM格式：保持源采样率
            targetSampleRate = sourceSampleRate
        } else {
            // 压缩格式：根据源采样率和质量智能选择
            switch config.videoQuality {
            case .low:
                // 低质量：降低采样率以减小文件
                if sourceSampleRate >= 48000 {
                    targetSampleRate = 44100
                } else if sourceSampleRate >= 44100 {
                    targetSampleRate = 44100
                } else {
                    targetSampleRate = sourceSampleRate
                }
            case .medium:
                // 中等质量：保持或稍微降低采样率
                targetSampleRate = min(sourceSampleRate, 44100)
            case .high:
                // 高质量：保持源采样率
                targetSampleRate = sourceSampleRate
            case .custom:
                targetSampleRate = sourceSampleRate
            }
        }
        
        settings[AVSampleRateKey] = targetSampleRate
        
        // 设置声道数：保持源声道数，但如果是单声道可以保持单声道以减小文件
        let targetChannels: Int
        if sourceChannels == 1 {
            targetChannels = 1  // 保持单声道
        } else {
            // 立体声或多声道：根据质量决定
            switch config.videoQuality {
            case .low:
                targetChannels = min(sourceChannels, 2)  // 最多立体声
            case .medium, .high, .custom:
                targetChannels = sourceChannels  // 保持原声道数
            }
        }
        
        settings[AVNumberOfChannelsKey] = targetChannels
        
        // 如果是PCM格式，设置PCM相关参数
        if audioFormatID == kAudioFormatLinearPCM {
            settings[AVLinearPCMBitDepthKey] = 16
            settings[AVLinearPCMIsBigEndianKey] = false
            settings[AVLinearPCMIsFloatKey] = false
            settings[AVLinearPCMIsNonInterleavedKey] = false
        } else {
            // 压缩格式：智能设置比特率
            let targetBitrate: Int
            
            if let sourceBitrate = sourceBitrate, sourceBitrate > 0 {
                // 有源比特率：根据质量调整
                switch config.videoQuality {
                case .low:
                    targetBitrate = max(64000, Int(Double(sourceBitrate) * 0.5))  // 降低50%
                case .medium:
                    targetBitrate = max(96000, Int(Double(sourceBitrate) * 0.75)) // 降低25%
                case .high, .custom:
                    targetBitrate = sourceBitrate  // 保持源比特率
                }
            } else {
                // 没有源比特率：根据声道数和采样率计算
                let baseBitrate: Int
                if targetChannels == 1 {
                    baseBitrate = 64000  // 单声道：64 kbps
                } else if targetChannels == 2 {
                    baseBitrate = 128000  // 立体声：128 kbps
                } else {
                    baseBitrate = 192000  // 多声道：192 kbps
                }
                
                switch config.videoQuality {
                case .low:
                    targetBitrate = Int(Double(baseBitrate) * 0.6)  // 低质量：60%
                case .medium:
                    targetBitrate = Int(Double(baseBitrate) * 0.8)  // 中等质量：80%
                case .high, .custom:
                    targetBitrate = baseBitrate  // 高质量：100%
                }
            }
            
            // 设置合理的比特率范围
            let minBitrate = targetChannels == 1 ? 32000 : 64000
            let maxBitrate = targetChannels == 1 ? 128000 : 320000
            let finalBitrate = max(minBitrate, min(maxBitrate, targetBitrate))
            
            settings[AVEncoderBitRateKey] = finalBitrate
            
            // AAC编码：设置编码质量（如果支持）
            if audioFormatID == kAudioFormatMPEG4AAC {
                // 使用比特率策略而不是质量策略，以获得更可预测的文件大小
            }
        }
        
        return settings
    }
    
    /// 获取视频读取设置（优化读取性能，减少不必要的格式转换）
    private func getVideoReadSettings(sourceTrack: AVAssetTrack) -> [String: Any]? {
        // 分析源视频的像素格式
        // 对于AVAssetReaderVideoCompositionOutput，通常使用420YpCbCr8BiPlanarVideoRange格式
        // 这是最常用的格式，系统会自动处理转换
        
        // 设置像素格式，使用标准格式以优化性能
        return [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
    }
    
    /// 辅助函数：将字符串转换为FourCharCode
    private func FourCharCodeFromString(_ string: String) -> FourCharCode {
        var result: FourCharCode = 0
        if let data = string.data(using: .macOSRoman), data.count >= 4 {
            data.withUnsafeBytes { bytes in
                result = (FourCharCode(bytes[0]) << 24) |
                         (FourCharCode(bytes[1]) << 16) |
                         (FourCharCode(bytes[2]) << 8) |
                         FourCharCode(bytes[3])
            }
        }
        return result
    }
    
    /// 获取音频读取设置（优化读取性能，减少不必要的格式转换）
    private func getAudioReadSettings(sourceTrack: AVAssetTrack) -> [String: Any]? {
        // 分析源音频格式
        var sourceFormatID: AudioFormatID?
        var sourceSampleRate: Double?
        var sourceChannels: Int?
        
        if let formatDescriptions = sourceTrack.formatDescriptions as? [CMFormatDescription],
           let formatDescription = formatDescriptions.first {
            
            if let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                let asbd = audioStreamBasicDescription.pointee
                sourceFormatID = asbd.mFormatID
                sourceSampleRate = asbd.mSampleRate
                sourceChannels = Int(asbd.mChannelsPerFrame)
            }
        }
        
        // 如果源格式是线性PCM，可以直接读取，减少转换
        // 否则让系统自动处理格式转换
        if sourceFormatID == kAudioFormatLinearPCM {
            return [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: sourceSampleRate ?? 44100.0,
                AVNumberOfChannelsKey: sourceChannels ?? 2,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsNonInterleavedKey: false
            ]
        }
        
        // 对于压缩格式，返回nil让系统自动处理
        return nil
    }
}


