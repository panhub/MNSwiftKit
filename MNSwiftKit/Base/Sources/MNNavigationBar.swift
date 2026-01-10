//
//  MNNavigationBar.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/14.
//  导航条

import UIKit
import Foundation
import CoreFoundation

/// 导航条事件代理
@objc public protocol MNNavigationBarDelegate: NSObjectProtocol {
    
    /// 获取左按钮视图
    /// - Returns: 导航左按钮
    @objc optional func navigationBarShouldCreateLeftBarItem() -> UIView?
    
    /// 获取右按钮视图
    /// - Returns: 导航右按钮
    @objc optional func navigationBarShouldCreateRightBarItem() -> UIView?
    
    /// 是否创建戴航返回按钮
    /// - Returns: 是否创建返回按钮
    @objc optional func navigationBarShouldRenderBackBarItem() -> Bool
    
    /// 左按钮点击事件
    /// - Parameter leftBarItem: 导航左按钮
    @objc optional func navigationBarLeftBarItemTouchUpInside(_ leftBarItem: UIView!)
    
    /// 右按钮点击事件
    /// - Parameter rightBarItem: 导航右按钮
    @objc optional func navigationBarRightBarItemTouchUpInside(_ rightBarItem: UIView!)
    
    /// 已经添加完子视图
    /// - Parameter navigationBar: 导航栏
    @objc optional func navigationBarDidLayoutSubitems(_ navigationBar: MNNavigationBar)
}

public class MNNavigationBar: UIView {
    
    /// 按钮大小
    public static let itemSize: CGFloat = 20.0
    
    /// 前边距
    public static let leading: CGFloat = 18.0
    
    /// 后边距
    public static let trailing: CGFloat = 18.0
    
    /// 事件代理
    public weak var delegate: MNNavigationBarDelegate?
    
    /// 为状态栏自动适配高度
    public var adjustsForStatusBar: Bool = true
    
    /// 毛玻璃视图
    private let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    /// 导航左按钮
    public private(set) var leftBarItem: UIView!
    
    /// 导航右按钮
    public private(set) var rightBarItem: UIView!
    
    /// 导航标题
    public let titleLabel = UILabel()
    
    /// 底部分割线
    private let separatorView = UIView()
    
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard subviews.isEmpty else { return }
        
        // 毛玻璃
        visualView.frame = bounds
        visualView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualView)
        NSLayoutConstraint.activate([
            visualView.topAnchor.constraint(equalTo: topAnchor),
            visualView.leftAnchor.constraint(equalTo: leftAnchor),
            visualView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        // 顶部调整的高度
        let adjustsHeight = adjustsForStatusBar ? MN_STATUS_BAR_HEIGHT : 0.0
        
        // 左按钮
        if let delegate = delegate, let barItem = delegate.navigationBarShouldCreateLeftBarItem?() {
            leftBarItem = barItem
        } else {
            leftBarItem = UIControl(frame: .init(origin: .zero, size: .init(width: MNNavigationBar.itemSize, height: MNNavigationBar.itemSize)))
            if let delegate = delegate, let renderBackBarItem = delegate.navigationBarShouldRenderBackBarItem?(), renderBackBarItem {
                // 返回按钮
                leftBarItem.layer.contents = BaseResource.image(named: "back")?.cgImage
                (leftBarItem as! UIControl).addTarget(self, action: #selector(leftBarItemTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
            }
        }
        leftBarItem.frame.origin.x = MNNavigationBar.leading
        leftBarItem.frame.origin.y = max(0.0, (frame.height - adjustsHeight - leftBarItem.frame.height)/2.0 + adjustsHeight)
        addSubview(leftBarItem)
        
        // 右按钮
        if let delegate = delegate, let barItem = delegate.navigationBarShouldCreateRightBarItem?() {
            rightBarItem = barItem
        } else {
            rightBarItem = UIControl(frame: .init(origin: .zero, size: .init(width: MNNavigationBar.itemSize, height: MNNavigationBar.itemSize)))
            (rightBarItem as! UIControl).addTarget(self, action: #selector(rightBarItemTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
        }
        rightBarItem.frame.origin.x = frame.width - MNNavigationBar.trailing - rightBarItem.frame.width
        rightBarItem.frame.origin.y = leftBarItem.frame.midY - rightBarItem.frame.height/2.0
        addSubview(rightBarItem)
        
        // 标题
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: leftBarItem.centerYAnchor)
        ])
        
        // 分割线
        if #available(iOS 13.0, *) {
            separatorView.backgroundColor = .opaqueSeparator
        } else {
            separatorView.backgroundColor = .gray.withAlphaComponent(0.15)
        }
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 0.7),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        // 回调代理
        if let delegate = delegate {
            delegate.navigationBarDidLayoutSubitems?(self)
        }
    }
}

