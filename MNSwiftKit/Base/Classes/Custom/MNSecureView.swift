//
//  MNSecureView.swift
//  anhe
//
//  Created by 冯盼 on 2022/5/5.
//  密码视图

import UIKit

public protocol MNSecureViewDelegate: NSObjectProtocol {
    /// 密码位触摸告知
    func secureViewTouchUpInside(_ secureView: MNSecureView) -> Void
}

public class MNSecureOptions: NSObject {
    
    /// 文本样式
    public enum TextMode {
        /// 文字文本
        case normal
        /// 自定义
        case custom
    }
    
    /// 边框样式
    public enum BorderStyle {
        /// 无边框
        case none
        /// 网格
        case grid
        /// 方格
        case square
        /// 底部线条
        case bottomLine
    }
    
    /// 文本样式
    public var textMode: TextMode = .normal
    /// 边框样式
    public var borderStyle: BorderStyle = .none
    /// 背景颜色
    public var backgroundColor: UIColor?
    /// 边角
    public var cornerRadius: CGFloat = 0.0
    /// 明文/密文颜色
    public var textColor: UIColor? = .black
    /// 明文字体 密文大小
    public var font: UIFont? = .systemFont(ofSize: 17.0, weight: .medium)
    /// 是否以密文显示
    public var isSecureEntry: Bool = true
    /// 自定义内容
    public var contentImage: UIImage?
    /// 自定义内容缩放模式
    public var contentMode: UIView.ContentMode = .scaleAspectFill
    /// 背景图片
    public var backgroundImage: UIImage?
    /// 背景缩放模式
    public var backgroundMode: UIView.ContentMode = .scaleAspectFill
    /// 边框颜色
    public var borderColor: UIColor?
    /// 高亮边框颜色
    public var highlightBorderColor: UIColor?
    /// 边框宽度
    public var borderWidth: CGFloat = 1.0
}

