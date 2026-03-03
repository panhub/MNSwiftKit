//
//  MNDefinition.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/14.
//  公共定义

import UIKit
import Foundation
import CoreFoundation

/// 屏幕尺寸最小值
public let MN_SCREEN_MIN: CGFloat = UIScreen.mn.min
/// 屏幕尺寸最大值
public let MN_SCREEN_MAX: CGFloat = UIScreen.mn.max
/// 屏幕尺寸宽
public var MN_SCREEN_WIDTH: CGFloat { UIScreen.mn.width }
/// 屏幕尺寸高
public var MN_SCREEN_HEIGHT: CGFloat { UIScreen.mn.height }

/// 状态栏高度
public let MN_STATUS_BAR_HEIGHT: CGFloat = UIApplication.mn.statusBarHeight
/// 导航栏高度
public let MN_NAV_BAR_HEIGHT: CGFloat = UINavigationBar.mn.height
/// 顶部栏总高度
public let MN_TOP_BAR_HEIGHT: CGFloat = (MN_STATUS_BAR_HEIGHT + MN_NAV_BAR_HEIGHT)
/// 底部安全区域高度
public let MN_BOTTOM_SAFE_HEIGHT: CGFloat = UIWindow.mn.safeAreaInsets.bottom
/// 底部标签栏高度
public let MN_TAB_BAR_HEIGHT: CGFloat = UITabBar.mn.height
/// 标签栏总高度
public let MN_BOTTOM_BAR_HEIGHT: CGFloat = (MN_TAB_BAR_HEIGHT + MN_BOTTOM_SAFE_HEIGHT)

/// 是否是调试模式
#if DEBUG
public let MN_IS_DEBUG: Bool = true
#else
public let MN_IS_DEBUG: Bool = false
#endif

/// 是否是模拟器
#if arch(i386) || arch(x86_64) || targetEnvironment(simulator)
public let MN_IS_SIMULATOR: Bool = true
#else
public let MN_IS_SIMULATOR: Bool = false
#endif
