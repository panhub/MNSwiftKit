//
//  MNMenuView.swift
//  MNTest
//
//  Created by 冯盼 on 2022/9/30.
//  菜单弹窗

import UIKit

/// 菜单视图配置
public class MNMenuOptions: NSObject {
    
    /// 箭头指向
    public enum ArrowDirection {
        case top, bottom, left, right
    }
    
    /// 动画类型
    public enum AnimationType {
        /// 渐现
        case fade
        /// 缩放
        case zoom
        /// 移动
        case move
    }
    
    /// 尺寸约束
    public enum Layout {
        /// 以内容约束并追加长度
        case fit(apped: CGFloat = 0.0)
        /// 以最大内容约束并追加长度
        case max(apped: CGFloat = 0.0)
        /// 指定长度
        case equal(_ value: CGFloat)
    }
    
    /// 标题字体
    public var titleColor: UIColor? = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    /// 标题字体
    public var titleFont: UIFont = .systemFont(ofSize: 16.0, weight: .medium)
    /// 箭头大小
    public  var arrowSize: CGSize = CGSize(width: 12.0, height: 10.0)
    /// 分割线尺寸 依据布局方向取值
    public var separatorSize: CGSize = CGSize(width: 1.0, height: 20.0)
    /// 分割线颜色
    public var separatorColor: UIColor? = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    /// 箭头偏移
    public var arrowOffset: UIOffset = .zero
    /// 边角大小
    public var cornerRadius: CGFloat = 5.0
    /// 布局方向
    public var axis: NSLayoutConstraint.Axis = .horizontal
    /// 内容边距
    public var contentInset: UIEdgeInsets = .zero
    /// 动画时长
    public var animationDuration: TimeInterval = 0.23
    /// 边框宽度
    public var borderWidth: CGFloat = 2.0
    /// 宽度描述
    public var widthLayout: MNMenuOptions.Layout = .max(apped: 15.0)
    /// 高度描述
    public var heightLayout: MNMenuOptions.Layout = .equal(35.0)
    /// 填充颜色
    public var visibleColor: UIColor? = UIColor(red: 76.0/255.0, green: 76.0/255.0, blue: 76.0/255.0, alpha: 1.0)
    /// 边框颜色
    public var borderColor: UIColor? = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    /// 箭头方向
    public var arrowDirection: MNMenuOptions.ArrowDirection = .top
    /// 动画类型
    public var animationType: MNMenuOptions.AnimationType = .zoom
}

/// 菜单视图
public class MNMenuView: UIView {
    /// 自身标记
    public static let Tag: Int = 131303
    /// 点击背景取消
    public var dismissWhenTapped: Bool = true
    /// 配置
    private let options: MNMenuOptions
    /// 轮廓视图
    private let shapeView: UIView = UIView()
    /// 内容视图
    private let contentView: UIView = UIView()
    /// 子菜单按钮集合
    private let stackView: UIView = UIView()
    /// 事件回调
    private var touchHandler: ((UIControl) -> Void)?
    
