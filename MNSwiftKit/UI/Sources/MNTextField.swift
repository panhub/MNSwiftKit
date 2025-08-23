//
//  MNTextField.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/14.
//  定制输入框

import UIKit
#if canImport(MNSwiftKit_Layout)
import MNSwiftKit_Layout
#endif

public class MNTextField: UITextField {
    
    /// 占位符位置
    public enum PlaceAlignment: Int {
        /// Visually left aligned
        case left = 0
        /// Visually centered
        case center = 1
        /// Visually right aligned
        case right = 2
    }
    
    /// 左占位图
    private var leftPlaceView: UIView?
    /// 右占位图
    private var rightPlaceView: UIView?
    /// 文字占位符
    private let placeLabel: UILabel = UILabel()
    /// 占位符位置
    public var placeAlignment: PlaceAlignment = .left
    /// 占位符颜色
    public var placeColor: UIColor? {
        get { placeLabel.textColor }
        set { placeLabel.textColor = newValue }
    }
    /// 占位符字体
    public var placeFont: UIFont? {
        get { placeLabel.font }
        set {
            placeLabel.font = newValue
            placeLabel.sizeToFit()
            layoutPlaceIfNeeded()
        }
    }
    
    /// 文字
    public override var text: String? {
        get { super.text }
        set {
            super.text = newValue
            updatePlaceLabel()
            layoutPlaceIfNeeded()
        }
    }
    
    /// 富文本
    public override var attributedText: NSAttributedString? {
        get { super.attributedText }
        set {
            super.attributedText = newValue
            updatePlaceLabel()
            layoutPlaceIfNeeded()
        }
    }
    
    /// 文字位置
    public override var textAlignment: NSTextAlignment {
        get { super.textAlignment }
        set {
            super.textAlignment = newValue
            layoutPlaceIfNeeded()
        }
    }
    
    /// 占位符
    public override var placeholder: String? {
        get { placeLabel.text }
        set {
            placeLabel.text = newValue
            placeLabel.sizeToFit()
            layoutPlaceIfNeeded()
        }
    }
    
    /// 占位符富文本
    public override var attributedPlaceholder: NSAttributedString? {
        get { placeLabel.attributedText }
        set {
            placeLabel.attributedText = newValue
            placeLabel.sizeToFit()
            layoutPlaceIfNeeded()
        }
    }
    
