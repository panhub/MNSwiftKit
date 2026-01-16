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
    
    /// 四周边界约束
    /// - Returns: 四周边界约束
    @objc optional func edgeInsetForDataEmptyView() -> UIEdgeInsets
    
    /// 背景颜色
    /// - Returns: 背景颜色
    @objc optional func backgroundColorForDataEmptyView() -> UIColor?
    
    /// 内容偏移
    /// - Returns: 内容偏移
    @objc optional func offsetForDataEmptyView() -> UIOffset
    
    /// 布局方向
    /// - Returns: 布局方向
    @objc optional func axisForDataEmptyView() -> NSLayoutConstraint.Axis
    
    /// 内容间隔
    /// - Returns: 间隔
    @objc optional func spacingForDataEmptyView() -> CGFloat
    
    /// 内容对齐方式
    /// - Returns: 对齐方式
    @objc optional func alignmentForDataEmptyView() -> UIStackView.Alignment
    
    /// 自定义视图
    /// - Returns: 自定义视图
    @objc optional func customViewForDataEmptyView() -> UIView?
    
    /// 图片
    /// - Returns: 图片
    @objc optional func imageForDataEmptyView() -> UIImage?
    
    /// 图片显示尺寸`pt`
    /// - Returns: 图片视图尺寸
    @objc optional func imageSizeForDataEmptyView() -> CGSize
    
    /// 图片填充模式
    /// - Returns: 填充模式
    @objc optional func imageModeForDataEmptyView() -> UIView.ContentMode
    
    /// 图片圆角大小
    /// - Returns: 圆角大小
    @objc optional func imageRadiusForDataEmptyView() -> CGFloat
    
    /// 提示信息富文本
    /// - Returns: 描述信息富文本
    @objc optional func attributedHintForDataEmptyView() -> NSAttributedString?
    
    /// 描述信息最大宽度`pt`
    /// - Returns: 最大宽度
    @objc optional func hintConstrainedMagnitudeForDataEmptyView() -> CGFloat
    
    /// 按钮大小
    /// - Returns: 按钮大小
    @objc optional func buttonSizeForDataEmptyView() -> CGSize
    
    /// 按钮圆角大小
    /// - Returns: 圆角大小
    @objc optional func buttonRadiusForDataEmptyView() -> CGFloat
    
    /// 按钮边框宽度
    /// - Returns: 按钮边框宽度
    @objc optional func buttonBorderWidthForDataEmptyView() -> CGFloat
    
    /// 按钮边框颜色
    /// - Returns: 边框颜色
    @objc optional func buttonBorderColorForDataEmptyView() -> UIColor?
    
    /// 按钮背景颜色
    /// - Returns: 背景颜色
    @objc optional func buttonBackgroundColorForDataEmptyView() -> UIColor?
    
    /// 按钮背景图片
    /// - Parameter state: 按钮状态
    /// - Returns: 背景图
    @objc optional func buttonBackgroundImageForDataEmptyView(for state: UIControl.State) -> UIImage?
    
    /// 按钮标题
    /// - Parameter state: 按钮状态
    /// - Returns: 按钮标题富文本
    @objc optional func buttonAttributedTitleForDataEmptyView(for state: UIControl.State) -> NSAttributedString?
    
    /// 空数据视图生命周期 -已经出现
    @objc optional func dataEmptyViewDidAppear()
    
    /// 空数据视图生命周期 -已经消失
    @objc optional func dataEmptyViewDidDisappear()
    
    /// 是否支持展示空数据视图
    /// - Returns: 是否展示
    @objc optional func dataEmptyViewShouldDisplay() -> Bool
    
    /// 默认渐现动画时长('>0.0'则加载动画)
    /// - Returns: 动画时长
    @objc optional func fadeAnimationDurationForDataEmptyView() -> TimeInterval
    
    /// 空数据视图按钮点击事件
    @objc optional func dataEmptyViewButtonTouchUpInside()
}

/// 空数据视图构成元素 component
@objc public enum MNDataEmptyComponent: Int {
    /// 图片
    case image
    /// 提示文字
    case text
    /// 按钮
    case button
}

