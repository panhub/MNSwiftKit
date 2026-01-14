//
//  MNDataEmptyView.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/18.
//  空数据占位图

import UIKit
import QuartzCore
import ObjectiveC.runtime
#if SWIFT_PACKAGE
import MNNameSpace
#endif

/// 空数据视图代理
@objc public protocol MNDataEmptyDelegate: NSObjectProtocol {
    
    /// 空数据视图生命周期 -已经出现
    @objc optional func dataEmptyViewDidAppear()
    
    /// 空数据视图生命周期 -已经消失
    @objc optional func dataEmptyViewDidDisappear()
    
    /// 是否支持展示空数据视图
    /// - Parameter superview: 父视图
    /// - Returns: 是否展示
    @objc optional func dataEmptyViewShouldDisplay(_ superview: UIView) -> Bool
    
    /// 显示时是否允许ScrollView滚动<添加到UIScrollView有效>
    /// - Parameter superview: 父视图
    /// - Returns: 是否可以滚动
    @objc optional func dataEmptyViewShouldScroll(_ superview: UIView) -> Bool
    
    /// 图片是否响应点击事件
    /// - Parameter superview: 父视图
    /// - Returns: 是否相应点击事件
    @objc optional func dataEmptyViewShouldTouchImage(_ superview: UIView) -> Bool
    
    /// 默认渐现动画时长('>0.0'则加载动画)
    /// - Parameter superview: 父视图
    /// - Returns: 动画时长
    @objc optional func fadeInDurationForDataEmptyView(_ superview: UIView) -> TimeInterval
    
    /// 文字是否响应点击事件
    /// - Parameter superview: 父视图
    /// - Returns: 是否相应点击事件
    @objc optional func dataEmptyViewShouldTouchDescription(_ superview: UIView) -> Bool
    
    /// 空数据视图图片点击事件
    /// - Parameter image: 图片
    @objc optional func dataEmptyViewImageTouchUpInside(_ image: UIImage?)
    
    /// 空数据视图文字点击事件
    /// - Parameter description: 文字
    @objc optional func dataEmptyViewDescriptionTouchUpInside(_ description: String?)
    
    /// 空数据视图按钮点击事件
    @objc optional func dataEmptyViewButtonTouchUpInside()
}

/// 空数据视图数据源代理
@objc public protocol MNDataEmptySource: NSObjectProtocol {
    
    /// 背景颜色
    /// - Parameter superview: 父视图
    /// - Returns: 背景颜色
    @objc optional func backgroundColorForDataEmptyView(_ superview: UIView) -> UIColor?
    
    /// 用户信息
    /// - Parameter superview: 父视图
    /// - Returns: 用户信息
    @objc optional func userInfoForDataEmptyView(_ superview: UIView) -> Any?
    
    /// 内容偏移
    /// - Parameter superview: 父视图
    /// - Returns: 内容偏移
    @objc optional func offsetForDataEmptyView(_ superview: UIView) -> UIOffset
    
    /// 布局方向
    /// - Parameter superview: 父视图
    /// - Returns: 布局方向
    @objc optional func axisForDataEmptyView(_ superview: UIView) -> NSLayoutConstraint.Axis
    
    /// 内容间隔
    /// - Parameter superview: 父视图
    /// - Returns: 间隔
    @objc optional func spacingForDataEmptyView(_ superview: UIView) -> CGFloat
    
    /// 内容对齐方式
    /// - Parameter superview: 父视图
    /// - Returns: 对齐方式
    @objc optional func alignmentForDataEmptyView(_ superview: UIView) -> UIStackView.Alignment
    
    /// 自定义视图
    /// - Parameter superview: 父视图
    /// - Returns: 自定义视图
    @objc optional func customViewForDataEmptyView(_ superview: UIView) -> UIView?
    
    /// 图片
    /// - Parameter superview: 父视图
    /// - Returns: 图片
    @objc optional func imageForDataEmptyView(_ superview: UIView) -> UIImage?
    
    /// 图片显示尺寸`pt`
    /// - Parameter superview: 父视图
    /// - Returns: 图片视图尺寸
    @objc optional func imageSizeForDataEmptyView(_ superview: UIView) -> CGSize
    