// MARK: - Property
extension MNNavigationBar {
    
    /// 导航栏是否启用毛玻璃效果
    public var translucent: Bool {
        get { visualView.isHidden == false }
        set { visualView.isHidden = newValue == false }
    }
    
    /// 导航栏标题字体
    public var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
        }
    }
    
    /// 导航栏富文本标题
    public var attributedTitle: NSAttributedString? {
        get { titleLabel.attributedText }
        set {
            titleLabel.attributedText = newValue
        }
    }
    
    /// 导航栏标题字体
    public var titleFont: UIFont? {
        get { titleLabel.font }
        set {
            titleLabel.font = newValue
        }
    }
    
    /// 导航栏标题颜色
    public var titleColor: UIColor? {
        get { titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    
    /// 导航栏返回按钮颜色
    public var backColor: UIColor? {
        get { nil }
        set {
            guard let image = BaseResource.image(named: "back") else { return }
            guard let backImage = image.mn.rendering(to: newValue ?? .black) else { return }
            leftItemImage = backImage
        }
    }
    
    /// 导航栏左按钮图片
    public var leftItemImage: UIImage? {
        get { leftBarItem.mn.contents }
        set { leftBarItem.mn.contents = newValue }
    }
    
    /// 导航栏右按钮图片
    public var rightItemImage: UIImage? {
        get { rightBarItem.mn.contents }
        set { rightBarItem.mn.contents = newValue }
    }
    
    /// 顶部阴影线颜色
    public var separatorColor: UIColor? {
        get { separatorView.backgroundColor }
        set { separatorView.backgroundColor = newValue }
    }
    
    /// 导航栏阴影线位置
    public var separatorInset: UIEdgeInsets {
        get {
            var insets: UIEdgeInsets = .zero
            for constraint in constraints {
                guard let firstItem = constraint.firstItem as? UIView, firstItem == separatorView else { continue }
                switch constraint.firstAttribute {
                case .left:
                    insets.left = constraint.constant
                case .bottom:
                    insets.bottom = constraint.constant
                case .right:
                    insets.right = constraint.constant
                default: break
                }
            }
            return insets
        }
        set {
            for constraint in constraints {
                guard let firstItem = constraint.firstItem as? UIView, firstItem == separatorView else { continue }
                switch constraint.firstAttribute {
                case .left:
                    constraint.constant = newValue.left
                case .bottom:
                    constraint.constant = newValue.bottom
                case .right:
                    constraint.constant = newValue.right
                default: break
                }
            }
        }
    }
}
 
// MARK: - Event
extension MNNavigationBar {
    
    /// 导航左按钮点击
    /// - Parameter leftBarItem: 左按钮
    @objc private func leftBarItemTouchUpInside(_ leftBarItem: UIView) {
        guard let delegate = delegate else { return }
        delegate.navigationBarLeftBarItemTouchUpInside?(leftBarItem)
    }
    
    /// 导航右按钮点击
    /// - Parameter rightBarItem: 右按钮
    @objc private func rightBarItemTouchUpInside(_ rightBarItem: UIView) {
        guard let delegate = delegate else { return }
        delegate.navigationBarRightBarItemTouchUpInside?(rightBarItem)
    }
}