/// 密码位视图
fileprivate class MNSecureLabel: UIControl {
    /// 绑定的配置
    let options: MNSecureOptions
    /// 明文密码
    private let textLabel: UILabel = UILabel()
    /// 密文密码(圆点)
    private let ciphertext: UIView = UIView()
    /// 背景
    private let backgroundView: UIImageView = UIImageView()
    /// 自定义密文密码
    private let textView: UIImageView = UIImageView()
    /// 边框
    private let borderLayer: CAShapeLayer = CAShapeLayer()
    /// 高亮边框
    private let highlightBorderLayer: CAShapeLayer = CAShapeLayer()
    /// 文字
    var text: String {
        get { textLabel.text ?? "" }
        set {
            textLabel.text = newValue
            updateSubviews()
        }
    }
    
    /// 构造密码位视图
    /// - Parameter options: 配置选项
    init(options: MNSecureOptions) {
        self.options = options
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        backgroundView.frame = bounds
        backgroundView.clipsToBounds = true
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundView)
        
        textView.frame = bounds
        textView.clipsToBounds = true
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(textView)
        
        textLabel.frame = bounds
        textLabel.numberOfLines = 1
        textLabel.textAlignment = .center
        textLabel.isUserInteractionEnabled = false
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(textLabel)
        
        ciphertext.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        ciphertext.center = CGPoint(x: bounds.midX, y: bounds.midY)
        ciphertext.backgroundColor = .black
        ciphertext.layer.cornerRadius = ciphertext.frame.height/2.0
        ciphertext.clipsToBounds = true
        ciphertext.isUserInteractionEnabled = false
        ciphertext.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        addSubview(ciphertext)
        
        layer.addSublayer(borderLayer)
        layer.addSublayer(highlightBorderLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let fontSize = options.font?.pointSize ?? 10.0
        let autoresizingMask = ciphertext.autoresizingMask
        ciphertext.autoresizingMask = []
        ciphertext.frame = CGRect(x: 0.0, y: 0.0, width: fontSize, height: fontSize)
        ciphertext.center = CGPoint(x: bounds.midX, y: bounds.midY)
        ciphertext.layer.cornerRadius = fontSize/2.0
        ciphertext.autoresizingMask = autoresizingMask
        ciphertext.backgroundColor = options.textColor ?? .black
        textLabel.font = options.font
        textLabel.textColor = options.textColor
        textView.image = options.contentImage
        textView.contentMode = options.contentMode
        backgroundView.image = options.backgroundImage
        backgroundView.contentMode = options.backgroundMode
        layer.cornerRadius = options.cornerRadius
        backgroundColor = options.backgroundColor
        let margin = options.borderWidth/2.0
        let roundedRect: CGRect = bounds.inset(by: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
        for layer in [borderLayer, highlightBorderLayer] {
            var path: UIBezierPath!
            switch options.borderStyle {
            case .grid:
                // 网格
                path = UIBezierPath(roundedRect: roundedRect, edges: tag == 0 ? .all : [.top, .right, .bottom])
            case .square:
                // 方格
                path = UIBezierPath(roundedRect: roundedRect, cornerRadius: options.cornerRadius)
            case .bottomLine:
                // 阴影线
                path = UIBezierPath(roundedRect: roundedRect, edges: .bottom)
            default: break
            }
            layer.path = path?.cgPath
            layer.lineCap = .square
            layer.lineWidth = options.borderWidth
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = layer == borderLayer ? options.borderColor?.cgColor : options.highlightBorderColor?.cgColor
        }
        updateSubviews()
    }
    
    /// 更新状态, 隐藏部分视图
    private func updateSubviews() {
        let isEmpty = text.isEmpty
        switch options.textMode {
        case .normal:
            // 文字
            textView.isHidden = true
            textLabel.isHidden = options.isSecureEntry ? true : isEmpty
            ciphertext.isHidden = options.isSecureEntry ? isEmpty : true
        case .custom:
            // 自定义图片
            textLabel.isHidden = true
            ciphertext.isHidden = true
            textView.isHidden = isEmpty
        }
        highlightBorderLayer.isHidden = isEmpty
    }
}

/// 密码视图
public class MNSecureView: UIView {
    /// 方向
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set { stackView.axis = newValue }
    }
    /// 间隔
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    /// 当前每个输入项大小
    public var itemSize: CGSize {
        guard let subview = stackView.arrangedSubviews.first else { return .zero }
        return subview.frame.size
    }
    /// 文字
    public var text: String {
        get {
            var characters = (stackView.arrangedSubviews as! [MNSecureLabel]).compactMap({ $0.text })
            characters.removeAll { $0 == "" }
            return characters.joined()
        }
        set {
            for label in stackView.arrangedSubviews as! [MNSecureLabel] {
                if label.tag < newValue.count {
                    let character = newValue[newValue.index(newValue.startIndex, offsetBy: label.tag)]
                    let substring = String(character)
                    label.text = substring
                } else {
                    label.text = ""
                }
            }
        }
    }
    /// 位数
    public var capacity: Int = 0 {
        didSet {
            // 删除多余的
            let subviews = stackView.arrangedSubviews.filter { $0.tag >= capacity }
            for subview in subviews.reversed() {
                stackView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
            // 添加新的
            if stackView.arrangedSubviews.count < capacity {
                for tag in stackView.arrangedSubviews.count..<capacity {
                    let label = MNSecureLabel(options: options)
                    label.tag = tag
                    label.addTarget(self, action: #selector(textLabelTouchUpInside), for: .touchUpInside)
                    stackView.addArrangedSubview(label)
                }
            }
        }
    }
    /// 内部约束视图
    private let stackView: UIStackView = UIStackView()
    /// 事件代理
    public weak var delegate: MNSecureViewDelegate?
    /// 配置信息
    public let options: MNSecureOptions = MNSecureOptions()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.frame = bounds
        stackView.spacing = 5.0
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MNSecureView {
    
    /// 追加字符
    /// - Parameter aString: 追加的字符串
    /// - Returns: 成功则返回当前字符
    @discardableResult
    public func append(_ aString: String) -> String? {
        var string = text
        guard aString.count > 0, (string.count + aString.count) <= capacity else { return nil }
        string.append(aString)
        text = string
        return string
    }
    
    /// 向前删除一位
    public func deleteBackward() {
        var string = text
        if string.isEmpty { return }
        string.removeLast()
        text = string
    }
    
    /// 删除所有文字
    public func removeAll() {
        text = ""
    }
}


// MARK: - Event
extension MNSecureView {
    
    @objc private func textLabelTouchUpInside() {
        guard let delegate = delegate else { return }
        delegate.secureViewTouchUpInside(self)
    }
}
