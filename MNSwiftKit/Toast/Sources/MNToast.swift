//
//  MNToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  弹窗定义

import UIKit
import ObjectiveC.runtime

@objc public protocol MNToastBuilder: NSObjectProtocol {
    
    /// 内容视图颜色
    /// - Returns: 颜色
    func contentColorForToast() -> ToastColor
    
    /// 内容视图出现的位置
    /// - Returns: 相对于自身位置
    func positionForToast() -> ToastPosition
    
    /// 内容视图文字/指示图四周约束
    /// - Returns: 四周约束
    func contentInsetForToast() -> UIEdgeInsets
    
    /// 内容视图控件间隔
    /// - Returns: 控件间隔
    func spacingForToast() -> CGFloat
    
    /// 询问内容视图中指示图
    /// - Returns: 指示图
    func activityViewForToast() -> UIView?
    
    /// 询问内容视图中文本描述
    /// - Returns: 文本描述
    func attributesForToastDescription() -> [NSAttributedString.Key:Any]
    
    /// 询问是否支持用户点击事件 不支持则屏蔽父视图事件 反之相反
    /// - Returns: 是否支持用户点击事件
    @objc optional func supportedUserInteraction() -> Bool
    
    /// 询问是否适应键盘事件
    /// - Returns: 是否适应键盘事件
    @objc optional func supportedAdjustsKeyboard() -> Bool
    
    /// 内容视图与键盘间隔
    /// - Returns: 间隔
    @objc optional func spacingForKeyboard() -> CGFloat
    
    /// 询问内容视图相对于位置的偏移量
    /// - Returns: 相对于位置的偏移量
    @objc optional func offsetYForToast() -> CGFloat
    
    /// 询问内容视图控件排列方向
    /// - Returns: 控件排列方向
    @objc optional func distributionForToastActivity() -> ToastDistribution
    
    /// 显现动画
    /// - Returns: 动画类型
    @objc optional func animationForToastShow() -> ToastAnimation
    
    /// 消失动画
    /// - Returns: 动画类型
    @objc optional func animationForToastDismiss() -> ToastAnimation
    
    /// 出现告知
    /// - Parameter toast: 提示弹窗
    @objc optional func toastDidAppear(_ toast: MNToast) -> Void
    
    /// 消失事件告知
    /// - Parameter toast: 提示弹窗
    @objc optional func toastDidDisappear(_ toast: MNToast) -> Void
    
    /// 文字变化告知
    /// - Parameter toast: 提示弹窗
    @objc optional func toastDidUpdateStatus(_ toast: MNToast) -> Void
    
    /// 进度变化告知
    /// - Parameters:
    ///   - toast: 提示弹窗
    ///   - progress: 进度值
    @objc optional func toast(_ toast: MNToast, update progress: Double) -> Void
}

/// 颜色样式
@objc public enum ToastColor: Int {
    ///   暗色  亮色 无颜色
    case dark, gray, clear
}

/// 显示的位置
@objc public enum ToastPosition: Int {
    case top, center, bottom
}

/// 动画类型
@objc public enum ToastAnimation: Int {
    case none, fade, move
}

/// 活动视图方位
@objc public enum ToastDistribution: Int {
    case top, bottom
}


/// 提示弹窗
public class MNToast: UIView {
    
    /// 内容提供者
    private let builder: MNToastBuilder
    
    /// 消失后回调
    public var dismissHandler: (()->Void)?
    
    /// 提示信息
    private let textLabel: UILabel = UILabel()
    
    /// 约束指示图与提示信息(纵向布局)
    private let stackView: UIStackView = UIStackView()
    
    /// 显示的内容(横向布局)
    private let contentView: UIStackView = UIStackView()
    
