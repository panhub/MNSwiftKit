//
//  MNPopoverView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/9/30.
//  菜单弹窗

import UIKit

/// 箭头方向
public enum MNPopoverArrowDirection {
    /// 箭头向上指向目标视图
    case up
    /// 箭头向下指向目标视图
    case down
    /// 箭头向左指向目标视图
    case left
    /// 箭头向右指向目标视图
    case right
}

/// 动画类型
public enum MNPopoverAnimationType {
    /// 渐现
    case fade
    /// 缩放
    case zoom
    /// 移动
    case move
}

/// 尺寸约束
public enum MNPopoverItemConstraint {
    /// 以内容约束并追加长度
    case fit(apped: CGFloat = 0.0)
    /// 以最长内容约束并追加长度
    case longest(apped: CGFloat = 0.0)
    /// 指定长度
    case fixed(_ value: CGFloat)
}

/// 分割线约束
public struct MNPopoverDividerConstraint: Equatable {
    
    /// 上/左间隔
    public let leading: CGFloat
    /// 下/右间隔
    public let trailing: CGFloat
    /// 尺寸
    /// - 横向：分割线宽度
    /// - 纵向：分割线高度
    public let dimension: CGFloat
    
    /// 不显示分割线
    public static var zero = MNPopoverDividerConstraint(leading: 0.0, trailing: 0.0, dimension: 0.0)
    
    
    /// 构造分割线尺寸
    /// - Parameters:
    ///   - leading: 上/左间隔
    ///   - trailing: 下/右间隔
    ///   - dimension: 分割线宽度/高度
    public init(leading: CGFloat, trailing: CGFloat, dimension: CGFloat) {
        self.leading = leading
        self.trailing = trailing
        self.dimension = dimension
    }
    
    /// 构造分割线尺寸
    /// - Parameters:
    ///   - inset: 两侧间隔
    ///   - dimension: 分割线宽度/高度
    public init(inset: CGFloat, dimension: CGFloat) {
        self.leading = inset
        self.trailing = inset
        self.dimension = dimension
    }
    
    public static func == (lhs: MNPopoverDividerConstraint, rhs: MNPopoverDividerConstraint) -> Bool {
        
        return lhs.leading == rhs.leading && lhs.trailing == rhs.trailing && lhs.dimension == rhs.dimension
    }
}

/// 菜单视图配置
public struct MNPopoverConfiguration {
    /// 标题字体
    public var titleColor: UIColor? = .init(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    /// 标题字体
    public var titleFont: UIFont = .systemFont(ofSize: 16.0, weight: .medium)
    /// 箭头大小
    public  var arrowSize: CGSize = .init(width: 12.0, height: 10.0)
    /// 分割线尺寸
    public var dividerSize: CGSize = .init(width: 30.0, height: 1.0)
    /// 分割线颜色
    public var dividerColor: UIColor? = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
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
    public var itemWidth: MNPopoverItemConstraint = .longest(apped: 18.0)
    /// 高度描述
    public var itemHeight: MNPopoverItemConstraint = .fixed(35.0)
    /// 可视部分的填充颜色
    public var fillColor: UIColor? = UIColor(red: 76.0/255.0, green: 76.0/255.0, blue: 76.0/255.0, alpha: 1.0)
    /// 边框颜色
    public var borderColor: UIColor? = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    /// 箭头方向
    public var arrowDirection: MNPopoverArrowDirection = .up
    /// 动画类型
    public var animationType: MNPopoverAnimationType = .fade
    
    /// 构造弹出视图配置入口
    public init() {}
}

/// 弹出视图
public class MNPopoverView: UIView {
    /// 配置
    private let configuration: MNPopoverConfiguration
    /// 是否允许底部事件交互
    public var allowUserInteraction = false
    /// 点击背景后关闭
    public var closeWhenBackgroundTap = true
    /// 子菜单按钮集合
    private let stackView = UIView()
    /// 轮廓视图
    private let shapeView = UIView()
    /// 内容视图
    private let contentView = UIView()
    /// 轮廓曲线
    private let bezierPath = UIBezierPath()
    /// 事件回调
    private var eventHandler: ((Int) -> Void)?
    
