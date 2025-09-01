//
//  MNEmoticonButton.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情按钮

import UIKit

class MNEmoticonButton: UIControl {
    /// 文字控件
    private let textLabel = UILabel()
    /// 图片控件
    private let imageView = UIImageView()
    /// 标题约束
    var textInset: UIEdgeInsets {
        get {
            var inset: UIEdgeInsets = .zero
            constraints.forEach { constraint in
                guard let firstItem = constraint.firstItem as? UILabel, firstItem == textLabel else { return }
                switch constraint.firstAttribute {
                case .top:
                    inset.top = constraint.constant
                case .left, .leading:
                    inset.left = constraint.constant
                case .bottom:
                    inset.bottom = -constraint.constant
                case .right, .trailing:
                    inset.right = -constraint.constant
                default: break
                }
            }
            return inset
        }
        set {
            constraints.forEach { constraint in
                guard let firstItem = constraint.firstItem as? UILabel, firstItem == textLabel else { return }
                switch constraint.firstAttribute {
                case .top:
                    constraint.constant = newValue.top
                case .left, .leading:
                    constraint.constant = newValue.left
                case .bottom:
                    constraint.constant = -newValue.bottom
                case .right, .trailing:
                    constraint.constant = -newValue.right
                default: break
                }
            }
        }
    }
    /// 图片约束
    var imageInset: UIEdgeInsets {
        get {
            var inset: UIEdgeInsets = .zero
            constraints.forEach { constraint in
                guard let firstItem = constraint.firstItem as? UIImageView, firstItem == imageView else { return }
                switch constraint.firstAttribute {
                case .top:
                    inset.top = constraint.constant
                case .left, .leading:
                    inset.left = constraint.constant
                case .bottom:
                    inset.bottom = -constraint.constant
                case .right, .trailing:
                    inset.right = -constraint.constant
                default: break
                }
            }
            return inset
        }
        set {
            constraints.forEach { constraint in
                guard let firstItem = constraint.firstItem as? UIImageView, firstItem == imageView else { return }
                switch constraint.firstAttribute {
                case .top:
                    constraint.constant = newValue.top
                case .left, .leading:
                    constraint.constant = newValue.left
                case .bottom:
                    constraint.constant = -newValue.bottom
                case .right, .trailing:
                    constraint.constant = -newValue.right
                default: break
                }
            }
        }
    }
    /// 文字
    var text: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }
    /// 文字字体
    var textFont: UIFont? {
        get { textLabel.font }
        set { textLabel.font = newValue }
    }
    /// 文字颜色
    var textColor: UIColor? {
        get { textLabel.textColor }
        set { textLabel.textColor = newValue }
    }
    /// 图片
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    /// 表情
    private var rawEmoticon: MNEmoticon!
    var emoticon: MNEmoticon! {
        get { rawEmoticon }
        set {
            rawEmoticon = newValue
            let image = newValue.image
            if let image = image, let images = image.images, images.count > 1 {
                imageView.image = images.first
            } else {
                imageView.image = image
            }
        }
    }
    /// 图片显示模式
    var imageMode: UIView.ContentMode {
        get { imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        textLabel.numberOfLines = 1
        textLabel.textAlignment = .center
        textLabel.isUserInteractionEnabled = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.leftAnchor.constraint(equalTo: leftAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            textLabel.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
