//
//  ToastViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class ToastViewController: UIViewController {
    // 多个Toast展示视图的组合控件
    @IBOutlet weak var stackView: UIStackView!
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航栏高度
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard mn.isFirstAssociated else { return }
        
        var views: [ToastView] = []
        for arrangedSubview in stackView.arrangedSubviews {
            guard arrangedSubview is UIStackView else { continue }
            let subStackView = arrangedSubview as! UIStackView
            views.append(contentsOf: subStackView.arrangedSubviews.compactMap({ $0 as? ToastView }))
        }
        
        views.forEach {
            $0.show()
        }
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        
        var views: [ToastView] = []
        for arrangedSubview in stackView.arrangedSubviews {
            guard arrangedSubview is UIStackView else { continue }
            let subStackView = arrangedSubview as! UIStackView
            views.append(contentsOf: subStackView.arrangedSubviews.compactMap({ $0 as? ToastView }))
        }
        
        views.forEach {
            $0.cancellation = sender.isOn
        }
        
        views.forEach {
            $0.show()
        }
    }
}
