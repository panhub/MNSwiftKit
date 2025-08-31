//
//  ViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 08/22/2025.
//  Copyright (c) 2025 mellow. All rights reserved.
//

import UIKit
import MNSwiftKit

class ViewController: UIViewController {
    
    lazy var textField = UITextField(frame: .init(x: 40.0, y: 100.0, width: view.frame.width - 80.0, height: 50.0))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .white
        
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 17.0)
        textField.leftViewMode = .always
        textField.leftView = .init(frame: .init(origin: .zero, size: .init(width: 30.0, height: 50.0)))
        textField.rightViewMode = .always
        textField.rightView = .init(frame: .init(origin: .zero, size: .init(width: 30.0, height: 50.0)))
        view.addSubview(textField)
        
        let em = MNEmoticonKeyboard.Options()
        em.returnKeyType = .done
        let keyboard = MNEmoticonKeyboard(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: 300.0 + MN_BOTTOM_SAFE_HEIGHT)), style: .paging, options: em)
        keyboard.delegate = self
        textField.inputView = keyboard
        
        
        
        
//        print("============\(MN_SCREEN_WIDTH)============")
//        print("============\(MN_SCREEN_HEIGHT)============")
//        print("============\(MN_SCREEN_MAX)============")
//        print("============\(MN_SCREEN_MIN)============")
//        print("============\(MN_TAB_BAR_HEIGHT)============")
//        print("============\(MN_BOTTOM_SAFE_HEIGHT)============")
//        print("============\(MN_BOTTOM_BAR_HEIGHT)============")
//        print("============\(MN_STATUS_BAR_HEIGHT)============")
//        print("============\(MN_NAV_BAR_HEIGHT)============")
//        print("============\(MN_TOP_BAR_HEIGHT)============")
//        print("============\("md5测试".crypto.md5)============")
//        print("============\(String.uuid)============")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        textField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: MNEmoticonKeyboardDelegate {
    
    func emoticonKeyboardShouldInput(emoticon: UIImage!, desc: String, style: MNSwiftKit.MNEmoticon.Style) {
        
        textField.input(emoticon: emoticon, desc: desc)
    }
    
    func emoticonKeyboardReturnButtonTouchUpInside(_ keyboard: MNSwiftKit.MNEmoticonKeyboard) {
        
        textField.resignFirstResponder()
    }
    
    func emoticonKeyboardDeleteButtonTouchUpInside(_ keyboard: MNSwiftKit.MNEmoticonKeyboard) {
        textField.deleteBackward()
    }
}
