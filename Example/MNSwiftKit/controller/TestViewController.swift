//
//  TestViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/11.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class TestViewController: UIViewController {
    /// 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    /// 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
}