    /// 构造菜单视图
    /// - Parameters:
    ///   - views: 子视图集合
    ///   - options: 配置信息
    public init(arrangedViews views: [UIView], options: MNMenuOptions = MNMenuOptions()) {
        self.options = options
        super.init(frame: .zero)
        self.tag = MNMenuView.Tag
        let totalWidth: CGFloat = views.reduce(0.0) { $0 + $1.frame.width }
        let totalHeight: CGFloat = views.reduce(0.0) { $0 + $1.frame.height }
        let maxWidth: CGFloat = views.reduce(0.0) { max($0, $1.frame.width) }
        let maxHeight: CGFloat = views.reduce(0.0) { max($0, $1.frame.height) }
        stackView.frame = CGRect(x: 0.0, y: 0.0, width: options.axis == .horizontal ? totalWidth : maxWidth, height: options.axis == .horizontal ? maxHeight : totalHeight)
        stackView.clipsToBounds = true
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        for view in views {
            var rect = view.frame
            switch options.axis {
            case .horizontal:
                rect.origin.x = x
                rect.origin.y = (stackView.frame.height - rect.height)/2.0
                x = rect.maxX
            default:
                rect.origin.y = y
                rect.origin.x = (stackView.frame.width - rect.width)/2.0
                y = rect.maxY
            }
            view.frame = rect
            if let control = view as? UIControl, control.allTargets.isEmpty {
                control.addTarget(self, action: #selector(menuTouchUpInside(_:)), for: .touchUpInside)
            }
            stackView.addSubview(view)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTouchUpInside))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    /// 构造菜单视图
    /// - Parameters:
    ///   - titles: 标题集合
    ///   - options: 配置信息
    public convenience init(titles: String..., options: MNMenuOptions = MNMenuOptions()) {
        let elements: [String] = titles.reduce(into: [String]()) { $0.append($1) }
        self.init(titles: elements, options: options)
    }
    
    /// 构造菜单视图
    /// - Parameters:
    ///   - titles: 标题集合
    ///   - options: 配置信息
    public convenience init(titles: [String], options: MNMenuOptions = MNMenuOptions()) {
        let font: UIFont = options.titleFont
        let itemSizes: [CGSize] = titles.reduce(into: [CGSize]()) { $0.append(($1 as NSString).size(withAttributes: [.font:font])) }
        let maxWidth: CGFloat = itemSizes.reduce(0.0) { max($0, $1.width) }
        let maxHeight: CGFloat = itemSizes.reduce(0.0) { max($0, $1.height) }
        var arrangedViews: [UIView] = [UIView]()
        for (index, title) in titles.enumerated() {
            var itemSize = itemSizes[index]
            // 宽
            switch options.widthLayout {
            case .fit(apped: let value):
                itemSize.width += value
            case .max(apped: let value):
                itemSize.width = ceil(maxWidth + value)
            case .equal(let value):
                itemSize.width = value
            }
            // 高
            switch options.heightLayout {
            case .fit(apped: let value):
                itemSize.height += value
            case .max(apped: let value):
                itemSize.height = ceil(maxHeight + value)
            case .equal(let value):
                itemSize.height = value
            }
            let button = UIButton(type: .custom)
            button.tag = index
            button.frame = CGRect(origin: .zero, size: itemSize)
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.setTitleColor(options.titleColor, for: .normal)
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            arrangedViews.append(button)
            if index < (titles.count - 1) {
                let separator = UIView(frame: CGRect(origin: .zero, size: options.separatorSize))
                separator.isUserInteractionEnabled = false
                separator.backgroundColor = options.separatorColor
                arrangedViews.append(separator)
            }
        }
        self.init(arrangedViews: arrangedViews, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MNMenuView {
    
    /// 显示菜单视图
    /// - Parameters:
    ///   - superview: 展示的父视图
    ///   - targetView: 目标视图
    ///   - animated: 是否使用动画
    ///   - touchHandler: 按钮点击回调
    public func show(in superview: UIView? = nil, target targetView: UIView, animated: Bool = true, touched touchHandler: ((_ sender: UIControl) -> Void)? = nil) {
        guard self.superview == nil else { return }
        guard stackView.frame.size.width > 0.0, stackView.frame.size.height > 0.0 else { return }
        guard let superview = superview ?? UIWindow.current else { return }
        guard let rect = targetView.superview?.convert(targetView.frame, to: superview) else { return }
        
        frame = superview.bounds
        superview.addSubview(self)
        self.touchHandler = touchHandler
        
        let arrowSize = options.arrowSize
        let arrowOffset = options.arrowOffset
        let borderWidth = options.borderWidth
        let contentInset = options.contentInset
        let cornerRadius = options.cornerRadius
        
        var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
        
        let bezierPath: UIBezierPath = UIBezierPath()
        
        switch options.arrowDirection {
        case .top:
            contentView.frame = CGRect(x: 0.0, y: 0.0, width: stackView.frame.width + contentInset.left + contentInset.right, height: stackView.frame.height + contentInset.top + contentInset.bottom + arrowSize.height)
            stackView.frame = CGRect(x: contentInset.left, y: arrowSize.height + contentInset.top, width: stackView.frame.width, height: stackView.frame.height)
            var contentRect = contentView.frame
            contentRect.origin.x = rect.midX - arrowOffset.horizontal - contentRect.width/2.0
            contentRect.origin.y = rect.maxY + arrowOffset.vertical
            contentView.frame = contentRect
            bezierPath.move(to: CGPoint(x: borderWidth/2.0, y: arrowSize.height + borderWidth + cornerRadius))
            bezierPath.addArc(withCenter: CGPoint(x: borderWidth + cornerRadius, y: arrowSize.height + borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi, endAngle: .pi/2.0 + .pi, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width/2.0 - arrowSize.width/2.0 + borderWidth/2.0 + arrowOffset.horizontal, y: arrowSize.height + borderWidth/2.0))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width/2.0 + arrowOffset.horizontal, y: borderWidth/2.0))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width/2.0 + arrowSize.width/2.0 - borderWidth/2.0 + arrowOffset.horizontal, y: arrowSize.height + borderWidth/2.0))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: arrowSize.height + borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: arrowSize.height + borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - borderWidth/2.0, y: contentView.frame.height - borderWidth - cornerRadius))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: contentView.frame.height - borderWidth - cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: borderWidth + cornerRadius, y: contentView.frame.height - borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: borderWidth + cornerRadius, y: contentView.frame.height - borderWidth - cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            bezierPath.close()
            anchorPoint.y = 0.0
            anchorPoint.x = (contentView.frame.width/2.0 + arrowOffset.horizontal)/contentView.frame.width
        case .left:
            contentView.frame = CGRect(x: 0.0, y: 0.0, width: stackView.frame.width + contentInset.left + contentInset.right + arrowSize.height, height: stackView.frame.height + contentInset.top + contentInset.bottom)
            stackView.frame = CGRect(x: contentInset.left + arrowSize.height, y: contentInset.top, width: stackView.frame.width, height: stackView.frame.height)
            var contentRect = contentView.frame
            contentRect.origin.x = rect.maxX + arrowOffset.horizontal
            contentRect.origin.y = rect.midY - arrowOffset.vertical - contentRect.height/2.0
            contentView.frame = contentRect
            bezierPath.move(to: CGPoint(x: arrowSize.height + borderWidth/2.0, y: cornerRadius + borderWidth))
            bezierPath.addArc(withCenter: CGPoint(x: arrowSize.height + borderWidth + cornerRadius, y: borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi, endAngle: .pi/2.0 + .pi, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - borderWidth/2.0, y: contentView.frame.height - cornerRadius - borderWidth))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - cornerRadius - borderWidth, y: contentView.frame.height - cornerRadius - borderWidth), radius: cornerRadius + borderWidth/2.0, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: arrowSize.width + borderWidth + cornerRadius, y: contentView.frame.height - borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: arrowSize.height + borderWidth + cornerRadius, y: contentView.frame.height - borderWidth - cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: arrowSize.height + borderWidth/2.0, y: contentView.frame.height/2.0 + arrowSize.width/2.0 - borderWidth/2.0 + arrowOffset.vertical))
            bezierPath.addLine(to: CGPoint(x: borderWidth/2.0, y: contentView.frame.height/2.0 + arrowOffset.vertical))
            bezierPath.addLine(to: CGPoint(x: arrowSize.height + borderWidth/2.0, y: contentView.frame.height/2.0 - arrowSize.width/2.0 + borderWidth/2.0 + arrowOffset.vertical))
            bezierPath.close()
            anchorPoint.x = 0.0
            anchorPoint.y = (contentView.frame.height/2.0 + arrowOffset.vertical)/contentView.frame.height
        case .bottom:
            contentView.frame = CGRect(x: 0.0, y: 0.0, width: stackView.frame.width + contentInset.left + contentInset.right, height: stackView.frame.height + contentInset.top + contentInset.bottom + arrowSize.height)
            stackView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: stackView.frame.width, height: stackView.frame.height)
            var contentRect = contentView.frame
            contentRect.origin.x = rect.midX - arrowOffset.horizontal - contentRect.width/2.0
            contentRect.origin.y = rect.minY + arrowOffset.vertical - contentRect.height
            contentView.frame = contentRect
            bezierPath.move(to: CGPoint(x: borderWidth/2.0, y: borderWidth + cornerRadius))
            bezierPath.addArc(withCenter: CGPoint(x: borderWidth + cornerRadius, y: borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi, endAngle: .pi/2.0 + .pi, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - borderWidth/2.0, y: contentView.frame.height - arrowSize.height - borderWidth - cornerRadius))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - borderWidth - cornerRadius, y: contentView.frame.height - arrowSize.height - borderWidth - cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width/2.0 + arrowSize.width/2.0 - borderWidth/2.0 + arrowOffset.horizontal, y: contentView.frame.height - arrowSize.height - borderWidth/2.0))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width/2.0 + arrowOffset.horizontal, y: contentView.frame.height - borderWidth/2.0))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width/2.0 - arrowSize.width/2.0 + borderWidth/2.0 + arrowOffset.horizontal, y: contentView.frame.height - arrowSize.height - borderWidth/2.0))
            bezierPath.addLine(to: CGPoint(x: cornerRadius + borderWidth, y: contentView.frame.height - arrowSize.height - borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: cornerRadius + borderWidth, y: contentView.frame.height - arrowSize.height - borderWidth - cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            bezierPath.close()
            anchorPoint.y = 1.0
            anchorPoint.x = (contentView.frame.width/2.0 + arrowOffset.horizontal)/contentView.frame.width
        case .right:
            contentView.frame = CGRect(x: 0.0, y: 0.0, width: stackView.frame.width + contentInset.left + contentInset.right + arrowSize.height, height: stackView.frame.height + contentInset.top + contentInset.bottom)
            stackView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: stackView.frame.width, height: stackView.frame.height)
            var contentRect = contentView.frame
            contentRect.origin.x = rect.minX + arrowOffset.horizontal - contentRect.width
            contentRect.origin.y = rect.midY - arrowOffset.vertical - contentRect.height/2.0
            contentView.frame = contentRect
            bezierPath.move(to: CGPoint(x: borderWidth/2.0, y: cornerRadius + borderWidth))
            bezierPath.addArc(withCenter: CGPoint(x: borderWidth + cornerRadius, y: borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi, endAngle: .pi/2.0 + .pi, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - arrowSize.height - borderWidth - cornerRadius, y: borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - arrowSize.height - borderWidth - cornerRadius, y: borderWidth + cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - arrowSize.height - borderWidth/2.0, y: contentView.frame.height/2.0 - arrowSize.width/2.0 + borderWidth/2.0 + arrowOffset.vertical))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - borderWidth/2.0, y: contentView.frame.height/2.0 + arrowOffset.vertical))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - arrowSize.height - borderWidth/2.0, y: contentView.frame.height/2.0 + arrowSize.width/2.0 - borderWidth/2.0 + arrowOffset.vertical))
            bezierPath.addLine(to: CGPoint(x: contentView.frame.width - arrowSize.height - borderWidth/2.0, y: contentView.frame.height - borderWidth - cornerRadius))
            bezierPath.addArc(withCenter: CGPoint(x: contentView.frame.width - arrowSize.height - borderWidth - cornerRadius, y: contentView.frame.height - borderWidth - cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            bezierPath.addLine(to: CGPoint(x: cornerRadius + borderWidth, y: contentView.frame.height - borderWidth/2.0))
            bezierPath.addArc(withCenter: CGPoint(x: cornerRadius + borderWidth, y: contentView.frame.height - borderWidth - cornerRadius), radius: cornerRadius + borderWidth/2.0, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            bezierPath.close()
            anchorPoint.x = 1.0
            anchorPoint.y = (contentView.frame.height/2.0 + arrowOffset.vertical)/contentView.frame.height
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = bezierPath.cgPath
        maskLayer.fillColor = (options.visibleColor ?? .clear).cgColor
        maskLayer.strokeColor = (options.borderColor ?? .clear).cgColor
        maskLayer.lineJoin = .round
        maskLayer.lineCap = .round
        maskLayer.lineWidth = borderWidth
        
        shapeView.frame = contentView.bounds
        shapeView.layer.addSublayer(maskLayer)
        contentView.clipsToBounds = true
        contentView.addSubview(shapeView)
        contentView.addSubview(stackView)
        addSubview(contentView)
        
        switch options.animationType {
        case .zoom:
            let frame = contentView.frame
            let point = contentView.layer.anchorPoint
            let hMargin = anchorPoint.x - point.x
            let vMargin = anchorPoint.y - point.y
            var position = contentView.layer.position
            position.x += hMargin*frame.width
            position.y += vMargin*frame.height
            contentView.layer.anchorPoint = anchorPoint
            contentView.layer.position = position
            contentView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            UIView.animate(withDuration: animated ? options.animationDuration : .leastNormalMagnitude, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.transform = .identity
            }
        case .fade:
            contentView.alpha = 0.0
            UIView.animate(withDuration: animated ? options.animationDuration : .leastNormalMagnitude, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 1.0
            }
        case .move:
            let target = contentView.frame
            var frame = contentView.frame
            var autoresizingMask: UIView.AutoresizingMask = []
            switch options.arrowDirection {
            case .top:
                frame.size.height = 0.0
                autoresizingMask = [.flexibleTopMargin]
            case .left:
                frame.size.width = 0.0
                autoresizingMask = [.flexibleLeftMargin]
            case .bottom:
                frame.origin.y = frame.maxY
                frame.size.height = 0.0
                autoresizingMask = [.flexibleBottomMargin]
            case .right:
                frame.origin.x = frame.maxX
                frame.size.width = 0.0
                autoresizingMask = [.flexibleRightMargin]
            }
            stackView.autoresizingMask = autoresizingMask
            shapeView.autoresizingMask = autoresizingMask
            contentView.frame = frame
            UIView.animate(withDuration: animated ? options.animationDuration : .leastNormalMagnitude, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.frame = target
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.stackView.autoresizingMask = []
                self.shapeView.autoresizingMask = []
            }
        }
    }
    
    /// 取消菜单视图
    /// - Parameters:
    ///   - animated: 是否显示动画过程
    ///   - completionHandler: 结束回调
    public func dismiss(animated: Bool = true, completion completionHandler: (()->Void)? = nil) {
        switch options.animationType {
        case .zoom:
            UIView.animate(withDuration: animated ? options.animationDuration : .leastNormalMagnitude, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.removeFromSuperview()
                completionHandler?()
            }
        case .fade:
            UIView.animate(withDuration: animated ? options.animationDuration : .leastNormalMagnitude, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 0.0
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.removeFromSuperview()
                completionHandler?()
            }
        case .move:
            var target = contentView.frame
            var autoresizingMask: UIView.AutoresizingMask = []
            switch options.arrowDirection {
            case .top:
                target.size.height = 0.0
                autoresizingMask = [.flexibleTopMargin]
            case .left:
                target.size.width = 0.0
                autoresizingMask = [.flexibleLeftMargin]
            case .bottom:
                target.origin.y = target.maxY
                target.size.height = 0.0
                autoresizingMask = [.flexibleBottomMargin]
            case .right:
                target.origin.x = target.maxX
                target.size.width = 0.0
                autoresizingMask = [.flexibleRightMargin]
            }
            shapeView.autoresizingMask = autoresizingMask
            stackView.autoresizingMask = autoresizingMask
            UIView.animate(withDuration: animated ? options.animationDuration : .leastNormalMagnitude, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.frame = target
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.removeFromSuperview()
                completionHandler?()
            }
        }
    }
}

// MARK: - Dismiss & Remove
extension UIView {
    
    /// 取消自身的菜单视图
    /// - Parameters:
    ///   - animated: 是否动态展示
    ///   - completionHandler: 结束回调
    public func dismissMenu(animated: Bool = true, completion completionHandler: (()->Void)? = nil) {
        guard let menuView = viewWithTag(MNMenuView.Tag) as? MNMenuView else { return }
        menuView.dismiss(animated: animated, completion: completionHandler)
    }
    
    /// 删除菜单视图
    public func removeMenu() {
        guard let menuView = viewWithTag(MNMenuView.Tag) as? MNMenuView else { return }
        menuView.removeFromSuperview()
    }
}

// MARK: - Event
private extension MNMenuView {
    
    /// 按钮点击事件
    /// - Parameter sender: 按钮
    @objc func menuTouchUpInside(_ sender: UIControl) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.touchHandler?(sender)
        }
    }
    
    /// 背景点击事件
    @objc func backgroundTouchUpInside() {
        guard dismissWhenTapped else { return }
        dismiss()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNMenuView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        return contentView.frame.contains(location) == false
    }
}
