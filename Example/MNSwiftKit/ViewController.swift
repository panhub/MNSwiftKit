//
//  ViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class ViewController: UIViewController {
    
    var progress: CGFloat = 0.0
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imageView.layer.cornerRadius = 8.0
        imageView.isHidden = true
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        } else {
            // tests[Int.random(in: 0..<tests.count)]
            let tests = ["测试提示信息", "今天天气不错", "你知道今天星期几吗", "xixie", "这厮怎么回事呢?"]
            MNToast.showSuccess(tests[Int.random(in: 0..<tests.count)], delay: 10.0) {
                print("----弹窗消失")
            }
            MNToast.dismiss(after: 3.0)
            if self.progress >= 1.0 {
                self.progress = 0.0
            } else {
                self.progress += 0.1
            }
        }
    }
}
