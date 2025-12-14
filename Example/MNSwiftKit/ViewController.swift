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
    
    @IBOutlet weak var titleTop: NSLayoutConstraint!
    
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        titleTop.constant = (MN_NAV_BAR_HEIGHT - titleHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }
}
