//
//  MNPageControl.swift
//  MNTest
//
//  Created by panhub on 2022/9/27.
//  简单页码指示器

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
    @objc optional func pageControl(_ pageControl: MNPageControl, didSelectPageAt index: Int)
    /// 告知即将展示指示器
    /// - Parameters:
    ///   - pageControl: 指示器
    ///   - indicator: 指示器视图
    ///   - index: 页码索引
    @objc optional func pageControl(_ pageControl: MNPageControl, willDisplay indicator: UIView, forPageAt index: Int)
}

/// 页码指示器
public class MNPageControl: UIControl {
    
    /// 指示器缓存
    private var indicators: [UIView] = []
    
    /// 内部约束视图
    private let stackView: UIStackView = UIStackView()
    
    /// 事件代理
    public weak var delegate: MNPageControlDelegate?
    
    /// 数据源代理
    public weak var dataSource: MNPageControlDataSource?
    
    /// 指示器触摸区域
    public var pageIndicatorTouchInset: UIEdgeInsets = .zero
    
    /// 布局方向
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set {
            stackView.axis = newValue
            guard let _ = superview else { return }
            setNeedsUpdateConstraints()
        }
    }
    
    /// 页码间隔
    public var spacing: CGFloat {
        get { stackView.spacing }
        set {
            stackView.spacing = newValue
            guard let _ = superview else { return }
            setNeedsUpdateConstraints()
        }
    }
    
    /// 页码数量 代理优先
    public var numberOfPages: Int = 0 {
        didSet {
            guard let _ = superview else { return }
            reloadPageIndicators()
        }
    }
    
    /// 当前选中的页码索引
    public var currentPageIndex: Int = 0 {
        didSet {
            let arrangedSubviews = stackView.arrangedSubviews
            if oldValue < arrangedSubviews.count {
                let indicator = arrangedSubviews[oldValue]
                indicator.backgroundColor = pageIndicatorTintColor
                indicator.layer.borderWidth = pageIndicatorBorderWidth
                indicator.layer.borderColor = pageIndicatorBorderColor?.cgColor
            }
            if currentPageIndex < arrangedSubviews.count {
                let indicator = arrangedSubviews[currentPageIndex]
                indicator.backgroundColor = currentPageIndicatorTintColor
                indicator.layer.borderWidth = currentPageIndicatorBorderWidth
                indicator.layer.borderColor = currentPageIndicatorBorderColor?.cgColor
            }
        }
    }
    
    /// 当只有一页时是否隐藏
    public var hidesForSinglePage: Bool = false {
        didSet {
            updateStackView()
        }
    }
    
    ///页码指示器大小
    public var pageIndicatorSize: CGSize = .init(width: 8.0, height: 8.0) {
        didSet {
            for arrangedSubview in stackView.arrangedSubviews {
                arrangedSubview.layer.cornerRadius = axis == .horizontal ? pageIndicatorSize.height/2.0 : pageIndicatorSize.width/2.0
            }
            guard let _ = superview else { return }
            setNeedsUpdateConstraints()
        }
    }
    
    /// 指示器颜色
    public var pageIndicatorTintColor: UIColor? = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0) {
        didSet {
            let arrangedSubviews = stackView.arrangedSubviews
            for (index, arrangedSubview) in arrangedSubviews.enumerated() {
                if index == currentPageIndex { continue }
                arrangedSubview.backgroundColor = pageIndicatorTintColor
            }
        }
    }
    
    /// 当前指示器颜色
    public var currentPageIndicatorTintColor: UIColor? = UIColor(red: 125.0/255.0, green: 125.0/255.0, blue: 125.0/255.0, alpha: 1.0) {
        didSet {
            let arrangedSubviews = stackView.arrangedSubviews
            guard currentPageIndex < arrangedSubviews.count else { return }
            let indicator = arrangedSubviews[currentPageIndex]
            indicator.backgroundColor = currentPageIndicatorTintColor
        }
    }
    
    /// 指示器边框宽度
    public var pageIndicatorBorderWidth: CGFloat = 0.0 {
        didSet {
            let arrangedSubviews = stackView.arrangedSubviews
            for (index, arrangedSubview) in arrangedSubviews.enumerated() {
                if index == currentPageIndex { continue }
                arrangedSubview.layer.borderWidth = pageIndicatorBorderWidth
            }
        }
    }
    
    /// 当前指示器边框宽度
    public var currentPageIndicatorBorderWidth: CGFloat = 0.0 {
        didSet {
            let arrangedSubviews = stackView.arrangedSubviews
            guard currentPageIndex < arrangedSubviews.count else { return }
            let indicator = arrangedSubviews[currentPageIndex]
            indicator.layer.borderWidth = currentPageIndicatorBorderWidth
        }
    }
    
    /// 指示器边框颜色
    public var pageIndicatorBorderColor: UIColor? {
        didSet {
            let arrangedSubviews = stackView.arrangedSubviews
            for (index, arrangedSubview) in arrangedSubviews.enumerated() {
                if index == currentPageIndex { continue }
                arrangedSubview.layer.borderColor = pageIndicatorBorderColor?.cgColor
            }
        }
    }
    
    /// 当前指示器边框颜色
    public var currentPageIndicatorBorderColor: UIColor? {
        didSet {
            let arrangedSubviews = stackView.arrangedSubviews
            guard currentPageIndex < arrangedSubviews.count else { return }
            let indicator = arrangedSubviews[currentPageIndex]
            indicator.layer.borderColor = currentPageIndicatorBorderColor?.cgColor
        }
    }
    
    public override var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        get { super.contentVerticalAlignment }
        set {
            super.contentVerticalAlignment = newValue
            guard let _ = superview else { return }
            setNeedsUpdateConstraints()
        }
    }
    
    public override var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        get { super.contentHorizontalAlignment }
        set {
            super.contentHorizontalAlignment = newValue
            guard let _ = superview else { return }
            setNeedsUpdateConstraints()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.isHidden = true
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else { return }
        reloadPageIndicators()
    }
    
    public override func updateConstraints() {
        // 删除指示器宽高约束
        for arrangedSubview in stackView.arrangedSubviews {
            NSLayoutConstraint.deactivate(arrangedSubview.constraints.filter({ constraint in
                guard constraint.firstAttribute == .width || constraint.firstAttribute == .height else { return false }
                return true
            }))
        }
        // 删除stackView的布局约束
        NSLayoutConstraint.deactivate(stackView.constraints.filter({ constraint in
            guard constraint.firstAttribute == .width || constraint.firstAttribute == .height else { return false }
            return true
        }))
        NSLayoutConstraint.deactivate(constraints.filter({ constraint in
            guard let firstItem = constraint.firstItem, firstItem is UIStackView else { return false }
            return true
        }))
        // 更新指示器约束
        for arrangedSubview in stackView.arrangedSubviews {
            NSLayoutConstraint.activate([
                arrangedSubview.widthAnchor.constraint(equalToConstant: pageIndicatorSize.width),
                arrangedSubview.heightAnchor.constraint(equalToConstant: pageIndicatorSize.height)
            ])
        }
        var constraints: [NSLayoutConstraint] = []
        let numberOfPages = stackView.arrangedSubviews.count
        if axis == .horizontal {
            // 横向布局
            let width = pageIndicatorSize.width*CGFloat(numberOfPages) + spacing*CGFloat(max(0, numberOfPages - 1))
            constraints.append(stackView.widthAnchor.constraint(equalToConstant: width))
            constraints.append(stackView.heightAnchor.constraint(equalToConstant: pageIndicatorSize.height))
        } else {
            // 纵向布局
            constraints.append(stackView.widthAnchor.constraint(equalToConstant: pageIndicatorSize.width))
            let height = pageIndicatorSize.height*CGFloat(numberOfPages) + spacing*CGFloat(max(0, numberOfPages - 1))
            constraints.append(stackView.heightAnchor.constraint(equalToConstant: height))
        }
        switch contentHorizontalAlignment {
        case .left:
            constraints.append(stackView.leftAnchor.constraint(equalTo: leftAnchor))
        case .right:
            constraints.append(stackView.rightAnchor.constraint(equalTo: rightAnchor))
        case .leading:
            constraints.append(stackView.leadingAnchor.constraint(equalTo: leadingAnchor))
        case .trailing:
            constraints.append(stackView.trailingAnchor.constraint(equalTo: trailingAnchor))
        default:
            constraints.append(stackView.centerXAnchor.constraint(equalTo: centerXAnchor))
        }
        switch contentVerticalAlignment {
        case .top:
            constraints.append(stackView.topAnchor.constraint(equalTo: topAnchor))
        case .bottom:
            constraints.append(stackView.bottomAnchor.constraint(equalTo: bottomAnchor))
        default:
            constraints.append(stackView.centerYAnchor.constraint(equalTo: centerYAnchor))
        }
        NSLayoutConstraint.activate(constraints)
        super.updateConstraints()
    }
}

