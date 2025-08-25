//
//  MNNavigationBar.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/14.
//  导航条

import UIKit
import Foundation
import CoreGraphics
//#if canImport(MNSwiftKitDefinition)
//import MNSwiftKitDefinition
//#endif
//#if canImport(MNSwiftKitLayout)
//import MNSwiftKitLayout
//#endif

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
    @objc optional func navigationBarShouldDrawBackBarItem() -> Bool
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

@objc public class MNNavigationBar: UIView {
    /// 按钮大小
    static let itemSize: CGFloat = 20.0
    /// 前边距
    static let leading: CGFloat = 18.0
    /// 后边距
    static let trailing: CGFloat = 18.0
    /// 事件代理
    @objc weak var delegate: MNNavigationBarDelegate?
    /// 毛玻璃视图
    private lazy var visualView: UIVisualEffectView = {
        let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualView.frame = bounds
        visualView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return visualView
    }()
    /// 导航左按钮
    @objc public private(set) lazy var leftBarItem: UIView = {
        var leftBarItem: UIView
        if let delegate = delegate, let barItem = delegate.navigationBarShouldCreateLeftBarItem?() {
            leftBarItem = barItem
        } else {
            leftBarItem = UIControl()
            leftBarItem.mn_layout.size = CGSize(width: MNNavigationBar.itemSize, height: MNNavigationBar.itemSize)
            if let delegate = delegate, (delegate.navigationBarShouldDrawBackBarItem?() ?? false) == true {
                // 返回按钮
                leftBarItem.layer.contents = BaseResource.image(named: "back")?.cgImage
                (leftBarItem as! UIControl).addTarget(self, action: #selector(leftBarItemTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
            }
        }
        leftBarItem.mn_layout.minX = MNNavigationBar.leading
        var y = (frame.height - UIApplication.StatusBarHeight - leftBarItem.frame.height)/2.0
        y = max(0.0, y)
        y += UIApplication.StatusBarHeight
        leftBarItem.mn_layout.minY = y
        leftBarItem.autoresizingMask = .flexibleTopMargin
        return leftBarItem
    }()
    /// 导航右按钮
    @objc public private(set) lazy var rightBarItem: UIView = {
        var rightBarItem: UIView
        if let delegate = delegate, let barItem = delegate.navigationBarShouldCreateRightBarItem?() {
            rightBarItem = barItem
        } else {
            rightBarItem = UIControl()
            rightBarItem.mn_layout.size = CGSize(width: MNNavigationBar.itemSize, height: MNNavigationBar.itemSize)
            (rightBarItem as! UIControl).addTarget(self, action: #selector(rightBarItemTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
        }
        var y = (frame.height - UIApplication.StatusBarHeight - rightBarItem.frame.height)/2.0
        y = max(0.0, y)
        y += UIApplication.StatusBarHeight
        rightBarItem.mn_layout.minY = y
        rightBarItem.mn_layout.maxX = frame.width - MNNavigationBar.trailing
        rightBarItem.autoresizingMask = .flexibleTopMargin
        return rightBarItem
    }()
    /// 导航底部分割线
    private lazy var separatorView: UIView = {
        let separatorView = UIView(frame: CGRect(x: 0.0, y: bounds.height - 0.7, width: bounds.width, height: 0.7))
        separatorView.autoresizingMask = .flexibleTopMargin
        if #available(iOS 13.0, *) {
            separatorView.backgroundColor = .opaqueSeparator
        } else {
            separatorView.backgroundColor = .gray.withAlphaComponent(0.15)
        }
        return separatorView
    }()
    /// 导航标题
    @objc public private(set) lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.center = CGPoint(x: frame.width/2.0, y: (frame.height - MN_STATUS_BAR_HEIGHT)/2.0 + MN_STATUS_BAR_HEIGHT)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.isUserInteractionEnabled = true
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        return titleLabel
    }()
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard subviews.isEmpty else { return }
        // 毛玻璃
        addSubview(visualView)
        // 导航左按钮
        addSubview(leftBarItem)
        // 导航右按钮
        addSubview(rightBarItem)
        // 标题视图
        addSubview(titleLabel)
        layoutTitleLabel()
        // 阴影线
        addSubview(separatorView)
        // 回调代理
        if let delegate = delegate {
            delegate.navigationBarDidLayoutSubitems?(self)
        }
    }
    
    /// 更新标题
    private func layoutTitleLabel() {
        let center: CGPoint = titleLabel.center
        let spacing: CGFloat = ceil(max(leftBarItem.frame.maxX, frame.width - rightBarItem.frame.minX)) + MNNavigationBar.trailing
        titleLabel.sizeToFit()
        titleLabel.mn_layout.width = min(ceil(titleLabel.frame.width), frame.width - spacing*2.0)
        titleLabel.mn_layout.height = min(ceil(titleLabel.frame.height), frame.height - MN_STATUS_BAR_HEIGHT)
        titleLabel.center = center
    }
}

