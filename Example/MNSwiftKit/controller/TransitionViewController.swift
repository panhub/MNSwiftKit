//
//  TransitionViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/11.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class TransitionViewController: UIViewController {
    /// 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    /// 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    deinit {
        navigationController?.mn.transitioningDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let navigationController = navigationController else { return }
        if navigationController.mn.transitioningDelegate == nil {
            // 设置转场代理
            navigationController.mn.transitioningDelegate = MNTransitioningDelegate()
        }
    }


    @IBAction func back() {
        
        navigationController?.mn.transitioningDelegate = nil
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func transition(_ sender: UIButton) {
        guard let navigationController = navigationController else { return }
        guard let transitioningDelegate = navigationController.mn.transitioningDelegate else { return }
        switch sender.tag {
        case 0:
            transitioningDelegate.transitionStyle = .normal
        case 1:
            transitioningDelegate.transitionStyle = .drawer
        case 2:
            transitioningDelegate.transitionStyle = .modal
        default:
            transitioningDelegate.transitionStyle = .flip
        }
        let vc = TestViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
