//
//  MNToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Toast定义

import UIKit
import ObjectiveC.runtime

/// Toast构建规则
public protocol MNToastBuilder {
    
    /// Toast布局方向
    var axisForToast: MNToast.Axis { get }
    
    /// Toast视觉效果
    var effectForToast: MNToast.Effect { get }
    
    /// Toast内容四周约束
    var contentInsetForToast: UIEdgeInsets { get }
    
    /// Toast指示视图
    var activityViewForToast: UIView? { get }
    
    /// Toast中状态文字的富文本描述
    var attributesForToastStatus: [NSAttributedString.Key:Any] { get }
    
    /// Toast渐入式显示
    var fadeInForToast: Bool { get }
    
    /// Toast渐隐式取消
    var fadeOutForToast: Bool { get }
    
    /// Toast显示时是否允许交互
    var allowUserInteractionWhenDisplayed: Bool { get }
}

/// 弹框动画规则
public protocol MNToastAnimationHandler where Self: MNToastBuilder {
    
    /// 开启动画
    func startAnimating()
    
    /// 停止动画
    func stopAnimating()
}

/// 弹框进度更新规则
public protocol MNToastProgressUpdater where Self: MNToastBuilder {
    
    /// 更新进度值
    /// - Parameter value: 进度值
    func toastProgressDidUpdate(_ value: CGFloat)
}

/// 弹框定时器规则
public protocol MNToastTimerHandler where Self: MNToastBuilder {
    
    /// 定时自动消失Toast
    /// - Parameter status: 状态文字
    /// - Returns: 延迟时长, nil则不做自动消失操作
    func toastShouldDelayDismiss(with status: String?) -> TimeInterval?
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
    
    /// 效果
    public enum Effect {
        ///   无颜色
        case none
        ///   暗色
        case dark
        ///   亮色
        case light
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
    
    /// 当前状态
    private enum State {
        /// 即将出现
        case willAppear
        /// 已经出现
        case appearing
        /// 即将消失
        case willDisappear
        /// 消失
        case disappear
    }
    
    /// 定时器
    private var timer: Timer!
    
    /// 内容提供者
    private let builder: MNToastBuilder
    
    /// 展示位置
    private let position: MNToast.Position
    
    /// 消失后回调
    public var dismissHandler: (()->Void)?
    
    /// 当前状态
    private var state: MNToast.State = .willAppear
    
    /// 预设的展示时长
    private var referenceTimeInterval: TimeInterval!
    
    /// 状态信息
    private let statusLabel = UILabel()
    
    /// 约束指示图与状态信息
    private let stackView = UIStackView()
    
    /// 内容视图
    private let visualView = UIVisualEffectView()
    
    /// 当前状态描述
    public var status: String? {
        get {
            if let attributedText = statusLabel.attributedText { return attributedText.string }
            return statusLabel.text
        }
        set {
            if let text = newValue, text.isEmpty == false {
                statusLabel.isHidden = false
                statusLabel.attributedText = NSAttributedString(string: text, attributes: builder.attributesForToastStatus)
            } else {
                statusLabel.isHidden = true
                statusLabel.attributedText = nil
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 构建Toast
    /// - Parameters:
    ///   - builder: 构建者
    ///   - position: 展示位置
    public init(builder: MNToastBuilder, position: MNToast.Position) {
        self.builder = builder
        self.position = position
        super.init(frame: .zero)
        
        visualView.clipsToBounds = true
        visualView.layer.cornerRadius = 8.0
        visualView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualView)
        NSLayoutConstraint.activate([visualView.centerXAnchor.constraint(equalTo: centerXAnchor)])
        switch position {
        case .top(let distance):
            NSLayoutConstraint.activate([visualView.topAnchor.constraint(equalTo: topAnchor, constant: distance)])
        case .center:
            NSLayoutConstraint.activate([visualView.centerYAnchor.constraint(equalTo: centerYAnchor)])
        case .bottom(let distance):
            NSLayoutConstraint.activate([visualView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -distance)])
        }
        
        switch builder.effectForToast {
        case .dark:
            visualView.effect = UIBlurEffect(style: .dark)
        case .light:
            visualView.effect = UIBlurEffect(style: .light)
        default: break
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
        visualView.contentView.addSubview(stackView)
        let contentInset = builder.contentInsetForToast
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: visualView.contentView.topAnchor, constant: contentInset.top),
            stackView.leftAnchor.constraint(equalTo: visualView.contentView.leftAnchor, constant: contentInset.left),
            stackView.bottomAnchor.constraint(equalTo: visualView.contentView.bottomAnchor, constant: -contentInset.bottom),
            stackView.rightAnchor.constraint(equalTo: visualView.contentView.rightAnchor, constant: -contentInset.right)
        ])
        