    /// 左视图
    public override var leftView: UIView? {
        get { leftPlaceView }
        set {
            leftPlaceView?.removeFromSuperview()
            if let value = newValue {
                let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: value.frame.width, height: frame.height))
                view.autoresizingMask = .flexibleHeight
                super.leftView = view
                leftPlaceView = value
                addSubview(value)
            } else {
                leftPlaceView = nil
                super.leftView = nil
            }
            layoutPlaceIfNeeded()
        }
    }
    
    /// 左视图显示时机
    public override var leftViewMode: UITextField.ViewMode {
        get { super.leftViewMode }
        set {
            super.leftViewMode = newValue
            layoutPlaceIfNeeded()
        }
    }
    
    /// 右视图
    public override var rightView: UIView? {
        get { rightPlaceView }
        set {
            rightPlaceView?.removeFromSuperview()
            if let value = newValue {
                let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: value.frame.width, height: frame.height))
                view.autoresizingMask = .flexibleHeight
                super.rightView = view
                rightPlaceView = value
                addSubview(value)
            } else {
                rightPlaceView = nil
                super.rightView = nil
            }
            layoutPlaceIfNeeded()
        }
    }
    
    /// 右视图显示时机
    public override var rightViewMode: UITextField.ViewMode {
        get { super.rightViewMode }
        set {
            super.rightViewMode = newValue
            layoutPlaceIfNeeded()
        }
    }
    
    /// 位置
    public override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue
            layoutPlaceIfNeeded()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentVerticalAlignment = .center
        contentHorizontalAlignment = .left
        font = .systemFont(ofSize: 17.0, weight: .regular)
        
        placeLabel.font = font
        placeLabel.numberOfLines = 1
        placeLabel.isUserInteractionEnabled = false
        placeLabel.textColor = .gray.withAlphaComponent(0.68)
        addSubview(placeLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBeginEditing), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndEditing), name: UITextField.textDidEndEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutPlaceIfNeeded()
    }
    
    /// 约束占位符
    private func updatePlaceLabel() {
        placeLabel.isHidden = false
        if let text = text, text.count > 0 {
            placeLabel.isHidden = true
        }
        if let attributedText = attributedText, attributedText.length > 0 {
            placeLabel.isHidden = true
        }
        if let leftView = leftPlaceView, leftViewMode == .unlessEditing {
            leftView.isHidden = placeLabel.isHidden
            if textAlignment == .left {
                placeLabel.mn_layout.minX = leftView.isHidden ? 0.0 : leftView.mn_layout.maxX
            }
        }
        if let rightView = rightPlaceView, rightViewMode == .unlessEditing {
            rightView.isHidden = placeLabel.isHidden
            if textAlignment == .right {
                placeLabel.mn_layout.maxX = rightView.isHidden ? frame.width : rightView.mn_layout.minX
            }
        }
    }
    
    /// 更新占位符
    private func layoutPlaceIfNeeded() {
        guard let _ = superview else { return }
        placeLabel.mn_layout.midY = frame.height/2.0
        leftPlaceView?.mn_layout.midY = frame.height/2.0
        rightPlaceView?.mn_layout.midY = frame.height/2.0
        if isFirstResponder {
            // 编辑状态
            if textAlignment == .left {
                // 居左
                if let leftView = leftPlaceView {
                    // 有左视图
                    leftView.mn_layout.minX = 0.0
                    switch leftViewMode {
                    case .always, .whileEditing:
                        leftView.isHidden = false
                        placeLabel.mn_layout.minX = leftView.mn_layout.maxX
                    case .unlessEditing:
                        if placeLabel.isHidden {
                            leftView.isHidden = true
                            placeLabel.mn_layout.minX = 0.0
                        } else {
                            leftView.isHidden = false
                            placeLabel.mn_layout.minX = leftView.mn_layout.maxX
                        }
                    default:
                        leftView.isHidden = true
                        placeLabel.mn_layout.minX = 0.0
                    }
                } else {
                    // 无左视图
                    placeLabel.mn_layout.minX = 0.0
                }
                // 判断右视图
                if let rightView = rightPlaceView {
                    rightView.mn_layout.maxX = frame.width
                    switch rightViewMode {
                    case .always, .whileEditing:
                        // 显示
                        rightView.isHidden = false
                    case .unlessEditing:
                        // 依据编辑状态而定
                        rightView.isHidden = placeLabel.isHidden
                    default:
                        // 隐藏
                        rightView.isHidden = true
                    }
                }
            } else {
                // 居右
                if let rightView = rightPlaceView {
                    // 有右视图
                    rightView.mn_layout.maxX = frame.width
                    switch rightViewMode {
                    case .always, .whileEditing:
                        rightView.isHidden = false
                        placeLabel.mn_layout.maxX = rightView.mn_layout.minX
                    case .unlessEditing:
                        if placeLabel.isHidden {
                            rightView.isHidden = true
                            placeLabel.mn_layout.maxX = frame.width
                        } else {
                            rightView.isHidden = false
                            placeLabel.mn_layout.maxX = rightView.mn_layout.minX
                        }
                    default:
                        rightView.isHidden = true
                        placeLabel.mn_layout.maxX = frame.width
                    }
                } else {
                    // 无右视图
                    placeLabel.mn_layout.maxX = frame.width
                }
                // 判断左视图
                if let leftView = leftPlaceView {
                    leftView.mn_layout.minX = 0.0
                    switch leftViewMode {
                    case .always, .whileEditing:
                        // 显示
                        leftView.isHidden = false
                    case .unlessEditing:
                        // 依据编辑状态而定
                        leftView.isHidden = placeLabel.isHidden
                    default:
                        // 隐藏
                        leftView.isHidden = true
                    }
                }
            }
        } else {
            // 非编辑状态
            var alignment = placeAlignment
            if placeLabel.isHidden {
                // 有内容
                if textAlignment == .right || contentHorizontalAlignment == .right {
                    alignment = .right
                } else {
                    alignment = .left
                }
            }
            switch alignment {
            case .left:
                // 居左
                if let leftView = leftView {
                    // 有左视图
                    leftView.mn_layout.minX = 0.0
                    switch leftViewMode {
                    case .always, .unlessEditing:
                        leftView.isHidden = false
                        placeLabel.mn_layout.minX = leftView.mn_layout.maxX
                    default:
                        leftView.isHidden = true
                        placeLabel.mn_layout.minX = 0.0
                    }
                } else {
                    // 无左视图
                    placeLabel.mn_layout.minX = 0.0
                }
                // 判断右视图
                if let rightView = rightPlaceView {
                    rightView.mn_layout.maxX = frame.width
                    switch rightViewMode {
                    case .always, .unlessEditing:
                        // 显示
                        rightView.isHidden = false
                    default:
                        // 隐藏
                        rightView.isHidden = true
                    }
                }
            case .center:
                // 居中
                var leftWidth: CGFloat = 0.0
                var rightWidth: CGFloat = 0.0
                let placeWidth: CGFloat = placeLabel.frame.width
                // 判断左视图
                if let leftView = leftPlaceView {
                    switch leftViewMode {
                    case .always, .unlessEditing:
                        // 显示
                        leftView.isHidden = false
                        leftWidth = leftView.frame.width
                    default:
                        // 隐藏
                        leftView.mn_layout.minX = 0.0
                        leftView.isHidden = true
                    }
                }
                // 判断右视图
                if let rightView = rightPlaceView {
                    switch rightViewMode {
                    case .always, .unlessEditing:
                        // 显示
                        rightView.isHidden = false
                        rightWidth = rightView.frame.width
                    default:
                        // 隐藏
                        rightView.isHidden = true
                        rightView.mn_layout.maxX = frame.width
                    }
                }
                let x: CGFloat = (frame.width - leftWidth - placeWidth - rightWidth)/2.0
                if let leftView = leftPlaceView, leftView.isHidden == false {
                    leftView.mn_layout.minX = x
                }
                placeLabel.mn_layout.minX = x + leftWidth
                if let rightView = rightPlaceView, rightView.isHidden == false {
                    rightView.mn_layout.minX = x + leftWidth + placeWidth
                }
            case .right:
                // 居右
                if let rightView = rightView {
                    // 有右视图
                    rightView.mn_layout.maxX = frame.width
                    switch rightViewMode {
                    case .always, .unlessEditing:
                        rightView.isHidden = false
                        placeLabel.mn_layout.maxX = rightView.mn_layout.minX
                    default:
                        rightView.isHidden = true
                        placeLabel.mn_layout.maxX = frame.width
                    }
                } else {
                    // 无右视图
                    placeLabel.mn_layout.maxX = frame.width
                }
                // 判断左视图
                if let leftView = leftPlaceView {
                    leftView.mn_layout.minX = 0.0
                    switch leftViewMode {
                    case .always, .unlessEditing:
                        // 显示
                        leftView.isHidden = false
                    default:
                        // 隐藏
                        leftView.isHidden = true
                    }
                }
            }
        }
    }
}

// MARK: - Notification
private extension MNTextField {
    
    @objc func didBeginEditing(_ notify: Notification) {
        guard let textField = notify.object as? UITextField, textField == self else { return }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.layoutPlaceIfNeeded()
        }, completion: nil)
    }
    
    @objc func didEndEditing(_ notify: Notification) {
        guard let textField = notify.object as? UITextField, textField == self else { return }
        //guard placeLabel.isHidden == false else { return }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.layoutPlaceIfNeeded()
        }, completion: nil)
    }
    
    @objc func textDidChange(_ notify: Notification) {
        guard let textField = notify.object as? UITextField, textField == self else { return }
        updatePlaceLabel()
    }
}