// MARK: - Property
extension MNNavigationBar {
    
    /// 导航栏是否启用毛玻璃效果
    @objc public var translucent: Bool {
        get { visualView.isHidden == false }
        set { visualView.isHidden = newValue == false }
    }
    
    /// 导航栏标题字体
    @objc public var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
            if let _ = superview {
                layoutTitleLabel()
            }
        }
    }
    
    /// 导航栏富文本标题
    @objc public var attributedTitle: NSAttributedString? {
        get { titleLabel.attributedText }
        set {
            titleLabel.attributedText = newValue
            guard let _ = superview else { return }
            layoutTitleLabel()
        }
    }
    
    /// 导航栏标题字体
    @objc public var titleFont: UIFont? {
        get { titleLabel.font }
        set {
            titleLabel.font = newValue
            guard let _ = superview else { return }
            layoutTitleLabel()
        }
    }
    
    /// 导航栏标题颜色
    @objc public var titleColor: UIColor? {
        get { titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    
    /// 导航栏返回按钮颜色
    @objc public var backColor: UIColor? {
        get { nil }
        set {
            guard let image = BaseResource.image(named: "back") else { return }
            guard let cgImage = image.cgImage else { return }
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.translateBy(x: 0.0, y: image.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            let rect = CGRect(origin: .zero, size: image.size)
            context.clip(to: rect, mask: cgImage)
            (newValue ?? .black).setFill()
            context.fill(rect)
            let currentImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            leftItemImage = currentImage
        }
    }
    
    /// 导航栏左按钮图片
    @objc public var leftItemImage: UIImage? {
        get {
            if let imageView = leftBarItem as? UIImageView {
                return imageView.image ?? imageView.highlightedImage
            } else if let button = leftBarItem as? UIButton {
                return button.currentBackgroundImage ?? button.currentImage
            } else if let contents = leftBarItem.layer.contents {
                return UIImage(cgImage: contents as! CGImage)
            }
            return nil
        }
        set {
            if let imageView = leftBarItem as? UIImageView {
                imageView.image = newValue
            } else if let button = leftBarItem as? UIButton {
                button.setBackgroundImage(newValue, for: .normal)
            } else {
                leftBarItem.layer.contents = newValue?.cgImage
            }
        }
    }
    
    /// 导航栏右按钮图片
    @objc public var rightItemImage: UIImage? {
        get {
            if let imageView = rightBarItem as? UIImageView {
                return imageView.image ?? imageView.highlightedImage
            } else if let button = rightBarItem as? UIButton {
                return button.currentBackgroundImage ?? button.currentImage
            } else if let contents = rightBarItem.layer.contents {
                return UIImage(cgImage: contents as! CGImage)
            }
            return nil
        }
        set {
            if let imageView = rightBarItem as? UIImageView {
                imageView.image = newValue
            } else if let button = rightBarItem as? UIButton {
                button.setBackgroundImage(newValue, for: .normal)
            } else {
                rightBarItem.layer.contents = newValue?.cgImage
            }
        }
    }
    
    /// 顶部阴影线颜色
    @objc public var separatorColor: UIColor? {
        get { separatorView.backgroundColor }
        set { separatorView.backgroundColor = newValue }
    }
    
    /// 导航栏阴影线位置
    @objc public var shadowInset: UIEdgeInsets {
        get { UIEdgeInsets(top: separatorView.frame.minY, left: separatorView.frame.minX, bottom: 0.0, right: frame.width - separatorView.frame.maxX) }
        set {
            let mask = separatorView.autoresizingMask
            separatorView.autoresizingMask = []
            separatorView.mn_layout.minX = newValue.left
            separatorView.mn_layout.width = frame.width - newValue.left - newValue.right
            separatorView.autoresizingMask = mask
        }
    }
}
 
// MARK: - Event
private extension MNNavigationBar {
    
    @objc func leftBarItemTouchUpInside(_ leftBarItem: UIView) -> Void {
        delegate?.navigationBarLeftBarItemTouchUpInside?(leftBarItem)
    }
    
    @objc func rightBarItemTouchUpInside(_ rightBarItem: UIView) -> Void {
        delegate?.navigationBarRightBarItemTouchUpInside?(rightBarItem)
    }
}
