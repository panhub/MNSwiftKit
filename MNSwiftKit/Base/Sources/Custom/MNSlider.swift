//
//  MNSlider.swift
//  MNKit
//
//  Created by 冯盼 on 2021/10/9.
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
    /**事件代理*/
    public weak var delegate: MNSliderDelegate?
    /**进度*/
    public private(set) var value: Double = 0.0
    /**是否在拖拽*/
    public private(set) var isDragging: Bool = false
    /**内容视图*/
    private lazy var contentView: UIView = {
        let contentView = UIView(frame: bounds)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return contentView
    }()
    /**轨迹*/
    private lazy var trackView: UIView = {
        let trackView = UIView(frame: CGRect(x: 0.0, y: (contentView.frame.height - 4.0)/2.0, width: contentView.frame.width, height: 4.0))
        trackView.clipsToBounds = true
        trackView.backgroundColor = .lightGray
        trackView.layer.cornerRadius = trackView.frame.height/2.0
        trackView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        return trackView
    }()
    /**进度*/
    private lazy var progressView: UIView = {
        let progressView = UIView(frame: trackView.bounds)
        progressView.isUserInteractionEnabled = false
        progressView.autoresizingMask = .flexibleHeight
        progressView.backgroundColor = .white
        return progressView
    }()
    /**滑块*/
    private lazy var thumbView: UIView = {
        let thumbView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: contentView.frame.height, height: contentView.frame.height))
        thumbView.contentMode = .scaleAspectFit
        thumbView.backgroundColor = .white
        thumbView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        thumbView.layer.cornerRadius = thumbView.frame.width/2.0
        thumbView.layer.shadowRadius = 1.0
        thumbView.layer.shadowOpacity = 0.25
        thumbView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        thumbView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        return thumbView
    }()
    /**滑块图片*/
    private lazy var thumbImageView: UIImageView = {
        let thumbImageView = UIImageView(frame: thumbView.bounds)
        thumbImageView.clipsToBounds = true
        thumbImageView.contentMode = .scaleAspectFit
        thumbImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return thumbImageView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.minX, y: frame.minY, width: max(frame.width, 10.0), height: max(frame.height, 4.0)))
        
        addSubview(contentView)
        contentView.addSubview(trackView)
        trackView.addSubview(progressView)
        contentView.addSubview(thumbView)
        thumbView.addSubview(thumbImageView)
        
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
        updateSubviews()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNSlider: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            if let allow = delegate?.sliderShouldBeginTouching?(self), allow == false { return false}
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if let allow = delegate?.sliderShouldBeginDragging?(self), allow == false { return false}
        }
        return true
    }
}

// MARK: - 交互处理
private extension MNSlider {
    
    @objc func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            delegate?.sliderWillBeginDragging?(self)
            isDragging = true
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            recognizer.setTranslation(.zero, in: recognizer.view)
            var frame = thumbView.frame
            frame.origin.x += translation.x
            frame.origin.x = min(max(0.0, frame.minX), contentView.frame.width - frame.width)
            thumbView.frame = frame
            frame = progressView.frame
            frame.size.width = thumbView.frame.midX
            progressView.frame = frame
            updateProgress()
            delegate?.sliderDidDragging?(self)
        case .ended:
            isDragging = false
            delegate?.sliderDidEndDragging?(self)
        default:
            isDragging = false
        }
    }
    
    @objc func tap(recognizer: UITapGestureRecognizer) {
        delegate?.sliderWillBeginTouching?(self)
        let location = recognizer.location(in: contentView)
        let width = contentView.frame.width - thumbView.frame.width
        value = min(max(0.0, location.x - thumbView.frame.width/2.0), width)/width
        updateSubviews()
        delegate?.sliderDidEndTouching?(self)
    }
    
    private func updateProgress() {
        let width = contentView.frame.width - thumbView.frame.width
        value = min(max(0.0, thumbView.frame.midX - thumbView.frame.width/2.0), width)/width
    }
    
    private func updateSubviews() {
        var frame = thumbView.frame
        frame.origin.x = (contentView.frame.width - frame.width)*value
        frame.origin.x = min(max(0.0, frame.minX), contentView.frame.width - frame.width)
        thumbView.frame = frame
        frame = progressView.frame
        frame.size.width = thumbView.frame.midX
        progressView.frame = frame
    }
}

// MARK: - 修改进度
extension MNSlider {
    
    public func setValue(_ value: Float, animated: Bool = false) {
        setValue(Double(value), animated: animated)
    }
    
    public func setValue(_ value: CGFloat, animated: Bool = false) {
        setValue(Double(value), animated: animated)
    }
    
    public func setValue(_ value: Double, animated: Bool = false) {
        guard isDragging == false else { return }
        self.value = min(max(0.0, value), 1.0)
        let animations: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.updateSubviews()
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
        get { trackView.frame.height }
        set {
            if trackView.frame.height == newValue { return }
            let autoresizingMask = trackView.autoresizingMask
            trackView.autoresizingMask = []
            var frame = trackView.frame
            frame.size.height = newValue
            frame.origin.y = (contentView.frame.height - newValue)/2.0
            trackView.frame = frame
            trackView.autoresizingMask = autoresizingMask
            trackView.layer.cornerRadius = frame.height/2.0
        }
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
