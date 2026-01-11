//
//  MNSwitch.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/8/28.
//  开关

import UIKit

/// 开关代理
@objc public protocol MNSwitchDelegate: NSObjectProtocol {
    
    /// 是否允许改变
    /// - Parameter switch: 开关
    /// - Returns: 是否允许改变
    @objc optional func switchShouldChangeValue(_ switch: MNSwitch) -> Bool
    
    /// 开关值变化告知
    /// - Parameter switch: 开关
    @objc optional func switchValueChanged(_ switch: MNSwitch)
}

/// 开关
@IBDesignable public class MNSwitch: UIControl {
    /// 内部使用
    private let spacing: CGFloat = 2.0
    /// 滑块
    private let thumb = UIView()
    /// 内容视图
    private let contentView = UIView()
    /// 标记动画期间 拒绝交互
    private var isAnimating: Bool = false
    /// 事件代理
    public weak var delegate: MNSwitchDelegate?
    /// 默认颜色
    private let contentColor: UIColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0)
    /// 打开时的颜色
    @IBInspectable public var onTintColor: UIColor = UIColor(red: 103.0/255.0, green: 196.0/255.0, blue: 98.0/255.0, alpha: 1.0) {
        didSet {
            updateContentColor()
        }
    }
    /// 滑块颜色
    @IBInspectable public var thumbTintColor: UIColor? {
        get { thumb.backgroundColor }
        set { thumb.backgroundColor = newValue ?? .white }
    }
    /// 正常状态下颜色
    public override var tintColor: UIColor! {
        didSet {
            updateContentColor()
        }
    }
    /// 是否处于开启状态
    public var isOn: Bool {
        set {
            setOn(newValue, animated: false)
        }
        get {
            guard let constraint = contentView.constraints.first(where: { constraint in
                guard let firstItem = constraint.firstItem as? UIView, firstItem == thumb else { return false }
                guard constraint.firstAttribute == .left else { return false }
                return true
            }) else { return false }
            return constraint.constant > spacing
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        thumb.clipsToBounds = true
        thumb.backgroundColor = .white
        thumb.isUserInteractionEnabled = false
        thumb.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumb)
        NSLayoutConstraint.activate([
            thumb.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            thumb.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: spacing),
            thumb.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
            thumb.widthAnchor.constraint(equalTo: thumb.heightAnchor, multiplier: 1.0)
        ])
        
        updateContentColor()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded()
        thumb.layer.cornerRadius = min(thumb.bounds.width, thumb.bounds.height)/2.0
        contentView.layer.cornerRadius = min(contentView.bounds.width, contentView.bounds.height)/2.0
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setOn(isOn == false, animated: true, interactive: true)
    }
    
    /// 修改Switch的状态
    /// - Parameters:
    ///   - on: 是否开启
    ///   - isAnimated: 是否动画
    public func setOn(_ on: Bool, animated isAnimated: Bool) {
        
        setOn(on, animated: isAnimated, interactive: false)
    }
    
    /// 修改Switch的状态
    /// - Parameters:
    ///   - on: 是否开启
    ///   - isAnimated: 是否动画
    ///   - isInteractive: 是否是由交互触发
    private func setOn(_ on: Bool, animated isAnimated: Bool, interactive isInteractive: Bool) {
        guard isAnimating == false, isOn != on else { return }
        var isAllowChangeValue: Bool = true
        if isInteractive, let delegate = delegate, let shouldChangeValue = delegate.switchShouldChangeValue?(self), shouldChangeValue == false {
            isAllowChangeValue = false
        }
        guard isAllowChangeValue else { return }
        if isAnimated {
            isAnimating = true
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut]) { [weak self] in
                guard let self = self else { return }
                self.update(on: on)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.isAnimating = false
                guard isInteractive else { return }
                self.sendActions(for: .valueChanged)
                guard let delegate = self.delegate else { return }
                delegate.switchValueChanged?(self)
            }
        } else {
            update(on: on)
        }
    }
    
    /// 更新UI
    /// - Parameter isOn: 是否开启状态
    private func update(on isOn: Bool) {
        guard let constraint = contentView.constraints.first(where: { constraint in
            guard let firstItem = constraint.firstItem as? UIView, firstItem == thumb else { return false }
            guard constraint.firstAttribute == .left else { return false }
            return true
        }) else { return }
        constraint.constant = isOn ? (bounds.width - spacing - thumb.bounds.width) : spacing
        contentView.layoutIfNeeded()
        updateContentColor()
    }
    
    /// 更新背景颜色
    private func updateContentColor() {
        
        contentView.backgroundColor = isOn ? onTintColor : (tintColor ?? contentColor)
    }
}
