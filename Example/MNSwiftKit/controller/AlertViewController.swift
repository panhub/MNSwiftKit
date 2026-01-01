//
//  AlertViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/1.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func alert() {
    }
    
    @IBAction func sheet() {
    }
}
