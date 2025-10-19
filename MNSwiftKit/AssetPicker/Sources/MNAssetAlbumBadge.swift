//
//  MNAssetAlbumBadge.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/30.
//  相簿角标

import UIKit

/// 相簿徽标按钮
class MNAssetAlbumBadge: UIControl {
    /// 配置信息
    private let options: MNAssetPickerOptions
    /// 标题
    private let label: UILabel = UILabel()
    /// 显示箭头
    private let arrowView: UIView = UIView()
    /// 箭头
    private let imageView: UIImageView = UIImageView()
    /// 可点击状态下宽度约束
    private lazy var ableConstraint: NSLayoutConstraint = arrowView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5.0)
    /// 可点击状态下宽度约束
    private lazy var unableConstraint: NSLayoutConstraint = label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0)
    /// 是否可选择相册
    override var isEnabled: Bool {
        get { super.isEnabled }
        set {
            super.isEnabled = newValue
            backgroundColor = newValue ? (options.mode == .light ? UIColor(white: 0.0, alpha: 0.12) : UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)) : .clear
            arrowView.isHidden = newValue == false
            ableConstraint.isActive = newValue
            unableConstraint.isActive = newValue == false
            setNeedsLayout()
        }
    }
    /// 当前是否选中状态
    override var isSelected: Bool {
        get { imageView.transform != .identity }
        set {
            let transform: CGAffineTransform = newValue ? CGAffineTransform(rotationAngle: .pi).concatenating(CGAffineTransform(translationX: 0.0, y: -1.5)) : .identity
            UIView.animate(withDuration: 0.28, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.imageView.transform = transform
            }
        }
    }
    
    /// 构造相簿徽标按钮
    /// - Parameter options: 资源选择器配置
    init(options: MNAssetPickerOptions) {
        
        self.options = options
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        label.textColor = options.mode == .light ? .black : UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        arrowView.isHidden = true
        arrowView.layer.cornerRadius = 10.0
        arrowView.clipsToBounds = true
        arrowView.isUserInteractionEnabled = false
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.backgroundColor = options.mode == .light ? .white : UIColor(red: 166.0/255.0, green: 166.0/255.0, blue: 166.0/255.0, alpha: 1.0)
        addSubview(arrowView)
        NSLayoutConstraint.activate([
            arrowView.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 7.0),
            arrowView.widthAnchor.constraint(equalToConstant: 20.0),
            arrowView.heightAnchor.constraint(equalToConstant: 20.0),
            arrowView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = AssetPickerResource.image(named: "down")
        arrowView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 11.0),
            imageView.heightAnchor.constraint(equalToConstant: 11.0),
            imageView.centerXAnchor.constraint(equalTo: arrowView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: arrowView.centerYAnchor)
        ])
        
        addConstraints([ableConstraint, unableConstraint])
        ableConstraint.isActive = false
        unableConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 切换相簿
    /// - Parameters:
    ///   - title: 标题
    ///   - animated: 是否动态展示过程
    ///   - completion: 结束回调
    func updateTitle(_ title: String?, animated: Bool = false, completion: (()->Void)? = nil) {
        let animations: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        label.text = title
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: animations) { _ in
                if let completion = completion {
                    completion()
                }
            }
        } else {
            animations()
            if let completion = completion {
                completion()
            }
        }
    }
}