// MARK: - Update
extension MNPageControl {
    
    /// 刷新指示器
    public func reloadPageIndicators() {
        
        // 删除指示器
        for arrangedSubview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
            indicators.append(arrangedSubview)
        }
        
        // 获取指示器数量
        var numberOfPages: Int = max(numberOfPages, 0)
        if let dataSource = dataSource, let count = dataSource.numberOfPageIndicator?(in: self) {
            numberOfPages = max(0, count)
        }
        
        if numberOfPages > 0 {
            // 添加指示器
            for index in 0..<numberOfPages {
                var indicator: UIView!
                if let dataSource = dataSource, let view = dataSource.pageControl?(self, viewForPageIndicator: index) {
                    indicator = view
                    indicators.removeAll { $0 == view }
                } else {
                    indicator = UIView()
                }
                if let delegate = delegate {
                    delegate.pageControl?(self, willDisplay: indicator, forPageAt: index)
                }
                if axis == .horizontal {
                    indicator.layer.cornerRadius = pageIndicatorSize.height/2.0
                } else {
                    indicator.layer.cornerRadius = pageIndicatorSize.width/2.0
                }
                indicator.clipsToBounds = true
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.backgroundColor = index == currentPageIndex ? currentPageIndicatorTintColor : pageIndicatorTintColor
                indicator.layer.borderWidth = index == currentPageIndex ? currentPageIndicatorBorderWidth : pageIndicatorBorderWidth
                indicator.layer.borderColor = index == currentPageIndex ? currentPageIndicatorBorderColor?.cgColor : pageIndicatorBorderColor?.cgColor
                stackView.addArrangedSubview(indicator)
            }
        }
        
        if currentPageIndex >= numberOfPages {
            currentPageIndex = max(0, numberOfPages - 1)
        }
        updateStackView()
        setNeedsUpdateConstraints()
    }
    
    
    /// 取出可用的指示器缓存
    /// - Returns: 缓存
    public func dequeueReusableIndicator() -> UIView? {
        indicators.first
    }
    
    /// 显示/隐藏StackView
    private func updateStackView() {
        switch stackView.arrangedSubviews.count {
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
        guard stackView.isHidden == false else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        for (index, indicator) in stackView.arrangedSubviews.enumerated() {
            let rect = stackView.convert(indicator.frame, to: self)
            guard rect.inset(by: pageIndicatorTouchInset).contains(location) else { continue }
            if index == currentPageIndex { break }
            currentPageIndex = index
            sendActions(for: .valueChanged)
            if let delegate = delegate {
                delegate.pageControl?(self, didSelectPageAt: index)
            }
            break
        }
    }
}
