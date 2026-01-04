//
//  PopoverViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/4.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class PopoverViewController: UIViewController {
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
    
    @IBAction func up(_ sender: UIView) {
        
        popup(sender, direction: .up)
    }
    
    @IBAction func left(_ sender: UIView) {
        
        popup(sender, direction: .left)
    }
    
    @IBAction func down(_ sender: UIView) {
        
        popup(sender, direction: .down)
    }
    
    @IBAction func right(_ sender: UIView) {
        
        popup(sender, direction: .right)
    }
    
    private func popup(_ sender: UIView, direction: MNPopoverArrowDirection) {
        
        var configuration = MNPopoverConfiguration()
        configuration.titleFont = .systemFont(ofSize: 13.0, weight: .medium)
        configuration.titleColor = .white
        configuration.arrowDirection = direction
        configuration.width = .fixed(60.0)
        configuration.height = .fixed(25.0)
        configuration.cornerRadius = 5.0
        
        let popoverView = MNPopoverView(titles: "选项一", "选项二", "选项三", configuration: configuration)
        popoverView.popup(in: view, target: sender, animated: true) { sender in
            print("点击了按钮 \(sender.tag)")
        }
    }
}
