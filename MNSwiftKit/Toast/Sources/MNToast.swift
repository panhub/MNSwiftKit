//
//  MNToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  弹窗定义

import UIKit
import ObjectiveC.runtime

public protocol MNToastBuilder {
    
    /// Toast布局方向
    var axisForToast: MNToast.Axis { get }
    
    /// Toast颜色样式
    var colorForToast: MNToast.Color { get }
    
    /// Toast内容四周约束
    var contentInsetForToast: UIEdgeInsets { get }
    
    /// Toast指示视图
    var activityViewForToast: UIView? { get }
    
    /// Toast显示时是否拒绝交互事件
    var userInteractionEnabledForToast: Bool { get }
    
    /// Toast显示的位置
    var positionForToast: MNToast.Position { get }
    
    /// Toast渐入式显示
    var fadeInForToast: Bool { get }
    
    /// Toast渐隐式取消
    var fadeOutForToast: Bool { get }
    
    /// Toast中文字的富文本描述
    var attributesForToastDescription: [NSAttributedString.Key:Any] { get }
    
    /// Toast出现告知
    /// - Parameter toast: 提示弹窗
    func toastDidAppear(_ toast: MNToast)
}

public protocol MNToastProgressUpdater where Self: MNToastBuilder {
    
    /// 更新进度值
    /// - Parameter progress: 进度值
    func toastShouldUpdate(progress: CGFloat)
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
    
    /// 布局方向
    public enum Axis {
        /// 纵向
        case vertical(spacing: CGFloat)
        /// 横向
        case horizontal(spacing: CGFloat)
    }
    
    /// 颜色
    public enum Color {
        ///   暗色
        case dark
        ///   亮色
        case light
        ///   无颜色
        case clear
    }
    
    /// 显示的位置
    public enum Position {
        /// 距离顶部一定距离的位置
        case top(distance: CGFloat)
        /// 中间显示
        case center
        /// 距离底部一定距离的位置
        case bottom(distance: CGFloat)
    }
    
    /// 动画类型
    public enum Animation {
        /// 不使用动画
        case none
        /// 渐入渐出
        case fade
        /// 移动
        case move
    }
    
    /// 定时器
    private var timer: Timer!
    
    /// 内容提供者
    private let builder: MNToastBuilder
    
    /// 消失后回调
    public var dismissHandler: (()->Void)?
    
    /// 状态信息
    private let statusLabel = UILabel()
    
    /// 内容视图
    private let contentView = UIView()
    
    /// 约束指示图与提示信息(纵向布局)
    private let stackView = UIStackView()
    