    /// 图片填充模式
    /// - Parameter superview: 父视图
    /// - Returns: 填充模式
    @objc optional func imageModeForDataEmptyView(_ superview: UIView) -> UIView.ContentMode
    
    /// 图片圆角大小
    /// - Parameter superview: 父视图
    /// - Returns: 圆角大小
    @objc optional func imageRadiusForDataEmptyView(_ superview: UIView) -> CGFloat
    
    /// 描述信息
    /// - Parameter superview: 父视图
    /// - Returns: 描述信息富文本
    @objc optional func descriptionForDataEmptyView(_ superview: UIView) -> NSAttributedString?
    
    /// 描述信息最大宽度`pt`
    /// - Parameter superview: 父视图
    /// - Returns: 最大宽度
    @objc optional func descriptionFiniteMagnitudeForDataEmptyView(_ superview: UIView) -> CGFloat
    
    /// 按钮大小
    /// - Parameter superview: 父视图
    /// - Returns: 按钮大小
    @objc optional func buttonSizeForDataEmptyView(_ superview: UIView) -> CGSize
    
    /// 按钮圆角大小
    /// - Parameter superview: 父视图
    /// - Returns: 圆角大小
    @objc optional func buttonRadiusForDataEmptyView(_ superview: UIView) -> CGFloat
    
    /// 按钮边框宽度
    /// - Parameter superview: 父视图
    /// - Returns: 按钮边框宽度
    @objc optional func buttonBorderWidthForDataEmptyView(_ superview: UIView) -> CGFloat
    
    /// 按钮边框颜色
    /// - Parameter superview: 父视图
    /// - Returns: 边框颜色
    @objc optional func buttonBorderColorForDataEmptyView(_ superview: UIView) -> UIColor?
    
    /// 按钮背景颜色
    /// - Parameter superview: 父视图
    /// - Returns: 背景颜色
    @objc optional func buttonBackgroundColorForDataEmptyView(_ superview: UIView) -> UIColor?
    
    /// 按钮背景图片
    /// - Parameters:
    ///   - superview: 父视图
    ///   - state: 按钮状态
    /// - Returns: 背景图
    @objc optional func buttonBackgroundImageForDataEmptyView(_ superview: UIView, with state: UIControl.State) -> UIImage?
    
    /// 按钮标题
    /// - Parameters:
    ///   - superview: 父视图
    ///   - state: 按钮状态
    /// - Returns: 按钮标题富文本
    @objc optional func buttonAttributedTitleForDataEmptyView(_ superview: UIView, with state: UIControl.State) -> NSAttributedString?
}

/// 空数据视图
public class MNDataEmptyView: UIView {
    
    /// 空数据视图构成元素 component
    @objc(MNDataEmptyComponent)
    public enum Component: Int {
        case image, text, button, custom
    }
    
    /// 记录父视图是否可滑动
    fileprivate var isScrollEnabled: Bool?
    /// 记录上一次的父视图
    private weak var parentView: UIView?
    /// 文字显示
    private let textLabel: UILabel = UILabel()
    /// 图片显示
    private let imageView: UIImageView = UIImageView()
    /// 按钮
    private let button: UIButton = UIButton(type: .custom)
    /// 内容显示
    private let stackView: UIStackView = UIStackView()
    /// 记录用户信息
    public var userInfo: Any?
    /// 交互代理
    public weak var delegate: MNDataEmptyDelegate?
    /// 数据源
    public weak var dataSource: MNDataEmptySource?
    /// 构成元素
    private var elements: [MNDataEmptyView.Component] = [.image, .text, .button]
    /// 构成元素对外接口
    public var components: [MNDataEmptyView.Component] {
        get { elements }
        set {
            var seen = Set<MNDataEmptyView.Component>()
            let components = newValue.filter { seen.insert($0).inserted }
            if components == elements { return }
            elements = components
            var arrangedSubviews: [UIView] = [UIView]()
            for component in components {
                switch component {
                case .image:
                    arrangedSubviews.append(imageView)
                case .text:
                    arrangedSubviews.append(textLabel)
                case .button:
                    arrangedSubviews.append(button)
                case .custom:
                    if let view = stackView.arrangedSubviews.first(where: { $0.tag > .min }) {
                        arrangedSubviews.append(view)
                    }
                }
            }
            stackView.arrangedSubviews.forEach {
                $0.removeFromSuperview()
            }
            for subview in arrangedSubviews {
                stackView.insertArrangedSubview(subview, at: stackView.arrangedSubviews.count)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addConstraints([
            NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        imageView.tag = .min
        imageView.isHidden = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTouchUpInside)))
        stackView.addArrangedSubview(imageView)
        imageView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        ])
        