        if let activityView = builder.activityViewForToast {
            activityView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(activityView)
            NSLayoutConstraint.activate([
                activityView.widthAnchor.constraint(equalToConstant: activityView.frame.width),
                activityView.heightAnchor.constraint(equalToConstant: activityView.frame.height)
            ])
        }
        
        statusLabel.numberOfLines = 0
        statusLabel.baselineAdjustment = .alignCenters
        statusLabel.textAlignment = stackView.axis == .horizontal ? .left : .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(statusLabel)
        NSLayoutConstraint.activate([statusLabel.widthAnchor.constraint(lessThanOrEqualToConstant: MNToast.Configuration.shared.greatestFiniteStatusWidth)])
        
        isUserInteractionEnabled = builder.allowUserInteractionWhenDisplayed == false
        
        // 键盘变化告知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        if let superview = newSuperview {
            superview.mn.toast = self
        } else if let superview = superview, let toast = superview.mn.toast, toast == self {
            superview.mn.toast = nil
        }
        super.willMove(toSuperview: newSuperview)
    }
    
    /// 更新进度
    /// - Parameter value: 进度值
    func update(progress value: any BinaryFloatingPoint) {
        guard builder is MNToastProgressUpdater else { return }
        let updater = builder as! MNToastProgressUpdater
        updater.toastProgressDidUpdate(CGFloat(value))
    }
    
    /// 立即定时指定时间后结束展示
    /// - Parameter timeInterval: 展示时长(多少秒后触发)
    func dismiss(after timeInterval: TimeInterval) {
        invalidateTimer()
        let fireDate = Date().addingTimeInterval(max(0.0, timeInterval))
        timer = Timer(fireAt: fireDate, interval: 0.0, target: self, selector: #selector(timerStrike), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    /// 根据当前状态判断是否立即定时
    /// - Parameters:
    ///   - timeInterval: 展示时长(多少秒后触发)
    ///   - handler: 取消展示回调
    func dismissWhenAppear(delay timeInterval: TimeInterval, completion handler: (()->Void)?) {
        // 更新回调
        if state != .disappear {
            if let handler = handler {
                dismissHandler = handler
            }
        }
        // 更新定时器
        if state == .willAppear {
            referenceTimeInterval = timeInterval
        } else if state == .appearing {
            dismiss(after: timeInterval)
        }
    }
    
    /// 销毁定时器
    func invalidateTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }
    
    /// 定时到期
    @objc private func timerStrike() {
        dismiss(completion: dismissHandler)
    }
    
    /// 依据状态文字计算Toast显示时长
    /// - Parameter status: 状态描述
    /// - Returns: 显示时长
    public class func displayTimeInterval(with status: String?) -> TimeInterval {
        var timeInterval = 1.5
        if let status = status, status.isEmpty == false {
            let string = status.components(separatedBy: "\n").joined()
            let count = string.count - 8
            if count > 0 {
                timeInterval += TimeInterval(count)*0.06
            }
        }
        return timeInterval
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}

// MARK: - Show
extension MNToast {
    
    /// 展示Toast, 若存在同类型则执行更新
    /// - Parameters:
    ///   - builder: 构建者
    ///   - superview: Toast父视图
    ///   - position: 展示的位置
    ///   - status: 状态
    ///   - progress: 进度
    ///   - delay: 展示时长
    ///   - dismissHandler: 展示结束回调
    public class func show(builder: MNToastBuilder, in superview: UIView, at position: MNToast.Position = MNToast.Configuration.shared.position, status: String?, progress: (any BinaryFloatingPoint)? = nil, delay: TimeInterval? = nil, dismiss dismissHandler: (()->Void)? = nil) {
        if let toast = superview.mn.toast {
            // 判断是否是当前类型, 存在则更新
            if type(of: toast.builder) == type(of: builder) {
                // 取消当前动画
                let isAnimating = toast.visualView.layer.animationKeys() != nil
                if isAnimating {
                    toast.visualView.layer.removeAllAnimations()
                    toast.visualView.transform = .identity
                }
                // 这里只做更新
                if let status = status {
                    toast.status = status
                }
                if let progress = progress {
                    toast.update(progress: progress)
                }
                if let delay = delay {
                    toast.invalidateTimer()
                    toast.referenceTimeInterval = delay
                }
                if let dismissHandler = dismissHandler {
                    toast.dismissHandler = dismissHandler
                }
                superview.bringSubviewToFront(toast)
                // 重新展示动画
                toast.show(animated: isAnimating)
                return
            }
            // 删除旧的Toast
            toast.invalidateTimer()
            toast.removeFromSuperview()
        }
        // 创建新的Toast
        let toast = MNToast(builder: builder, position: position)
        toast.status = status
        toast.dismissHandler = dismissHandler
        toast.referenceTimeInterval = delay
        if let progress = progress {
            toast.update(progress: progress)
        }
        toast.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: superview.topAnchor),
            toast.leftAnchor.constraint(equalTo: superview.leftAnchor),
            toast.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            toast.rightAnchor.constraint(equalTo: superview.rightAnchor)
        ])
        toast.show(animated: builder.fadeInForToast)
    }
    
    private func show(animated: Bool) {
        if let _ = window {
            layoutIfNeeded()
        }
        let animationHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.visualView.alpha = 1.0
            self.visualView.transform = .identity
        }
        let completionHandler: (Bool)->Void = { [weak self] finished in
            guard let self = self else { return }
            guard finished else { return }
            self.state = .appearing
            if self.builder is MNToastAnimationHandler {
                let delegate = self.builder as! MNToastAnimationHandler
                delegate.startAnimating()
            }
            if self.builder is MNToastTimerHandler {
                let delegate = self.builder as! MNToastTimerHandler
                if let timeInterval = delegate.toastShouldDelayDismiss(with: self.status) {
                    self.dismiss(after: timeInterval)
                }
            }
            if let delay = self.referenceTimeInterval {
                self.referenceTimeInterval = nil
                self.dismiss(after: delay)
            }
        }
        if animated {
            state = .willAppear
            visualView.alpha = 0.0
            switch position {
            case .top:
                visualView.transform = .init(translationX: 0.0, y: -10.0)
            case .center:
                visualView.transform = .init(scaleX: 1.22, y: 1.22)
            case .bottom:
                visualView.transform = .init(translationX: 0.0, y: 10.0)
            }
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: animationHandler, completion: completionHandler)
        } else {
            completionHandler(true)
        }
    }
}

