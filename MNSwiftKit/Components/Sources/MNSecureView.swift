//
//  MNSecureView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/5.
//  密码视图

import UIKit

/// 密码视图代理
public protocol MNSecureViewDelegate: NSObjectProtocol {
    
    /// 密码位触摸告知
    func secureViewTouchUpInside(_ secureView: MNSecureView)
}

/// 密码选项
public class MNSecureConfiguration: NSObject {
    
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
    
    /// 密码框样式
    public var borderStyle: BorderStyle = .grid
    /// 明文/密文颜色
    public var textColor: UIColor? = .black
    /// 明文字体 密文大小
    public var textFont: UIFont? = .systemFont(ofSize: 17.0, weight: .medium)
    /// 是否以密文显示
    public var isSecureEntry: Bool = true
    /// 自定义密文密码大小
    public var cipherSize: CGSize = .init(width: 10.0, height: 10.0)
    /// 自定义密文密码颜色
    public var cipherColor: UIColor = .black
    /// 自定义密文密码图片
    public var cipherImage: UIImage?
    /// 自定义密文密码圆角大小
    public var cipherRadius: CGFloat = 5.0
    /// 自定义密码图片的缩放模式
    public var cipherMode: UIView.ContentMode = .scaleAspectFill
    /// 密码位视图背景颜色
    public var backgroundColor: UIColor?
    /// 密码位视图背景图片
    public var backgroundImage: UIImage?
    /// 密码位视图背景图片缩放模式
    public var backgroundMode: UIView.ContentMode = .scaleAspectFill
    /// 密码位视图圆角大小
    public var cornerRadius: CGFloat = 8.0
    /// 密码位视图边框颜色
    public var borderColor: UIColor? = UIColor(red: 210.0/255.0, green: 212.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    /// 密码位视图高亮边框颜色
    public var highlightBorderColor: UIColor? = UIColor(red: 210.0/255.0, green: 212.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    /// 密码位视图边框宽度
    public var borderWidth: CGFloat = 1.4
}

/// 密码视图
fileprivate class MNSecureItemView: UIImageView {
    /// 绑定的配置
    private let configuration: MNSecureConfiguration
    /// 明文密码
    private let cipherLabel = UILabel()
    /// 自定义密码
    private let cipherView = UIImageView()
    /// 边框
    private let borderLayer = CAShapeLayer()
    /// 高亮边框
    private let highlightBorderLayer = CAShapeLayer()
    /// 文字
    var text: String {
        set {
            cipherLabel.text = newValue
            cipherLabel.isHidden = configuration.isSecureEntry ? true : newValue.isEmpty
            cipherView.isHidden = configuration.isSecureEntry ? newValue.isEmpty : true
            highlightBorderLayer.isHidden = newValue.isEmpty
        }
        get {
            guard let text = cipherLabel.text else { return "" }
            return text
        }
    }
    
    /// 构造密码位视图
    /// - Parameter configuration: 配置选项
    init(configuration: MNSecureConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        clipsToBounds = true
        isUserInteractionEnabled = true
        
        cipherLabel.isHidden = true
        cipherLabel.numberOfLines = 1
        cipherLabel.textAlignment = .center
        cipherLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cipherLabel)
        NSLayoutConstraint.activate([
            cipherLabel.topAnchor.constraint(equalTo: topAnchor),
            cipherLabel.leftAnchor.constraint(equalTo: leftAnchor),
            cipherLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            cipherLabel.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        cipherView.isHidden = true
        cipherView.clipsToBounds = true
        cipherView.isUserInteractionEnabled = false
        cipherView.layer.cornerRadius = configuration.cipherRadius
        cipherView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cipherView)
        NSLayoutConstraint.activate([
            cipherView.widthAnchor.constraint(equalToConstant: configuration.cipherSize.width),
            cipherView.heightAnchor.constraint(equalToConstant: configuration.cipherSize.height),
            cipherView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cipherView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        layer.addSublayer(borderLayer)
        
        highlightBorderLayer.isHidden = true
        layer.addSublayer(highlightBorderLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        image = configuration.backgroundImage
        contentMode = configuration.backgroundMode
        backgroundColor = configuration.backgroundColor
        layer.cornerRadius = configuration.cornerRadius
    
        cipherLabel.font = configuration.textFont
        cipherLabel.textColor = configuration.textColor
        
        cipherView.image = configuration.cipherImage
        cipherView.contentMode = configuration.cipherMode
        cipherView.backgroundColor = configuration.cipherColor
        cipherView.layer.cornerRadius = configuration.cipherRadius
        
        let margin = configuration.borderWidth/2.0
        let roundedRect = bounds.inset(by: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
        for layer in [borderLayer, highlightBorderLayer] {
            var path: UIBezierPath!
            switch configuration.borderStyle {
            case .grid:
                // 网格
                path = UIBezierPath(roundedRect: roundedRect, edges: tag == 0 ? .all : [.top, .right, .bottom])
            case .square:
                // 方格
                path = UIBezierPath(roundedRect: roundedRect, cornerRadius: configuration.cornerRadius)
            case .bottomLine:
                // 阴影线
                path = UIBezierPath(roundedRect: roundedRect, edges: .bottom)
            default: break
            }
            layer.path = path?.cgPath
            layer.lineCap = .square
            layer.lineWidth = configuration.borderWidth
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = layer == borderLayer ? configuration.borderColor?.cgColor : configuration.highlightBorderColor?.cgColor
        }
    }
}

/// 密码视图
@IBDesignable public class MNSecureView: UIView {
    /// 方向
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set { stackView.axis = newValue }
    }
    /// 间隔
    @IBInspectable public var spacing: CGFloat {
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
            let arrangedSubviews = stackView.arrangedSubviews.compactMap { $0 as? MNSecureItemView }
            return arrangedSubviews.compactMap { $0.text }.joined()
        }
        set {
            for label in stackView.arrangedSubviews.compactMap({ $0 as? MNSecureItemView }) {
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
    /// 密码位数
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
                    let itemView = MNSecureItemView(configuration: configuration)
                    itemView.tag = tag
                    stackView.addArrangedSubview(itemView)
                    let control = UIControl()
                    control.translatesAutoresizingMaskIntoConstraints = false
                    control.addTarget(self, action: #selector(itemViewTouchUpInside), for: .touchUpInside)
                    itemView.addSubview(control)
                    NSLayoutConstraint.activate([
                        control.topAnchor.constraint(equalTo: itemView.topAnchor),
                        control.leftAnchor.constraint(equalTo: itemView.leftAnchor),
                        control.bottomAnchor.constraint(equalTo: itemView.bottomAnchor),
                        control.rightAnchor.constraint(equalTo: itemView.rightAnchor)
                    ])
                }
            }
            setNeedsLayout()
        }
    }
    /// 内部约束视图
    private let stackView = UIStackView()
    /// 事件代理
    public weak var delegate: MNSecureViewDelegate?
    /// 配置信息
    public lazy var configuration = MNSecureConfiguration()
    
    
    /// 构造密码输入视图
    /// - Parameters:
    ///   - frame: 位置
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // 构造内部密码位视图
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // 构造内部密码位视图
        commonInit()
    }
    
    private func commonInit() {
        
        stackView.spacing = 5.0
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}

extension MNSecureView {
    
    /// 追加字符
    /// - Parameter aString: 追加的字符串
    /// - Returns: 成功则返回当前字符
    @discardableResult
    public func append(_ aString: String) -> String? {
        var string = text
        guard aString.isEmpty == false, (string.count + aString.count) <= capacity else { return nil }
        string.append(aString)
        text = string
        return string
    }
    
    /// 向前删除一位
    public func deleteBackward() {
        var string = text
        guard string.isEmpty == false else { return }
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
    
    /// 文字点击
    @objc private func itemViewTouchUpInside() {
        guard let delegate = delegate else { return }
        delegate.secureViewTouchUpInside(self)
    }
}
