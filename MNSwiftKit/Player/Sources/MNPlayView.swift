//
//  MNPlayView.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/8.
//  播放器画布

import UIKit
import AVFoundation

/// 播放视图代理
@objc public protocol MNPlayViewDelegate: NSObjectProtocol {
    
    /// 询问是否响应点击手势
    /// - Parameter playView: 播放视图
    /// - Returns: 是否响应点击
    @objc optional func playViewShouldReceiveTouch(_ playView: MNPlayView) -> Bool
    
    /// 点击事件告知
    /// - Parameter playView: 播放视图
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
        get { (layer as? AVPlayerLayer)?.videoGravity ?? .resize }
        set {
            coverView.contentMode = newValue.asContentMode
            (layer as? AVPlayerLayer)?.videoGravity = newValue
        }
    }
    
    /// 点击手势
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clicked(_:)))
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
    public private(set) lazy var coverView: UIImageView = {
        let coverView = UIImageView(frame: bounds)
        coverView.clipsToBounds = true
        coverView.backgroundColor = .clear
        coverView.contentMode = .scaleAspectFit
        coverView.isUserInteractionEnabled = false
        coverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return coverView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        videoGravity = .resizeAspect
        addSubview(coverView)
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Event
extension MNPlayView {
    
    @objc private func clicked(_ recognizer: UITapGestureRecognizer) {
        delegate?.playViewTouchUpInside?(self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNPlayView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return delegate?.playViewShouldReceiveTouch?(self) ?? true
    }
}