// MARK: - Dismiss
extension MNToast {
    
    /// 关闭Toast弹窗
    /// - Parameter dismissHandler: 结束后回调
    public func dismiss(completion dismissHandler: (()->Void)? = nil) {
        guard state == .willAppear || state == .appearing else { return }
        invalidateTimer()
        let animationHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.visualView.alpha = 0.0
            switch self.position {
            case .top:
                self.visualView.transform = .init(translationX: 0.0, y: -10.0)
            case .center:
                self.visualView.transform = .init(scaleX: 0.78, y: 0.78)
            case .bottom:
                self.visualView.transform = .init(translationX: 0.0, y: 10.0)
            }
        }
        let completionHandler: (Bool)->Void = { [weak self] finished in
            guard let self = self else { return }
            guard finished else { return }
            if self.builder is MNToastAnimationHandler {
                let delegate = self.builder as! MNToastAnimationHandler
                delegate.stopAnimating()
            }
            self.removeFromSuperview()
            self.state = .disappear
            if let dismissHandler = dismissHandler {
                // 延迟执行, 确保视图已在界面消失
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: dismissHandler)
            }
        }
        if builder.fadeOutForToast {
            state = .willAppear
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: animationHandler, completion: completionHandler)
        } else {
            completionHandler(true)
        }
    }
}

// MARK: - Notification
extension MNToast {
    
    /// 键盘Frame变化通知
    /// - Parameter notification: 通知
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let window = window else { return }
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let convertedRect = convert(visualView.frame, to: window)
        let minY = keyboardFrame.minY - 15.0 - convertedRect.height
        switch position {
        case .top(let distance):
            // 顶部
            guard let constraint = constraints.first(where: { constraint in
                guard let firstItem = constraint.firstItem, firstItem is UIVisualEffectView else { return false }
                guard constraint.firstAttribute == .top else { return false }
                return true
            }) else { break }
            constraint.constant = min(distance, minY - convertedRect.minY + constraint.constant)
            layoutIfNeeded()
        case .center:
            // 中心
            guard let constraint = constraints.first(where: { constraint in
                guard let firstItem = constraint.firstItem, firstItem is UIVisualEffectView else { return false }
                guard constraint.firstAttribute == .centerY else { return false }
                return true
            }) else { break }
            constraint.constant = min(0.0, minY - convertedRect.minY + constraint.constant)
            layoutIfNeeded()
        case .bottom(let distance):
            // 底部
            guard let constraint = constraints.first(where: { constraint in
                guard let firstItem = constraint.firstItem, firstItem is UIVisualEffectView else { return false }
                guard constraint.firstAttribute == .bottom else { return false }
                return true
            }) else { break }
            constraint.constant = min(-distance, minY - convertedRect.minY + constraint.constant)
            layoutIfNeeded()
        }
    }
}