    /// 记录键盘位置
    private var keyboardFrame: CGRect = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: UIScreen.main.bounds.height, left: 0.0, bottom: 0.0, right: 0.0))
    
    /// 纵向中心约束
    private lazy var verticalLayout: NSLayoutConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(builder: MNToastBuilder) {
        self.builder = builder
        super.init(frame: .zero)
        
        switch builder.colorForToast {
        case .dark:
            contentView.backgroundColor = UIColor(white: 0.05, alpha: 1.0)
        case .light:
            contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        case .clear:
            contentView.backgroundColor = .clear
        }
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8.0
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([contentView.centerXAnchor.constraint(equalTo: centerXAnchor)])
        switch builder.positionForToast {
        case .top(let distance):
            NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalTo: topAnchor, constant: distance)])
        case .center:
            NSLayoutConstraint.activate([contentView.centerYAnchor.constraint(equalTo: centerYAnchor)])
        case .bottom(let distance):
            NSLayoutConstraint.activate([contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -distance)])
        }
        
        /// 布局视图
        switch builder.axisForToast {
        case .vertical(let spacing):
            stackView.axis = .vertical
            stackView.spacing = spacing
        case .horizontal(let spacing):
            stackView.axis = .horizontal
            stackView.spacing = spacing
        }
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        let contentInset = builder.contentInsetForToast
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentInset.top),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: contentInset.left),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentInset.bottom),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentInset.right)
        ])
        
        if let activityView = builder.activityViewForToast {
            activityView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(activityView)
        }
        
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = stackView.axis == .horizontal ? .left : .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(statusLabel)
        NSLayoutConstraint.activate([statusLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200.0)])
        
        isUserInteractionEnabled = builder.userInteractionEnabledForToast == false
        
        // 键盘变化告知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 关联弹窗
    open override func willMove(toSuperview newSuperview: UIView?) {
        if let superview = newSuperview {
            superview.mn.toast = self
        } else if let superview = superview, let toast = superview.mn.toast, toast == self {
            superview.mn.toast = nil
        }
        super.willMove(toSuperview: newSuperview)
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let _ = window else { return }
        applyToKeyboard()
    }
    
    /// 更新进度
    /// - Parameter progress: 进度值
    func update(progress: CGFloat!) {
        guard let progress = progress else { return }
        guard builder is MNToastProgressUpdater else { return }
        let updater = builder as! MNToastProgressUpdater
        updater.toastShouldUpdate(progress: progress)
    }
    
    /// 更新提示信息
    /// - Parameter status: 提示信息
    func update(status: String?) {
        if let status = status, status.isEmpty == false {
            statusLabel.attributedText = NSAttributedString(string: status, attributes: builder.attributesForToastDescription)
            statusLabel.isHidden = false
        } else {
            statusLabel.attributedText = nil
            statusLabel.isHidden = true
        }
    }
    
    /// 定时指定时间后结束展示
    /// - Parameter timeInterval: 触发时长
    func dismiss(after timeInterval: TimeInterval) {
        invalidateTimer()
        let fireDate = Date().addingTimeInterval(timeInterval)
        timer = Timer(fireAt: fireDate, interval: 0.0, target: self, selector: #selector(timerStrike), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func invalidateTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }
    
    /// 定时到期
    @objc private func timerStrike() {
        dismiss(completion: dismissHandler)
    }
    
    /// 拒绝事件响应
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}

// MARK: - 显示
extension MNToast {
    
    class func show(builder: MNToastBuilder, in superview: UIView! = MNToast.window, status: String?, progress: CGFloat?, dismiss handler: (()->Void)? = nil) {
        guard let superview = superview else { return }
        if let toast = superview.mn.toast {
            // 取消定时器
            toast.invalidateTimer()
            // 判断是否是当前类型
            if type(of: toast.builder) == type(of: builder) {
                // 取消当前动画
                let animationKeys = toast.contentView.layer.animationKeys()
                if let _ = animationKeys {
                    toast.contentView.layer.removeAllAnimations()
                    toast.contentView.transform = .identity
                }
                // 这里只做更新
                if let status = status {
                    toast.update(status: status)
                }
                if let progress = progress {
                    toast.update(progress: progress)
                }
                if let handler = handler {
                    toast.dismissHandler = handler
                }
                superview.bringSubviewToFront(toast)
                // 重新展示动画
                toast.show(animated: animationKeys != nil)
                return
            }
            // 删除
            toast.removeFromSuperview()
        }
        // 创建
        let toast = MNToast(builder: builder)
        toast.update(status: status)
        toast.update(progress: progress)
        toast.dismissHandler = handler
        toast.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: superview.topAnchor),
            toast.leftAnchor.constraint(equalTo: superview.leftAnchor),
            toast.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            toast.rightAnchor.constraint(equalTo: superview.rightAnchor)
        ])
        toast.show(animated: true)
    }
    
    private func show(animated: Bool) {
        if let _ = window {
            layoutIfNeeded()
        }
        let animationHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.contentView.alpha = 1.0
            self.contentView.transform = .identity
        }
        let completionHandler: (Bool)->Void = { [weak self] finished in
            guard let self = self else { return }
            guard finished else { return }
            self.builder.toastDidAppear(self)
        }
        if animated, builder.fadeInForToast {
            contentView.alpha = 0.0
            contentView.transform = .init(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: animationHandler, completion: completionHandler)
        } else {
            completionHandler(true)
        }
    }
    
    /// 取消Toast展示
    /// - Parameter handler: 完成后回调
    public func dismiss(completion handler: (()->Void)? = nil) {
        guard contentView.alpha == 1.0 else { return }
        invalidateTimer()
        let animationHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.contentView.alpha = 0.0
            self.contentView.transform = .init(scaleX: 0.75, y: 0.75)
        }
        let completionHandler: (Bool)->Void = { [weak self] finished in
            guard let self = self else { return }
            guard finished else { return }
            self.removeFromSuperview()
            if let dismissHandler = handler {
                dismissHandler()
            }
        }
        if builder.fadeOutForToast {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: animationHandler, completion: completionHandler)
        } else {
            completionHandler(true)
        }
    }
}

// MARK: - Helper
extension MNToast {
    
    private func applyToKeyboard() {
//        // 原本位置
//        let constant = constantForNormal()
//        // 与键盘间隔
//        let spacing = keyboardFrame.minY < UIScreen.main.bounds.height ? (builder.spacingForKeyboard?() ?? 0.0) : 0.0
//        // 内容视图位置
//        let point = CGPoint(x: keyboardFrame.midX, y: keyboardFrame.minY - spacing - contentView.bounds.midY)
//        // 转换到自身坐标系
//        let center = convert(point, from: nil)
//        // 与中心点间隔
//        let margin = center.y - bounds.midY
//        verticalLayout.constant = min(margin, constant)
//        layoutIfNeeded()
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
//        guard let isAdjustsKeyboard = builder.supportedAdjustsKeyboard?(), isAdjustsKeyboard == true else { return }
//        guard let userInfo = notify.userInfo else { return }
//        guard let rect = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect else { return }
//        keyboardFrame = rect
//        guard let _ = window else { return }
//        applyToKeyboard()
    }
    
    /// 键盘可见高度
    var visibleKeyboardHeight: CGFloat {
        guard let window = MNToast.window else { return 0.0 }
        for possibleKeyboard in window.subviews {
            let viewName = NSStringFromClass(type(of: possibleKeyboard))
            guard viewName.hasPrefix("UI") else { continue }
            if viewName.hasSuffix("PeripheralHostView") || viewName.hasSuffix("Keyboard") {
                return possibleKeyboard.bounds.height
            } else if viewName.hasSuffix("InputSetContainerView") {
                for possibleKeyboardSubview in possibleKeyboard.subviews {
                    let subviewName = NSStringFromClass(type(of: possibleKeyboardSubview))
                    guard subviewName.hasPrefix("UI"), subviewName.hasSuffix("InputSetHostView") else { continue }
                    let convertedRect = possibleKeyboard.convert(possibleKeyboardSubview.frame, to: self)
                    let intersectedRect = convertedRect.intersection(bounds)
                    guard intersectedRect.isNull == false else { continue }
                    return intersectedRect.height
                }
            }
        }
        return 0.0
    }
}
