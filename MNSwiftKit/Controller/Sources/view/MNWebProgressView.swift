//
//  MNWebProgressView.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/7.
//  网页加载进度

import UIKit

/// 网页加载进度条
public class MNWebProgressView: UIView {
    /// 进度
    private var progress: Double = 0.0
    /// 进度条
    private let progressView: UIView = UIView()
    /// 消失动画延迟
    public var fadeAnimationDelay: TimeInterval = 0.5
    /// 渐隐渐现动画是时长
    public var fadeAnimationDuration: TimeInterval = 0.25
    /// 进度变化动画时长
    public var progressAnimationDuration: TimeInterval = 0.25
    /// 进度条颜色
    public override var tintColor: UIColor? {
        get { progressView.backgroundColor }
        set { progressView.backgroundColor = newValue }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = UIColor.clear
        // 内容视图
        let contentView = UIView(frame: bounds)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        // 进度条
        progressView.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: contentView.frame.height)
        progressView.autoresizingMask = .flexibleHeight
        progressView.backgroundColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 254.0/255.0, alpha: 1.0)
        contentView.addSubview(progressView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        // 更新进度
        setProgress(progress, animated: false)
    }
    
    /// 更新进度
    /// - Parameters:
    ///   - progress: 进度值
    ///   - animated: 是否使用动画
    public func setProgress(_ progress: Double, animated: Bool) {
        if progressView.alpha <= 0.0 {
            self.progress = 0.0
            progressView.alpha = 1.0
            var rect = progressView.frame
            rect.size.width = 0.0
            progressView.frame = rect
        }
        let newValue = min(1.0, max(0.0, progress))
        let oldValue = self.progress
        self.progress = progress
        let width = frame.width*newValue
        // 更新位置
        if animated, newValue > oldValue {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                var rect = self.progressView.frame
                rect.size.width = width
                self.progressView.frame = rect
            } completion: { [weak self] _ in
                guard let self = self else { return }
                if self.progress >= 1.0, self.progressView.alpha >= 1.0 {
                    // 隐藏
                    UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                        guard let self = self else { return }
                        self.progressView.alpha = 0.0
                    }
                }
            }
        } else {
            var rect = progressView.frame
            rect.size.width = width
            progressView.frame = rect
            if self.progress >= 1.0, progressView.alpha >= 1.0 {
                progressView.alpha = 0.0
            } else if self.progress < 1.0, progressView.alpha <= 0.0 {
                progressView.alpha = 1.0
            }
        }
    }
}