        textLabel.tag = .min
        textLabel.isHidden = true
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.descriptionTouchUpInside)))
        stackView.addArrangedSubview(textLabel)
        textLabel.addConstraint(
            NSLayoutConstraint(item: textLabel, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: .greatestFiniteMagnitude)
        )
        
        button.tag = .min
        button.isHidden = true
        button.clipsToBounds = true
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.buttonTouchUpInside), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        button.addConstraints([
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        ])
    }
    
    public convenience init(parentView: UIView) {
        self.init(frame: .zero)
        self.parentView = parentView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let newSuperview = newSuperview {
            parentView = newSuperview
        }
    }
}

// MARK: - Layout
extension MNDataEmptyView {
    
    /// 布局方向 (默认`vertical`)
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set { stackView.axis = newValue }
    }
    
    /// 布局间隔 (默认20`pt`)
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    /// 对齐方式
    public var alignment: UIStackView.Alignment {
        get { stackView.alignment }
        set { stackView.alignment = newValue }
    }
    
    /// 内容偏移 (参照中心点)
    public var offset: UIOffset {
        set {
            for constraint in constraints {
                switch constraint.firstAttribute {
                case .centerX:
                    constraint.constant = newValue.horizontal
                case .centerY:
                    constraint.constant = newValue.vertical
                default: break
                }
            }
        }
        get {
            var vertical: CGFloat = 0.0
            var horizontal: CGFloat = 0.0
            for constraint in constraints {
                switch constraint.firstAttribute {
                case .centerX:
                    horizontal = constraint.constant
                case .centerY:
                    vertical = constraint.constant
                default: break
                }
            }
            return UIOffset(horizontal: horizontal, vertical: vertical)
        }
    }
    
    /// 自定义视图
    public var customView: UIView? {
        get {
            stackView.arrangedSubviews.first { $0.tag > .min }
        }
        set {
            for subview in stackView.subviews.filter({ $0.tag > .min }) {
                // 若存在于arrangedSubviews也会删除
                subview.removeFromSuperview()
            }
            if let newValue = newValue, let index = elements.firstIndex(of: .custom) {
                newValue.autoresizingMask = []
                newValue.contentMode = .scaleAspectFit
                newValue.removeConstraints(newValue.constraints)
                newValue.translatesAutoresizingMaskIntoConstraints = false
                stackView.insertArrangedSubview(newValue, at: index)
                newValue.addConstraints([NSLayoutConstraint(item: newValue, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: newValue.frame.width), NSLayoutConstraint(item: newValue, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: newValue.frame.height)])
            }
        }
    }
    
    /// 图片
    public var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }
    
    /// 图片尺寸 (默认`zero`)
    public var imageSize: CGSize {
        set {
            for constraint in imageView.constraints {
                switch constraint.firstAttribute {
                case .width:
                    constraint.constant = ceil(newValue.width)
                case .height:
                    constraint.constant = ceil(newValue.height)
                default: break
                }
            }
        }
        get {
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            for constraint in imageView.constraints {
                switch constraint.firstAttribute {
                case .width:
                    width = constraint.constant
                case .height:
                    height = constraint.constant
                default: break
                }
            }
            return CGSize(width: width, height: height)
        }
    }
    
    /// 图片圆角 (默认0`pt`)
    public var imageRadius: CGFloat {
        get { imageView.layer.cornerRadius }
        set { imageView.layer.cornerRadius = newValue }
    }
    
    /// 图片填充模式 (默认`scaleAspectFit`)
    public var imageMode: UIView.ContentMode {
        get { imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    /// 图片是否响应事件 `default is false`
    public var imageTouchEnabled: Bool {
        get { imageView.isUserInteractionEnabled }
        set { imageView.isUserInteractionEnabled = newValue }
    }
    
    /// 文字是否响应事件 `default is false`
    public var descriptionTouchEnabled: Bool {
        get { textLabel.isUserInteractionEnabled }
        set { textLabel.isUserInteractionEnabled = newValue }
    }
    
    /// 描述富文本
    public var attributedDescription: NSAttributedString? {
        get { textLabel.attributedText }
        set {
            textLabel.attributedText = newValue
            if let newValue = newValue, newValue.length > 0 {
                textLabel.isHidden = false
            } else {
                textLabel.isHidden = true
            }
        }
    }
    
    /// 富文本最大宽度
    public var descriptionFiniteMagnitude: CGFloat {
        set {
            for constraint in textLabel.constraints {
                switch constraint.firstAttribute {
                case .width:
                    constraint.constant = newValue
                default: break
                }
            }
        }
        get {
            var width: CGFloat = 0.0
            for constraint in textLabel.constraints {
                switch constraint.firstAttribute {
                case .width:
                    width = constraint.constant
                default: break
                }
            }
            return width
        }
    }

    /// 按钮大小 (默认zero)
    public var buttonSize: CGSize {
        set {
            for constraint in button.constraints {
                switch constraint.firstAttribute {
                case .width:
                    constraint.constant = newValue.width
                case .height:
                    constraint.constant = newValue.height
                default: break
                }
            }
        }
        get {
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            for constraint in button.constraints {
                switch constraint.firstAttribute {
                case .width:
                    width = constraint.constant
                case .height:
                    height = constraint.constant
                default: break
                }
            }
            return CGSize(width: width, height: height)
        }
    }
    
    /// 按钮圆角
    public var buttonRadius: CGFloat {
        get { button.layer.cornerRadius }
        set { button.layer.cornerRadius = newValue }
    }
    
    /// 按钮边框宽度
    public var buttonBorderWidth: CGFloat {
        get { button.layer.borderWidth }
        set { button.layer.borderWidth = newValue }
    }
    
    /// 按钮边框颜色
    public var buttonBorderColor: UIColor? {
        get {
            if let borderColor = button.layer.borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
        set { button.layer.borderColor = newValue?.cgColor }
    }
    
    /// 按钮背景颜色
    public var buttonBackgroundColor: UIColor? {
        get { button.backgroundColor }
        set { button.backgroundColor = newValue }
    }
    
    /// 设置按钮富文本标题
    /// - Parameters:
    ///   - attributedTitle: 按钮标题
    ///   - state: 状态
    public func setButtonAttributedTitle(_ attributedTitle: NSAttributedString?, for state: UIControl.State) {
        button.setAttributedTitle(attributedTitle, for: state)
        hideButtonIfNeeded()
    }
    
    /// 按钮富文本标题
    /// - Parameter state: 状态
    /// - Returns: 状态下富文本标题
    public func buttonAttributedTitle(for state: UIControl.State) -> NSAttributedString? {
        button.attributedTitle(for: state)
    }
    
    /// 设置按钮背景图片
    /// - Parameters:
    ///   - image: 背景图片
    ///   - state: 状态
    public func setButtonBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        button.setBackgroundImage(image, for: state)
        hideButtonIfNeeded()
    }
    
    /// 按钮背景图片
    /// - Parameter state: 状态
    /// - Returns: 状态下背景图片
    public func buttonBackgroundImage(for state: UIControl.State) -> UIImage? {
        button.backgroundImage(for: state)
    }
    
    /// 根据情况隐藏按钮
    private func hideButtonIfNeeded() {
        var isHidden = true
        let normalTitle = button.attributedTitle(for: .normal)
        let highlightedTitle = button.attributedTitle(for: .highlighted)
        let normalImage = button.backgroundImage(for: .normal)
        let highlightedImage = button.backgroundImage(for: .highlighted)
        for element in [normalTitle, highlightedTitle, normalImage, highlightedImage] {
            switch element {
            case Optional<NSObject>.some(_):
                isHidden = false
            default: break
            }
        }
        button.isHidden = isHidden
    }
}

// MARK: - Event
extension MNDataEmptyView {
    
    /// 图片点击事件
    @objc private func imageTouchUpInside() {
        guard let delegate = delegate else { return }
        delegate.dataEmptyViewImageTouchUpInside?(imageView.image)
    }
    
    /// 文字点击事件
    @objc private func descriptionTouchUpInside() {
        guard let delegate = delegate else { return }
        delegate.dataEmptyViewDescriptionTouchUpInside?(textLabel.attributedText?.string)
    }
    
    /// 按钮点击事件
    @objc private func buttonTouchUpInside() {
        guard let delegate = delegate else { return }
        delegate.dataEmptyViewButtonTouchUpInside?()
    }
}

// MARK: - Show&Dismiss
extension MNDataEmptyView {
    
    /// 询问代理 是则显示 否则删除
    @MainActor
    @objc public func showIfNeeded() {
        guard let parentView = parentView else { return }
        if let delegate = delegate, let display = delegate.dataEmptyViewShouldDisplay?(parentView), display {
            show()
        } else {
            dismiss()
        }
    }
    
    /// 显示
    @MainActor
    @objc public func show() {
        guard let dataSource = dataSource else { return }
        var view: UIView!
        var displaying: Bool = false
        if let superview = superview {
            displaying = alpha == 1.0
            view = superview
            superview.sendSubviewToBack(self)
        } else {
            guard let parentView = parentView else { return }
            view = parentView
            translatesAutoresizingMaskIntoConstraints = false
            parentView.insertSubview(self, at: 0)
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: parentView.topAnchor),
                leftAnchor.constraint(equalTo: parentView.leftAnchor),
                bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                rightAnchor.constraint(equalTo: parentView.rightAnchor)
            ])
        }
        let areAnimationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        userInfo = dataSource.userInfoForDataEmptyView?(view)
        backgroundColor = dataSource.backgroundColorForDataEmptyView?(view)
        offset = dataSource.offsetForDataEmptyView?(view) ?? .zero
        axis = dataSource.axisForDataEmptyView?((view)) ?? .vertical
        spacing = dataSource.spacingForDataEmptyView?(view) ?? 20.0
        alignment = dataSource.alignmentForDataEmptyView?(view) ?? .center
        customView = dataSource.customViewForDataEmptyView?(view)
        image = dataSource.imageForDataEmptyView?(view)
        imageSize = dataSource.imageSizeForDataEmptyView?(view) ?? .zero
        imageRadius = dataSource.imageRadiusForDataEmptyView?(view) ?? 0.0
        imageMode = dataSource.imageModeForDataEmptyView?(view) ?? .scaleAspectFit
        attributedDescription = dataSource.descriptionForDataEmptyView?(view)
        descriptionFiniteMagnitude = min(dataSource.descriptionFiniteMagnitudeForDataEmptyView?(view) ?? .greatestFiniteMagnitude, frame.width)
        buttonSize = dataSource.buttonSizeForDataEmptyView?(view) ?? .zero
        buttonRadius = dataSource.buttonRadiusForDataEmptyView?(view) ?? 0.0
        buttonBorderColor = dataSource.buttonBorderColorForDataEmptyView?(view)
        buttonBorderWidth = dataSource.buttonBorderWidthForDataEmptyView?(view) ?? 0.0
        buttonBackgroundColor = dataSource.buttonBackgroundColorForDataEmptyView?(view)
        setButtonAttributedTitle(dataSource.buttonAttributedTitleForDataEmptyView?(view, with: .normal), for: .normal)
        setButtonAttributedTitle(dataSource.buttonAttributedTitleForDataEmptyView?(view, with: .highlighted), for: .highlighted)
        setButtonBackgroundImage(dataSource.buttonBackgroundImageForDataEmptyView?(view, with: .normal), for: .normal)
        setButtonBackgroundImage(dataSource.buttonBackgroundImageForDataEmptyView?(view, with: .highlighted), for: .highlighted)
        layoutIfNeeded()
        UIView.setAnimationsEnabled(areAnimationsEnabled)
        if let delegate = delegate {
            if let touchEnabled = delegate.dataEmptyViewShouldTouchImage?(view) {
                imageTouchEnabled = touchEnabled
            }
            if let touchEnabled = delegate.dataEmptyViewShouldTouchDescription?(view) {
                descriptionTouchEnabled = touchEnabled
            }
            if view is UIScrollView, let scrollEnabled = delegate.dataEmptyViewShouldScroll?(view) {
                let scrollView = view as! UIScrollView
                isScrollEnabled = scrollView.isScrollEnabled
                scrollView.isScrollEnabled = scrollEnabled
            }
        }
        guard displaying == false else { return }
        var animationDuration: TimeInterval = 0.0
        if let delegate = delegate, let duration = delegate.fadeInDurationForDataEmptyView?(view) {
            alpha = 0.0
            animationDuration = duration
        }
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1.0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            if let delegate = self.delegate {
                delegate.dataEmptyViewDidDisappear?()
            }
        }
    }
    
    /// 隐藏
    @MainActor
    @objc public func dismiss() {
        guard let superview = superview else { return }
        userInfo = nil
        if let scrollEnabled = isScrollEnabled {
            isScrollEnabled = nil
            if superview is UIScrollView {
                let scrollView = superview as! UIScrollView
                scrollView.isScrollEnabled = scrollEnabled
            }
        }
        if let delegate = delegate {
            delegate.dataEmptyViewDidDisappear?()
        }
   }
}

