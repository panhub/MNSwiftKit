//
//  MNTextView.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/24.
//  带占位文字的输入框

import UIKit

@objc public protocol MNTextViewUpdater:NSObjectProtocol {
    @objc optional func textViewTextDidChange(_ textView: MNTextView) -> Void
    @objc optional func textView(_ textView: MNTextView, shouldLayout height: CGFloat) -> Void
}

public class MNTextView: UITextView {
    
    /// 记录是否已监听文字变化
    private var isObserver: Bool = false
    /// 记录最低高度
    private var leastNormalHeight: CGFloat = 0.0
    /// 候选文本
    private let placeholderLabel: UILabel = UILabel()
    /// 事件代理
    public weak var updater: MNTextViewUpdater?
    
    public override var font: UIFont? {
        get { super.font }
        set {
            super.font = newValue
            placeholderLabel.font = newValue
            placeholderLabel.sizeToFit()
            setNeedsLayout()
        }
    }
    
    public override var text: String! {
        get { super.text }
        set {
            super.text = newValue
            updatePlaceholderLabel()
        }
    }
    
    public override var attributedText: NSAttributedString! {
        get { super.attributedText }
        set {
            super.attributedText = newValue
            updatePlaceholderLabel()
        }
    }
    
    public var placeholder: String? {
        get { placeholderLabel.text }
        set {
            placeholderLabel.text = newValue
            placeholderLabel.sizeToFit()
            setNeedsLayout()
        }
    }
    
    public var placeholderColor: UIColor? {
        get { placeholderLabel.textColor }
        set { placeholderLabel.textColor = newValue }
    }
    
    public var attributedPlaceholder: NSAttributedString? {
        get { placeholderLabel.attributedText }
        set {
            placeholderLabel.attributedText = newValue
            placeholderLabel.sizeToFit()
            setNeedsLayout()
        }
    }
    
    public var greatestFiniteHeight: CGFloat = 0.0 {
        didSet {
            if greatestFiniteHeight > frame.size.height {
                leastNormalHeight = frame.size.height
                if isObserver == false {
                    isObserver = true
                    addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
                }
            }
        }
    }
    
    private var placeholderFrame: CGRect {
        let contentInset = contentInset
        let textContainerInset = textContainerInset
        var frame = caretRect(for: beginningOfDocument)
        frame.size.width = bounds.inset(by: contentInset).width - frame.minX - textContainerInset.right
        frame.size.width = max(0.0, frame.width)
        return frame
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        placeholderLabel.font = font
        placeholderLabel.numberOfLines = 1
        placeholderLabel.textColor = UIColor(red: 178.0/255.0, green: 178.0/255.0, blue: 178.0/255.0, alpha: 1.0)
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    public convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if isObserver {
            removeObserver(self, forKeyPath: "contentSize")
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        var placeholderFrame = placeholderFrame
        placeholderFrame.size = placeholderLabel.frame.size
        placeholderLabel.frame = placeholderFrame
        updatePlaceholderLabel()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = superview {
            placeholderLabel.sizeToFit()
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == "contentSize", let change = change else { return }
        guard let oldSize = change[.oldKey] as? CGSize, let newSize = change[.newKey] as? CGSize else { return }
        let oldHeight: CGFloat = oldSize.height
        let newHeight: CGFloat = newSize.height
        let changeHeight: CGFloat = newHeight - oldHeight
        guard abs(changeHeight) > 0.01 else { return }
        let contentInset = contentInset
        let normalHeight = bounds.inset(by: contentInset).height
        // 增加文字时, 要先达到最大尺寸再修改
        if changeHeight > 0.0, newHeight <= normalHeight { return }
        // 删除文字时, 要先把滑动部分用完再修改
        if changeHeight < 0.0, newHeight >= normalHeight { return }
        // 计算
        var targetHeight: CGFloat = 0.0
        let leastNormalHeight: CGFloat = max(0.0, leastNormalHeight - contentInset.top - contentInset.bottom)
        let greatestNormalHeight: CGFloat = max(0.0, greatestFiniteHeight - contentInset.top - contentInset.bottom)
        if newHeight < leastNormalHeight {
            targetHeight = self.leastNormalHeight
        } else if newHeight > greatestNormalHeight {
            targetHeight = greatestFiniteHeight
        } else {
            targetHeight = min(greatestFiniteHeight, max(ceil(newHeight + contentInset.top + contentInset.bottom), self.leastNormalHeight))
        }
        // 计算变化
        guard abs(frame.height - targetHeight) > 0.01 else { return }
        // 通知变化
        updater?.textView?(self, shouldLayout: targetHeight)
    }
    
    /// 更新占位标签
    private func updatePlaceholderLabel() {
        if let text = text, text.count > 0 {
            placeholderLabel.isHidden = true
        } else {
            placeholderLabel.isHidden = false
        }
    }
}

private extension MNTextView {
    
    @objc func textDidChangeNotification(_ notify: Notification) {
        guard let object = notify.object as? UITextView, object == self else { return }
        updatePlaceholderLabel()
        updater?.textViewTextDidChange?(self)
    }
}
