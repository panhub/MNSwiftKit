//
//  EmoticonKeyboardController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/17.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class EmoticonKeyboardController: UIViewController {
    // 显示内容
    @IBOutlet weak var textView: UITextView!
    // 显示选中的图片表情
    @IBOutlet weak var imageView: UIImageView!
    // 表情键盘样式控制
    @IBOutlet weak var styleControl: UISegmentedControl!
    // 键盘类型控制
    @IBOutlet weak var typeControl: UISegmentedControl!
    // 候选文字
    @IBOutlet weak var placeholderLabel: UILabel!
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航栏高度
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        textView.contentInset = .zero
        textView.textContainerInset = .init(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        textView.textContainer.lineFragmentPadding = 0.0
        
        typeValueChanged(typeControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        textView.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        textView.resignFirstResponder()
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func styleValueChanged(_ sender: UISegmentedControl) {
        guard typeControl.selectedSegmentIndex == 1 else { return }
        let isFirstResponder = textView.isFirstResponder
        textView.resignFirstResponder()
        typeValueChanged(typeControl)
        if isFirstResponder {
            textView.becomeFirstResponder()
        }
    }
    
    @IBAction func typeValueChanged(_ sender: UISegmentedControl) {
        let isFirstResponder = textView.isFirstResponder
        textView.resignFirstResponder()
        if sender.selectedSegmentIndex == 0 {
            // 系统键盘
            textView.inputView = nil
        } else {
            // 表情键盘
            let options = MNEmoticonKeyboard.Options()
            options.hidesForSingle = true
            options.packets = [.wechat, .favorites, .face, .animal, .food, .favorites, .object, .travel, .exercise]
            options.enableFeedbackWhenInputClicks = true
            let emoticonKeyboard = MNEmoticonKeyboard(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: 310.0)), style: styleControl.selectedSegmentIndex == 1 ? .compact : .paging, options: options)
            emoticonKeyboard.delegate = self
            textView.inputView = emoticonKeyboard
        }
        if isFirstResponder {
            textView.becomeFirstResponder()
        }
    }
}

// MARK: - MNEmoticonKeyboardDelegate
extension EmoticonKeyboardController: MNEmoticonKeyboardDelegate {
    
    func emoticonKeyboardShouldInput(emoticon: MNSwiftKit.MNEmoticon) {
        
        switch emoticon.style {
        case .image:
            //
            imageView.image = emoticon.image
        default:
            textView.mn.input(emoticon: emoticon)
        }
    }
    
    func emoticonKeyboardReturnButtonTouchUpInside(_ keyboard: MNSwiftKit.MNEmoticonKeyboard) {
        
        textView.resignFirstResponder()
    }
    
    func emoticonKeyboardDeleteButtonTouchUpInside(_ keyboard: MNSwiftKit.MNEmoticonKeyboard) {
        
        textView.deleteBackward()
    }
    
    func emoticonKeyboardShouldAddToFavorites(_ keyboard: MNEmoticonKeyboard) {
        // 添加
        textView.resignFirstResponder()
        let options = MNAssetPickerOptions()
        options.allowsPickingVideo = false
        options.allowsPickingPhoto = true
        options.allowsPickingGif = true
        options.allowsPickingLivePhoto = true
        options.usingPhotoPolicyPickingLivePhoto = true
        options.maxPickingCount = 1
        options.mode = .dark
        let picker = MNAssetPicker(options: options)
        picker.present { picker, assets in
            if let asset = assets.first, let image = asset.contents as? UIImage {
                MNEmoticonManager.shared.addEmoticonToFavorites(image: image)
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension EmoticonKeyboardController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
}

// MARK: - Notification
extension EmoticonKeyboardController {
    
    @objc private func textDidChangeNotification(_ notify: Notification) {
        let text = textView.mn.plainText
        placeholderLabel.isHidden = text.isEmpty == false
    }
}
