//
//  MNPlayView.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/8.
//  播放器画布

import UIKit
import CoreGraphics
import AVFoundation

/// 播放视图代理
@objc public protocol MNPlayViewDelegate: NSObjectProtocol {
    
    /// 询问是否响应点击手势
    /// - Parameters:
    ///   - playView: 播放器画布
    ///   - location: 点击位置
    /// - Returns: 是否响应点击
    @objc optional func playView(_ playView: MNPlayView, shouldReceiveTouchAt location: CGPoint) -> Bool
    
    /// 点击事件告知
    /// - Parameter playView: 播放器画布
    @objc optional func playViewTouchUpInside(_ playView: MNPlayView)
}

extension AVLayerVideoGravity {
    
    /// AVLayerVideoGravity => UIView.ContentMode
    public var asContentMode: UIView.ContentMode {
        switch self {
        case .resize: return .scaleToFill
        case .resizeAspect: return .scaleAspectFit
        case .resizeAspectFill: return .scaleAspectFill
        default: return .scaleToFill
        }
    }
}

/// 播放器画布
public class MNPlayView: UIView {
    
    /// 代理
    @objc public weak var delegate: MNPlayViewDelegate?
    
    /// 指定播放器画布
    public override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    /// 画面渲染方式
    @objc public var videoGravity: AVLayerVideoGravity {
        get {
            let layer = layer as! AVPlayerLayer
            return layer.videoGravity
        }
        set {
            coverView.contentMode = newValue.asContentMode
            let layer = layer as! AVPlayerLayer
            layer.videoGravity = newValue
        }
    }
    
    /// 点击手势
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchUpInside))
        tap.isEnabled = false
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    /// 是否响应点击事件
    @objc public var isTouchEnabled: Bool {
        get { tap.isEnabled }
        set { tap.isEnabled = newValue }
    }
    
    /// 封面视图
    public let coverView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        coverView.clipsToBounds = true
        coverView.backgroundColor = .clear
        coverView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coverView)
        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(equalTo: topAnchor),
            coverView.leftAnchor.constraint(equalTo: leftAnchor),
            coverView.bottomAnchor.constraint(equalTo: bottomAnchor),
            coverView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        videoGravity = .resizeAspect
        
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Event
extension MNPlayView {
    
    /// 点击事件
    @objc private func touchUpInside() {
        guard let delegate = delegate else { return }
        delegate.playViewTouchUpInside?(self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNPlayView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        guard let delegate = delegate else { return true }
        guard let allows = delegate.playView?(self, shouldReceiveTouchAt: location) else { return true }
        return allows
    }
}