// MARK: - Observer
fileprivate class MNDataEmptyObserver: NSObject {
    
    /// 无参响应方法
    private var action: Selector?
    
    /// 事件响应者
    private weak var target: NSObjectProtocol?
    
    /// 记录上次回调时的内容尺寸
    private var referenceSize: CGSize = .zero
    
    /// 记录正在监听的滚动视图
    private weak var scrollView: UIScrollView!
    
    
    /// 构造监听对象
    /// - Parameters:
    ///   - target: 响应者
    ///   - action: 响应事件
    init(target: NSObjectProtocol, action: Selector) {
        super.init()
        self.target = target
        self.action = action
    }
    
    deinit {
        if let scrollView = scrollView {
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        }
    }
    
    /// 开始监听滚动视图
    /// - Parameter scrollView: 滚动视图
    func beginObserve(_ scrollView: UIScrollView) {
        if let old = self.scrollView {
            if old == scrollView { return }
            referenceSize = .zero
            old.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        }
        self.scrollView = scrollView
        referenceSize = scrollView.contentSize
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.new], context: nil)
    }
    
    /// 结束监听滚动视图
    func endObserve() {
        guard let scrollView = scrollView else { return }
        self.scrollView = nil
        referenceSize = .zero
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == #keyPath(UIScrollView.contentSize) else { return }
        guard let contentSize = change?[.newKey] as? CGSize else { return }
        guard contentSize.width.isNaN == false, contentSize.height.isNaN == false else { return }
        if abs(referenceSize.width - contentSize.width) < 1.0, abs(referenceSize.height - contentSize.height) < 1.0 { return }
        referenceSize = contentSize
        guard let target = target, let action = action else { return }
        target.perform(action)
    }
}

