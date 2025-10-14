//
//  MNSlider.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/9.
//  进度滑块

import UIKit

// MARK: - 事件代理
@objc public protocol MNSliderDelegate: NSObjectProtocol {
    /// 想要滑动询问
    /// - Parameter slider: 滑块
    /// - Returns: 是否允许滑动
    @objc optional func sliderShouldBeginDragging(_ slider: MNSlider) -> Bool
    /// 即将开始滑动
    /// - Parameter slider: 滑块
    @objc optional func sliderWillBeginDragging(_ slider: MNSlider)
    /// 滑块滑动
    /// - Parameter slider: 滑块
    @objc optional func sliderDidDragging(_ slider: MNSlider)
    /// 停止滑动
    /// - Parameter slider: 滑块
    @objc optional func sliderDidEndDragging(_ slider: MNSlider)
    /// 想要点击询问
    /// - Parameter slider: 滑块
    /// - Returns: 是否允许滑动
    @objc optional func sliderShouldBeginTouching(_ slider: MNSlider) -> Bool
    /// 即将点击
    /// - Parameter slider: 滑块
    @objc optional func sliderWillBeginTouching(_ slider: MNSlider)
    /// 点击结束
    /// - Parameter slider: 滑块
    @objc optional func sliderDidEndTouching(_ slider: MNSlider)
}

public class MNSlider: UIView {
    /// 事件代理
    public weak var delegate: MNSliderDelegate?
    /// 进度
    public private(set) var value: Double = 0.0
    /// 是否在拖拽
    public private(set) var isDragging: Bool = false
    /// 轨迹
    private let trackView = UIView()
    /// 进度条
    private let progressView = UIView()
    /// 滑块
    private let thumbView = UIView()
    /// 滑块圆点
    private let thumbImageView = UIImageView()
    /// 轨迹高度约束
    private var trackHeightConstraint: NSLayoutConstraint!
    /// 滑块左侧约束
    private var thumbLeftConstraint: NSLayoutConstraint!
    /// 滑块宽度约束
    private var thumbWidthConstraint: NSLayoutConstraint!
    /// 进度条约束
    private var progressLeftConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackView.clipsToBounds = true
        trackView.backgroundColor = .lightGray
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)
        trackHeightConstraint = trackView.heightAnchor.constraint(equalToConstant: 4.0)
        NSLayoutConstraint.activate([
            trackView.leftAnchor.constraint(equalTo: leftAnchor),
            trackView.rightAnchor.constraint(equalTo: rightAnchor),
            trackHeightConstraint,
            trackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        progressView.backgroundColor = .white
        progressView.isUserInteractionEnabled = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(progressView)
        progressLeftConstraint = progressView.leftAnchor.constraint(equalTo: trackView.leftAnchor)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressLeftConstraint,
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 0.0)
        ])
        
        thumbView.backgroundColor = .white
//        thumbView.layer.shadowRadius = 1.0
//        thumbView.layer.shadowOpacity = 0.25
//        thumbView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//        thumbView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumbView)
        thumbLeftConstraint = thumbView.leftAnchor.constraint(equalTo: leftAnchor)
        thumbWidthConstraint = thumbView.widthAnchor.constraint(equalToConstant: 15.0)
        NSLayoutConstraint.activate([
            thumbLeftConstraint,
            thumbWidthConstraint,
            thumbView.heightAnchor.constraint(equalToConstant: 15.0),
            thumbView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        thumbImageView.clipsToBounds = true
        thumbImageView.contentMode = .scaleAspectFit
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.addSubview(thumbImageView)
        NSLayoutConstraint.activate([
            thumbImageView.topAnchor.constraint(equalTo: thumbView.topAnchor),
            thumbImageView.leftAnchor.constraint(equalTo: thumbView.leftAnchor),
            thumbImageView.bottomAnchor.constraint(equalTo: thumbView.bottomAnchor),
            thumbImageView.rightAnchor.constraint(equalTo: thumbView.rightAnchor)
        ])
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(recognizer:)))
        pan.delegate = self
        thumbView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(recognizer:)))
        tap.delegate = self
        trackView.addGestureRecognizer(tap)
        
        tap.require(toFail: pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        trackView.layer.cornerRadius = trackHeightConstraint.constant/2.0
    }
    
    public override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()
        let width = frame.width - thumbWidthConstraint.constant
        thumbLeftConstraint.constant = width*value
        progressLeftConstraint.constant = thumbLeftConstraint.constant + thumbWidthConstraint.constant/2.0
    }
    
    /// 更新进度
    private func updateProgress() {
        let width = frame.width - thumbWidthConstraint.constant
        guard width > 0.0 else { return }
        let progress = thumbLeftConstraint.constant/width
        value = Swift.max(0.0, Swift.min(1.0, progress))
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNSlider: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let delegate = delegate {
            if gestureRecognizer is UITapGestureRecognizer {
                if let isAllow = delegate.sliderShouldBeginTouching?(self), isAllow == false { return false }
            } else if gestureRecognizer is UIPanGestureRecognizer {
                if let isAllow = delegate.sliderShouldBeginDragging?(self), isAllow == false { return false }
            }
        }
        return true
    }
}

