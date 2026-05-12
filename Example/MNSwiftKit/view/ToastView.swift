//
//  ToastView.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

enum ToastViewType: Int {
    case activity = 0, gradient = 1, arc = 2, pair = 3, info = 4, msg = 5, success = 6, error = 7, circular = 8, fill = 9
}

@IBDesignable class ToastView: UIView {
    
    private var timer: Timer!
    
    private var progress: CGFloat = 0.0
    
    private var type: ToastViewType = .activity
    
    var cancellable: Bool = false
    
    @IBInspectable var rawValue: Int = 0 {
        didSet {
            type = ToastViewType(rawValue: rawValue)!
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    
    func commonInit() {
        
        let control = UIControl()
        control.addTarget(self, action: #selector(show), for: .touchUpInside)
        control.translatesAutoresizingMaskIntoConstraints = false
        addSubview(control)
        NSLayoutConstraint.activate([
            control.topAnchor.constraint(equalTo: topAnchor),
            control.leftAnchor.constraint(equalTo: leftAnchor),
            control.bottomAnchor.constraint(equalTo: bottomAnchor),
            control.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        let label = UILabel()
        label.text = "点击重新加载"
        label.font = .systemFont(ofSize: 14.0, weight: .regular)
        label.textColor = .systemGray.withAlphaComponent(0.5)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    deinit {
        destroyTimer()
    }
    
    @objc func show() {
        switch type {
        case .activity:
            mn.showActivityToast("加载中", cancellable: cancellable, delay: 2.5) { isCancelled in
                print("加载弹窗关闭")
            }
        case .gradient:
            mn.showRotationToast("请稍后", style: .gradient, cancellable: cancellable, delay: 2.8) { isCancelled in
                print("弹窗消失")
            }
        case .arc:
            mn.showRotationToast("请稍后", style: .arc, cancellable: cancellable, delay: 3.0) { isCancelled in
                print("弹窗消失")
            }
        case .pair:
            mn.showRotationToast("请稍后", style: .pair, cancellable: cancellable, delay: 3.3) { isCancelled in
                print("弹窗消失")
            }
        case .info:
            mn.showInfoToast("提示信息", cancellable: cancellable, delay: 3.5) { isCancelled in
                print("提示信息消失")
            }
        case .msg:
            mn.showMsgToast("提示信息", cancellable: cancellable, delay: 3.8) { isCancelled in
                print("Msg信息弹窗消失")
            }
        case .circular, .fill:
            destroyTimer()
            progress = 0.0
            mn.showProgressToast("正在下载", style: type == .circular ? .circular : .fill, value: 0.0, cancellable: cancellable) { [weak self] isCancelled in
                guard let self = self else { return }
                if isCancelled {
                    self.destroyTimer()
                }
                print("进度Toast消失")
            }
            fireTimer()
        case .success:
            mn.showSuccessToast("加载成功", cancellable: cancellable, delay: 4.0) { isCancelled in
                print("成功Toast消失")
            }
        case .error:
            mn.showErrorToast("加载失败", cancellable: cancellable, delay: 4.3) { isCancelled in
                print("失败Toast消失")
            }
        }
    }
    
    /// 销毁定时器
    private func destroyTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }
    
    private func fireTimer() {
        let fireDate = Date().addingTimeInterval(0.5)
        timer = Timer(fireAt: fireDate, interval: 0.3, target: self, selector: #selector(timerStrike), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    /// 定时器事件
    @objc private func timerStrike() {
        progress += 0.05
        progress = min(1.0, progress)
        mn.showProgressToast(nil, value: progress, delay: progress >= 1.0 ? 0.5 : nil) { [weak self] isCancelled in
            guard let self = self else { return }
            if isCancelled {
                self.destroyTimer()
            }
            print("进度Toast消失")
        }
        if progress >= 1.0 {
            destroyTimer()
        }
    }
}
