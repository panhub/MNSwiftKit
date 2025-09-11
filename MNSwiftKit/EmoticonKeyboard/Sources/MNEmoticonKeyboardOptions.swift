//
//  MNEmoticonKeyboardOptions.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情键盘配置选项

import UIKit
import Foundation

extension MNEmoticonKeyboard {
    
    @objc(MNEmoticonKeyboardStyle)
    public enum Style: Int {
        /// 纵向滑动表情
        case compact = 0
        /// 分页滑动
        case paging
    }
    
    @objc(MNEmoticonKeyboardOptions)
    public class Options: NSObject {
        /// 表情包
        @objc public var packets: [String] = [MNEmoticon.Packet.Name.default.rawValue, MNEmoticon.Packet.Name.favorites.rawValue]
        /// returnKey类型
        @objc public var returnKeyType: UIReturnKeyType = .default
        /// compact: 只有一个表情包时 是否隐藏表情包栏
        /// paging: 只有一页表情时是否隐藏页码指示图
        @objc public var hidesForSingle: Bool = false
        /// 表情包栏高度, 内部会自行根据需要加上底部安全区域高度
        @objc public var packetBarHeight: CGFloat = 50.0
        /// 表情包相邻间隔
        @objc public var packetInteritemSpacing: CGFloat = 12.0
        /// 表情包视图四周约束
        @objc public var packetSectionInset: UIEdgeInsets = UIEdgeInsets(top: 6.0, left: 15.0, bottom: 6.0, right: 15.0)
        /// 表情包图片四周约束
        @objc public var packetItemInset: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        /// 表情包选择背景颜色
        @objc public var packetHighlightedColor: UIColor! = .white
        /// 表情包栏背景颜色
        @objc public var packetBarColor: UIColor! = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        /// returnKey颜色
        @objc public var returnKeyColor: UIColor! = .white
        /// returnKey标题颜色
        @objc public var returnKeyTitleColor: UIColor! = .black
        /// returnKey标题字体
        @objc public var returnKeyTitleFont: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
        /// 分割线颜色
        @objc public var separatorColor: UIColor! = .darkGray.withAlphaComponent(0.15)
        /// 背景颜色
        @objc public var backgroundColor: UIColor! = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        /// 页码指示器高度
        @objc public var pageControlHeight: CGFloat = 20.0
        /// 表情包栏高度, 内部会自行根据需要加上底部安全区域高度
        @objc public var pageIndicatorSize: CGSize = .init(width: 7.0, height: 7.0)
        /// 页码指示器颜色
        @objc public var pageIndicatorColor: UIColor! = .gray.withAlphaComponent(0.37)
        /// 页码指示器间隔
        @objc public var pageIndicatorSpacing: CGFloat = 11.0
        /// 页码指示器选中颜色
        @objc public var currentPageIndicatorColor: UIColor! = .gray.withAlphaComponent(0.88)
        /// 页码指示器纵向对齐方式
        @objc public var pageIndicatorVerticalAlignment: UIControl.ContentVerticalAlignment = .top
        /// 页码指示器横向对齐方式
        @objc public var pageIndicatorHorizontalAlignment: UIControl.ContentHorizontalAlignment = .center
        /// 是否允许播放音效
        @objc public var enableFeedbackWhenInputClicks: Bool = false
    }
}

/// 表情键盘Return键标题
extension UIReturnKeyType {
    
    /// 首选标题
    public var preferredTitle: String {
        switch self {
        case .default: return "确定"
        case .go: return "前进"
        case .google: return "Google"
        case .join: return "加入"
        case .next: return "下一步"
        case .route: return "路线"
        case .search: return "搜索"
        case .send: return "发送"
        case .yahoo: return "Yahoo"
        case .done: return "确定"
        case .emergencyCall: return "呼叫"
        case .continue: return "继续"
        @unknown default: return "确定"
        }
    }
}