// MARK: - Display & Remove
extension UIView {
    
    /// 判断是否需要展示空数据视图
    @objc fileprivate func empty_display_if_needed() {
        guard let emptyView = mn.emptyView else { return }
        guard let dataSource = emptyView.dataSource else { return }
        var visible: Bool = false
        if let delegate = emptyView.delegate, let display = delegate.dataEmptyViewShouldDisplay?(self) {
            visible = display
        } else if let itemCount = mn.dataItemCount {
            visible = itemCount <= 0
        } else if self is UIScrollView {
            let scrollView = self as! UIScrollView
            let contentRect = CGRect(origin: .zero, size: scrollView.contentSize)
            visible = contentRect.isNull || contentRect.isEmpty
        }
        if visible {
            // 显示
            emptyView.show()
        } else {
            // 隐藏
            emptyView.dismiss()
        }
    }
}

// MARK: - 构造命名空间/包装器
extension UIView {
    
    fileprivate struct MNDataEmptyAssociated {
        
        nonisolated(unsafe) static var view: Void?
        nonisolated(unsafe) static var observer: Void?
        nonisolated(unsafe) static var autoDisplay: Void?
        nonisolated(unsafe) static var components: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIView {
    
    /// 空数据视图数据源
    @MainActor
    public var emptyViewSource: MNDataEmptySource? {
        set {
            if let newValue = newValue {
                let emptyView = viewForDataEmpty()
                emptyView.dataSource = newValue
                if base is UIScrollView {
                    dataEmptyObserver.beginObserve(base as! UIScrollView)
                }
            } else if let emptyView = emptyView {
                emptyView.dataSource = nil
                if base is UIScrollView {
                    dataEmptyObserver.endObserve()
                }
            }
        }
        get {
            guard let emptyView = emptyView else { return nil }
            return emptyView.dataSource
        }
    }
    
    /// 空数据视图代理
    @MainActor
    public var emptyViewDelegate: MNDataEmptyDelegate? {
        set {
            if let newValue = newValue {
                let emptyView = viewForDataEmpty()
                emptyView.delegate = newValue
            } else if let emptyView = emptyView {
                emptyView.delegate = nil
            }
        }
        get {
            guard let emptyView = emptyView else { return nil }
            return emptyView.delegate
        }
    }
    
    /// 自动根据数据源刷新空数据视图
    public var autoDisplayEmptyView: Bool {
        set {
            if newValue {
                if base is UIScrollView {
                    dataEmptyObserver.beginObserve(base as! UIScrollView)
                }
            } else {
                dataEmptyObserver.endObserve()
            }
            objc_setAssociatedObject(base, &UIView.MNDataEmptyAssociated.autoDisplay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(base, &UIView.MNDataEmptyAssociated.autoDisplay) as? Bool ?? true
        }
    }
    
    
    /// 空数据元素集合
    public var emptyViewComponents: [MNDataEmptyView.Component] {
        set {
            if let emptyView = emptyView {
                emptyView.components = newValue
            }
            objc_setAssociatedObject(base, &UIView.MNDataEmptyAssociated.components, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let emptyView = emptyView {
                return emptyView.components
            }
            return objc_getAssociatedObject(base, &UIView.MNDataEmptyAssociated.components) as? [MNDataEmptyView.Component] ?? []
        }
    }
    
    /// 空数据视图
    fileprivate var emptyView: MNDataEmptyView? {
        set {
            objc_setAssociatedObject(base, &UIView.MNDataEmptyAssociated.view, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(base, &UIView.MNDataEmptyAssociated.view) as? MNDataEmptyView
        }
    }
    
    /// 空数据监听
    fileprivate var dataEmptyObserver: MNDataEmptyObserver {
        if let observer = objc_getAssociatedObject(base, &UIView.MNDataEmptyAssociated.observer) as? MNDataEmptyObserver {
            return observer
        }
        let observer = MNDataEmptyObserver(target: base, action: #selector(base.empty_display_if_needed))
        objc_setAssociatedObject(base, &UIView.MNDataEmptyAssociated.observer, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }
    
    /// 关联空数据视图
    /// - Returns: 空数据视图
    private func viewForDataEmpty() -> MNDataEmptyView {
        if let emptyView = emptyView { return emptyView }
        let emptyView = MNDataEmptyView(parentView: base)
        let components = emptyViewComponents
        if components.isEmpty == false {
            emptyView.components = components
        }
        self.emptyView = emptyView
        return emptyView
    }
    
    /// 表格数量
    fileprivate var dataItemCount: Int? {
        if base is UITableView {
            var itemCount: Int = 0
            let tableView = base as! UITableView
            guard let dataSource = tableView.dataSource else { return 0 }
            let sections = dataSource.numberOfSections?(in: tableView) ?? 1
            guard sections > 0 else { return 0 }
            for section in 0..<sections {
                itemCount += dataSource.tableView(tableView, numberOfRowsInSection: section)
            }
            return itemCount
        }
        if base is UICollectionView {
            var itemCount: Int = 0
            let collectionView = base as! UICollectionView
            guard let dataSource = collectionView.dataSource else { return 0 }
            let sections = dataSource.numberOfSections?(in: collectionView) ?? 1
            guard sections > 0 else { return 0 }
            for section in 0..<sections {
                itemCount += dataSource.collectionView(collectionView, numberOfItemsInSection: section)
            }
            return itemCount
        }
        return nil
    }
}
