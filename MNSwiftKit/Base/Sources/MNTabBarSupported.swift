//
//  MNTabBarSupported.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/18.
//

import UIKit
import Foundation

/// 定制标签栏
public protocol MNTabBarSupported {
    /// 按钮大小
    var bottomBarItemSize: CGSize { get }
    /// 标签栏标题
    var bottomBarItemTitle: String? { get }
    /// 标题字体
    var bottomBarItemTitleFont: UIFont { get }
    /// 标题颜色
    var bottomBarItemTitleColor: UIColor { get }
    /// 标题选择颜色
    var bottomBarItemSelectedTitleColor: UIColor { get }
    /// 标题图片间隔
    var bottomBarItemSpacing: CGFloat { get }
    /// 标签栏按钮图片
    var bottomBarItemImage: UIImage? { get }
    /// 标签栏选择按钮图片
    var bottomBarItemSelectedImage: UIImage? { get }
    /// 标签栏徽标内容填充
    var bottomBarItemBadgeContentInset: UIEdgeInsets { get }
    /// 标签栏徽标偏移量<相对于中心点>
    var bottomBarItemBadgeOffset: UIOffset { get }
    /// 标签栏徽标颜色
    var bottomBarItemBadgeColor: UIColor { get }
    /// 标签栏徽标字体
    var bottomBarItemBadgeTextFont: UIFont { get }
    /// 标签栏徽标字体颜色
    var bottomBarItemBadgeTextColor: UIColor { get }
}

extension UIViewController: MNTabBarSupported {
    /// 按钮大小
    @objc open var bottomBarItemSize: CGSize { CGSize(width: 50.0, height: 42.0) }
    /// 标签栏标题
    @objc open var bottomBarItemTitle: String? { nil }
    /// 标题字体
    @objc open var bottomBarItemTitleFont: UIFont { UIFont.systemFont(ofSize: 12.0) }
    /// 标题颜色
    @objc open var bottomBarItemTitleColor: UIColor { .gray }
    /// 标题选择颜色
    @objc open var bottomBarItemSelectedTitleColor: UIColor { .darkText }
    /// 标题图片间隔
    @objc open var bottomBarItemSpacing: CGFloat { 0.0 }
    /// 标签栏按钮图片
    @objc open var bottomBarItemImage: UIImage? { nil }
    /// 标签栏选择按钮图片
    @objc open var bottomBarItemSelectedImage: UIImage? { nil }
    /// 标签栏徽标偏移
    @objc open var bottomBarItemBadgeOffset: UIOffset { .zero }
    /// 标签栏徽标颜色
    @objc open var bottomBarItemBadgeColor: UIColor { .systemRed }
    /// 标签栏徽标字体颜色
    @objc open var bottomBarItemBadgeTextColor: UIColor { .white }
    /// 标签栏徽标字体
    @objc open var bottomBarItemBadgeTextFont: UIFont { .systemFont(ofSize: 10.0, weight: .medium) }
    /// 标签栏徽标内容填充
    @objc open var bottomBarItemBadgeContentInset: UIEdgeInsets { .init(top: 4.0, left: 7.0, bottom: 3.0, right: 7.0) }
}

extension MNNameSpaceWrapper where Base: UIViewController {
    
    /// 获取标签按钮
    public var tabBarItem: MNTabBarItem? {
        let vc = base.presentingViewController ?? base
        guard let tabBarController = vc.tabBarController else { return nil }
        guard let bottomBar = tabBarController.mn.bottomBar else { return nil }
        guard let viewControllers = tabBarController.viewControllers else { return nil }
        if let index = viewControllers.firstIndex(of: vc) {
            return bottomBar.item(for: index)
        }
        if let nav = vc.navigationController, let index = viewControllers.firstIndex(of: nav) {
            return bottomBar.item(for: index)
        }
        return nil
    }
    
    /// 角标
    public var badge: Any? {
        set {
            let vc = base.presentingViewController ?? base
            guard let tabBarController = vc.tabBarController else { return }
            guard let bottomBar = tabBarController.mn.bottomBar else { return }
            guard let viewControllers = tabBarController.viewControllers else { return }
            if let index = viewControllers.firstIndex(of: vc) {
                bottomBar.setBadge(newValue, for: index)
            } else if let nav = vc.navigationController, let index = viewControllers.firstIndex(of: nav) {
                bottomBar.setBadge(newValue, for: index)
            }
        }
        get {
            let vc = base.presentingViewController ?? base
            guard let tabBarController = vc.tabBarController else { return nil }
            guard let bottomBar = tabBarController.mn.bottomBar else { return nil }
            guard let viewControllers = tabBarController.viewControllers else { return nil }
            if let index = viewControllers.firstIndex(of: vc) {
                return bottomBar.badge(for: index)
            }
            if let nav = vc.navigationController, let index = viewControllers.firstIndex(of: nav) {
                return bottomBar.badge(for: index)
            }
            return nil
        }
    }
}
