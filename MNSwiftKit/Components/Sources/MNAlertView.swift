//
//  AHAlertView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/10.
//  弹窗

import UIKit
import Foundation
#if canImport(MNSwiftKitLayout)
import MNSwiftKitLayout
#endif

/// 弹窗按钮
public struct MNAlertAction {
    
    /// 标题样式
    public enum Style : Int {
        // 默认按钮
        case `default` = 0
        // 取消
        case cancel = 1
        // 删除
        case destructive = 2
    }
    
    /// 样式
    public let style: MNAlertAction.Style
    /// 事件回调
    private let handler: ((MNAlertAction)->Void)?
    /// 标题
    public let title: String
    /// 标题字体
    private let font: UIFont = .systemFont(ofSize: 16.0, weight: .medium)
    /// 颜色
    private var color: UIColor {
        switch style {
        case .cancel:
            return UIColor(red: 47.0/255.0, green: 124.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        case .destructive:
            return UIColor(red: 255.0/255.0, green: 58.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        default:
            return .darkText.withAlphaComponent(0.88)//.black
        }
    }
    /// 标题富文本
    public var attributedTitle: NSAttributedString! {
        NSAttributedString(string: title, attributes: [.font:font, .foregroundColor:color])
    }
    
    /// 初始化按钮
    /// - Parameters:
    ///   - title: 标题
    ///   - style: 样式
    ///   - handler: 事件回调
    public init(title: String, style: MNAlertAction.Style, handler: ((MNAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    /// 回调事件
    fileprivate func execute() {
        handler?(self)
    }
}

/// 输入框
public struct MNAlertField {
    
    /// 输入框
    fileprivate let textField: UITextField = UITextField()
    
    /// 配置回调
    private let configurationHandler: ((UITextField)->Void)?
    
    /// 构造弹窗输入框
    /// - Parameter configurationHandler: 配置回调
    public init(configurationHandler: ((UITextField)->Void)?) {
        self.configurationHandler = configurationHandler
    }
    
    /// 回调输入框
    fileprivate func execute() {
        configurationHandler?(textField)
    }
}

/// 关闭弹窗通知
public let MNAlertCloseNotification: Notification.Name = Notification.Name(rawValue: "com.mnkit.alert.view.close")

/// 提示弹窗
public class MNAlertView: UIView {
    
    /// 弹窗样式
    public enum Style: Int {
        /// 提醒弹窗
        case alert = 0
        /// 操作表单
        case actionSheet = 1
    }
    
    /// 样式
    private let style: Style
    /// 标题
    private let title: String?
    /// 提示信息
    private let message: String?
    /// 标题
    private let titleLabel: UILabel = UILabel()
    /// 提示信息
    private let textLabel: UILabel = UILabel()
    /// 内容视图
    private let contentView: UIView = UIView()
    /// 输入框集合
    private var alertFields: [MNAlertField] = [MNAlertField]()
    /// 事件集合
    private var actions: [MNAlertAction] = [MNAlertAction]()
    /// 暂存弹窗
    nonisolated(unsafe) fileprivate static var alerts: [MNAlertView] = [MNAlertView]()
    /// 分割线高度
    private let separatorHeight: CGFloat = 1.0
    /// 按钮高度
    private var actionHeight: CGFloat { style == .alert ? 47.0 : 54.0 }
    /// 分割线颜色
    private var separatorColor: UIColor { style == .alert ? UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0) : UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0) }
    
    /// 构造提醒弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 提示信息
    ///   - preferredStyle: 指定样式
    public init(title: String?, message: String?, preferredStyle: MNAlertView.Style) {
        self.style = preferredStyle
        self.title = title
        self.message = message
        super.init(frame: UIScreen.main.bounds)
        // 背景点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTouchUpInside))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
        // 注册关闭弹窗通知
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: MNAlertCloseNotification, object: nil)
    }
    
    /// 构造提醒弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 提示信息
    ///   - style: 指定弹窗/操作表单样式
    ///   - cancelButtonTitle: 取消样式按钮标题
    ///   - destructiveButtonTitle: 不可恢复样式按钮标题
    ///   - otherButtonTitles: 其它按钮标题
    ///   - handler: 按钮点击事件回调
    public convenience init(title: String?, message: String?, style: MNAlertView.Style, cancelButtonTitle: String?, destructiveButtonTitle: String? = nil, otherButtonTitles: String?..., clicked handler: ((_ tag: Int, _ action: MNAlertAction) -> Void)? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
        var elements: [(MNAlertAction.Style, String)] = []
        for buttonTitle in otherButtonTitles {
            guard let title = buttonTitle else { break }
            elements.append((MNAlertAction.Style.default, title))
        }
        if let cancelButtonTitle = cancelButtonTitle {
            elements.append((MNAlertAction.Style.cancel, cancelButtonTitle))
        }
        if let destructiveButtonTitle = destructiveButtonTitle {
            elements.append((MNAlertAction.Style.destructive, destructiveButtonTitle))
        }
        for (index, element) in elements.enumerated() {
            addAction(title: element.1, style: element.0) { action in
                handler?(index, action)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Build
private extension MNAlertView {
    
    /// 创建子视图
    func createSubview() {
        
        guard contentView.frame == .zero else { return }
        
        contentView.mn_layout.width = 270.0
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15.0
        addSubview(contentView)
        
        let x: CGFloat = 18.0
        
        // 标题
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.mn_layout.width = contentView.frame.width - x*2.0
        titleLabel.mn_layout.midX = contentView.bounds.midX
        if let title = title, title.isEmpty == false {
            let string = NSAttributedString(string: title, attributes: [.font:UIFont.systemFont(ofSize: 18.0, weight: .medium), .foregroundColor:UIColor.black])
            titleLabel.attributedText = string
            titleLabel.mn_layout.height = ceil(string.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(titleLabel)
        }
        
        // 提示信息
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.mn_layout.width = contentView.frame.width - x*2.0
        textLabel.mn_layout.midX = contentView.bounds.midX
        let font: UIFont = titleLabel.frame.height > 0.0 ? .systemFont(ofSize: 15.0, weight: .regular) : .systemFont(ofSize: 16.0, weight: .medium)
        if let message = message, message.isEmpty == false {
            let string = NSAttributedString(string: message, attributes: [.font: font, .foregroundColor:UIColor.darkText.withAlphaComponent(0.88)])
            textLabel.attributedText = string
            textLabel.mn_layout.height = ceil(string.boundingRect(with: CGSize(width: textLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(textLabel)
        }
        
        // 计算位置
        // 标题与提示信息间隔
        let textSpacing: CGFloat = (titleLabel.frame.height > 0.0 && textLabel.frame.height > 0.0) ? 4.0 : 0.0
        // 输入框与提示信息间隔
        let textFieldSpacing: CGFloat = ((titleLabel.frame.height + textLabel.frame.height) > 0.0 && alertFields.count > 0) ? 15.0 : 0.0
        // 输入框高度
        let textFieldHeight: CGFloat = 39.0
        // 输入框之间间隔
        let textFieldInterval: CGFloat = 8.0
        // 输入框总体高度
        let textFieldTotalHeight: CGFloat = CGFloat(alertFields.count)*textFieldHeight + CGFloat(max(alertFields.count - 1, 0))*textFieldInterval
        // 内容高度
        let contentTotalHeight: CGFloat = titleLabel.frame.height + textSpacing + textLabel.frame.height + textFieldSpacing + textFieldTotalHeight
        // 内容高度 + 上下间隔
        let totalHeight: CGFloat = max(contentTotalHeight + 40.0, 75.0)
        
        titleLabel.mn_layout.minY = (totalHeight - contentTotalHeight)/2.0
        textLabel.mn_layout.minY = titleLabel.mn_layout.maxY + textSpacing
        var y: CGFloat = textLabel.mn_layout.maxY + textFieldSpacing
        
        // 输入框
        for (idx, alertField) in alertFields.enumerated() {
            
            let rect = CGRect(x: x, y: y, width: contentView.frame.width - x*2.0, height: textFieldHeight)
            
            let textField = alertField.textField
            textField.frame = rect
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.font = .systemFont(ofSize: 16.0)
            alertField.execute()
            
            textField.frame = rect
            textField.borderStyle = .none
            textField.clipsToBounds = true
            textField.layer.cornerRadius = 6.0
            textField.layer.borderWidth = separatorHeight
            textField.layer.borderColor = separatorColor.cgColor
            contentView.addSubview(textField)
            
            y = textField.mn_layout.maxY + (idx < (alertFields.count - 1) ? textFieldInterval : 0.0)
        }
        
        // 分割线
        let separator = UIView()
        separator.mn_layout.minY = totalHeight
        separator.mn_layout.height = separatorHeight
        separator.mn_layout.width = contentView.frame.width
        separator.backgroundColor = separatorColor
        contentView.addSubview(separator)
        
        y = separator.frame.maxY
        
        // 按钮
        if actions.count == 1 {
            
            let button: UIButton = UIButton(type: .custom)
            button.mn_layout.minY = y
            button.mn_layout.width = contentView.frame.width
            button.mn_layout.height = actionHeight
            button.setAttributedTitle(actions.first?.attributedTitle, for: .normal)
            button.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            
            y = button.frame.maxY
            
        } else if actions.count == 2 {
            
            let left: UIButton = UIButton(type: .custom)
            left.mn_layout.minY = y
            left.mn_layout.width = contentView.frame.width/2.0
            left.mn_layout.height = actionHeight
            left.setAttributedTitle(actions.first?.attributedTitle, for: .normal)
            left.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
            contentView.addSubview(left)
            
            let right: UIButton = UIButton(type: .custom)
            right.tag = 1
            right.frame = left.frame
            right.mn_layout.minX = left.frame.maxX
            right.setAttributedTitle(actions.last?.attributedTitle, for: .normal)
            right.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
            contentView.addSubview(right)
            
            let separator = UIView()
            separator.mn_layout.minY = left.frame.minY
            separator.mn_layout.height = actionHeight
            separator.mn_layout.width = separatorHeight
            separator.mn_layout.midX = contentView.bounds.midX
            separator.backgroundColor = separatorColor
            contentView.addSubview(separator)
            
            y = left.frame.maxY
            
        } else {
            
            for (idx, action) in actions.enumerated() {
                
                let button: UIButton = UIButton(type: .custom)
                button.tag = idx
                button.mn_layout.minY = y
                button.mn_layout.width = contentView.frame.width
                button.mn_layout.height = actionHeight
                button.setAttributedTitle(action.attributedTitle, for: .normal)
                button.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
                contentView.addSubview(button)
                
                if idx < (actions.count - 1) {
                    
                    let separator = UIView()
                    separator.mn_layout.minY = button.frame.maxY
                    separator.mn_layout.height = separatorHeight
                    separator.mn_layout.width = contentView.frame.width
                    separator.backgroundColor = separatorColor
                    contentView.addSubview(separator)
                    
                    y = separator.frame.maxY
                    
                } else {
                    y = button.frame.maxY
                }
            }
        }
        
        contentView.mn_layout.height = y
        
        if alertFields.count > 0 {
            // 注册键盘通知
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
        }
    }
    
    func buildActionSheet() {
        
        guard contentView.frame == .zero else { return }
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            contentView.mn_layout.width = mn_layout.height > mn_layout.width ? mn_layout.width : ceil(mn_layout.width/3.0*2.0)
        } else {
            // iPad
            contentView.mn_layout.width = 390.0
        }
        contentView.backgroundColor = .white
        addSubview(contentView)
        
        var y: CGFloat = 0.0
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.mn_layout.width = contentView.frame.width - 35.0
        titleLabel.mn_layout.midX = contentView.bounds.midX
        if let title = title, title.isEmpty == false {
            // 标题
            let string = NSAttributedString(string: title, attributes: [.font:UIFont.systemFont(ofSize: 17.0, weight: .medium), .foregroundColor:UIColor.black])
            titleLabel.mn_layout.minY = 18.0
            titleLabel.attributedText = string
            titleLabel.mn_layout.height = ceil(string.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(titleLabel)
            
            y = titleLabel.frame.maxY + titleLabel.frame.minY
        }
        
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.mn_layout.width = contentView.frame.width - 35.0
        textLabel.mn_layout.midX = contentView.bounds.midX
        let font: UIFont = titleLabel.mn_layout.height > 0.0 ? .systemFont(ofSize: 15.0, weight: .regular) : .systemFont(ofSize: 16.0, weight: .medium)
        if let message = message, message.isEmpty == false {
            // 提示
            let string = NSAttributedString(string: message, attributes: [.font: font, .foregroundColor:UIColor.darkText.withAlphaComponent(0.88)])
            textLabel.mn_layout.minY = titleLabel.frame.height > 0.0 ? (titleLabel.frame.maxY + 4.0) : 18.0
            textLabel.attributedText = string
            textLabel.mn_layout.height = ceil(string.boundingRect(with: CGSize(width: textLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(textLabel)
            
            y = textLabel.frame.maxY + (titleLabel.frame.height > 0.0 ? titleLabel.frame.minY : textLabel.frame.minY)
        }
        
        var cornerRadius: CGFloat = 0.0
        if y > 0.0 {
            
            cornerRadius = 15.0
            
            let separator = UIView()
            separator.mn_layout.minY = y
            separator.mn_layout.height = separatorHeight
            separator.mn_layout.width = contentView.frame.width
            separator.backgroundColor = separatorColor
            contentView.addSubview(separator)
            
            y = separator.frame.maxY
        }
        
        var others: [MNAlertAction] = actions.filter { $0.style == .default }
        others.append(contentsOf: actions.filter { $0.style == .cancel })
        let destructives: [MNAlertAction] = actions.filter { $0.style == .destructive }
        updateActions(others + destructives)
        let groups: [[MNAlertAction]] = [others, destructives]
        
        // 创建按钮
        var tag: Int = 0
        for (index, group) in groups.enumerated() {
            for (idx, action) in group.enumerated() {
                
                let button: UIButton = UIButton(type: .custom)
                button.tag = tag
                button.mn_layout.minY = y
                button.mn_layout.height = actionHeight
                button.mn_layout.width = contentView.frame.width
                button.setAttributedTitle(action.attributedTitle, for: .normal)
                button.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
                contentView.addSubview(button)
                
                tag += 1
                
                if idx < (group.count - 1) {
                    
                    let separator = UIView()
                    separator.mn_layout.minY = button.frame.maxY
                    separator.mn_layout.height = separatorHeight
                    separator.mn_layout.width = contentView.frame.width
                    separator.backgroundColor = separatorColor
                    contentView.addSubview(separator)
                    
                    y = separator.frame.maxY
                    
                } else {
                    
                    y = button.frame.maxY
                }
            }
            
            // 分割线
            if group.count > 0, index < (groups.count - 1) {
                
                let separator = UIView()
                separator.mn_layout.minY = y
                separator.mn_layout.height = 10.0
                separator.mn_layout.width = contentView.frame.width
                separator.backgroundColor = separatorColor
                contentView.addSubview(separator)
                
                y = separator.frame.maxY
            }
        }
        
        // 安全区域
        var bottomInset = 0.0
        if #available(iOS 11.0, *) {
            bottomInset = UIWindow().safeAreaInsets.bottom
        }
        if bottomInset > 0.0 {
            let separator = UIView()
            separator.mn_layout.minY = y
            separator.mn_layout.height = bottomInset
            separator.mn_layout.width = contentView.frame.width
            separator.backgroundColor = separatorColor
            contentView.addSubview(separator)
            
            y = separator.frame.maxY
        }
        
        contentView.mn_layout.height = y
        
        // 圆角
        if cornerRadius > 0.0 {
            let path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            contentView.layer.mask = mask
        }
    }
}

// MARK: - Add Action
extension MNAlertView {
    
    /// 添加按钮
    /// - Parameter action: 按钮
    public func addAction(_ action: MNAlertAction) {
        if action.style == .cancel || action.style == .destructive {
            guard actions.filter ({ $0.style == action.style }).isEmpty else { return }
        }
        actions.append(action)
    }
    
    /// 添加按钮
    /// - Parameters:
    ///   - title: 标题
    ///   - style: 样式
    ///   - handler: 事件回调
    public func addAction(title: String, style: MNAlertAction.Style = .default, handler: ((MNAlertAction) -> Void)? = nil) {
        addAction(MNAlertAction(title: title, style: style, handler: handler))
    }
    
    /// 更新按钮
    /// - Parameter actions: 按钮集合
    private func updateActions(_ actions: [MNAlertAction]) {
        self.actions.removeAll()
        self.actions.append(contentsOf: actions)
    }
}

// MARK: - Add TextField
extension MNAlertView {
    
    /// 文本框集合
    public var textFields: [UITextField] {
        alertFields.compactMap { $0.textField }
    }
    
    /// 获取指定输入框
    /// - Parameter index: 指定索引
    /// - Returns: 输入框
    public func textField(at index: Int) -> UITextField? {
        guard index < alertFields.count else { return nil }
        return alertFields[index].textField
    }
    
    /// 添加输入框
    /// - Parameter alertField: 输入框
    public func addTextField(_ alertField: MNAlertField) {
        guard style == .alert else { return }
        alertFields.append(alertField)
    }
    
    /// 添加输入框
    /// - Parameter configurationHandler: 输入框配置
    public func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        addTextField(MNAlertField(configurationHandler: configurationHandler))
    }
}

// MARK: - Show & Dismiss
extension MNAlertView {
    
    /// 展示
    public func show() {
        guard superview == nil, actions.count > 0 else { return }
        guard let superview = UIWindow.current else { return }
        // 注销键盘
        superview.endEditing(true)
        // 取消当前
        if let alert = Self.alerts.last, let _ = alert.superview {
            alert.endEditing(true)
            alert.removeFromSuperview()
        }
        // 显示当前
        autoresizingMask = []
        frame = superview.bounds
        backgroundColor = .clear
        superview.addSubview(self)
        Self.alerts.append(self)
        switch style {
        case .alert:
            createSubview()
            contentView.autoresizingMask = []
            contentView.alpha = 0.0
            contentView.transform = .identity
            contentView.center = CGPoint(x: bounds.midX, y: bounds.midY)
            contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            UIView.animate(withDuration: 0.17, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 1.0
                self.contentView.transform = .identity
                self.backgroundColor = .black.withAlphaComponent(0.4)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.contentView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
                self.alertFields.first?.textField.becomeFirstResponder()
            }
        case .actionSheet:
            buildActionSheet()
            contentView.autoresizingMask = []
            contentView.transform = .identity
            contentView.mn_layout.midX = bounds.midX
            contentView.mn_layout.maxY = bounds.height
            contentView.transform = CGAffineTransform(translationX: 0.0, y: contentView.frame.height)
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.transform = .identity
                self.backgroundColor = .black.withAlphaComponent(0.4)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.contentView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
            }
        }
    }
    
    /// 结束动画
    /// - Parameter action: 点击的按钮
    public final func dismiss(action: MNAlertAction? = nil) {
        dismissAnimation { [weak self] _ in
            guard let self = self else { return }
            self.close()
            if let action = action {
                action.execute()
            }
            guard let alert = Self.alerts.last else { return }
            Self.alerts.removeLast()
            alert.show()
        }
    }
    
    /// 弹窗消失动画
    /// - Parameter completion: 动画结束回调
    private func dismissAnimation(completion: @escaping (Bool)->Void) {
        UIView.animate(withDuration: 0.17, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.backgroundColor = .clear
            switch self.style {
            case .alert:
                self.contentView.alpha = 0.0
                self.contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            case .actionSheet:
                self.contentView.transform = CGAffineTransform(translationX: 0.0, y: self.contentView.frame.height)
            }
        }, completion: completion)
    }
}

// MARK: - Event
private extension MNAlertView {
    
    /// 按钮点击事件
    /// - Parameter sender: 按钮
    @objc func actionButtonTouchUpInside(_ sender: UIView) {
        let action: MNAlertAction? = (actions.count > 0 && sender.tag < actions.count) ? actions[sender.tag] : nil
        dismiss(action: action)
    }
    
    /// 背景点击事件
    /// - Parameter recognizer: 点击对象
    @objc func backgroundTouchUpInside() {
        switch style {
        case .alert:
            for alertField in alertFields.filter ({ $0.textField.isFirstResponder }) {
                alertField.textField.resignFirstResponder()
            }
        case .actionSheet:
            dismiss()
        }
    }
}

// MARK: - Notification
private extension MNAlertView {
    
    /// 接收到关闭通知
    @objc func close() {
        if let _ = superview {
            endEditing(true)
            removeFromSuperview()
        }
        if let index = Self.alerts.firstIndex(of: self) {
            Self.alerts.remove(at: index)
        }
    }
    
    /// 键盘位置变化
    /// - Parameter notify: 通知
    @objc func keyboardWillChangeFrame(_ notify: Notification) {
        guard let superview = superview, alertFields.count > 0 else { return }
        guard let userInfo = notify.userInfo else { return }
        guard let rect = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        // superview即UIWindow, 避免后期自身位置与UIWindow大小不同, 这里做一次转换
        let frame: CGRect = superview.convert(rect, to: self)
        let midY: CGFloat = min(frame.minY - 10.0 - contentView.frame.height/2.0, bounds.midY)
        if midY == contentView.frame.midY { return }
        let autoresizingMask: UIView.AutoresizingMask = contentView.autoresizingMask
        //let duration: TimeInterval = userInfo[UIWindow.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        contentView.autoresizingMask = []
        contentView.mn_layout.midY = midY
        contentView.autoresizingMask = autoresizingMask
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNAlertView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        return contentView.frame.contains(location) == false
    }
}

