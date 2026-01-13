//
//  MNTabBar.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/11.
//  标签栏

import UIKit

/// 标签栏代理
@objc public protocol MNTabBarDelegate: NSObjectProtocol {
    
    /// 标签栏选择事件
    /// - Parameters:
    ///   - tabBar: 标签栏
    ///   - index: 选择索引
    func tabBar(_ tabBar: MNTabBar, didSelectItemAt index: Int)
    
    /// 标签栏想要选中询问
    /// - Parameters:
    ///   - tabBar: 标签栏
    ///   - index: 想要选中的索引
    /// - Returns: 是否选中
    @objc optional func tabBar(_ tabBar: MNTabBar, shouldSelectItemAt index: Int) -> Bool
}

/// 标签栏
public class MNTabBar: UIView {
    /// 交互代理
    public weak var delegate: MNTabBarDelegate?
    /// 按钮
    private var items: [MNTabBarItem] = [MNTabBarItem]()
    /// 阴影线
    private let separatorView = UIView()
    /// 毛玻璃
    private let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    /// 选择索引
    public var selectedIndex: Int = 0 {
        didSet {
            for index in 0..<items.count {
                items[index].isSelected = index == selectedIndex
            }
        }
    }
    /// 按钮偏移
    public var itemOffset: UIOffset = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds.inset(by: UIEdgeInsets(top: UIScreen.main.bounds.height - MN_BOTTOM_BAR_HEIGHT, left: 0.0, bottom: 0.0, right: 0.0)))
        backgroundColor = .white
        
        // 毛玻璃
        visualView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualView)
        NSLayoutConstraint.activate([
            visualView.topAnchor.constraint(equalTo: topAnchor),
            visualView.leftAnchor.constraint(equalTo: leftAnchor),
            visualView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualView.rightAnchor.constraint(equalTo: rightAnchor)
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
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.7)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加控制器
    public func setViewControllers(_ viewControllers: [UIViewController]?) {
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
        guard let viewControllers = viewControllers else { return }
        for (idx, viewController) in viewControllers.enumerated() {
            var vc: UIViewController! = viewController
            while let controller = vc {
                if controller is UINavigationController {
                    vc = (controller as! UINavigationController).viewControllers.first
                } else if controller is UITabBarController {
                    vc = (controller as! UITabBarController).selectedViewController
                } else { break }
            }
            guard let vc = vc else { continue }
            let itemSize = vc.bottomBarItemSize
            let item = MNTabBarItem(frame: CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height))
            item.tag = idx
            item.isSelected = idx == selectedIndex
            item.title = vc.bottomBarItemTitle ?? ""
            item.selectedTitle = vc.bottomBarItemTitle ?? ""
            item.image = vc.bottomBarItemImage
            item.selectedImage = vc.bottomBarItemSelectedImage
            item.titleColor = vc.bottomBarItemTitleColor
            item.selectedTitleColor = vc.bottomBarItemSelectedTitleColor
            item.titleFont = vc.bottomBarItemTitleFont
            item.spacing = vc.bottomBarItemSpacing
            item.badgeOffset = vc.bottomBarItemBadgeOffset
            item.badgeColor = vc.bottomBarItemBadgeColor
            item.badgeTextFont = vc.bottomBarItemBadgeTextFont
            item.badgeTextColor = vc.bottomBarItemBadgeTextColor
            item.badgeContentInset = vc.bottomBarItemBadgeContentInset
            item.addTarget(self, action: #selector(itemButtonTouchUpInside(_:)), for: .touchUpInside)
            addSubview(item)
            items.append(item)
        }
        setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        let items: [MNTabBarItem] = self.items.filter { $0.isHidden == false }
        guard items.isEmpty == false else { return }
        let width: CGFloat = items.reduce(0.0) { $0 + $1.frame.width }
        let m: CGFloat = ceil((bounds.width - width)/CGFloat(items.count + 1))
        var x: CGFloat = m + itemOffset.horizontal
        for item in items {
            item.frame.origin.x = x
            if MN_BOTTOM_SAFE_HEIGHT > 0.0 {
                item.frame.origin.y = bounds.height - MN_BOTTOM_SAFE_HEIGHT - item.frame.height + itemOffset.vertical
            } else {
                item.frame.origin.y = bounds.midY - item.frame.height/2.0 + itemOffset.vertical
            }
            x = item.frame.maxX + m + itemOffset.horizontal
        }
    }
    
    /// 按钮点击事件
    /// - Parameter item: 按钮
    @objc private func itemButtonTouchUpInside(_ item: MNTabBarItem) {
        if let delegate = delegate, let shouldSelect = delegate.tabBar?(self, shouldSelectItemAt: item.tag), shouldSelect == false { return }
        selectedIndex = item.tag
        guard let delegate = delegate else { return }
        delegate.tabBar(self, didSelectItemAt: item.tag)
    }
}

// MARK: -
extension MNTabBar {
    
    /// 是否需要毛玻璃效果
    public var translucent: Bool {
        get { visualView.isHidden == false }
        set { visualView.isHidden = newValue == false }
    }
    
    /// 顶部阴影线颜色
    public var separatorColor: UIColor? {
        get { separatorView.backgroundColor }
        set { separatorView.backgroundColor = newValue }
    }
    
    ///  阴影线位置
    public var separatorInset: UIEdgeInsets {
        get {
            var insets: UIEdgeInsets = .zero
            for constraint in constraints {
                guard let firstItem = constraint.firstItem as? UIView, firstItem == separatorView else { continue }
                switch constraint.firstAttribute {
                case .left:
                    insets.left = constraint.constant
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
                case .right:
                    constraint.constant = -newValue.right
                default: break
                }
            }
        }
    }
}

// MARK: - 设置角标
extension MNTabBar {
    
    /// 设置角标
    /// - Parameters:
    ///   - badge: 角标内容
    ///   - index: 索引
    public func setBadge(_ badge: Any?, for index: Int) {
        guard let item = item(for: index) else { return }
        item.badge = badge
    }
    
    /// 获取角标
    /// - Parameter index: 索引
    /// - Returns: 角标内容
    public func badge(for index: Int) -> Any? {
        guard let item = item(for: index) else { return nil }
        return item.badge
    }
}

// MARK: - 标签按钮
extension MNTabBar {
    
    /// 获取标签按钮
    /// - Parameter index: 索引
    /// - Returns: 角标内容
    public func item(for index: Int) -> MNTabBarItem? {
        guard index < items.count else { return nil }
        return items[index]
    }
}
