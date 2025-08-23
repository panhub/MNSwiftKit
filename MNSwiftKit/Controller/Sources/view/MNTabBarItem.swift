//
//  MNTabBarItem.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/11.
//  标签控制器按钮

import UIKit
#if canImport(MNSwiftKit_Layout)
import MNSwiftKit_Layout
#endif

/// 标签栏按钮
public class MNTabBarItem: UIControl {
    
    /// 图片
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 12.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    /// 布局视图
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// 角标
    private lazy var badgeLabel: UILabel = {
        let badgeLabel = UILabel()
        badgeLabel.isHidden = true
        badgeLabel.clipsToBounds = true
        badgeLabel.numberOfLines = 1
        badgeLabel.textAlignment = .center
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.font = .systemFont(ofSize: 10.0, weight: .medium)
        return badgeLabel
    }()
    
    /// 标题与图片间隔
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    /// 标题字体
    public var titleFont: UIFont {
        get { titleLabel.font! }
        set { titleLabel.font = newValue }
    }
    
    /// 正常状态下标题
    public var title: String = "" {
        didSet {
            if isSelected == false {
                titleLabel.text = title
            }
        }
    }
    
    /// 选择状态标题
    public var selectedTitle: String = "" {
        didSet {
            if isSelected {
                titleLabel.text = selectedTitle
            }
        }
    }
    
    /// 正常状态下标题颜色
    public var titleColor: UIColor = .gray {
        didSet {
            if isSelected == false {
                titleLabel.textColor = titleColor
            }
        }
    }
    
    /// 选择状态下标题颜色
    public var selectedTitleColor: UIColor = .black {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedTitleColor
            }
        }
    }
    
    /// 正常状态下图片
    public var image: UIImage? {
        didSet {
            if isSelected == false {
                imageView.image = image
            }
        }
    }
    
    /// 选择状态下图片
    public var selectedImage: UIImage? {
        didSet {
            if isSelected {
                imageView.image = selectedImage
            }
        }
    }
    
    /// 角标背景色
    public var badgeColor: UIColor {
        get { badgeLabel.backgroundColor! }
        set { badgeLabel.backgroundColor = newValue }
    }
    
    /// 角标字体
    public var badgeTextFont: UIFont {
        get { badgeLabel.font! }
        set {
            badgeLabel.font = newValue
            setNeedsLayout()
        }
    }
    
    /// 角标文字颜色
    public var badgeTextColor: UIColor {
        get { badgeLabel.textColor! }
        set { badgeLabel.textColor = newValue }
    }
    
    /// 角标偏移 (默认以图片右上角为中心点)
    public var badgeOffset: UIOffset = .zero {
        didSet {
            layoutBadge()
        }
    }
    
    /// 角标内容左右增加尺寸
    public var badgeContentPadding: CGSize = .init(width: 8.0, height: 8.0) {
        didSet {
            layoutBadge()
        }
    }
    
    /// 角标内容
    public var badge: Any? {
        didSet {
            updateBadge()
        }
    }
    
    /// 选中状态
    public override var isSelected: Bool {
        get { super.isSelected }
        set {
            guard super.isSelected != newValue else { return }
            super.isSelected = newValue
            if newValue {
                titleLabel.text = selectedTitle
                titleLabel.textColor = selectedTitleColor
                imageView.image = selectedImage
            } else {
                titleLabel.text = title
                titleLabel.textColor = titleColor
                imageView.image = image
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 添加布局视图
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        addSubview(badgeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新角标
    public func updateBadge() {
        var text: String?
        if let badge = badge {
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
        guard let text = text else {
            badgeLabel.isHidden = true
            return
        }
        badgeLabel.text = text
        if text.isEmpty {
            // 圆点
            badgeLabel.mn_layout.size = badgeContentPadding
            badgeLabel.layer.cornerRadius = badgeContentPadding.height/2.0
        } else {
            // 文字
            badgeLabel.sizeToFit()
            var badgeSize: CGSize = .zero
            badgeSize.height = ceil(badgeLabel.mn_layout.size.height) + badgeContentPadding.height
            if text.count > 1 {
                //
                badgeSize.width = ceil(badgeLabel.mn_layout.size.width) + badgeContentPadding.width
            } else {
                let width = ceil(badgeLabel.mn_layout.width)
                if width > badgeSize.height {
                    badgeSize.height = width + 3.0
                }
                badgeSize.width = badgeSize.height
            }
            badgeLabel.mn_layout.size = badgeSize
            badgeLabel.layer.cornerRadius = badgeSize.height/2.0
        }
        layoutBadge()
    }
    
    /// 约束角标位置
    public func layoutBadge() {
        var center = CGPoint(x: bounds.midX, y: bounds.midY)
        center.x += badgeOffset.horizontal
        center.y += badgeOffset.vertical
        badgeLabel.center = center
    }
}
