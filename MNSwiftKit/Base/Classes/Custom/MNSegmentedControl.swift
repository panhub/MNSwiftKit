//
//  MNSegmentedControl.swift
//  anhe
//
//  Created by 冯盼 on 2022/11/29.
//  分段按钮

import UIKit

public class MNSegmentedControl: UIControl {
    /// 滑块
    private let segment: UIView = UIView()
    /// 内容视图
    private let contentView: UIView = UIView()
    /// 是否在动画中
    private var isAnimating: Bool = false
    /// 在动画之前回调触发事件
    @objc public var sendActionWhenPreferBeforeAnimation: Bool = false
    /// 标题集合
    private var items: [UILabel] = [UILabel]()
    /// 标题设置
    private var attributes: [UInt:[NSAttributedString.Key : Any]] = [UInt:[NSAttributedString.Key : Any]]()
    /// 当前选择
    private var segmentIndexRawValue: Int = 0
    @objc public var selectedSegmentIndex: Int {
        get { segmentIndexRawValue }
        set {
            guard isAnimating == false, newValue != segmentIndexRawValue else { return }
            segmentIndexRawValue = newValue
            updateSegmentIndex(newValue)
        }
    }
    /// 边角大小
    @objc public var segmentRadius: CGFloat {
        get { segment.layer.cornerRadius }
        set { segment.layer.cornerRadius = newValue }
    }
    /// 滑块颜色
    @objc public var segmentColor: UIColor? {
        get { segment.backgroundColor }
        set { segment.backgroundColor = newValue }
    }
    /// 内容约束
    @objc public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0) {
        didSet {
            setNeedsLayout()
        }
    }
    /// 滑块高度
    @objc public var segmentHeight: CGFloat = 35.0 {
        didSet {
            setNeedsLayout()
        }
    }
    /// 间隔
    @objc public var itemSpacing: CGFloat = 18.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init(items: [String]) {
        super.init(frame: .zero)
        
        clipsToBounds = true
        layer.cornerRadius = 5.0
        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        
        segment.clipsToBounds = true
        segment.backgroundColor = .white
        segment.isUserInteractionEnabled = false
        segment.layer.cornerRadius = layer.cornerRadius
        contentView.addSubview(segment)
        
        for item in items {
            let label = UILabel()
            label.text = item
            label.numberOfLines = 1
            label.textAlignment = .center
            label.isUserInteractionEnabled = false
            contentView.addSubview(label)
            self.items.append(label)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitleTextAttributes(_ attributes: [NSAttributedString.Key : Any]?, for state: UIControl.State) {
        self.attributes[state.rawValue] = attributes
        setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var normalFont: UIFont!
        var normalColor: UIColor!
        if let attributes = attributes[UIControl.State.normal.rawValue] {
            normalColor = (attributes[.foregroundColor] as? UIColor) ?? .gray
            normalFont = (attributes[.font] as? UIFont) ?? .systemFont(ofSize: 15.0, weight: .medium)
        }
        var selectedFont: UIFont!
        var selectedColor: UIColor!
        if let attributes = attributes[UIControl.State.selected.rawValue] {
            selectedColor = (attributes[.foregroundColor] as? UIColor) ?? .black
            selectedFont = (attributes[.font] as? UIFont) ?? .systemFont(ofSize: 15.0, weight: .medium)
        }
        var x: CGFloat = contentInset.left
        let font: UIFont = normalFont.pointSize >= selectedFont.pointSize ? normalFont : selectedFont
        for (index, item) in items.enumerated() {
            item.font = font
            item.sizeToFit()
            item.frame = CGRect(x: x, y: contentInset.top, width: ceil(item.frame.width) + itemSpacing, height: segmentHeight)
            item.font = index == selectedSegmentIndex ? selectedFont : normalFont
            item.textColor = index == selectedSegmentIndex ? selectedColor : normalColor
            x = item.frame.maxX
        }
        
        let width: CGFloat = (items.reduce(0.0) { $0 + $1.frame.width }) + contentInset.left + contentInset.right
        let height: CGFloat = segmentHeight + contentInset.top + contentInset.bottom
        size = CGSize(width: width, height: height)
        
        segment.frame = items[selectedSegmentIndex].frame
    }
    
    /// 设置当前选择项
    /// - Parameters:
    ///   - selectedIndex: 选择索引
    ///   - animated: 是否动态显示
    @objc public func setSegmentIndex(_ selectedIndex: Int, animated: Bool) {
        setSegmentIndex(selectedIndex, animated: animated, touched: false)
    }
    
    /// 设置当前选择项
    /// - Parameters:
    ///   - selectedIndex: 选择索引
    ///   - animated: 是否动态显示
    ///   - touched: 是否点击触发
    private func setSegmentIndex(_ selectedIndex: Int, animated: Bool, touched: Bool) {
        guard isAnimating == false, segmentIndexRawValue != selectedIndex else { return }
        segmentIndexRawValue = selectedIndex
        if animated {
            isAnimating = true
            if touched {
                self.sendActions(for: .valueChanged)
            }
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
                guard let self = self else { return }
                self.updateSegmentIndex(selectedIndex)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.isAnimating = false
            }
        } else {
            updateSegmentIndex(selectedIndex)
        }
    }
    
    private func updateSegmentIndex(_ selectedIndex: Int) {
        var normalFont: UIFont!
        var normalColor: UIColor!
        if let attributes = attributes[UIControl.State.normal.rawValue] {
            normalColor = (attributes[.foregroundColor] as? UIColor) ?? .gray
            normalFont = (attributes[.font] as? UIFont) ?? .systemFont(ofSize: 15.0, weight: .medium)
        }
        var selectedFont: UIFont!
        var selectedColor: UIColor!
        if let attributes = attributes[UIControl.State.selected.rawValue] {
            selectedColor = (attributes[.foregroundColor] as? UIColor) ?? .black
            selectedFont = (attributes[.font] as? UIFont) ?? .systemFont(ofSize: 15.0, weight: .medium)
        }
        for (index, item) in items.enumerated() {
            item.font = index == selectedIndex ? selectedFont : normalFont
            item.textColor = index == selectedIndex ? selectedColor : normalColor
        }
        segment.frame = items[selectedIndex].frame
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let event = event, event.type == .touches else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        for (index, item) in items.enumerated() {
            let rect = item.frame.inset(by: UIEdgeInsets(top: -contentInset.top, left: 0.0, bottom: -contentInset.bottom, right: 0.0))
            guard rect.contains(location) else { continue }
            setSegmentIndex(index, animated: true, touched: true)
            break
        }
    }
}
