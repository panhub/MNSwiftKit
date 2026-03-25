//
//  DatabaseEditingController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class DatabaseEditingController: UIViewController {
    // 类型
    let table: Table
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航高度约束
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    // StackView宽度约束
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    // StackView中每一项高度约束
    @IBOutlet weak var itemHeight: NSLayoutConstraint!
    // 标题
    @IBOutlet weak var titleLabel: UILabel!
    //
    @IBOutlet weak var stackView: UIStackView!
    // 返回按钮高度约束
    @IBOutlet weak var collectionView: UICollectionView!
    // 集合视图约束
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    
    init(table: Table) {
        self.table = table
        super.init(nibName: "DatabaseEditingController", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        collectionView.register(DatabaseEditingCell.self, forCellWithReuseIdentifier: "DatabaseEditingCell")
        collectionLayout.itemSize = .init(width: MN_SCREEN_WIDTH - stackWidth.constant - 1.0, height: itemHeight.constant)
        
        
//        switch type {
//        case .user:
//            // 用户表
//            
//            
//        case .order:
//            <#code#>
//        case .comment:
//            <#code#>
//        }
        
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
