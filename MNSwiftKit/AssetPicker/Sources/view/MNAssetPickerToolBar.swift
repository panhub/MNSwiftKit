//
//  MNAssetPickerToolBar.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/1/30.
//  资源选择器底部控制栏

import UIKit

/// 资源选择器底部控制栏代理
protocol MNAssetPickerToolDelegate: NSObjectProtocol {
    /// 清除事件
    /// - Parameter toolBar: 资源选择器底部控制栏
    func clearButtonTouchUpInside(_ toolBar: MNAssetPickerToolBar) -> Void
    /// 预览事件
    /// - Parameter toolBar: 资源选择器底部控制栏
    func previewButtonTouchUpInside(_ toolBar: MNAssetPickerToolBar) -> Void
    /// 确定事件
    /// - Parameter toolBar: 资源选择器底部控制栏
    func doneButtonTouchUpInside(_ toolBar: MNAssetPickerToolBar) -> Void
}

class MNAssetPickerToolBar: UIView {
    /// 按钮无效颜色
    private let disabledColor: UIColor
    /// 资源选择器配置模型
    private let options: MNAssetPickerOptions
    /// 原图按钮
    weak var delegate: MNAssetPickerToolDelegate?
    /// 清除
    private let clearButton: UIButton = UIButton(type: .custom)
    /// 确定
    private let doneButton: UIButton = UIButton(type: .custom)
    /// 预览
    private let previewButton: UIButton = UIButton(type: .custom)
    /// 确定按钮宽度约束
    private lazy var doneWidthLayout: NSLayoutConstraint = NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)
    
    /// 构造资源选择器底部控制栏
    /// - Parameter options: 资源选择器配置模型
    init(options: MNAssetPickerOptions) {
        
        self.options = options
        disabledColor = options.mode == .light ? UIColor(white: 0.0, alpha: 0.12) : UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    
        super.init(frame: .zero)
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: options.mode == .light ? .extraLight : .dark))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(effectView)
        addConstraints([
            NSLayoutConstraint(item: effectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: effectView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: effectView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: effectView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = options.mode == .light ? .gray.withAlphaComponent(0.15) : .black.withAlphaComponent(0.85)
        addSubview(separator)
        separator.addConstraint(NSLayoutConstraint(item: separator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.7))
        addConstraints([
            NSLayoutConstraint(item: separator, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: separator, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: separator, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        clearButton.isEnabled = false
        clearButton.setTitle("清空", for: .normal)
        clearButton.setTitleColor(options.themeColor, for: .normal)
        clearButton.setTitleColor(disabledColor, for: .disabled)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .medium)
        clearButton.contentHorizontalAlignment = .left
        clearButton.contentVerticalAlignment = .center
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        addSubview(clearButton)
        clearButton.addConstraints([
            NSLayoutConstraint(item: clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0),
            NSLayoutConstraint(item: clearButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32.0)
        ])
        addConstraints([NSLayoutConstraint(item: clearButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 18.0), NSLayoutConstraint(item: clearButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: MN_BOTTOM_SAFE_HEIGHT > 0.0 ? (options.bottomBarHeight - MN_BOTTOM_SAFE_HEIGHT - 32.0) : (options.bottomBarHeight - 32.0)/2.0)])
        
        previewButton.isEnabled = false
        previewButton.setTitle("预览", for: .normal)
        previewButton.setTitleColor(options.themeColor, for: .normal)
        previewButton.setTitleColor(disabledColor, for: .disabled)
        previewButton.titleLabel?.font = clearButton.titleLabel?.font
        previewButton.contentVerticalAlignment = .center
        previewButton.contentHorizontalAlignment = .center
        previewButton.isHidden = options.allowsPreview == false
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.addTarget(self, action: #selector(preview), for: .touchUpInside)
        addSubview(previewButton)
        addConstraints([
            NSLayoutConstraint(item: previewButton, attribute: .width, relatedBy: .equal, toItem: clearButton, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: previewButton, attribute: .height, relatedBy: .equal, toItem: clearButton, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: previewButton, attribute: .centerY, relatedBy: .equal, toItem: clearButton, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: previewButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        ])
        
        doneButton.isEnabled = false
        doneButton.clipsToBounds = true
        doneButton.layer.cornerRadius = 4.0
        doneButton.setTitle("确定", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .medium)
        doneButton.setTitleColor(UIColor(red:251.0/255.0, green:251.0/255.0, blue:251.0/255.0, alpha:1.0), for: .normal)
        doneButton.setTitleColor(options.mode == .light ? UIColor(red:251.0/255.0, green:251.0/255.0, blue:251.0/255.0, alpha:1.0) : .white.withAlphaComponent(0.5), for: .disabled)
        doneButton.setBackgroundImage(UIImage(picker_color: options.themeColor), for: .normal)
        doneButton.setBackgroundImage(UIImage(picker_color: disabledColor), for: .disabled)
        doneButton.contentVerticalAlignment = .center
        doneButton.contentHorizontalAlignment = .center
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        addSubview(doneButton)
        doneButton.addConstraint(doneWidthLayout)
        addConstraints([
            NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: clearButton, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: doneButton, attribute: .centerY, relatedBy: .equal, toItem: clearButton, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: doneButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -18.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Event
extension MNAssetPickerToolBar {
    
    /// 清除事件
    @objc func clear() {
        guard let delegate = delegate else { return }
        delegate.clearButtonTouchUpInside(self)
    }
    
    /// 预览事件
    @objc func preview() {
        guard let delegate = delegate else { return }
        delegate.previewButtonTouchUpInside(self)
    }
    
    /// 确定事件
    @objc func done() {
        guard let delegate = delegate else { return }
        delegate.doneButtonTouchUpInside(self)
    }
}

// MARK: - Update
extension MNAssetPickerToolBar {
    
    /// 更新资源
    /// - Parameter assets: 资源模型集合
    func updateAssets(_ assets: [MNAsset]) {
        var suffix: String
        if options.showFileSize {
            let fileSize: Int64 = assets.reduce(0) { $0 + max($1.fileSize, 0) }
            suffix = fileSize > 0 ? fileSize.mn_picker.fileSizeString : ""
        } else {
            suffix = assets.count > 0 ? "\(assets.count)" : ""
        }
        let title = suffix.count > 0 ? "确定(\(suffix))" : "确定"
        let string = NSMutableAttributedString(string: title)
        string.addAttribute(.font, value: doneButton.titleLabel!.font!, range: NSRange(location: 0, length: string.length))
        string.addAttribute(.foregroundColor, value: doneButton.titleColor(for: (assets.count > 0 && assets.count >= options.minPickingCount) ? .normal : .disabled)!, range: NSRange(location: 0, length: string.length))
        string.addAttribute(.font, value: options.showFileSize ? UIFont.systemFont(ofSize: 12.0, weight: .medium) : doneButton.titleLabel!.font!, range: (title as NSString).range(of: suffix))
        let width = ceil(string.boundingRect(with: CGSize(width: 1000.0, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.width)
        doneButton.setAttributedTitle(string, for: .normal)
        doneButton.setAttributedTitle(string, for: .disabled)
        clearButton.isEnabled = assets.count > 0
        previewButton.isEnabled = assets.count > 0
        doneButton.isEnabled = (assets.count > 0 && assets.count >= options.minPickingCount)
        doneWidthLayout.constant = width + 15.0
        setNeedsLayout()
    }
}
