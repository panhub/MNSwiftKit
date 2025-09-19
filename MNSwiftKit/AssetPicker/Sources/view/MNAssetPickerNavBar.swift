//
//  MNAssetPickerNavBar.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/30.
//  资源选择器顶部导航栏

import UIKit

/// 资源选择器导航代理
protocol MNAssetPickerNavDelegate: NSObjectProtocol {
    
    /// 关闭按钮点击事件
    func navBarCloseButtonTouchUpInside()
    
    /// 相册点击事件
    /// - Parameter badge: 相册徽标按钮
    func navBarAlbumButtonTouchUpInside(_ badge: MNAssetAlbumBadge)
}

/// 资源选择器导航栏
class MNAssetPickerNavBar: UIView {
    /// 相簿徽标按钮
    let badge: MNAssetAlbumBadge
    /// 事件代理
    weak var delegate: MNAssetPickerNavDelegate?
    
    /// 构造导航栏
    /// - Parameter options: 资源选择器配置
    init(options: MNAssetPickerOptions) {
        
        badge = MNAssetAlbumBadge(options: options)
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: options.mode == .light ? .extraLight : .dark))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(effectView)
        addConstraints([
            NSLayoutConstraint(item: effectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: effectView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: effectView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: effectView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let backgroundImage = AssetPickerResource.image(named: "back")?.mn.rendering(to: options.mode == .light ? .black : UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0))
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            closeButton.configuration = configuration
            closeButton.configurationUpdateHandler = { button in
                switch button.state {
                case .normal, .highlighted:
                    button.configuration?.background.image = backgroundImage
                default: break
                }
            }
        } else {
            closeButton.adjustsImageWhenHighlighted = false
            closeButton.setBackgroundImage(backgroundImage, for: .normal)
        }
        closeButton.addTarget(self, action: #selector(closeButton(touchUpInside:)), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.addConstraints([
            NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0),
            NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0)
        ])
        addConstraints([
            NSLayoutConstraint(item: closeButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: (options.navBarHeight - 24.0)/2.0 + options.statusBarHeight)
        ])
        
        badge.clipsToBounds = true
        badge.layer.cornerRadius = 15.0
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.addTarget(self, action: #selector(badge(touchUpInside:)), for: .touchUpInside)
        addSubview(badge)
        badge.addConstraint(NSLayoutConstraint(item: badge, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0))
        addConstraints([
            NSLayoutConstraint(item: badge, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: badge, attribute: .centerY, relatedBy: .equal, toItem: closeButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = options.mode == .light ? .gray.withAlphaComponent(0.15) : .black.withAlphaComponent(0.85)
        addSubview(separator)
        separator.addConstraint(NSLayoutConstraint(item: separator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.7))
        addConstraints([
            NSLayoutConstraint(item: separator, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: separator, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: separator, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Events
extension MNAssetPickerNavBar {
    
    @objc private func closeButton(touchUpInside sender: UIButton) {
        guard let delegate = delegate else { return }
        delegate.navBarCloseButtonTouchUpInside()
    }
    
    @objc private func badge(touchUpInside sender: MNAssetAlbumBadge) {
        guard let delegate = delegate else { return }
        delegate.navBarAlbumButtonTouchUpInside(sender)
    }
}
