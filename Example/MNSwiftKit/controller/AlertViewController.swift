//
//  AlertViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/1.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class AlertViewController: UIViewController {
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }
    
    
    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func alert() {
        // 类似于UIKit方式
        let alertView = MNAlertView(title: "提示", message: "这是一个弹窗提示信息。", preferredStyle: .alert)
        alertView.addTextField { textField in
            textField.font = .systemFont(ofSize: 15.0, weight: .regular)
            textField.placeholder = "这是第一个输入框"
        }
        alertView.addAction(title: "取消", style: .cancel) { action in
            
        }
        alertView.addAction(title: "删除", style: .destructive) { action in
            
        }
        alertView.show()
    }
    
    @IBAction func sheet() {
        // 快捷方式
        MNAlertView(title: "操作表单", message: "这是一个操作表单", style: .actionSheet, cancelButtonTitle: "取消", destructiveButtonTitle: "删除", otherButtonTitles: "选项一", "选项二", "选项三") { tag, action in
            print(tag)
        }.show()
    }
}