    /// 记录键盘位置
    private var keyboardFrame: CGRect = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: UIScreen.main.bounds.height, left: 0.0, bottom: 0.0, right: 0.0))
    
    /// 纵向中心约束
    private lazy var verticalLayout: NSLayoutConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    
    /// 文本内容
    public var text: String? {
        get {
            textLabel.attributedText?.string
        }
        set {
            if let newValue = newValue {
                textLabel.isHidden = false
                textLabel.attributedText = NSAttributedString(string: newValue, attributes: builder.attributesForToastDescription())
            } else {
                textLabel.isHidden = true
                textLabel.attributedText = nil
            }
            builder.toastDidUpdateStatus?(self)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(builder: MNToastBuilder) {
        self.builder = builder
        super.init(frame: .zero)
        
        contentView.spacing = 0.0
        contentView.axis = .horizontal
        contentView.alignment = .center
        contentView.distribution = .equalSpacing
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8.0
        contentView.isUserInteractionEnabled = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        addConstraints([verticalLayout, NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)])
        
        let edgeInset = builder.contentInsetForToast()
        
        let left = UIView()
        left.translatesAutoresizingMaskIntoConstraints = false
        contentView.addArrangedSubview(left)
        contentView.addConstraint(NSLayoutConstraint(item: left, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0))
        left.addConstraint(NSLayoutConstraint(item: left, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: edgeInset.left))
        
        /// 添加指示图
        stackView.spacing = 0.0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        contentView.addArrangedSubview(stackView)
        
        let right = UIView()
        right.translatesAutoresizingMaskIntoConstraints = false
        contentView.addArrangedSubview(right)
        contentView.addConstraint(NSLayoutConstraint(item: right, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0))
        right.addConstraint(NSLayoutConstraint(item: right, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: edgeInset.right))
        
        let top = UIView()
        top.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(top)
        stackView.addConstraint(NSLayoutConstraint(item: top, attribute: .width, relatedBy: .equal, toItem: stackView, attribute: .width, multiplier: 1.0, constant: 0.0))
        top.addConstraint(NSLayoutConstraint(item: top, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: edgeInset.top))
        
        if let activityView = builder.activityViewForToast() {
            // 活动指示图
            activityView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(activityView)
            activityView.addConstraints([NSLayoutConstraint(item: activityView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: activityView.frame.width), NSLayoutConstraint(item: activityView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: activityView.frame.height)])
            // 间隔
            let spacing = builder.spacingForToast()
            if spacing > 0.0 {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(spacer)
                stackView.addConstraint(NSLayoutConstraint(item: spacer, attribute: .width, relatedBy: .equal, toItem: stackView, attribute: .width, multiplier: 1.0, constant: 0.0))
                spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spacing))
            }
        }
        
        textLabel.isHidden = true
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        if let distribution = builder.distributionForToastActivity?(), distribution == .bottom {
            stackView.insertArrangedSubview(textLabel, at: 1)
        } else {
            stackView.addArrangedSubview(textLabel)
        }
        textLabel.addConstraint(NSLayoutConstraint(item: textLabel, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 175.0))
        
        let bottom = UIView()
        bottom.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(bottom)
        stackView.addConstraint(NSLayoutConstraint(item: bottom, attribute: .width, relatedBy: .equal, toItem: stackView, attribute: .width, multiplier: 1.0, constant: 0.0))
        bottom.addConstraint(NSLayoutConstraint(item: bottom, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: edgeInset.bottom))
        
        /// 添加颜色视图
        switch builder.contentColorForToast() {
        case .dark:
            let effect = UIBlurEffect(style: .dark)
            let visualView = UIVisualEffectView(effect: effect)
            visualView.frame = contentView.bounds
            visualView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.insertSubview(visualView, at: 0)
        case .gray:
            let visualView = UIView(frame: contentView.bounds)
            visualView.backgroundColor = UIColor(white: 0.0, alpha: 0.12)
            visualView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.insertSubview(visualView, at: 0)
            contentView.backgroundColor = .white
        default: break
        }
        
        // 交互
        if let userInteractionEnabled = builder.supportedUserInteraction?(), userInteractionEnabled == true {
            isUserInteractionEnabled = false
        }
        
        // 键盘变化告知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateProgress(_ progress: Double) {
        builder.toast?(self, update: progress)
    }
    
    /// 关联弹窗
    open override func willMove(toSuperview newSuperview: UIView?) {
        if let superview = newSuperview {
            superview.toast = self
        } else if let superview = superview {
            superview.toast = nil
        }
        super.willMove(toSuperview: newSuperview)
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let _ = window else { return }
        applyToKeyboard()
    }
    
    /// 拒绝事件响应
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}

// MARK: - 显示
extension MNToast {
    
    /// 加载弹窗
    /// - Parameters:
    ///   - superview: 父视图
    ///   - handler: 消失回调
    public func show(in superview: UIView! = MNToast.window, dismiss handler: (()->Void)? = nil) {
        guard let superview = superview else { return }
        dismissHandler = handler
        translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        superview.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: superview, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: superview, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        layoutIfNeeded()
        let animation = builder.animationForToastShow?() ?? .none
        show(animation: animation)
    }
    
