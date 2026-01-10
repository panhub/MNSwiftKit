//
//  PasswordViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/10.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class PasswordViewController: UIViewController {
    /// 输入框，触发键盘
    @IBOutlet weak var textField: UITextField!
    /// 密码视图
    @IBOutlet weak var secureView: MNSecureView!
    /// 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    /// 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        secureView.configuration.borderStyle = .square
        secureView.capacity = 5
        secureView.spacing = 15.0
        secureView.backgroundColor = .yellow
        secureView.delegate = self
        
        let numberKeyboard = MNNumberKeyboard(frame: .init(origin: .zero, size: .init(width: view.frame.width, height: 300.0)), configuration: .init())
        numberKeyboard.delegate = self
        textField.inputView = numberKeyboard
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        textField.resignFirstResponder()
    }
    
    
    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
}


extension PasswordViewController: MNNumberKeyboardDelegate {
    
    
    func numberKeyboard(_ keyboard: MNSwiftKit.MNNumberKeyboard, didInput key: MNSwiftKit.MNNumberKeyboard.Key) {
        
        secureView.text = keyboard.text
    }
}


extension PasswordViewController: MNSecureViewDelegate {
    
    func secureViewTouchUpInside(_ secureView: MNSwiftKit.MNSecureView) {
        
        textField.becomeFirstResponder()
    }
}
