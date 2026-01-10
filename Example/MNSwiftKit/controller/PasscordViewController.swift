//
//  PasscordViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/10.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class PasscordViewController: UIViewController {
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
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        secureView.capacity = 5
        secureView.spacing = 15.0
        secureView.delegate = self
        secureView.configuration.borderStyle = .square
        secureView.configuration.borderWidth = 1.4
        secureView.configuration.cipherColor = .black
        secureView.configuration.cipherRadius = 5.0
        secureView.configuration.cornerRadius = 8.0
        secureView.configuration.highlightBorderColor = .black
        secureView.configuration.borderColor = UIColor(red: 210.0/255.0, green: 212.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        
        var configuration = MNNumberKeyboard.Configuration()
        configuration.leftKeyName = .clear
        configuration.rightKeyName = .delete
        configuration.textFont = UIFont(name: "DINAlternate-Bold", size: 25.0)!
        let numberKeyboard = MNNumberKeyboard(frame: .init(origin: .zero, size: .init(width: view.frame.width, height: 265.0)), configuration: configuration)
        numberKeyboard.delegate = self
        numberKeyboard.setFont(.systemFont(ofSize: 30.0), for: .delete)
        numberKeyboard.setFont(.systemFont(ofSize: 28.0, weight: .medium), for: .clear)
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

// MARK: - MNNumberKeyboardDelegate
extension PasscordViewController: MNNumberKeyboardDelegate {
    
    
    func numberKeyboard(_ keyboard: MNNumberKeyboard, shouldInput key: MNNumberKeyboard.Key) -> Bool {
        
        if key == .delete { return true }
        return secureView.text.count < secureView.capacity
    }
    
    
    func numberKeyboard(_ keyboard: MNSwiftKit.MNNumberKeyboard, didInput key: MNSwiftKit.MNNumberKeyboard.Key) {
        
        secureView.text = keyboard.text
    }
}

// MARK: - MNSecureViewDelegate
extension PasscordViewController: MNSecureViewDelegate {
    
    func secureViewTouchUpInside(_ secureView: MNSwiftKit.MNSecureView) {
        
        textField.becomeFirstResponder()
    }
}