    private func show(animation: ToastAnimation) {
        switch animation {
        case .none:
            applyToKeyboard()
            builder.toastDidAppear?(self)
            builder.toastDidUpdateStatus?(self)
        case .fade:
            applyToKeyboard()
            contentView.alpha = 0.0
            contentView.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 1.0
                self.contentView.transform = .identity
            } completion: { [weak self] finish in
                guard let self = self else { return }
                self.builder.toastDidAppear?(self)
                self.builder.toastDidUpdateStatus?(self)
            }
        case .move:
            switch builder.positionForToast() {
            case .top:
                verticalLayout.constant = -frame.height/2.0 - contentView.frame.height/2.0
            case .center:
                verticalLayout.constant = 0.0
            case .bottom:
                verticalLayout.constant = frame.height/2.0 + contentView.frame.height/2.0
            }
            layoutIfNeeded()
            contentView.alpha = 0.0
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 1.0
            }
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) { [weak self] in
                guard let self = self else { return }
                self.applyToKeyboard()
                self.layoutIfNeeded()
            } completion: { [weak self] finish in
                guard let self = self else { return }
                self.builder.toastDidAppear?(self)
                self.builder.toastDidUpdateStatus?(self)
            }
        }
    }
    
    func dismiss(animation: ToastAnimation) {
        switch animation {
        case .none:
            removeFromSuperview()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.builder.toastDidDisappear?(self)
                self.dismissHandler?()
            }
        case .fade:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 0.0
                self.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } completion: { [weak self] finish in
                guard let self = self else { return }
                self.removeFromSuperview()
                self.builder.toastDidDisappear?(self)
                self.dismissHandler?()
            }
        case .move:
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 0.0
                switch self.builder.positionForToast() {
                case .top:
                    self.verticalLayout.constant = -self.frame.height/2.0 - self.contentView.frame.height/2.0
                case .center, .bottom:
                    self.verticalLayout.constant = (self.frame.height + self.contentView.frame.height)/2.0
                }
                self.layoutIfNeeded()
            } completion: { [weak self] finish in
                guard let self = self else { return }
                self.removeFromSuperview()
                self.builder.toastDidDisappear?(self)
                self.dismissHandler?()
            }
        }
    }
    
    @objc func close() {
        let animation = builder.animationForToastDismiss?() ?? .none
        dismiss(animation: animation)
    }
}

// MARK: - Helper
extension MNToast {
    
    private func constantForPosition() -> CGFloat {
        var constant: CGFloat = 0.0
        switch builder.positionForToast() {
        case .top:
            constant = contentView.bounds.midY - bounds.midY
        case .center:
            constant = 0.0
        case .bottom:
            constant = bounds.midY - contentView.bounds.midY
        }
        return constant
    }
    
    private func constantForNormal() -> CGFloat {
        var constant = constantForPosition()
        let offsetY = builder.offsetYForToast?() ?? 0.0
        constant += offsetY
        return constant
    }
    
    private func applyToKeyboard() {
        // 原本位置
        let constant = constantForNormal()
        // 与键盘间隔
        let spacing = keyboardFrame.minY < UIScreen.main.bounds.height ? (builder.spacingForKeyboard?() ?? 0.0) : 0.0
        // 内容视图位置
        let point = CGPoint(x: keyboardFrame.midX, y: keyboardFrame.minY - spacing - contentView.bounds.midY)
        // 转换到自身坐标系
        let center = convert(point, from: nil)
        // 与中心点间隔
        let margin = center.y - bounds.midY
        verticalLayout.constant = min(margin, constant)
        layoutIfNeeded()
    }
    
    public class func duration(with description: String?) -> TimeInterval {
        max(TimeInterval(description?.count ?? 0)*0.06 + 0.5, 1.5)
    }
}

// MARK: - 键盘变化通知
extension MNToast {
    
    /// 键盘变化通知
    /// - Parameter notify: 通知
    @objc private func keyboardWillChangeFrame(_ notify: Notification) {
        guard let isAdjustsKeyboard = builder.supportedAdjustsKeyboard?(), isAdjustsKeyboard == true else { return }
        guard let userInfo = notify.userInfo else { return }
        guard let rect = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardFrame = rect
        guard let _ = window else { return }
        applyToKeyboard()
    }
}