/// 空数据视图
fileprivate class MNDataEmptyView: UIView {
    /// 记录上一次的父视图
    private weak var parentView: UIView?
    /// 自定义视图
    private weak var rawCustomView: UIView?
    /// 文字显示
    private let textLabel: UILabel = UILabel()
    /// 图片显示
    private let imageView: UIImageView = UIImageView()
    /// 按钮
    private let button: UIButton = UIButton(type: .custom)
    /// 内容显示
    private let stackView: UIStackView = UIStackView()
    /// 交互代理
    weak var delegate: MNDataEmptyDelegate?
    /// 构成元素
    private var rawComponents: [MNDataEmptyComponent] = [.image, .text, .button]
    /// 构成元素对外接口
    var components: [MNDataEmptyComponent] {
        get { rawComponents }
        set {
            var seen = Set<MNDataEmptyComponent>()
            let components = newValue.filter { seen.insert($0).inserted }
            if components == rawComponents { return }
            rawComponents = components
            var arrangedSubviews: [UIView] = []
            for component in components {
                switch component {
                case .image:
                    arrangedSubviews.append(imageView)
                case .text:
                    arrangedSubviews.append(textLabel)
                case .button:
                    arrangedSubviews.append(button)
                }
            }
            rawCustomView = nil
            stackView.arrangedSubviews.forEach {
                $0.removeFromSuperview()
            }
            for subview in arrangedSubviews {
                stackView.insertArrangedSubview(subview, at: stackView.arrangedSubviews.count)
            }
        }
    }
    
    override init(frame: CGRect) {
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
    
    convenience init(parentView: UIView) {
        self.init(frame: .zero)
        self.parentView = parentView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension MNDataEmptyView {
    
    /// 布局方向 (默认`vertical`)
    fileprivate var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set { stackView.axis = newValue }
    }
    
    /// 布局间隔 (默认20`pt`)
    fileprivate var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    /// 对齐方式
    fileprivate var alignment: UIStackView.Alignment {
        get { stackView.alignment }
        set { stackView.alignment = newValue }
    }
    
    /// 内容偏移 (参照中心点)
    fileprivate var offset: UIOffset {
        get {
            var vertical: CGFloat = 0.0
            var horizontal: CGFloat = 0.0
            for constraint in constraints.filter({ constraint in
                guard let firstItem = constraint.firstItem, firstItem is UIStackView else { return false }
                return true
            }) {
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
        set {
            for constraint in constraints.filter({ constraint in
                guard let firstItem = constraint.firstItem, firstItem is UIStackView else { return false }
                return true
            }) {
                switch constraint.firstAttribute {
                case .centerX:
                    constraint.constant = newValue.horizontal
                case .centerY:
                    constraint.constant = newValue.vertical
                default: break
                }
            }
        }
    }
    
    /// 四周约束
    fileprivate var edgeInset: UIEdgeInsets {
        get {
            guard let superview = superview else { return .zero }
            var edgeInset: UIEdgeInsets = .zero
            for constraint in superview.constraints.filter({ constraint in
                guard let firstItem = constraint.firstItem, firstItem is MNDataEmptyView else { return false }
                return true
            }) {
                switch constraint.firstAttribute {
                case .top:
                    edgeInset.top = constraint.constant
                case .left, .leading:
                    edgeInset.left = constraint.constant
                case .bottom:
                    edgeInset.bottom = -constraint.constant
                case .right, .trailing:
                    edgeInset.right = -constraint.constant
                default:
                    break
                }
            }
            return edgeInset
        }
        set {
            guard let superview = superview else { return }
            for constraint in superview.constraints.filter({ constraint in
                guard let firstItem = constraint.firstItem, firstItem is MNDataEmptyView else { return false }
                return true
            }) {
                switch constraint.firstAttribute {
                case .top:
                    constraint.constant = newValue.top
                case .left, .leading:
                    constraint.constant = newValue.left
                case .bottom:
                    constraint.constant = -newValue.bottom
                case .right, .trailing:
                    constraint.constant = -newValue.right
                default:
                    break
                }
            }
        }
    }
    
    /// 自定义视图
    fileprivate var customView: UIView? {
        get { rawCustomView }
        set {
            if let subview = rawCustomView {
                rawCustomView = nil
                subview.removeFromSuperview()
            }
            guard let newValue = newValue else { return }
            guard let index = components.firstIndex(where: { $0 == .image }) else { return }
            rawCustomView = newValue
            newValue.autoresizingMask = []
            newValue.contentMode = .scaleAspectFit
            newValue.translatesAutoresizingMaskIntoConstraints = false
            stackView.insertArrangedSubview(newValue, at: index)
            newValue.addConstraints([
                NSLayoutConstraint(item: newValue, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: newValue.frame.width),
                NSLayoutConstraint(item: newValue, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: newValue.frame.height)
            ])
        }
    }
    
    /// 图片
    fileprivate var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }
    
    /// 图片尺寸 (默认`zero`)
    fileprivate var imageSize: CGSize {
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
    fileprivate var imageRadius: CGFloat {
        get { imageView.layer.cornerRadius }
        set { imageView.layer.cornerRadius = newValue }
    }
    
    /// 图片填充模式 (默认`scaleAspectFit`)
    fileprivate var imageMode: UIView.ContentMode {
        get { imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    /// 描述富文本
    fileprivate var attributedDescription: NSAttributedString? {
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
    fileprivate var descriptionFiniteMagnitude: CGFloat {
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
    fileprivate var buttonSize: CGSize {
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
    fileprivate var buttonRadius: CGFloat {
        get { button.layer.cornerRadius }
        set { button.layer.cornerRadius = newValue }
    }
    
    /// 按钮边框宽度
    fileprivate var buttonBorderWidth: CGFloat {
        get { button.layer.borderWidth }
        set { button.layer.borderWidth = newValue }
    }
    
    /// 按钮边框颜色
    fileprivate var buttonBorderColor: UIColor? {
        get {
            if let borderColor = button.layer.borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
        set { button.layer.borderColor = newValue?.cgColor }
    }
    
    /// 按钮背景颜色
    fileprivate var buttonBackgroundColor: UIColor? {
        get { button.backgroundColor }
        set { button.backgroundColor = newValue }
    }
    
    /// 设置按钮富文本标题
    /// - Parameters:
    ///   - attributedTitle: 按钮标题
    ///   - state: 状态
    fileprivate func setButtonAttributedTitle(_ attributedTitle: NSAttributedString?, for state: UIControl.State) {
        button.setAttributedTitle(attributedTitle, for: state)
        hideButtonIfNeeded()
    }
    
    /// 按钮富文本标题
    /// - Parameter state: 状态
    /// - Returns: 状态下富文本标题
    fileprivate func buttonAttributedTitle(for state: UIControl.State) -> NSAttributedString? {
        button.attributedTitle(for: state)
    }
    
    /// 设置按钮背景图片
    /// - Parameters:
    ///   - image: 背景图片
    ///   - state: 状态
    fileprivate func setButtonBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        button.setBackgroundImage(image, for: state)
        hideButtonIfNeeded()
    }
    
    /// 按钮背景图片
    /// - Parameter state: 状态
    /// - Returns: 状态下背景图片
    fileprivate func buttonBackgroundImage(for state: UIControl.State) -> UIImage? {
        button.backgroundImage(for: state)
    }
    
    /// 根据情况隐藏按钮
    fileprivate func hideButtonIfNeeded() {
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
    
    /// 按钮点击事件
    @objc private func buttonTouchUpInside() {
        guard let delegate = delegate else { return }
        delegate.dataEmptyViewButtonTouchUpInside?()
    }
}

// MARK: - Show&Dismiss
extension MNDataEmptyView {
    /// 显示
    fileprivate func show() {
        guard let delegate = delegate else { return }
        var displaying: Bool = false
        if let superview = superview {
            displaying = alpha == 1.0
            superview.bringSubviewToFront(self)
        } else {
            guard let parentView = parentView else { return }
            var superview: UIView!
            if parentView is UICollectionView {
                let collectionView = parentView as! UICollectionView
                if let backgroundView = collectionView.backgroundView {
                    superview = backgroundView
                } else {
                    let backgroundView = UIView()
                    collectionView.backgroundView = backgroundView
                    superview = backgroundView
                }
            } else if parentView is UITableView {
                let tableView = parentView as! UITableView
                if let backgroundView = tableView.backgroundView {
                    superview = backgroundView
                } else {
                    let backgroundView = UIView()
                    tableView.backgroundView = backgroundView
                    superview = backgroundView
                }
            } else {
                superview = parentView
            }
            translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(self)
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: superview.topAnchor),
                leftAnchor.constraint(equalTo: superview.leftAnchor),
                bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                rightAnchor.constraint(equalTo: superview.rightAnchor)
            ])
        }
        let areAnimationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        backgroundColor = delegate.backgroundColorForDataEmptyView?()
        edgeInset = delegate.edgeInsetForDataEmptyView?() ?? .zero
        axis = delegate.axisForDataEmptyView?() ?? .vertical
        offset = delegate.offsetForDataEmptyView?() ?? .zero
        spacing = delegate.spacingForDataEmptyView?() ?? 20.0
        alignment = delegate.alignmentForDataEmptyView?() ?? .center
        customView = delegate.customViewForDataEmptyView?()
        image = delegate.imageForDataEmptyView?()
        imageSize = delegate.imageSizeForDataEmptyView?() ?? .zero
        imageRadius = delegate.imageRadiusForDataEmptyView?() ?? 0.0
        imageMode = delegate.imageModeForDataEmptyView?() ?? .scaleAspectFit
        attributedDescription = delegate.attributedHintForDataEmptyView?()
        descriptionFiniteMagnitude = delegate.hintConstrainedMagnitudeForDataEmptyView?() ?? .greatestFiniteMagnitude
        buttonSize = delegate.buttonSizeForDataEmptyView?() ?? .zero
        buttonRadius = delegate.buttonRadiusForDataEmptyView?() ?? 0.0
        buttonBorderColor = delegate.buttonBorderColorForDataEmptyView?()
        buttonBorderWidth = delegate.buttonBorderWidthForDataEmptyView?() ?? 0.0
        buttonBackgroundColor = delegate.buttonBackgroundColorForDataEmptyView?()
        setButtonAttributedTitle(delegate.buttonAttributedTitleForDataEmptyView?(for: .normal), for: .normal)
        setButtonAttributedTitle(delegate.buttonAttributedTitleForDataEmptyView?(for: .highlighted), for: .highlighted)
        setButtonBackgroundImage(delegate.buttonBackgroundImageForDataEmptyView?(for: .normal), for: .normal)
        setButtonBackgroundImage(delegate.buttonBackgroundImageForDataEmptyView?(for: .highlighted), for: .highlighted)
        layoutIfNeeded()
        UIView.setAnimationsEnabled(areAnimationsEnabled)
        guard displaying == false else { return }
        var animationDuration: TimeInterval = 0.0
        if let duration = delegate.fadeAnimationDurationForDataEmptyView?(), duration > 0.0 {
            animationDuration = duration
        }
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1.0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            if let delegate = self.delegate {
                delegate.dataEmptyViewDidAppear?()
            }
        }
    }
    
    /// 隐藏
    fileprivate func dismiss() {
        guard let _ = superview, alpha == 1.0 else { return }
        var animationDuration: TimeInterval = 0.0
        if let delegate = delegate, let duration = delegate.fadeAnimationDurationForDataEmptyView?(), duration > 0.0 {
            animationDuration = duration
        }
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.alpha = 0.0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            if let delegate = self.delegate {
                delegate.dataEmptyViewDidDisappear?()
            }
        }
    }
}

// MARK: - Observer
fileprivate class MNDataEmptyObserver: NSObject {
    
    /// 内容尺寸变化处理回调
    private var actionHandler: (()->Void)!
    
    /// 记录上次回调时的内容尺寸
    private var lastContentSize: CGSize = .zero
    
    /// 记录正在监听的滚动视图
    private weak var scrollView: UIScrollView!
    
    /// 构造监听对象
    /// - Parameter actionHandler: 内容尺寸变化处理回调
    init(actionHandler: @escaping ()->Void) {
        super.init()
        self.actionHandler = actionHandler
    }
    
    deinit {
        guard let scrollView = scrollView else { return }
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
    }
    
    /// 开始监听滚动视图
    /// - Parameter scrollView: 滚动视图
    func beginObserve(_ scrollView: UIScrollView) {
        if let old = self.scrollView {
            if old == scrollView { return }
            old.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        }
        self.scrollView = scrollView
        lastContentSize = scrollView.contentSize
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.new], context: nil)
    }
    
    /// 结束监听滚动视图
    func endObserve() {
        guard let scrollView = scrollView else { return }
        self.scrollView = nil
        lastContentSize = .zero
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == #keyPath(UIScrollView.contentSize) else { return }
        guard let change = change, let contentSize = change[.newKey] as? CGSize else { return }
        guard contentSize.width.isNaN == false, contentSize.height.isNaN == false else { return }
        if abs(contentSize.width - lastContentSize.width) < 0.1, abs(contentSize.height - lastContentSize.height) < 0.1 { return }
        lastContentSize = contentSize
        guard let actionHandler = actionHandler else { return }
        actionHandler()
    }
}

extension UIView {
    
    fileprivate struct MNDataEmptyAssociated {
        // 空数据视图
        nonisolated(unsafe) static var view: Void?
        // 监听内容尺寸变化
        nonisolated(unsafe) static var observer: Void?
        // 空数据视图组件
        nonisolated(unsafe) static var components: Void?
        // 自动显示空数据视图
        nonisolated(unsafe) static var automatically: Void?
    }
}

// MARK: - 空数据占位处理
extension MNNameSpaceWrapper where Base: UIView {
    
    /// 空数据视图数据源
    public var dataEmptyDelegate: MNDataEmptyDelegate? {
        set {
            if let newValue = newValue {
                let emptyView = viewForDataEmpty()
                emptyView.delegate = newValue
                if base is UIScrollView, automaticallyShowsEmptyView {
                    dataEmptyObserver.beginObserve(base as! UIScrollView)
                }
            } else if let emptyView = emptyView {
                emptyView.delegate = nil
                if base is UIScrollView {
                    dataEmptyObserver.endObserve()
                }
                if let _ = emptyView.superview {
                    emptyView.removeFromSuperview()
                }
            }
        }
        get {
            guard let emptyView = emptyView else { return nil }
            return emptyView.delegate
        }
    }
    
    /// 自动根据数据源刷新空数据视图
    public var automaticallyShowsEmptyView: Bool {
        set {
            if newValue {
                if base is UIScrollView, let _ = dataEmptyDelegate {
                    dataEmptyObserver.beginObserve(base as! UIScrollView)
                }
            } else {
                dataEmptyObserver.endObserve()
            }
            objc_setAssociatedObject(base, &UIView.MNDataEmptyAssociated.automatically, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(base, &UIView.MNDataEmptyAssociated.automatically) as? Bool ?? true
        }
    }
    
    /// 空数据元素集合
    public var dataEmptyComponents: [MNDataEmptyComponent] {
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
            return objc_getAssociatedObject(base, &UIView.MNDataEmptyAssociated.components) as? [MNDataEmptyComponent] ?? []
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
        let view = base
        let observer = MNDataEmptyObserver { [weak view] in
            guard let view = view else { return }
            view.mn.showEmptyViewIfNeeded()
        }
        objc_setAssociatedObject(base, &UIView.MNDataEmptyAssociated.observer, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }
    
    /// 关联空数据视图
    /// - Returns: 空数据视图
    private func viewForDataEmpty() -> MNDataEmptyView {
        if let emptyView = emptyView { return emptyView }
        let emptyView = MNDataEmptyView(parentView: base)
        emptyView.alpha = 0.0
        let components = dataEmptyComponents
        if components.isEmpty == false {
            emptyView.components = components
        }
        self.emptyView = emptyView
        return emptyView
    }
}

// MARK: - Display & Remove
extension MNNameSpaceWrapper where Base: UIView {
    
    /// 判断是否需要展示空数据视图
    public func showEmptyViewIfNeeded() {
        guard let emptyView = emptyView else { return }
        guard let delegate = emptyView.delegate else { return }
        var display: Bool = false
        if let allow = delegate.dataEmptyViewShouldDisplay?() {
            display = allow
        } else if let itemCount = dataItemCount {
            display = itemCount <= 0
        } else if base is UIScrollView {
            let scrollView = base as! UIScrollView
            let contentRect = CGRect(origin: .zero, size: scrollView.contentSize)
            display = contentRect.isNull == false && contentRect.isEmpty
        }
        if display {
            // 显示
            emptyView.show()
        } else {
            // 隐藏
            emptyView.dismiss()
        }
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
