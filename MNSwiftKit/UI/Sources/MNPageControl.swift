//
//  MNPageControl.swift
//  MNTest
//
//  Created by panhub on 2022/9/27.
//  页码指示器

import UIKit

/// 页码指示器数据源
@objc public protocol MNPageControlDataSource: NSObjectProtocol {
    /// 询问页码总数
    /// - Parameter pageControl: 指示器
    /// - Returns: 页码总数
    @objc optional func numberOfPageIndicator(in pageControl: MNPageControl) -> Int
    /// 定制指示器
    /// - Parameters:
    ///   - pageControl: 指示器
    ///   - index: 页码索引
    /// - Returns: 指示器视图
    @objc optional func pageControl(_ pageControl: MNPageControl, viewForPageIndicator index: Int) -> UIView
}

/// 页码指示器交互代理
@objc public protocol MNPageControlDelegate: NSObjectProtocol {
    /// 交互式修改页码指示器
    /// - Parameters:
    ///   - pageControl: 指示器
    ///   - index: 页码索引
    @objc optional func pageControl(_ pageControl: MNPageControl, didSelectPageAt index: Int) -> Void
    /// 告知即将展示指示器
    /// - Parameters:
    ///   - pageControl: 指示器
    ///   - indicator: 指示器视图
    ///   - index: 页码索引
    @objc optional func pageControl(_ pageControl: MNPageControl, willDisplay indicator: UIView, forPageAt index: Int) -> Void
}

/// 页码指示器
public class MNPageControl: UIControl {
    /// 对齐方式
    public enum Alignment {
        /// 头部对齐
        case leading
        /// 居中
        case center
        /// 尾部对齐
        case trailing
    }
    /// 布局方向
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set {
            stackView.axis = newValue
            setNeedsUpdateConstraints()
        }
    }
    /// 页码间隔
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    /// 排列方向的对齐方式
    public var alignment: Alignment = .center {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    /// 页码数量 代理优先
    public var numberOfPages: Int = 0 {
        didSet {
            reloadPageIndicators()
        }
    }
    /// 内容边距约束
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    /// 当只有一页时是否隐藏
    public var hidesForSinglePage: Bool = false {
        didSet {
            updateStackView()
        }
    }
    ///页码指示器大小
    public var pageIndicatorSize: CGSize {
        guard let indicator = stackView.arrangedSubviews.first else { return .zero }
        return indicator.frame.size
    }
    /// 当前选中的页码索引
    public var currentPageIndex: Int = 0 {
        didSet {
            if let indicator = stackView.arrangedSubviews.first(where: { $0.isHidden == false && $0.tag == oldValue }) {
                indicator.backgroundColor = pageIndicatorTintColor
            }
            if let indicator = stackView.arrangedSubviews.first(where: { $0.isHidden == false && $0.tag == currentPageIndex }) {
                indicator.backgroundColor = currentPageIndicatorTintColor
            }
        }
    }
    /// 指示器颜色
    public var pageIndicatorTintColor: UIColor? = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0) {
        didSet {
            for indicator in stackView.arrangedSubviews.filter({ $0.isHidden == false && $0.tag != currentPageIndex }) {
                indicator.backgroundColor = pageIndicatorTintColor
            }
        }
    }
    /// 当前指示器颜色
    public var currentPageIndicatorTintColor: UIColor? = UIColor(red: 125.0/255.0, green: 125.0/255.0, blue: 125.0/255.0, alpha: 1.0) {
        didSet {
            if let indicator = stackView.arrangedSubviews.first(where: { $0.isHidden == false && $0.tag == currentPageIndex }) {
                indicator.backgroundColor = currentPageIndicatorTintColor
            }
        }
    }
    /// 内部约束视图
    private let stackView: UIStackView = UIStackView()
    /// 事件代理
    public weak var delegate: MNPageControlDelegate?
    /// 数据源代理
    public weak var dataSource: MNPageControlDataSource?
    /// 指示器触摸区域
    public var pageIndicatorTouchInset: UIEdgeInsets = .zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.spacing = 5.0
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addConstraints([NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: stackView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: stackView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if let _ = newSuperview {
            reloadPageIndicators()
        }
        super.willMove(toSuperview: newSuperview)
    }
    
    public override func updateConstraints() {
        // 激活所有约束
        var activates = constraints
        activates.append(contentsOf: stackView.arrangedSubviews.flatMap({ $0.constraints }))
        NSLayoutConstraint.activate(activates)
        // 记录需要设置无效的约束
        var deactivates: [NSLayoutConstraint] = [NSLayoutConstraint]()
        // StackView
        switch alignment {
        case .leading:
            // 头部对齐
            switch axis {
            case .horizontal:
                // 横向布局
                for constraint in constraints {
                    guard let firstItem = constraint.firstItem as? UIStackView else { continue }
                    guard firstItem == stackView else { continue }
                    switch constraint.firstAttribute {
                    case .top:
                        constraint.constant = contentInset.top
                    case .left:
                        constraint.constant = contentInset.left
                    case .bottom:
                        constraint.constant = -contentInset.bottom
                    case .right, .centerX, .centerY:
                        deactivates.append(constraint)
                    default: break
                    }
                }
            default:
                // 纵向布局
                for constraint in constraints {
                    guard let firstItem = constraint.firstItem as? UIStackView else { continue }
                    guard firstItem == stackView else { continue }
                    switch constraint.firstAttribute {
                    case .top:
                        constraint.constant = contentInset.top
                    case .left:
                        constraint.constant = contentInset.left
                    case .right:
                        constraint.constant = -contentInset.right
                    case .bottom, .centerX, .centerY:
                        deactivates.append(constraint)
                    default: break
                    }
                }
            }
        case .center:
            // 居中对齐
            switch axis {
            case .horizontal:
                // 横向布局
                for constraint in constraints {
                    guard let firstItem = constraint.firstItem as? UIStackView else { continue }
                    guard firstItem == stackView else { continue }
                    switch constraint.firstAttribute {
                    case .top:
                        constraint.constant = contentInset.top
                    case .bottom:
                        constraint.constant = -contentInset.bottom
                    case .left, .right, .centerY:
                        deactivates.append(constraint)
                    default: break
                    }
                }
            default:
                // 纵向布局
                for constraint in constraints {
                    guard let firstItem = constraint.firstItem as? UIStackView else { continue }
                    guard firstItem == stackView else { continue }
                    switch constraint.firstAttribute {
                    case .left:
                        constraint.constant = contentInset.left
                    case .right:
                        constraint.constant = -contentInset.right
                    case .top, .bottom, .centerX:
                        deactivates.append(constraint)
                    default: break
                    }
                }
            }
        case .trailing:
            // 尾部对齐
            switch axis {
            case .horizontal:
                // 横向布局
                for constraint in constraints {
                    guard let firstItem = constraint.firstItem as? UIStackView else { continue }
                    guard firstItem == stackView else { continue }
                    switch constraint.firstAttribute {
                    case .top:
                        constraint.constant = contentInset.top
                    case .bottom:
                        constraint.constant = -contentInset.bottom
                    case .right:
                        constraint.constant = -contentInset.right
                    case .left, .centerX, .centerY:
                        deactivates.append(constraint)
                    default: break
                    }
                }
            default:
                // 纵向布局
                for constraint in constraints {
                    guard let firstItem = constraint.firstItem as? UIStackView else { continue }
                    guard firstItem == stackView else { continue }
                    switch constraint.firstAttribute {
                    case .left:
                        constraint.constant = contentInset.left
                    case .bottom:
                        constraint.constant = -contentInset.bottom
                    case .right:
                        constraint.constant = -contentInset.right
                    case .top, .centerX, .centerY:
                        deactivates.append(constraint)
                    default: break
                    }
                }
            }
        }
        // 指示器
        switch axis {
        case .horizontal:
            // 横向布局
            for subview in stackView.arrangedSubviews {
                deactivates.append(contentsOf: subview.constraints.filter({ $0.firstAttribute == .height }))
            }
        default:
            // 纵向布局
            for subview in stackView.arrangedSubviews {
                deactivates.append(contentsOf: subview.constraints.filter({ $0.firstAttribute == .width }))
            }
        }
        NSLayoutConstraint.deactivate(deactivates)
        super.updateConstraints()
    }
}

