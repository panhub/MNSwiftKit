//
//  MNButton.swift
//  MNTest
//
//  Created by panhub on 2022/9/13.
//  自定义按钮

import UIKit

/// 定制按钮
public class MNButton: UIControl {
    
    /// 分布状态
    public enum Distribution: Int {
        /// 没有
        case none
        /// 仅有
        case only
        /// 左侧
        case left
        /// 右侧
        case right
        /// 上方
        case top
        /// 下方
        case bottom
    }
    
    /// 按钮状态
    public enum State: Int {
        /// 正常
        case normal
        /// 高亮
        case highlighted
        /// 选中
        case selected
        /// 不可用
        case disabled
    }
    
    /// 外观描述
    fileprivate enum Attribute: String {
        case title, titleColor, titleFont, attributedTitle, image, backgroundImage
    }
    
    /// 标题
    private let titleLabel: UILabel = UILabel()
    /// 图片
    private let imageView: UIImageView = UIImageView()
    /// 图片
    private let backgroundView: UIImageView = UIImageView()
    /// 内部约束视图
    private let stackView: UIStackView = UIStackView()
    /// 描述
    fileprivate var attributes: [MNButton.State:[MNButton.Attribute:Any]] = [.normal:[.titleColor:UIColor.black, .titleFont:UIFont.systemFont(ofSize: 16.0, weight: .regular)]]
    /// 是否选中
    public override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    /// 是否响应事件
    public override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    /// 是否高亮状态
    public override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }
    /// 图片位置描述
    public var imageDistribution: Distribution = .left {
        didSet {
            if imageDistribution == oldValue { return }
            updateStackView()
        }
    }
    /// 内容边距约束
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            let inset = contentInset
            let constraints = constraints.filter {
                guard let firstItem = $0.firstItem else { return false }
                return firstItem is UIStackView
            }
            for constraint in constraints {
                switch constraint.firstAttribute {
                case .top:
                    constraint.constant = inset.top
                case .left, .leading:
                    constraint.constant = inset.left
                case .bottom:
                    constraint.constant = -inset.bottom
                case .right, .trailing:
                    constraint.constant = -inset.right
                default: break
                }
            }
            setNeedsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView.frame = bounds
        backgroundView.clipsToBounds = true
        backgroundView.contentMode = .scaleToFill
        backgroundView.isUserInteractionEnabled = false
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundView)
        
        stackView.spacing = 3.0
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addConstraints([NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: contentInset.top), NSLayoutConstraint(item: stackView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: contentInset.left), NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: contentInset.bottom), NSLayoutConstraint(item: stackView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: contentInset.right)])
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(imageView)
        stackView.addConstraints([NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: stackView, attribute: .width, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 1.0, constant: 0.0)])
        
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新内部控件
    private func updateStackView() {
        switch imageDistribution {
        case .none:
            // 只有标题
            titleLabel.isHidden = false
            imageView.isHidden = true
        case .only:
            // 只有图片
            titleLabel.isHidden = true
            imageView.isHidden = false
        case .top, .left, .bottom, .right:
            // 图片 标题
            titleLabel.isHidden = false
            imageView.isHidden = false
            switch imageDistribution {
            case .left, .right:
                stackView.axis = .horizontal
            default:
                stackView.axis = .vertical
            }
            switch imageDistribution {
            case .left, .top:
                stackView.insertArrangedSubview(imageView, at: 0)
            default:
                stackView.insertArrangedSubview(titleLabel, at: 0)
            }
        }
        setNeedsUpdateConstraints()
    }
    
    public override func updateConstraints() {
        NSLayoutConstraint.activate(stackView.constraints)
        switch imageDistribution {
        case .left, .right:
            NSLayoutConstraint.deactivate(stackView.constraints.filter { $0.firstAttribute == .width })
        case .top, .bottom:
            NSLayoutConstraint.deactivate(stackView.constraints.filter { $0.firstAttribute == .height })
        default: break
        }
        super.updateConstraints()
    }
    
    /// 更新外观
    private func updateAppearance() {
        let state = currentState
        let attributes: [MNButton.Attribute:Any]? = attributes[state] ?? attributes[.normal]
        if let attributedTitle = attributes?[.attributedTitle] as? NSAttributedString {
            titleLabel.attributedText = attributedTitle
        } else {
            if let title = attributes?[.title] as? String {
                titleLabel.text = title
            }
            if let titleFont = attributes?[.titleFont] as? UIFont {
                titleLabel.font = titleFont
            }
            if let titleColor = attributes?[.titleColor] as? UIColor {
                titleLabel.textColor = titleColor
            }
        }
        imageView.image = attributes?[.image] as? UIImage
        backgroundView.image = attributes?[.backgroundImage] as? UIImage
    }
}


extension MNButton {
    
    /// 图片与标题间隔
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    /// 标题背景颜色
    public var titleBackgroundColor: UIColor? {
        get { titleLabel.backgroundColor }
        set { titleLabel.backgroundColor = newValue }
    }
    
    /// 图片背景颜色
    public var imageBackgroundColor: UIColor? {
        get { imageView.backgroundColor }
        set { imageView.backgroundColor = newValue }
    }
    