// MARK: - 交互处理
private extension MNSlider {
    
    @objc func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if let delegate = delegate {
                delegate.sliderWillBeginDragging?(self)
            }
            isDragging = true
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            recognizer.setTranslation(.zero, in: recognizer.view)
            var constant = thumbLeftConstraint.constant
            constant += translation.x
            thumbLeftConstraint.constant = Swift.max(0.0, Swift.min(constant, frame.width - thumbWidthConstraint.constant))
            progressLeftConstraint.constant = thumbLeftConstraint.constant + thumbWidthConstraint.constant/2.0
            updateProgress()
            if let delegate = delegate {
                delegate.sliderDidDragging?(self)
            }
        case .ended:
            isDragging = false
            if let delegate = delegate {
                delegate.sliderDidEndDragging?(self)
            }
        default:
            isDragging = false
        }
    }
    
    @objc func tap(recognizer: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.sliderWillBeginTouching?(self)
        }
        let location = recognizer.location(in: self)
        thumbLeftConstraint.constant = Swift.max(0.0, Swift.min(location.x, frame.width - thumbWidthConstraint.constant))
        progressLeftConstraint.constant = thumbLeftConstraint.constant + thumbWidthConstraint.constant/2.0
        updateProgress()
        if let delegate = delegate {
            delegate.sliderDidEndTouching?(self)
        }
    }
}

// MARK: - 修改进度
extension MNSlider {
    
    public func setValue<T>(_ value: T, animated: Bool = false) where T: BinaryFloatingPoint {
        setValue(Double(value), animated: animated)
    }
    
    public func updateProgress(_ progress: Double, animated: Bool = false) {
        guard isDragging == false else { return }
        value = Swift.max(0.0, Swift.min(progress, 1.0))
        let animations: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: animations)
        } else {
            animations()
        }
    }
}

// MARK: - Buid UI
extension MNSlider {
    
    // 修改轨迹
    public var trackHeight: CGFloat {
        get { trackHeightConstraint.constant }
        set { trackHeightConstraint.constant = newValue }
    }
    
    /// 轨迹颜色
    public var trackColor: UIColor? {
        get { trackView.backgroundColor }
        set { trackView.backgroundColor = newValue }
    }
    
    /// 边框颜色
    public var borderColor: UIColor? {
        get {
            guard let color = trackView.layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { trackView.layer.borderColor = newValue?.cgColor }
    }
    
    /// 边框宽度
    public var borderWidth: CGFloat {
        get { trackView.layer.borderWidth }
        set { trackView.layer.borderWidth = newValue }
    }
    
    /// 进度颜色
    public var progressColor: UIColor? {
        get { progressView.backgroundColor }
        set { progressView.backgroundColor = newValue }
    }
    
    /// 滑块颜色
    public var thumbColor: UIColor? {
        get { thumbView.backgroundColor }
        set { thumbView.backgroundColor = newValue }
    }
    
    /// 滑块图片
    public var thumbImage: UIImage? {
        get { thumbImageView.image }
        set { thumbImageView.image = newValue }
    }
    
    /// 滑块圆角
    public var thumbRadius: CGFloat {
        get { thumbView.layer.cornerRadius }
        set { thumbView.layer.cornerRadius = newValue }
    }
    
    /// 滑块阴影颜色
    public var thumbShadowColor: UIColor? {
        get {
            guard let color = thumbView.layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { thumbView.layer.shadowColor = newValue?.cgColor }
    }
}
