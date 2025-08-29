//
//  MNEmojiHelper.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/29.
//  辅助文件

import UIKit
import Foundation

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

extension MNEmoticonKeyboardOptions {
    
    /// 推荐尺寸
    public var preferredRect: CGRect {
        var rect: CGRect = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 0.0)
        let itemSize = prefersItemSize(rect: rect, style: .emoji)
        let lineSpacing = prefersLineSpacing(rect: rect, style: .emoji)
        switch axis {
        case .horizontal:
            let numberOfRows: Int = 4
            rect.size.height = itemSize.height*CGFloat(numberOfRows) + lineSpacing*CGFloat(numberOfRows + 1) + floor(itemSize.height/2.0) + pageControlHeight + packetViewHeight + MN_BOTTOM_SAFE_HEIGHT
        default:
            let numberOfRows: Int = 6
            rect.size.height = itemSize.height*CGFloat(numberOfRows) + lineSpacing*CGFloat(numberOfRows) + max(lineSpacing, MN_BOTTOM_SAFE_HEIGHT)
            if packets.count > 1 || hidesForSinglePacket == false {
                rect.size.height += packetViewHeight
            }
        }
        return rect
    }
    
    /// 最小尺寸
    var leastNormalRect: CGRect {
        var rect: CGRect = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 0.0)
        let itemSize = prefersItemSize(rect: rect, style: .image)
        let lineSpacing = prefersLineSpacing(rect: rect, style: .image)
        let numberOfRows: Int = 1
        switch axis {
        case .horizontal:
            rect.size.height = itemSize.height*CGFloat(numberOfRows) + lineSpacing*CGFloat(numberOfRows + 1) + floor(itemSize.height/5.0) + pageControlHeight + packetViewHeight + MN_BOTTOM_SAFE_HEIGHT
        default:
            rect.size.height = itemSize.height*CGFloat(numberOfRows) + lineSpacing + max(lineSpacing, MN_BOTTOM_SAFE_HEIGHT)
            if packets.count > 1 || hidesForSinglePacket == false {
                rect.size.height += packetViewHeight
            }
        }
        return rect
    }
    
    func prefersItemSize(rect: CGRect, style: MNEmoticonPacket.Style) -> CGSize {
        switch style {
        case .emoji:
            return rect.width >= 390.0 ? CGSize(width: 32.0, height: 32.0) : CGSize(width: 30.0, height: 30.0)
        default:
            return rect.width >= 390.0 ? CGSize(width: 68.0, height: 68.0) : CGSize(width: 63.0, height: 63.0)
        }
    }
    
    func prefersNumberOfColumns(rect: CGRect, style: MNEmoticonPacket.Style) -> Int {
        switch style {
        case .emoji:
            return rect.width >= 414.0 ? 8 : 7
        default:
            return 4
        }
    }
    
    func prefersInteritemSpacing(rect: CGRect, style: MNEmoticonPacket.Style) -> CGFloat {
        let itemSize = prefersItemSize(rect: rect, style: style)
        let numberOfColumns = prefersNumberOfColumns(rect: rect, style: style)
        switch style {
        case .emoji:
            let interitemSpacing = (rect.width - CGFloat(numberOfColumns)*itemSize.width)/(CGFloat(numberOfColumns) + 0.65)
            return floor(interitemSpacing)
        default:
            let interitemSpacing = (rect.width - CGFloat(numberOfColumns)*itemSize.width)/CGFloat(numberOfColumns)
            return floor(interitemSpacing)
        }
    }
    
    func prefersLineSpacing(rect: CGRect, style: MNEmoticonPacket.Style) -> CGFloat {
        let interitemSpacing = prefersInteritemSpacing(rect: rect, style: style)
        switch style {
        case .emoji:
            let lineSpacing = floor(interitemSpacing/6.0*5.0)
            return lineSpacing
        default:
            let itemSize = prefersItemSize(rect: rect, style: style)
            let numberOfColumns = prefersNumberOfColumns(rect: rect, style: style)
            let lineSpacing = (rect.width - CGFloat(numberOfColumns)*itemSize.width - CGFloat(numberOfColumns - 1)*interitemSpacing)/2.0
            return floor(lineSpacing)
        }
    }
    
    func prefersNumberOfRows(rect: CGRect, style: MNEmoticonPacket.Style) -> Int {
        let itemSize = prefersItemSize(rect: rect, style: style)
        let lineSpacing = prefersLineSpacing(rect: rect, style: style)
        let rows = Int(floor((rect.height - lineSpacing)/(lineSpacing + itemSize.height)))
        return rows
    }
}