    /// 图片拉伸方式
    public var imageContentMode: UIView.ContentMode {
        get { imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    /// 背景图片拉伸方式
    public var backgroundContentMode: UIView.ContentMode {
        get { backgroundView.contentMode }
        set { backgroundView.contentMode = newValue }
    }
}

extension MNButton {
    
    /// 设置标题
    /// - Parameters:
    ///   - title: 标题
    ///   - state: 状态
    public func setTitle(_ title: String?, for state: MNButton.State) {
        setAttribute(.title, value: title, for: state)
    }
    
    /// 设置标题颜色
    /// - Parameters:
    ///   - color: 文字颜色
    ///   - state: 状态
    public func setTitleColor(_ color: UIColor?, for state: MNButton.State) {
        setAttribute(.titleColor, value: color, for: state)
    }
    
    /// 设置标题字体
    /// - Parameters:
    ///   - font: 字体
    ///   - state: 状态
    public func setTitleFont(_ font: UIFont?, for state: MNButton.State) {
        setAttribute(.titleFont, value: font, for: state)
    }
    
    /// 设置富文本标题
    /// - Parameters:
    ///   - title: 富文本
    ///   - state: 状态
    public func setAttributedTitle(_ title: NSAttributedString?, for state: MNButton.State) {
        setAttribute(.attributedTitle, value: title, for: state)
    }
    
    /// 设置图片
    /// - Parameters:
    ///   - image: 图片
    ///   - state: 状态
    public func setImage(_ image: UIImage?, for state: MNButton.State) {
        setAttribute(.image, value: image, for: state)
    }
    
    /// 设置背景图片
    /// - Parameters:
    ///   - image: 背景图片
    ///   - state: 状态
    public func setBackgroundImage(_ image: UIImage?, for state: MNButton.State) {
        setAttribute(.backgroundImage, value: image, for: state)
    }
    
    private func setAttribute(_ attribute: MNButton.Attribute, value: Any?, for state: MNButton.State) {
        var dic = attributes[state] ?? [MNButton.Attribute:Any]()
        if let value = value {
            dic[attribute] = value
        } else {
            dic.removeValue(forKey: attribute)
        }
        if dic.count > 0 {
            attributes[state] = dic
        } else{
            attributes.removeValue(forKey: state)
        }
        updateAppearance()
    }
}


extension MNButton {
    
    /// 获取标题
    /// - Parameter state: 状态
    /// - Returns: 按钮标题
    public func title(for state: MNButton.State) -> String? {
        if let attributedTitle = value(with: .attributedTitle, for: state) as? NSAttributedString { return attributedTitle.string }
        if let title = value(with: .title, for: state) as? String { return title }
        return nil
    }
    
    /// 获取标题颜色
    /// - Parameter state: 状态
    /// - Returns: 标题颜色
    public func titleColor(for state: MNButton.State) -> UIColor? {
        value(with: .titleColor, for: state) as? UIColor
    }
    
    /// 获取标题字体
    /// - Parameter state: 状态
    /// - Returns: 标题字体
    public func titleFont(for state: MNButton.State) -> UIFont? {
        value(with: .titleFont, for: state) as? UIFont
    }
    
    /// 获取富文本标题
    /// - Parameter state: 状态
    /// - Returns: 富文本
    public func attributedTitle(for state: MNButton.State) -> NSAttributedString? {
        value(with: .attributedTitle, for: state) as? NSAttributedString
    }
    
    /// 获取图片
    /// - Parameter state: 状态
    /// - Returns: 图片
    public func image(for state: MNButton.State) -> UIImage? {
        value(with: .image, for: state) as? UIImage
    }
    
    /// 获取背景图片
    /// - Parameter state: 状态
    /// - Returns: 背景图片
    public func backgroundImage(for state: MNButton.State) -> UIImage? {
        value(with: .backgroundImage, for: state) as? UIImage
    }
    
    private func value(with attribute: MNButton.Attribute, for state: MNButton.State) -> Any? {
        guard let dic = attributes[state] else { return nil }
        return dic[attribute]
    }
}


extension MNButton {
    
    /// 当前状态
    public var currentState: MNButton.State {
        var state: MNButton.State = .normal
        if isHighlighted {
            state = .highlighted
        }
        if isEnabled == false {
            state = .disabled
        }
        if isSelected {
            state = .selected
        }
        return state
    }
    
    /// 当前标题
    public var currentTitle: String? {
        titleLabel.text
    }
    
    /// 当前标题颜色
    public var currentTitleColor: UIColor? {
        titleLabel.textColor
    }
    
    /// 当前标题字体
    public var currentTitleFont: UIFont? {
        titleLabel.font
    }
    
    /// 当前富文本标题
    public var currentAttributedTitle: NSAttributedString? {
        titleLabel.attributedText
    }
    
    /// 当前图片
    public var currentImage: UIImage? {
        imageView.image
    }
    
    /// 当前背景图片
    public var currentBackgroundImage: UIImage? {
        backgroundView.image
    }
}
