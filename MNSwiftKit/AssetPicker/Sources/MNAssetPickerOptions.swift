//
//  MNAssetPickerOptions.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  资源选择器配置信息 allowsMultipleSelection

import UIKit
import Foundation

/// 选择器样式
@objc public enum MNAssetPickerMode: Int {
    /// 白色
    case light = 0
    /// 暗黑
    case dark = 1
}

/// 相册资源选择条件
public class MNAssetPickerOptions: NSObject {
    /**
     最多选择数量
     */
    @objc public var maxPickingCount: Int = 1
    /**
     至少选择数量 <default 0 不限制>
     */
    @objc public var minPickingCount: Int = 0
    /**
     是否允许编辑<"maxPickingCount==1"有效>
     */
    @objc public var allowsEditing: Bool = false
    /**
     是否允许预览
     */
    @objc public var allowsPreview: Bool = false
    /**
     是否允许显示文件大小
     */
    @objc public var showFileSize: Bool = false
    /**
     是否允许挑选图片
     */
    @objc public var allowsPickingPhoto: Bool = true
    /**
     是否允许挑选多张图片
     */
    @objc public var allowsMultiplePickingPhoto: Bool = true
    /**
     是否允许挑选视频
     */
    @objc public var allowsPickingVideo: Bool = true
    /**
     是否允许挑选多个视频
     */
    @objc public var allowsMultiplePickingVideo: Bool = true
    /**
     是否允许挑选GIF
     */
    @objc public var allowsPickingGif: Bool = true
    /**
     是否允许挑选多张GIF
     */
    @objc public var allowsMultiplePickingGif: Bool = true
    /**
     是否允许挑选LivePhoto
     */
    @objc public var allowsPickingLivePhoto: Bool = true
    /**
     是否允许挑选多张LivePhoto
     */
    @objc public var allowsMultiplePickingLivePhoto: Bool = true
    /**
     是否允许混合选择<'allowsMixPicking == false'时根据首选资源类型限制>
     */
    @objc public var allowsMixPicking: Bool = true
    /**
     #available(iOS 10.0, *)
     是否允许输出heif/heic格式图片
     */
    @objc public var allowsExportHeifc: Bool = false
    /**
     是否允许`AVAssetExportSession`输出视频
     */
    @objc public var allowsExportVideo: Bool = false
    /**
     如果需要压缩 压缩系数
     */
    @objc public var compressionQuality: CGFloat = 1.0
    /**
     把GIF当做Image使用
     */
    @objc public var usingPhotoPolicyPickingGif: Bool = false
    /**
     把LivePhoto当做Image使用
     */
    @objc public var usingPhotoPolicyPickingLivePhoto: Bool = false
    /**
     当未响应退出代理方法时是否允许内部自行退出
     */
    @objc public var allowsAutoDismiss: Bool = true
    /**
     是否允许滑动选择
     */
    @objc public var allowsSlidePicking: Bool = false
    /**
     是否允许切换相册
     */
    @objc public var allowsPickingAlbum: Bool = true
    /**
     是否导出LivePhoto的资源文件
     */
    @objc public var allowsExportLiveResource: Bool = false
    /**
     显示的列数
     */
    @objc public var numberOfColumns: Int = 4
    /**
     分页数量 (循环查询至满足分页数量, 只多不少)
     */
    @objc public var pageCount: Int = 300
    /**
     资源项行间隔
     */
    @objc public var minimumLineSpacing: CGFloat = 4.0
    /**
     资源项列间隔
     */
    @objc public var minimumInteritemSpacing: CGFloat = 4.0
    /**
     是否升序排列
     */
    @objc public var sortAscending: Bool = false
    /**
     图片调整比例
     */
    @objc public var cropScale: CGFloat = 1.0
    /**
     导出视频的最小时长<仅视频有效 不符合时长要求的视频裁剪或隐藏处理>
     */
    @objc public var minExportDuration: TimeInterval = 0.0
    /**
     导出视频的最大时长<仅视频有效 不符合时长要求的视频裁剪或隐藏处理>
     */
    @objc public var maxExportDuration: TimeInterval = 0.0
    /**
     视频导出路径
     */
    @objc public var outputURL: URL?
    /**
     视频导出质量<default 'AVAssetExportPresetMediumQuality'>
     */
    @objc public var exportPreset: String?
    /**
     预览图大小<太大会影响性能>
     */
    @objc public var renderSize: CGSize = CGSize(width: 250.0, height: 250.0)
    /**
     主题颜色 UIColor(red: 23.0/255.0, green: 79.0/255.0, blue: 218.0/255.0, alpha: 1.0)
     */
    @objc public var themeColor: UIColor = UIColor(red: 72.0/255.0, green: 122.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    /**
     辅助颜色
     */
    @objc public var tintColor: UIColor = .black
    /**
     背景样式
     */
    @objc public var mode: MNAssetPickerMode = .dark
    /**
     弹出类型
     */
    @objc public var presentationStyle: UIModalPresentationStyle = .fullScreen
    /**
     交互事件代理
     */
    @objc public weak var delegate: MNAssetPickerDelegate?
    /**
     分析文件位置及大小的队列
     */
    @objc public let queue: DispatchQueue = DispatchQueue(label: "com.mn.asset.picker.queue", attributes: .concurrent)
}

// MARK: - 辅助
extension MNAssetPickerOptions {
    /// 状态栏栏高度
    internal var statusBarHeight: CGFloat { presentationStyle == .fullScreen ? MN_STATUS_BAR_HEIGHT : 0.0 }
    /// 导航栏高度
    internal var navBarHeight: CGFloat { MN_NAV_BAR_HEIGHT }
    /// 顶部栏总高度
    internal var topBarHeight: CGFloat { statusBarHeight +  navBarHeight}
    /// 底部栏高度
    internal var bottomBarHeight: CGFloat { max(MN_BOTTOM_BAR_HEIGHT, 55.0) }
    /// 内容布局
    internal var contentInset: UIEdgeInsets {
        UIEdgeInsets(top: topBarHeight, left: 0.0, bottom: maxPickingCount > 1 ? bottomBarHeight : 0.0, right: 0.0)
    }
    /// 背景颜色
    internal var backgroundColor: UIColor { mode == .light ? .white : UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0) }
}
