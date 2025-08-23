//
//  MNSplitCell.swift
//  anhe
//
//  Created by 冯盼 on 2022/5/29.
//  顶部导航项表格

import UIKit

@objc public protocol MNSplitCellConvertible where Self: UICollectionViewCell {
    
    /// 更新分离器
    /// - Parameters:
    ///   - spliter: 模型
    ///   - index: 当前索引
    ///   - axis: 约束方向
    @objc optional func update(spliter: MNSpliter, at index: Int, axis: NSLayoutConstraint.Axis)
    
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
    @objc optional func updateItemState(_ selected: Bool, at index: Int)
}

public class MNSplitCell: UICollectionViewCell, MNSplitCellConvertible {
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
    
    public func update(spliter: MNSpliter, at index: Int, axis: NSLayoutConstraint.Axis) {
        
        switch axis {
        case .horizontal:
            divider.frame = CGRect(x: contentView.frame.width - 0.7, y: spliter.dividerInset.top, width: 0.7, height: contentView.frame.height - spliter.dividerInset.top - spliter.dividerInset.bottom)
        default:
            divider.frame = CGRect(x: spliter.dividerInset.left, y: contentView.frame.height - 0.7, width: contentView.frame.width - spliter.dividerInset.left - spliter.dividerInset.right, height: 0.7)
        }
        divider.backgroundColor = spliter.dividerColor
        
        var text: String?
        if let badge = spliter.badge {
            if let string = badge as? String {
                if string != "0" {
                    text = string
                }
            } else if let number = badge as? Int {
                if number > 0 {
                    text = "\(number)"
                }
            } else if let flag = badge as? Bool {
                if flag {
                    text = ""
                }
            }
        }
        if let text = text, text != "0" {
            var textSize: CGSize = .zero
            if text.isEmpty == false {
                textSize = (text as NSString).size(withAttributes: [.font:spliter.badgeFont])
                textSize.width = ceil(textSize.width)
                textSize.height = ceil(textSize.height)
            }
            textSize.width += (spliter.badgeInset.left + spliter.badgeInset.right)
            textSize.height += (spliter.badgeInset.top + spliter.badgeInset.bottom)
            textSize.width = max(textSize.width, textSize.height)
            badgeLabel.text = text
            badgeLabel.font = spliter.badgeFont
            badgeLabel.textColor = spliter.badgeTextColor
            badgeView.image = spliter.badgeImage
            badgeView.backgroundColor = spliter.badgeColor
            badgeView.frame = .init(origin: .zero, size: textSize)
            badgeView.layer.cornerRadius = textSize.height/2.0
            badgeView.center = CGPoint(x: contentView.frame.width + spliter.badgeOffset.horizontal, y: spliter.badgeOffset.vertical)
            badgeView.isHidden = false
        } else {
            badgeView.isHidden = true
        }
        
        titleLabel.transform = .identity
        titleLabel.text = spliter.title
        titleLabel.font = spliter.titleFont
        titleLabel.textColor = spliter.titleColor
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY)
        titleLabel.transform = CGAffineTransform(scaleX: spliter.transformScale, y: spliter.transformScale)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderView.layer.borderWidth = spliter.borderWidth
        borderView.layer.cornerRadius = spliter.borderRadius
        borderView.layer.borderColor = spliter.borderColor?.cgColor
        CATransaction.commit()
        borderView.image = spliter.backgroundImage
        
        borderView.backgroundColor = spliter.backgroundColor
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
