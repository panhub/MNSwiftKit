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
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var switchButton: UISwitch!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var backTop: NSLayoutConstraint!
    
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    
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
        
        switchValueChanged(switchButton)
        
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
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        let isFirstResponder = textView.isFirstResponder
        textView.resignFirstResponder()
        if sender.isOn {
            // 表情键盘
            let options = MNEmoticonKeyboard.Options()
            options.packets = [MNEmoticon.Packet.Name.wechat.rawValue, MNEmoticon.Packet.Name.emotion.rawValue, MNEmoticon.Packet.Name.animal.rawValue, MNEmoticon.Packet.Name.food.rawValue, MNEmoticon.Packet.Name.favorites.rawValue]
            options.enableFeedbackWhenInputClicks = true
            let emoticonKeyboard = MNEmoticonKeyboard(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: 310.0)), options: options)
            emoticonKeyboard.delegate = self
            textView.inputView = emoticonKeyboard
        } else {
            // 系统键盘
            textView.inputView = nil
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
