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
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var backTop: NSLayoutConstraint!
    
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    
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
