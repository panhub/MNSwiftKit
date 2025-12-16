//
//  AssetPickerController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class AssetPickerController: UIViewController {
    
    @IBOutlet weak var backTop: NSLayoutConstraint!
    
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
}
