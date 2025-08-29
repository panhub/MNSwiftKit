//
//  MNEmoticonButton.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情按钮

import UIKit

class MNEmoticonButton: UIControl {
    /// 响应约束
    var boundInset: UIEdgeInsets = .zero
    /// 标题约束
    var textInset: UIEdgeInsets {
        get { .zero }
        set {
            textLabel.autoresizingMask = []
            textLabel.frame = bounds.inset(by: newValue)
            textLabel.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        }
    }
    /// 图片约束
    var imageInset: UIEdgeInsets {
        get { .zero }
        set {
            imageView.autoresizingMask = []
            imageView.frame = bounds.inset(by: newValue)
            imageView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
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
    private var emojiRawValue: MNEmoticon!
    var emoji: MNEmoticon! {
        get { emojiRawValue }
        set {
            emojiRawValue = newValue
            let image = newValue.image
            if let images = image?.images, images.count > 0 {
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
    /// 图片控件
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imageView
    }()
    /// 文字控件
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: bounds)
        textLabel.numberOfLines = 1
        textLabel.textAlignment = .center
        textLabel.isUserInteractionEnabled = false
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        addSubview(imageView)
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 决定是否响应
    /// - Parameters:
    ///   - point: 发起响应的点
    ///   - event: 响应事件
    /// - Returns: 是否响应
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height).inset(by: boundInset).contains(point)
    }
}
