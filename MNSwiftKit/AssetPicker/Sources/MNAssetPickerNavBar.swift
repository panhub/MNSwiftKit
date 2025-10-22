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
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.leftAnchor.constraint(equalTo: leftAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            effectView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = options.mode == .light ? .gray.withAlphaComponent(0.15) : .black.withAlphaComponent(0.85)
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leftAnchor.constraint(equalTo: leftAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.rightAnchor.constraint(equalTo: rightAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.7)
        ])
        
        let back = UIButton(type: .custom)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.addTarget(self, action: #selector(backButtonTouchUpInside(_:)), for: .touchUpInside)
        let backgroundImage = AssetPickerResource.image(named: "back")?.mn.rendering(to: options.mode == .light ? .black : UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0))
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            back.configuration = configuration
            back.configurationUpdateHandler = { button in
                switch button.state {
                case .normal, .highlighted:
                    button.configuration?.background.image = backgroundImage
                default: break
                }
            }
        } else {
            back.adjustsImageWhenHighlighted = false
            back.setBackgroundImage(backgroundImage, for: .normal)
        }
        addSubview(back)
        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: topAnchor, constant: options.statusBarHeight + (options.navBarHeight - 24.0)/2.0),
            back.leftAnchor.constraint(equalTo: leftAnchor, constant: 16.0),
            back.widthAnchor.constraint(equalToConstant: 24.0),
            back.heightAnchor.constraint(equalToConstant: 24.0)
        ])
        
        badge.clipsToBounds = true
        badge.layer.cornerRadius = 15.0
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.addTarget(self, action: #selector(badgeTouchUpInside(_:)), for: .touchUpInside)
        addSubview(badge)
        NSLayoutConstraint.activate([
            badge.heightAnchor.constraint(equalToConstant: 30.0),
            badge.centerXAnchor.constraint(equalTo: centerXAnchor),
            badge.centerYAnchor.constraint(equalTo: back.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Events
extension MNAssetPickerNavBar {
    
    @objc private func backButtonTouchUpInside(_ sender: UIButton) {
        guard let delegate = delegate else { return }
        delegate.navBarCloseButtonTouchUpInside()
    }
    
    @objc private func badgeTouchUpInside(_ sender: MNAssetAlbumBadge) {
        guard let delegate = delegate else { return }
        delegate.navBarAlbumButtonTouchUpInside(sender)
    }
}