    /// 构造菜单视图
    /// - Parameters:
    ///   - views: 子视图集合
    ///   - configuration: 配置信息
    public init(arrangedViews views: [UIView], configuration: MNPopoverConfiguration = .init()) {
        self.configuration = configuration
        super.init(frame: .zero)
        let totalWidth: CGFloat = views.reduce(0.0) { $0 + $1.frame.width }
        let totalHeight: CGFloat = views.reduce(0.0) { $0 + $1.frame.height }
        let maxWidth: CGFloat = views.reduce(0.0) { max($0, $1.frame.width) }
        let maxHeight: CGFloat = views.reduce(0.0) { max($0, $1.frame.height) }
        stackView.frame = CGRect(x: 0.0, y: 0.0, width: configuration.axis == .horizontal ? totalWidth : maxWidth, height: configuration.axis == .horizontal ? maxHeight : totalHeight)
        stackView.clipsToBounds = true
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        for view in views {
            var rect = view.frame
            switch configuration.axis {
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
                control.addTarget(self, action: #selector(itemTouchUpInside(_:)), for: .touchUpInside)
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
    public convenience init(titles: String..., configuration: MNPopoverConfiguration = .init()) {
        let elements: [String] = titles.reduce(into: [String]()) { $0.append($1) }
        self.init(titles: elements, configuration: configuration)
    }
    
    /// 构造菜单视图
    /// - Parameters:
    ///   - titles: 标题集合
    ///   - options: 配置信息
    public convenience init(titles: [String], configuration: MNPopoverConfiguration = .init()) {
        let font: UIFont = configuration.titleFont
        let itemSizes: [CGSize] = titles.reduce(into: [CGSize]()) { $0.append(($1 as NSString).size(withAttributes: [.font:font])) }
        let maxWidth: CGFloat = itemSizes.reduce(0.0) { max($0, $1.width) }
        let maxHeight: CGFloat = itemSizes.reduce(0.0) { max($0, $1.height) }
        var arrangedViews: [UIView] = []
        for (index, title) in titles.enumerated() {
            var itemSize = itemSizes[index]
            // 宽
            switch configuration.itemWidth {
            case .fit(apped: let value):
                itemSize.width += value
            case .longest(apped: let value):
                itemSize.width = ceil(maxWidth + value)
            case .fixed(let value):
                itemSize.width = value
            }
            // 高
            switch configuration.itemHeight {
            case .fit(apped: let value):
                itemSize.height += value
            case .longest(apped: let value):
                itemSize.height = ceil(maxHeight + value)
            case .fixed(let value):
                itemSize.height = value
            }
            let button = UIButton(type: .custom)
            button.tag = index
            button.frame = CGRect(origin: .zero, size: itemSize)
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.setTitleColor(configuration.titleColor, for: .normal)
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            arrangedViews.append(button)
            if index < (titles.count - 1) {
                let divider = UIView(frame: CGRect(origin: .zero, size: configuration.dividerSize))
                divider.backgroundColor = configuration.dividerColor
                arrangedViews.append(divider)
            }
        }
        self.init(arrangedViews: arrangedViews, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard allowUserInteraction else {
            return super.point(inside: point, with: event)
        }
        // 判断位置
        if isHidden || alpha <= 0.01 { return false }
        let location = convert(point, to: contentView)
        return bezierPath.contains(location)
    }
}

extension MNPopoverView {
    
    /// 显示菜单视图
    /// - Parameters:
    ///   - superview: 展示的父视图
    ///   - targetView: 目标视图
    ///   - animated: 是否使用动画
    ///   - eventHandler: 按钮点击回调(按钮索引)
    ///   - completionHandler: 展示后回调
    public func popup(in superview: UIView? = nil, target targetView: UIView, animated: Bool = true, events eventHandler: ((_ index: Int) -> Void)? = nil, completion completionHandler: (()->Void)? = nil) {
        guard self.superview == nil else { return }
        guard stackView.bounds.isNull == false, stackView.bounds.isEmpty == false else { return }
        guard let superview = superview ?? UIWindow.mn.current else { return }
        guard let rect = targetView.superview?.convert(targetView.frame, to: superview) else { return }
        
        frame = superview.bounds
        superview.addSubview(self)
        self.eventHandler = eventHandler
        
        let arrowSize = configuration.arrowSize
        let arrowOffset = configuration.arrowOffset
        let borderWidth = configuration.borderWidth
        let contentInset = configuration.contentInset
        let cornerRadius = configuration.cornerRadius
        
        let halfBorderWidth = borderWidth/2.0
        let adjustedCornerRadius = max(cornerRadius - halfBorderWidth, halfBorderWidth)
        let adjustedTriangleWidth = max(arrowSize.width - borderWidth, 0.0)
        
        var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
        
        switch configuration.arrowDirection {
        case .up:
            // 指向上
            contentView.frame.size.width = borderWidth + contentInset.left + stackView.frame.width + contentInset.right + borderWidth
            contentView.frame.size.height = arrowSize.height + borderWidth + contentInset.top + stackView.frame.height + contentInset.bottom + borderWidth
            contentView.frame.origin.x = rect.midX - contentView.frame.width/2.0 - arrowOffset.horizontal
            contentView.frame.origin.y = rect.maxY + arrowOffset.vertical
            
            stackView.frame.origin.x = borderWidth + contentInset.left
            stackView.frame.origin.y = arrowSize.height + borderWidth + contentInset.top
            
            let roundedRect = contentView.bounds.inset(by: .init(top: arrowSize.height + halfBorderWidth, left: halfBorderWidth, bottom: halfBorderWidth, right: halfBorderWidth))
            
            // 三角形顶点位置（在矩形顶部上方，考虑偏移）
            let triangleTopX = roundedRect.midX + arrowOffset.horizontal
            let triangleTopY = halfBorderWidth
            // 三角形底边左侧的点
            let triangleBaseLeftX = triangleTopX - adjustedTriangleWidth/2.0
            let triangleBaseLeftY = roundedRect.minY
            // 三角形底边右侧的点
            let triangleBaseRightX = triangleTopX + adjustedTriangleWidth/2.0
            let triangleBaseRightY = roundedRect.minY
            
            // 移动到左上角 开始绘制圆角
            bezierPath.move(to: .init(x: roundedRect.minX, y: roundedRect.minY + adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi, endAngle: .pi + .pi/2.0, clockwise: true)
            // 绘制三角
            bezierPath.addLine(to: .init(x: triangleBaseLeftX, y: triangleBaseLeftY))
            bezierPath.addLine(to: .init(x: triangleTopX, y: triangleTopY))
            bezierPath.addLine(to: .init(x: triangleBaseRightX, y: triangleBaseRightY))
            // 右上角
            bezierPath.addLine(to: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            // 右下角
            bezierPath.addLine(to: .init(x: roundedRect.maxX, y: roundedRect.maxY - adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            // 左下角
            bezierPath.addLine(to: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            
            bezierPath.close()
            
            anchorPoint.y = 0.0
            anchorPoint.x = triangleTopX/contentView.frame.width
        case .left:
            // 指向左
            contentView.frame.size.width = arrowSize.height + borderWidth + contentInset.left + stackView.frame.width + contentInset.right + borderWidth
            contentView.frame.size.height = borderWidth + contentInset.top + stackView.frame.height + contentInset.bottom + borderWidth
            contentView.frame.origin.x = rect.maxX + arrowOffset.horizontal
            contentView.frame.origin.y = rect.midY - contentView.frame.height/2.0 - arrowOffset.vertical
            
            stackView.frame.origin.x = arrowSize.height + borderWidth + contentInset.left
            stackView.frame.origin.y = borderWidth + contentInset.top
            
            let roundedRect = contentView.bounds.inset(by: .init(top: halfBorderWidth, left: arrowSize.height + halfBorderWidth, bottom: halfBorderWidth, right: halfBorderWidth))
            
            // 三角形顶点位置（在矩形顶部上方，考虑偏移）
            let triangleTopX = halfBorderWidth
            let triangleTopY = roundedRect.midY + arrowOffset.vertical
            // 三角形底边左(下)侧的点
            let triangleBaseLeftX = roundedRect.minX
            let triangleBaseLeftY = triangleTopY + adjustedTriangleWidth/2.0
            // 三角形底边右(上)侧的点
            let triangleBaseRightX = roundedRect.minX
            let triangleBaseRightY = triangleTopY - adjustedTriangleWidth/2.0
            
            // 移动到左上角 准备绘制圆角
            bezierPath.move(to: .init(x: roundedRect.minX, y: roundedRect.minY + adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi, endAngle: .pi + .pi/2.0, clockwise: true)
            // 右上角
            bezierPath.addLine(to: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            // 右下角
            bezierPath.addLine(to: .init(x: roundedRect.maxX, y: roundedRect.maxY - adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            // 左下角
            bezierPath.addLine(to: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            // 绘制三角
            bezierPath.addLine(to: .init(x: triangleBaseLeftX, y: triangleBaseLeftY))
            bezierPath.addLine(to: .init(x: triangleTopX, y: triangleTopY))
            bezierPath.addLine(to: .init(x: triangleBaseRightX, y: triangleBaseRightY))
            
            bezierPath.close()
            
            anchorPoint.x = 0.0
            anchorPoint.y = triangleTopY/contentView.frame.height
        case .down:
            // 指向下
            contentView.frame.size.width = borderWidth + contentInset.left + stackView.frame.width + contentInset.right + borderWidth
            contentView.frame.size.height = borderWidth + contentInset.top + stackView.frame.height + contentInset.bottom + borderWidth + arrowSize.height
            contentView.frame.origin.x = rect.midX - contentView.frame.width/2.0 - arrowOffset.horizontal
            contentView.frame.origin.y = rect.minY - contentView.frame.height + arrowOffset.vertical
            
            stackView.frame.origin.x = borderWidth + contentInset.left
            stackView.frame.origin.y = borderWidth + contentInset.top
            
            let roundedRect = contentView.bounds.inset(by: .init(top: halfBorderWidth, left: halfBorderWidth, bottom: halfBorderWidth + arrowSize.height, right: halfBorderWidth))
            
            // 三角形顶点位置
            let triangleTopX = roundedRect.midX + arrowOffset.horizontal
            let triangleTopY = roundedRect.maxY + arrowSize.height
            // 三角形底边左侧的点
            let triangleBaseLeftX = triangleTopX - adjustedTriangleWidth/2.0
            let triangleBaseLeftY = roundedRect.maxY
            // 三角形底边右侧的点
            let triangleBaseRightX = triangleTopX + adjustedTriangleWidth/2.0
            let triangleBaseRightY = roundedRect.maxY
            
            // 移动到左上角 开始绘制圆角
            bezierPath.move(to: .init(x: roundedRect.minX, y: roundedRect.minY + adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi, endAngle: .pi + .pi/2.0, clockwise: true)
            // 右上角
            bezierPath.addLine(to: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            // 右下角
            bezierPath.addLine(to: .init(x: roundedRect.maxX, y: roundedRect.maxY - adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            // 绘制三角
            bezierPath.addLine(to: .init(x: triangleBaseRightX, y: triangleBaseRightY))
            bezierPath.addLine(to: .init(x: triangleTopX, y: triangleTopY))
            bezierPath.addLine(to: .init(x: triangleBaseLeftX, y: triangleBaseLeftY))
            // 左下角
            bezierPath.addLine(to: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            
            bezierPath.close()
            
            anchorPoint.y = 1.0
            anchorPoint.x = triangleTopX/contentView.frame.width
        case .right:
            // 指向右
            contentView.frame.size.width = borderWidth + contentInset.left + stackView.frame.width + contentInset.right + borderWidth + arrowSize.height
            contentView.frame.size.height = borderWidth + contentInset.top + stackView.frame.height + contentInset.bottom + borderWidth
            contentView.frame.origin.x = rect.minX - contentView.frame.width + arrowOffset.horizontal
            contentView.frame.origin.y = rect.midY - contentView.frame.height/2.0 - arrowOffset.vertical
            
            stackView.frame.origin.x = borderWidth + contentInset.left
            stackView.frame.origin.y = borderWidth + contentInset.top
            
            let roundedRect = contentView.bounds.inset(by: .init(top: halfBorderWidth, left: halfBorderWidth, bottom: halfBorderWidth, right: halfBorderWidth + arrowSize.height))
            
            // 三角形顶点位置（在矩形顶部上方，考虑偏移）
            let triangleTopX = roundedRect.maxX + arrowSize.height
            let triangleTopY = roundedRect.midY + arrowOffset.vertical
            // 三角形底边左(上)侧的点
            let triangleBaseLeftX = roundedRect.maxX
            let triangleBaseLeftY = triangleTopY - adjustedTriangleWidth/2.0
            // 三角形底边右(上)侧的点
            let triangleBaseRightX = roundedRect.maxX
            let triangleBaseRightY = triangleTopY + adjustedTriangleWidth/2.0
            
            // 移动到左上角 准备绘制圆角
            bezierPath.move(to: .init(x: roundedRect.minX, y: roundedRect.minY + adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi, endAngle: .pi + .pi/2.0, clockwise: true)
            // 右上角
            bezierPath.addLine(to: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.minY + adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: -.pi/2.0, endAngle: 0.0, clockwise: true)
            // 绘制三角
            bezierPath.addLine(to: .init(x: triangleBaseLeftX, y: triangleBaseLeftY))
            bezierPath.addLine(to: .init(x: triangleTopX, y: triangleTopY))
            bezierPath.addLine(to: .init(x: triangleBaseRightX, y: triangleBaseRightY))
            // 右下角
            bezierPath.addLine(to: .init(x: roundedRect.maxX, y: roundedRect.maxY - adjustedCornerRadius))
            bezierPath.addArc(withCenter: .init(x: roundedRect.maxX - adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: 0.0, endAngle: .pi/2.0, clockwise: true)
            // 左下角
            bezierPath.addLine(to: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY))
            bezierPath.addArc(withCenter: .init(x: roundedRect.minX + adjustedCornerRadius, y: roundedRect.maxY - adjustedCornerRadius), radius: adjustedCornerRadius, startAngle: .pi/2.0, endAngle: .pi, clockwise: true)
            
            bezierPath.close()
            
            anchorPoint.x = 1.0
            anchorPoint.y = triangleTopY/contentView.frame.height
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = bezierPath.cgPath
        maskLayer.lineCap = .butt
        maskLayer.lineJoin = .round
        maskLayer.lineWidth = borderWidth
        maskLayer.fillColor = (configuration.fillColor ?? .clear).cgColor
        maskLayer.strokeColor = (configuration.borderColor ?? .clear).cgColor
        
        shapeView.frame = contentView.bounds
        shapeView.layer.addSublayer(maskLayer)
        contentView.clipsToBounds = true
        contentView.addSubview(shapeView)
        contentView.addSubview(stackView)
        addSubview(contentView)
        
        switch configuration.animationType {
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
            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.8, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.transform = .identity
            } completion: { _ in
                completionHandler?()
            }
//            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
//                guard let self = self else { return }
//                self.contentView.transform = .identity
//            } completion: { _ in
//                completionHandler?()
//            }
        case .fade:
            contentView.alpha = 0.0
            contentView.transform = .init(scaleX: 0.98, y: 0.98)
            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 1.0
                self.contentView.transform = .identity
            } completion: { _ in
                completionHandler?()
            }
        case .move:
            let target = contentView.frame
            var frame = contentView.frame
            var autoresizingMask: UIView.AutoresizingMask = []
            switch configuration.arrowDirection {
            case .up:
                frame.size.height = 0.0
                autoresizingMask = [.flexibleTopMargin]
            case .left:
                frame.size.width = 0.0
                autoresizingMask = [.flexibleLeftMargin]
            case .down:
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
//            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
//                guard let self = self else { return }
//                self.contentView.frame = target
//            } completion: { [weak self] _ in
//                guard let self = self else { return }
//                self.stackView.autoresizingMask = []
//                self.shapeView.autoresizingMask = []
//                completionHandler?()
//            }
            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.8, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.frame = target
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.stackView.autoresizingMask = []
                self.shapeView.autoresizingMask = []
                completionHandler?()
            }
        }
    }
    
    /// 关闭弹出视图
    /// - Parameters:
    ///   - animated: 是否显示动画过程
    ///   - completionHandler: 结束回调
    public func close(animated: Bool = true, completion completionHandler: (()->Void)? = nil) {
        switch configuration.animationType {
        case .zoom:
            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.removeFromSuperview()
                completionHandler?()
            }
//            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75, options: [.beginFromCurrentState, .curveLinear]) { [weak self] in
//                guard let self = self else { return }
//                self.contentView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
//            } completion: { [weak self] _ in
//                guard let self = self else { return }
//                self.removeFromSuperview()
//                completionHandler?()
//            }
        case .fade:
            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut]) { [weak self] in
                guard let self = self else { return }
                self.contentView.alpha = 0.0
                self.contentView.transform = .init(scaleX: 0.98, y: 0.98)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.removeFromSuperview()
                completionHandler?()
            }
        case .move:
            var target = contentView.frame
            var autoresizingMask: UIView.AutoresizingMask = []
            switch configuration.arrowDirection {
            case .up:
                target.size.height = 0.0
                autoresizingMask = [.flexibleTopMargin]
            case .left:
                target.size.width = 0.0
                autoresizingMask = [.flexibleLeftMargin]
            case .down:
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
//            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
//                guard let self = self else { return }
//                self.contentView.frame = target
//            } completion: { [weak self] _ in
//                guard let self = self else { return }
//                self.removeFromSuperview()
//                completionHandler?()
//            }
            UIView.animate(withDuration: animated ? configuration.animationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.8, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
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

// MARK: - Event
extension MNPopoverView {
    
    /// 弹出视图中按钮点击事件
    /// - Parameter sender: 按钮
    @objc private func itemTouchUpInside(_ sender: UIControl) {
        close(animated: true) { [weak self] in
            guard let self = self else { return }
            guard let eventHandler = self.eventHandler else { return }
            eventHandler(sender.tag)
        }
    }
    
    /// 背景点击事件
    @objc private func backgroundTouchUpInside() {
        guard closeWhenBackgroundTap else { return }
        close()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNPopoverView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        return contentView.frame.contains(location) == false
    }
}

// MARK: - Dismiss & Remove
extension MNNameSpaceWrapper where Base: UIView {
    
    /// 是否存在弹出视图
    public var isPopoverAppearing: Bool {
        base.subviews.reversed().first { $0 is MNPopoverView } != nil
    }
    
    /// 取消自身的弹出视图
    /// - Parameters:
    ///   - animated: 是否动态展示过程
    ///   - completionHandler: 结束回调
    public func closePopoverView(animated: Bool = true, completion completionHandler: (()->Void)? = nil) {
        if base is MNPopoverView {
            (base as! MNPopoverView).close(animated: animated, completion: completionHandler)
            return
        }
        guard let popoverView = base.subviews.reversed().first(where: { $0 is MNPopoverView }) as? MNPopoverView else { return }
        popoverView.close(animated: animated, completion: completionHandler)
    }
    
    /// 删除自身的弹出视图
    public func removePopoverView() {
        if base is MNPopoverView {
            (base as! MNPopoverView).removeFromSuperview()
            return
        }
        guard let popoverView = base.subviews.reversed().first(where: { $0 is MNPopoverView }) as? MNPopoverView else { return }
        popoverView.removeFromSuperview()
    }
}
