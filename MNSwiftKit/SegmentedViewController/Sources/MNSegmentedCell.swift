//
//  MNSegmentedCell.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit
import Foundation
import CoreFoundation

@objc public protocol MNSegmentedCellConvertible where Self: UICollectionViewCell {
    
    /// 更新标题缩放
    /// - Parameter scale: 缩放因数
    @objc optional func updateTitleScale(_ scale: CGFloat)
    
    /// 更新标题颜色
    /// - Parameter color: 标题颜色
    @objc optional func updateTitleColor(_ color: UIColor?)
    
    /// 更新边框颜色
    /// - Parameter color: 边框颜色
    @objc optional func updateBorderColor(_ color: UIColor?)
    
    /// 更新背景颜色
    /// - Parameter color: 背景颜色
    @objc optional func updateBackgroundColor(_ color: UIColor?)
    
    /// 更新背景图片
    /// - Parameter image: 背景图片
    @objc optional func updateBackgroundImage(_ image: UIImage?)
    
    /// 更新选中状态
    /// - Parameter selected: 是否选中
    /// - Parameter index: 索引
    @objc optional func updateCell(selected: Bool, at index: Int)
    
    /// 更新分离器
    /// - Parameters:
    ///   - item: 模型
    ///   - index: 当前索引
    ///   - orientation: 滑动方向
    @objc optional func update(item: MNSegmentedItem, at index: Int, orientation: UIPageViewController.NavigationOrientation)
}

public class MNSegmentedCell: UICollectionViewCell, MNSplitCellConvertible {
    /// 分割线
    public var divider = UIView()
    /// 标题
    public var titleLabel = UILabel()
    /// 边框/背景颜色/背景图片
    public var borderView = UIImageView()
    /// 角标背景图片
    public var badgeView = UIImageView()
    /// 角标
    public lazy var badgeLabel = UILabel(frame: badgeView.bounds)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        contentView.frame = bounds
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        borderView.clipsToBounds = true
        borderView.frame = contentView.bounds
        borderView.contentMode = .scaleAspectFit
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(borderView)
        
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        titleLabel.isUserInteractionEnabled = false
        contentView.addSubview(titleLabel)
        
        divider.frame = CGRect(x: 0.0, y: contentView.frame.height - 0.7, width: contentView.frame.width, height: 0.7)
        contentView.addSubview(divider)
        
        badgeView.clipsToBounds = true
        badgeView.contentMode = .scaleToFill
        contentView.addSubview(badgeView)
        
        badgeLabel.numberOfLines = 1
        badgeLabel.textAlignment = .center
        badgeLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        badgeView.addSubview(badgeLabel)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(item: MNSegmentedItem, at index: Int, orientation: UIPageViewController.NavigationOrientation) {
        
        switch orientation {
        case .horizontal:
            divider.frame = .init(origin: .init(x: (contentView.frame.width - item.dividerSize.width)/2.0, y: contentView.frame.height - item.dividerSize.height), size: item.dividerSize)
        default:
            divider.frame = .init(origin: .init(x: contentView.frame.width - item.dividerSize.width, y: (contentView.frame.height - item.dividerSize.height)/2.0), size: item.dividerSize)
        }
        divider.backgroundColor = item.dividerColor
        
        var text: String?
        if let badge = item.badge {
            if let string = badge as? String {
                if string != "0" {
                    text = string
                }
            } else if let number = badge as? Int {
                if number > 0 {
                    text = NSNumber(value: number).stringValue
                }
            } else if let flag = badge as? Bool {
                if flag {
                    text = ""
                }
            }
        }
        if let text = text, text != "0" {
            var size: CGSize = .zero
            if text.isEmpty == false {
                size = (text as NSString).size(withAttributes: [.font:item.badgeFont])
                size.width = ceil(size.width)
                size.height = ceil(size.height)
            }
            size.width += (item.badgeInset.left + item.badgeInset.right)
            size.height += (item.badgeInset.top + item.badgeInset.bottom)
            size.width = max(size.width, size.height)
            badgeLabel.text = text
            badgeLabel.font = item.badgeFont
            badgeLabel.textColor = item.badgeTextColor
            badgeView.image = item.badgeImage
            badgeView.backgroundColor = item.badgeColor
            badgeView.frame = .init(origin: .zero, size: size)
            badgeView.layer.cornerRadius = size.height/2.0
            badgeView.center = CGPoint(x: contentView.frame.width + item.badgeOffset.horizontal, y: item.badgeOffset.vertical)
            badgeView.isHidden = false
        } else {
            badgeView.isHidden = true
        }
        
        titleLabel.transform = .identity
        titleLabel.text = item.title
        titleLabel.font = item.titleFont
        titleLabel.textColor = item.titleColor
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY)
        titleLabel.transform = CGAffineTransform(scaleX: item.transformScale, y: item.transformScale)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderView.layer.borderWidth = item.borderWidth
        borderView.layer.cornerRadius = item.borderRadius
        borderView.layer.borderColor = item.borderColor?.cgColor
        CATransaction.commit()
        borderView.image = item.backgroundImage
        
        borderView.backgroundColor = item.backgroundColor
    }
    
    public func updateTitleColor(_ color: UIColor?) {
        titleLabel.textColor = color
    }
    
    public func updateTitleScale(_ scale: CGFloat) {
        titleLabel.transform = .identity
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    public func updateBorderColor(_ color: UIColor?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderView.layer.borderColor = color?.cgColor
        CATransaction.commit()
    }
    
    public func updateBackgroundColor(_ color: UIColor?) {
        borderView.backgroundColor = color
    }
    
    public func updateBackgroundImage(_ image: UIImage?) {
        borderView.image = image
    }
}
