//
//  SplitViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class SplitViewController: UIViewController {
    
    //var splitController = <#value#>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 这里先不布局控制器，界面还不确定
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard mn.isFirstAssociated else { return }
        createSplitController()
    }
    
    private func createSplitController() {
        
        
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
