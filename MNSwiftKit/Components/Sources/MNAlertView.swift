//
//  AHAlertView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/10.
//  弹窗

import UIKit
import Foundation

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
public let MNAlertCloseNotification: Notification.Name = Notification.Name(rawValue: "com.mn.alert.view.close")

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
    private let titleLabel = UILabel()
    /// 提示信息
    private let textLabel = UILabel()
    /// 内容视图
    private let contentView = UIView()
    /// 事件集合
    private var actions: [MNAlertAction] = []
    /// 输入框集合
    private var alertFields: [MNAlertField] = []
    /// 分割线高度
    private let separatorHeight: CGFloat = 1.0
    /// 暂存弹窗
    fileprivate nonisolated(unsafe) static var alerts: [MNAlertView] = []
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
    }
    
    /// 构造提醒弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 提示信息
    ///   - style: 指定弹窗/操作表单样式
    ///   - cancelButtonTitle: 取消样式按钮标题
    ///   - destructiveButtonTitle: 不可恢复样式按钮标题
    ///   - otherButtonTitles: 其它按钮标题
    ///   - events: 按钮点击事件回调
    public convenience init(title: String?, message: String?, style: MNAlertView.Style, cancelButtonTitle: String?, destructiveButtonTitle: String? = nil, otherButtonTitles: String?..., events: ((_ tag: Int, _ action: MNAlertAction) -> Void)? = nil) {
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
                events?(index, action)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Build
extension MNAlertView {
    
    /// 创建子视图
    private func buildAlertView() {
        
        guard contentView.subviews.isEmpty else { return }
        
        contentView.frame.size.width = 270.0
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15.0
        addSubview(contentView)
        
        let x: CGFloat = 18.0
        
        // 标题
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.frame.size.width = contentView.frame.width - x*2.0
        titleLabel.frame.origin.x = contentView.bounds.midX - titleLabel.frame.width/2.0
        if let title = title, title.isEmpty == false {
            let string = NSAttributedString(string: title, attributes: [.font:UIFont.systemFont(ofSize: 18.0, weight: .medium), .foregroundColor:UIColor.black])
            titleLabel.attributedText = string
            titleLabel.frame.size.height = ceil(string.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(titleLabel)
        }
        
        // 提示信息
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.frame.size.width = contentView.frame.width - x*2.0
        textLabel.frame.origin.x = contentView.bounds.midX - textLabel.frame.width/2.0
        let textFont: UIFont = titleLabel.frame.height > 0.0 ? .systemFont(ofSize: 13.0, weight: .regular) : .systemFont(ofSize: 16.0, weight: .medium)
        if let message = message, message.isEmpty == false {
            let string = NSAttributedString(string: message, attributes: [.font: textFont, .foregroundColor:UIColor.darkText.withAlphaComponent(0.88)])
            textLabel.attributedText = string
            textLabel.frame.size.height = ceil(string.boundingRect(with: CGSize(width: textLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(textLabel)
        }
        
        // 计算位置
        // 标题与提示信息间隔
        let textSpacing: CGFloat = (titleLabel.frame.height > 0.0 && textLabel.frame.height > 0.0) ? 4.0 : 0.0
        // 输入框与提示信息间隔
        let textFieldSpacing: CGFloat = ((titleLabel.frame.height + textLabel.frame.height) > 0.0 && alertFields.count > 0) ? 12.0 : 0.0
        // 输入框高度
        let textFieldHeight: CGFloat = 35.0
        // 输入框之间间隔
        let textFieldInterval: CGFloat = 6.0
        // 输入框总体高度
        let textFieldTotalHeight: CGFloat = CGFloat(alertFields.count)*textFieldHeight + CGFloat(max(alertFields.count - 1, 0))*textFieldInterval
        // 内容高度
        let contentTotalHeight: CGFloat = titleLabel.frame.height + textSpacing + textLabel.frame.height + textFieldSpacing + textFieldTotalHeight
        // 内容高度 + 上下间隔
        let totalHeight: CGFloat = max(contentTotalHeight + 36.0, 75.0)
        
        titleLabel.frame.origin.y = (totalHeight - contentTotalHeight)/2.0
        textLabel.frame.origin.y = titleLabel.frame.maxY + textSpacing
        
        var y: CGFloat = textLabel.frame.maxY + textFieldSpacing
        
        // 输入框
        for (idx, alertField) in alertFields.enumerated() {
            
            let rect = CGRect(x: x, y: y, width: contentView.frame.width - x*2.0, height: textFieldHeight)
            
            let textField = alertField.textField
            textField.frame = rect
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.font = .systemFont(ofSize: 15.0, weight: .regular)
            alertField.execute()
            
            textField.frame = rect
            textField.borderStyle = .none
            textField.clipsToBounds = true
            textField.layer.cornerRadius = 6.0
            textField.layer.borderWidth = separatorHeight
            textField.layer.borderColor = separatorColor.cgColor
            if textField.leftView == nil {
                // 左视图
                let leftView = UIView(frame: .init(origin: .zero, size: .init(width: 8.0, height: textField.frame.height)))
                if let rightView = textField.rightView {
                    leftView.frame.size.width = rightView.frame.width
                }
                textField.leftView = leftView
                textField.leftViewMode = .always
            }
            if textField.rightView == nil {
                let rightView = UIView(frame: .init(origin: .zero, size: .init(width: textField.leftView!.frame.width, height: textField.frame.height)))
                textField.rightView = rightView
                textField.rightViewMode = .always
            }
            contentView.addSubview(textField)
            
            y = textField.frame.maxY + (idx < (alertFields.count - 1) ? textFieldInterval : 0.0)
        }
        
        if alertFields.isEmpty {
            // 没有输入框
            y = textLabel.frame.maxY + titleLabel.frame.minY
        } else {
            // 有输入框， 输入框与按钮间隔
            y += 10.0
        }
        
        // 分割线
        let separator = UIView()
        separator.frame.origin.y = y
        separator.frame.size = .init(width: contentView.frame.width, height: separatorHeight)
        separator.backgroundColor = separatorColor
        contentView.addSubview(separator)
        
        y = separator.frame.maxY
        
        // 按钮
        if actions.count == 1 {
            
            let button: UIButton = UIButton(type: .custom)
            button.frame.origin.y = y
            button.frame.size = .init(width: contentView.frame.width, height: actionHeight)
            button.setAttributedTitle(actions.first?.attributedTitle, for: .normal)
            button.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            
            y = button.frame.maxY
            
        } else if actions.count == 2 {
            
            let left: UIButton = UIButton(type: .custom)
            left.frame.origin.y = y
            left.frame.size = .init(width: contentView.frame.width/2.0, height: actionHeight)
            left.setAttributedTitle(actions.first?.attributedTitle, for: .normal)
            left.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
            contentView.addSubview(left)
            
            let right: UIButton = UIButton(type: .custom)
            right.tag = 1
            right.frame = left.frame
            right.frame.origin.x = left.frame.maxX
            right.setAttributedTitle(actions.last?.attributedTitle, for: .normal)
            right.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
            contentView.addSubview(right)
            
            let separator = UIView()
            separator.frame.origin.y = left.frame.minY
            separator.frame.size = .init(width: separatorHeight, height: actionHeight)
            separator.frame.origin.x = contentView.bounds.midX - separator.frame.width/2.0
            separator.backgroundColor = separatorColor
            contentView.addSubview(separator)
            
            y = left.frame.maxY
            
        } else {
            
            for (idx, action) in actions.enumerated() {
                
                let button: UIButton = UIButton(type: .custom)
                button.tag = idx
                button.frame.origin.y = y
                button.frame.size = .init(width: contentView.frame.width, height: actionHeight)
                button.setAttributedTitle(action.attributedTitle, for: .normal)
                button.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
                contentView.addSubview(button)
                
                if idx < (actions.count - 1) {
                    
                    let separator = UIView()
                    separator.frame.origin.y = button.frame.maxY
                    separator.frame.size = .init(width: contentView.frame.width, height: separatorHeight)
                    separator.backgroundColor = separatorColor
                    contentView.addSubview(separator)
                    
                    y = separator.frame.maxY
                    
                } else {
                    y = button.frame.maxY
                }
            }
        }
        
        contentView.frame.size.height = y
    }
    
    private func buildSheetView() {
        
        guard contentView.subviews.isEmpty else { return }
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            contentView.frame.size.width = frame.height > frame.width ? frame.width : ceil(frame.width/3.0*2.0)
        } else {
            // iPad
            contentView.frame.size.width = 390.0
        }
        contentView.backgroundColor = .white
        addSubview(contentView)
        
        var y: CGFloat = 0.0
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.frame.size.width = contentView.frame.width - 35.0
        titleLabel.frame.origin.x = contentView.bounds.midX - titleLabel.frame.width/2.0
        if let title = title, title.isEmpty == false {
            // 标题
            let string = NSAttributedString(string: title, attributes: [.font:UIFont.systemFont(ofSize: 18.0, weight: .medium), .foregroundColor:UIColor.black])
            titleLabel.frame.origin.y = 18.0
            titleLabel.attributedText = string
            titleLabel.frame.size.height = ceil(string.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(titleLabel)
            
            y = titleLabel.frame.maxY + titleLabel.frame.minY
        }
        
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.frame.size.width = contentView.frame.width - 35.0
        textLabel.frame.origin.x = contentView.bounds.midX - textLabel.frame.width/2.0
        let textFont: UIFont = titleLabel.frame.height > 0.0 ? .systemFont(ofSize: 13.0, weight: .regular) : .systemFont(ofSize: 16.0, weight: .medium)
        if let message = message, message.isEmpty == false {
            // 提示
            let string = NSAttributedString(string: message, attributes: [.font: textFont, .foregroundColor:UIColor.darkText.withAlphaComponent(0.88)])
            textLabel.frame.origin.y = titleLabel.frame.height > 0.0 ? (titleLabel.frame.maxY + 4.0) : 18.0
            textLabel.attributedText = string
            textLabel.frame.size.height = ceil(string.boundingRect(with: CGSize(width: textLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height)
            contentView.addSubview(textLabel)
            
            y = textLabel.frame.maxY + (titleLabel.frame.height > 0.0 ? titleLabel.frame.minY : textLabel.frame.minY)
        }
        
        var cornerRadius: CGFloat = 0.0
        if y > 0.0 {
            
            cornerRadius = 15.0
            
            let separator = UIView()
            separator.frame.origin.y = y
            separator.frame.size = .init(width: contentView.frame.width, height: separatorHeight)
            separator.backgroundColor = separatorColor
            contentView.addSubview(separator)
            
            y = separator.frame.maxY
        }
        
        var others: [MNAlertAction] = actions.filter { $0.style == .default }
        others.append(contentsOf: actions.filter { $0.style == .destructive })
        let destructives: [MNAlertAction] = actions.filter { $0.style == .cancel }
        updateActions(others + destructives)
        let groups: [[MNAlertAction]] = [others, destructives]
        
        // 创建按钮
        var tag: Int = 0
        for (index, group) in groups.enumerated() {
            for (idx, action) in group.enumerated() {
                
                let button: UIButton = UIButton(type: .custom)
                button.tag = tag
                button.frame.origin.y = y
                button.frame.size = .init(width: contentView.frame.width, height: actionHeight)
                button.setAttributedTitle(action.attributedTitle, for: .normal)
                button.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), for: .touchUpInside)
                contentView.addSubview(button)
                
                tag += 1
                
                if idx < (group.count - 1) {
                    
                    let separator = UIView()
                    separator.frame.origin.y = button.frame.maxY
                    separator.frame.size = .init(width: contentView.frame.width, height: separatorHeight)
                    separator.backgroundColor = separatorColor
                    contentView.addSubview(separator)
                    
                    y = separator.frame.maxY
                    
                } else {
                    
                    y = button.frame.maxY
                }
            }
            
            // 分割线
            if group.isEmpty == false, index < (groups.count - 1) {
                
                let separator = UIView()
                separator.frame.origin.y = y
                separator.frame.size = .init(width: contentView.frame.width, height: 10.0)
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
            separator.frame.origin.y = y
            separator.frame.size = .init(width: contentView.frame.width, height: bottomInset)
            separator.backgroundColor = separatorColor
            contentView.addSubview(separator)
            
            y = separator.frame.maxY
        }
        
        contentView.frame.size.height = y
        
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
        let alertFields = alertFields
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
        guard superview == nil, actions.isEmpty == false else { return }
        guard let window = UIWindow.mn.current else { return }
        // 注销键盘
        window.endEditing(true)
        // 取消当前
        if let alert = Self.alerts.last, let _ = alert.superview {
            alert.endEditing(true)
            alert.removeFromSuperview()
            if alert.alertFields.isEmpty == false {
                NotificationCenter.default.removeObserver(alert, name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
            }
        }
        // 显示当前
        autoresizingMask = []
        frame = window.bounds
        backgroundColor = .clear
        window.addSubview(self)
        Self.alerts.append(self)
        // 注册关闭弹窗通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.close), name: MNAlertCloseNotification, object: nil)
        switch style {
        case .alert:
            buildAlertView()
            contentView.alpha = 0.0
            contentView.autoresizingMask = []
            contentView.transform = .identity
            contentView.center = CGPoint(x: bounds.midX, y: bounds.midY)
            contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            UIView.animate(withDuration: 0.17, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 1.0
                self.contentView.transform = .identity
                self.backgroundColor = .black.withAlphaComponent(0.45)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.contentView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
                if let alertFields = self.alertFields.first {
                    // 注册键盘通知
                    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
                    alertFields.textField.becomeFirstResponder()
                }
            }
        case .actionSheet:
            buildSheetView()
            contentView.autoresizingMask = []
            contentView.transform = .identity
            contentView.frame.origin.x = bounds.midX - contentView.frame.width/2.0
            contentView.frame.origin.y = bounds.height - contentView.frame.height
            contentView.transform = CGAffineTransform(translationX: 0.0, y: contentView.frame.height)
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.transform = .identity
                self.backgroundColor = .black.withAlphaComponent(0.45)
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
            guard Self.alerts.isEmpty == false else { return }
            let alert = Self.alerts.removeLast()
            NotificationCenter.default.removeObserver(alert, name: MNAlertCloseNotification, object: nil)
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
                self.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
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
extension MNAlertView {
    
    /// 接收到关闭通知
    @objc private func close() {
        if let _ = superview {
            endEditing(true)
            removeFromSuperview()
            // 删除通知
            if alertFields.isEmpty == false {
                NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
            }
        }
        if let index = Self.alerts.firstIndex(of: self) {
            Self.alerts.remove(at: index)
            NotificationCenter.default.removeObserver(self, name: MNAlertCloseNotification, object: nil)
        }
    }
    
    /// 键盘位置变化
    /// - Parameter notify: 通知
    @objc private func keyboardWillChangeFrame(_ notify: Notification) {
        guard let superview = superview, alertFields.isEmpty == false else { return }
        guard let userInfo = notify.userInfo else { return }
        guard let rect = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let midY: CGFloat = min(CGRect(x: 0.0, y: 0.0, width: superview.frame.width, height: rect.minY).midY, bounds.midY)
        if midY == contentView.frame.midY { return }
        let autoresizingMask: UIView.AutoresizingMask = contentView.autoresizingMask
        //let duration: TimeInterval = userInfo[UIWindow.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        contentView.autoresizingMask = []
        contentView.frame.origin.y = midY - contentView.frame.height/2.0
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

