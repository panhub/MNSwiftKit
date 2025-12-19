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
    var allowUserInteraction: Bool { get }
}

/// 弹框动画规则
public protocol MNToastAnimationSupported where Self: MNToastBuilder {
    
    /// 开启动画
    func startAnimating()
    
    /// 停止动画
    func stopAnimating()
}

/// 弹框进度更新规则
public protocol MNToastProgressSupported where Self: MNToastBuilder {
    
    /// Toast需要更新进度
    /// - Parameter value: 进度值
    func toastShouldUpdateProgress(_ value: CGFloat)
}

/// 弹框自动关闭支持
public protocol MNToastCloseSupported where Self: MNToastBuilder {
    
    /// Toast想要定时自动关闭
    /// - Parameter status: 状态文字
    /// - Returns: 显示时长(nil则不做自动关闭操作)
    func toastShouldClose(with status: String?) -> TimeInterval
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
        case top(distance: CGFloat = 90.0)
        /// 中间显示
        case center
        /// 距离底部一定距离的位置
        case bottom(distance: CGFloat = 45.0)
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
    /// 是否支持手动取消
    private let cancellation: Bool
    /// 记录是否是手动触发的关闭操作, 手动关闭时，不再显示
    private var isManualClose: Bool = false
    /// 消失后回调
    public var closeHandler: ((Bool)->Void)?
    /// 当前状态
    private var state: MNToast.State = .willAppear
    /// 延迟执行关闭操作的时长
    private var delayTimeInterval: TimeInterval!
    /// 关闭按钮
    private var closeButton: UIButton!
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
            // 存在关闭按钮以及活动视图则需要适配关闭按钮
            guard let closeButton = closeButton else { return }
            guard let closeWidthConstraint = closeButton.constraints.first(where: { $0.firstAttribute == .width }) else { return }
            guard let closeRightConstraint = visualView.contentView.constraints.first(where: { constraint in
                guard let firstItem = constraint.firstItem, firstItem is UIButton else { return false }
                guard constraint.firstAttribute == .right, constraint.secondAttribute == .right else { return false }
                return true
            }) else { return }
            guard let stackRightConstraint = visualView.contentView.constraints.first(where: { constraint in
                guard let firstItem = constraint.firstItem, firstItem is UIStackView else { return false }
                guard constraint.firstAttribute == .right, constraint.secondAttribute == .right else { return false }
                return true
            }) else { return }
            let contentInset = builder.contentInsetForToast
            if let activityView = stackView.arrangedSubviews.first, activityView != statusLabel {
                // 存在活动视图
                switch builder.axisForToast {
                case .vertical:
                    // 纵向布局
                    guard let activityWidthConstraint = activityView.constraints.first(where: { $0.firstAttribute == .width }) else { break }
                    guard let stackLeftConstraint = visualView.contentView.constraints.first(where: { constraint in
                        guard let firstItem = constraint.firstItem, firstItem is UIStackView else { return false }
                        guard constraint.firstAttribute == .left, constraint.secondAttribute == .left else { return false }
                        return true
                    }) else { break }
                    // 活动视图与关闭按钮最小间隔
                    let leastSpacingMagnitude = 10.0
                    // 右部分正常宽度
                    var contentPartWidth = activityWidthConstraint.constant/2.0
                    if let statusText = statusLabel.attributedText {
                        let statusTextWidth = statusText.boundingRect(with: .init(width: MNToast.Configuration.shared.greatestFiniteStatusWidth, height: .greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).width
                        if statusTextWidth > activityWidthConstraint.constant {
                            contentPartWidth += ceil(statusTextWidth - activityWidthConstraint.constant)/2.0
                        }
                    }
                    contentPartWidth += contentInset.right
                    // 活动视图与关闭按钮间隔
                    let spacing = contentPartWidth - abs(closeRightConstraint.constant) - closeWidthConstraint.constant - activityWidthConstraint.constant/2.0
                    // 假如需要添加, 添加的量
                    let addition = leastSpacingMagnitude - spacing
                    if addition <= 0.0 {
                        // 正常约束即可
                        stackLeftConstraint.constant = contentInset.left
                        stackRightConstraint.constant = -contentInset.right
                    } else {
                        // 修改约束
                        stackLeftConstraint.constant = contentInset.left + addition
                        stackRightConstraint.constant = -contentInset.right - addition
                    }
                case .horizontal:
                    // 横向布局
                    // 活动视图与关闭按钮最小间隔
                    let leastSpacingMagnitude = stackView.spacing
                    closeRightConstraint.constant = -contentInset.right
                    stackRightConstraint.constant = -leastSpacingMagnitude - closeWidthConstraint.constant - contentInset.right
                    guard let closeHeightConstraint = closeButton.constraints.first(where: { $0.firstAttribute == .height }) else { return }
                    guard let closeTopConstraint = visualView.contentView.constraints.first(where: { constraint in
                        guard let firstItem = constraint.firstItem, firstItem is UIButton else { return false }
                        guard constraint.firstAttribute == .top, constraint.secondAttribute == .top else { return false }
                        return true
                    }) else { return }
                    guard let activityHeightConstraint = activityView.constraints.first(where: { $0.firstAttribute == .height }) else { break }
                    var contentHeight = activityHeightConstraint.constant
                    if let statusText = statusLabel.attributedText {
                        // [.usesFontLeading, .usesLineFragmentOrigin]
                        //
                        let statusTextHeight = statusText.boundingRect(with: .init(width: MNToast.Configuration.shared.greatestFiniteStatusWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
                        contentHeight = max(contentHeight, statusTextHeight)
                    }
                    closeTopConstraint.constant = (contentInset.top + contentHeight + contentInset.bottom - closeHeightConstraint.constant)/2.0
                }
            } else {
                // 不存在活动视图
                // 活动视图与关闭按钮最小间隔
                let leastSpacingMagnitude = 7.0
                closeRightConstraint.constant = -contentInset.right
                stackRightConstraint.constant = -leastSpacingMagnitude - closeWidthConstraint.constant - contentInset.right
                // 按钮与文字应纵向中心对齐
                guard let statusText = statusLabel.attributedText else { return }
                guard let closeHeightConstraint = closeButton.constraints.first(where: { $0.firstAttribute == .height }) else { return }
                guard let closeTopConstraint = visualView.contentView.constraints.first(where: { constraint in
                    guard let firstItem = constraint.firstItem, firstItem is UIButton else { return false }
                    guard constraint.firstAttribute == .top, constraint.secondAttribute == .top else { return false }
                    return true
                }) else { return }
                let statusTextHeight = statusText.boundingRect(with: .init(width: MNToast.Configuration.shared.greatestFiniteStatusWidth, height: .greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).height
                closeTopConstraint.constant = (contentInset.top + statusTextHeight + contentInset.bottom - closeHeightConstraint.constant)/2.0
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
    ///   - cancellation: 是否允许手动取消
    public init(builder: MNToastBuilder, position: MNToast.Position, cancellation: Bool) {
        self.builder = builder
        self.position = position
        self.cancellation = cancellation
        super.init(frame: .zero)
        
        visualView.clipsToBounds = true
        visualView.layer.cornerRadius = MNToast.Configuration.shared.cornerRadius
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
            visualView.effect = UIBlurEffect(style: .extraLight)
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
        
        if cancellation {
            let closeImage = ToastResource.image(named: "toast_close")?.withRenderingMode(.alwaysTemplate)
            closeButton = UIButton(type: .custom)
            closeButton.tintColor = MNToast.Configuration.shared.activityColor
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.addTarget(self, action: #selector(closeToast), for: .touchUpInside)
            if #available(iOS 15.0, *) {
                var configuration = UIButton.Configuration.plain()
                configuration.background.backgroundColor = .clear
                closeButton.configuration = configuration
                closeButton.configurationUpdateHandler = { button in
                    switch button.state {
                    case .normal, .highlighted:
                        button.configuration?.background.image = closeImage
                    default: break
                    }
                }
            } else {
                closeButton.adjustsImageWhenHighlighted = false
                closeButton.setBackgroundImage(closeImage, for: .normal)
            }
            visualView.contentView.addSubview(closeButton)
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: visualView.contentView.topAnchor, constant: 8.0),
                closeButton.rightAnchor.constraint(equalTo: visualView.contentView.rightAnchor, constant: -8.0),
                closeButton.widthAnchor.constraint(equalToConstant: 14.0),
                closeButton.heightAnchor.constraint(equalToConstant: 14.0)
            ])
        }
        
        // 键盘变化告知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        destroyTimer()
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
        guard builder is MNToastProgressSupported else { return }
        let updater = builder as! MNToastProgressSupported
        let floatValue: CGFloat = Swift.min(1.0, Swift.max(CGFloat(value), 0.0))
        updater.toastShouldUpdateProgress(floatValue)
    }
    
    /// 根据当前状态判断是否立即定时
    /// - Parameters:
    ///   - timeInterval: 显示时长后自动关闭
    ///   - handler: 结束展示后回调
    func closeWhenAppear(delay timeInterval: TimeInterval, completion handler: ((Bool)->Void)?) {
        // 更新回调
        if state != .disappear {
            if let handler = handler {
                closeHandler = handler
            }
        }
        // 更新定时器
        if state == .willAppear {
            delayTimeInterval = timeInterval
        } else if state == .appearing {
            close(delay: timeInterval)
        }
    }
    
    /// 立即定时指定时间后结束展示
    /// - Parameter timeInterval: 显示时长后自动关闭
    private func close(delay timeInterval: TimeInterval) {
        destroyTimer()
        let fireDate = Date().addingTimeInterval(max(0.0, timeInterval))
        timer = Timer(fireAt: fireDate, interval: 0.0, target: self, selector: #selector(timerStrike), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    /// 定时器事件
    @objc private func timerStrike() {
        close(manual: false)
    }
    
    /// 销毁定时器
    private func destroyTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }
    
    /// 关闭Toast
    @objc private func closeToast() {
        close(manual: true)
    }
    
    /// 依据状态文字计算Toast显示时长
    /// - Parameter status: 状态描述
    /// - Returns: 显示时长
    public class func displayDuration(with status: String?) -> TimeInterval {
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
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isHidden || alpha <= 0.01 { return false }
        if visualView.frame.contains(point) { return true }
        return builder.allowUserInteraction == false
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
    ///   - cancellation: 是否支持手动取消
    ///   - delay: 展示时长
    ///   - handler: 展示结束回调
    public class func show(builder: MNToastBuilder, in superview: UIView, at position: MNToast.Position = MNToast.Configuration.shared.position, status: String?, progress: (any BinaryFloatingPoint)? = nil, cancellation: Bool = false, delay: TimeInterval? = nil, close handler: ((Bool)->Void)? = nil) {
        if let toast = superview.mn.toast {
            guard toast.isManualClose == false else { return }
            // 判断是否是当前类型, 存在则更新
            if type(of: toast.builder) == type(of: builder) {
                // 停止当前定时器
                if let delay = delay, delay > 0.0 {
                    toast.destroyTimer()
                }
                // 取消当前动画
                if toast.state == .willDisappear {
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
                if let handler = handler {
                    toast.closeHandler = handler
                }
                // 重新展示动画
                switch toast.state {
                case .willAppear, .willDisappear:
                    if let delay = delay, delay > 0.0 {
                        toast.delayTimeInterval = delay
                    }
                    if toast.state == .willDisappear {
                        superview.bringSubviewToFront(toast)
                        toast.show(animated: builder.fadeInForToast)
                    }
                case .appearing:
                    if let delay = delay, delay > 0.0 {
                        toast.close(delay: delay)
                    }
                default: break
                }
                return
            }
            // 删除旧的Toast
            toast.destroyTimer()
            toast.removeFromSuperview()
        }
        // 创建新的Toast
        let toast = MNToast(builder: builder, position: position, cancellation: cancellation)
        toast.status = status
        toast.closeHandler = handler
        toast.delayTimeInterval = delay
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
            if self.builder is MNToastAnimationSupported {
                let delegate = self.builder as! MNToastAnimationSupported
                delegate.startAnimating()
            }
            // 定时关闭
            if let timeInterval = self.delayTimeInterval {
                self.delayTimeInterval = nil
                self.close(delay: timeInterval)
            } else if self.builder is MNToastCloseSupported {
                let delegate = self.builder as! MNToastCloseSupported
                let timeInterval = delegate.toastShouldClose(with: self.status)
                self.close(delay: timeInterval)
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
    
    /// 关闭Toast
    /// - Parameter manual: 是否是手动关闭的
    @objc func close(manual: Bool) {
        isManualClose = manual
        guard state == .willAppear || state == .appearing else { return }
        destroyTimer()
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
            self.state = .disappear
            if self.builder is MNToastAnimationSupported {
                let delegate = self.builder as! MNToastAnimationSupported
                delegate.stopAnimating()
            }
            self.removeFromSuperview()
            if let closeHandler = self.closeHandler {
                // 延迟执行, 确保Toast已释放
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    closeHandler(manual)
                }
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
        let minY = keyboardFrame.minY - MNToast.Configuration.shared.spacingToKeyboard - convertedRect.height
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