// MARK: - Update
extension MNPageControl {
    
    /// 刷新指示器
    public func reloadPageIndicators() {
        
        // 指示器数量
        var count: Int = dataSource?.numberOfPageIndicator?(in: self) ?? numberOfPages
        count = max(0, count)
        
        // 更新视图
        for view in stackView.arrangedSubviews.filter({ $0.tag < count }) {
            view.isHidden = false
        }
        
        for view in stackView.arrangedSubviews.filter({ $0.tag >= count }) {
            view.isHidden = true
        }
        
        let arrangedSubviews = stackView.arrangedSubviews.filter { $0.isHidden == false }
        
        for tag in 0..<count {
            let indicator: UIView
            if arrangedSubviews.count > tag {
                indicator = arrangedSubviews[tag]
            } else {
                // 创建
                indicator = MNPageIndicator()
                indicator.tag = tag
                indicator.clipsToBounds = true
                indicator.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(indicator)
                indicator.addConstraints([NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: indicator, attribute: .height, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: indicator, attribute: .height, relatedBy: .equal, toItem: indicator, attribute: .width, multiplier: 1.0, constant: 0.0)])
                if let subview = dataSource?.pageControl?(self, viewForPageIndicator: tag) {
                    indicator.addSubview(subview)
                }
            }
            delegate?.pageControl?(self, willDisplay: indicator, forPageAt: tag)
        }
        
        for subview in stackView.arrangedSubviews.filter({ $0.isHidden == false }) {
            subview.backgroundColor = subview.tag == currentPageIndex ? currentPageIndicatorTintColor : pageIndicatorTintColor
        }
        
        updateStackView()
    }
    
    /// 显示/隐藏StackView
    private func updateStackView() {
        let arrangedSubviews = stackView.arrangedSubviews.filter { $0.isHidden == false }
        switch arrangedSubviews.count {
        case 0:
            stackView.isHidden = true
        case 1:
            stackView.isHidden = hidesForSinglePage
        default:
            stackView.isHidden = false
        }
    }
}

// MARK: - Touch
extension MNPageControl {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        update(touches: touches, with: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        update(touches: touches, with: event)
    }
    
    private func update(touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        for indicator in stackView.arrangedSubviews.filter({ $0.isHidden == false }).reversed() {
            let rect = stackView.convert(indicator.frame, to: self)
            guard rect.inset(by: pageIndicatorTouchInset).contains(location) else { continue }
            if indicator.tag == currentPageIndex { break }
            currentPageIndex = indicator.tag
            sendActions(for: .valueChanged)
            delegate?.pageControl?(self, didSelectPageAt: currentPageIndex)
            break
        }
    }
}

/// 页码指示器
fileprivate class MNPageIndicator: UIView {
    
    override func layoutSubviews() {
        for subview in subviews {
            subview.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        layer.cornerRadius = min(frame.width, frame.height)/2.0
    }
}
