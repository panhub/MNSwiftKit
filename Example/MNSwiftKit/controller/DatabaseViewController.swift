//
//  DatabaseViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class DatabaseViewController: UIViewController {
    
    private var table: Table = .user
    
    private var columns: [MNTableColumn] = []
    
    private var rows: [Table.Row] = []
    
    private let database = MNDatabase()
    
    @IBOutlet weak var stackView: UIStackView!
    // 滑动视图
    @IBOutlet weak var scrollView: UIScrollView!
    // 返回按钮高度约束
    @IBOutlet weak var collectionView: UICollectionView!
    //
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航高度约束
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    // 表格项宽度约束
    @IBOutlet weak var itemWidth: NSLayoutConstraint!
    // 表格项高度约束
    @IBOutlet weak var itemHeight: NSLayoutConstraint!
    
    // 集合视图约束
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for table in [Table.user/*, Table.order, Table.comment*/] {
            
            if database.create(table: table.tableName, using: table.modelType) == false {
                print("创建表失败")
            }
        }
        
        //
        let u1 = User()
        u1.age = 14
        u1.birthday = "2010-02-02"
        u1.gender = .female
        u1.username = "用户1"
        u1.email = "edddd@qq.com"
        u1.phone = "18137709257"
        u1.status = .inactive
        
        let u2 = User()
        u2.gender = .male
        u2.username = "用户2"
        u2.phone = "13330364470"
        u2.status = .forbidden
        
        let u3 = User()
        u3.username = "用户3"
        u3.gender = .unknown
        u3.status = .forbidden
        
        for user in [u1, u2, u3] {
            
            if database.insert(into: table.tableName, using: user) == false {
                print("插入数据失败")
            }
        }
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.register(UINib(nibName: "DatabaseCollectionCell", bundle: .main), forCellWithReuseIdentifier: "DatabaseCollectionCell")
        
        updateTable()
    }

    /// 更新表字段
    private func updateTable() {
        
        let columns = database.columns(in: table.tableName)
        self.columns.removeAll()
        self.columns.append(contentsOf: columns)
        
        let nameLabels = stackView.arrangedSubviews.compactMap { $0 as? UILabel }
        for (index, column) in columns.enumerated() {
            if nameLabels.count > index {
                let nameLabel = nameLabels[index]
                nameLabel.isHidden = false
                nameLabel.text = column.name
            } else {
                // 添加
                let nameLabel = UILabel()
                nameLabel.numberOfLines = 1
                nameLabel.textAlignment = .center
                nameLabel.font = .systemFont(ofSize: 14.0)
                nameLabel.textColor = .darkText
                nameLabel.backgroundColor = UIColor(mn_rgb: 238.0)
                nameLabel.text = column.name
                stackView.addArrangedSubview(nameLabel)
            }
        }
        
        if nameLabels.count > columns.count {
            let nameLabels = nameLabels.suffix(from: columns.count)
            nameLabels.forEach { $0.isHidden = true }
        }
        let itemWidth = itemWidth.constant*CGFloat(columns.count) + stackView.spacing*CGFloat(Swift.max(0, columns.count - 1))
        collectionLayout.itemSize = .init(width: itemWidth, height: itemHeight.constant)
        
        reloadTable()
    }
    
    private func reloadTable() {
        MNToast.showActivity("正在加载表")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var rows: [Table.Row] = []
            switch self.table {
            case .user:
                //
                guard let users = database.selectRows(from: self.table.tableName, type: User.self) else { break }
                for user in users {
                    var contents: [String] = []
                    for column in columns {
                        switch column.name {
                        case "uid":
                            contents.append("\(user.uid)")
                        case "age":
                            if let age = user.age {
                                contents.append("\(age)")
                            } else {
                                contents.append("NULL")
                            }
                        case "birthday":
                            if let birthday = user.birthday {
                                contents.append("\(birthday)")
                            } else {
                                contents.append("NULL")
                            }
                        case "gender":
                            contents.append("\(user.gender.rawValue)")
                        case "username":
                            contents.append(user.username)
                        case "phone":
                            if let phone = user.phone {
                                contents.append(phone)
                            } else {
                                contents.append("NULL")
                            }
                        case "email":
                            if let email = user.email {
                                contents.append(email)
                            } else {
                                contents.append("NULL")
                            }
                        case "status":
                            if let status = user.status {
                                contents.append("\(status.rawValue)")
                            } else {
                                contents.append("NULL")
                            }
                        default: break
                        }
                    }
                    let row = Table.Row(contents: contents)
                    rows.append(row)
                }
            case .order:
                break
            case .comment:
                break
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                self.rows.removeAll()
                self.rows.append(contentsOf: rows)
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
                MNToast.close()
            }
        }
    }

    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        guard let table = Table(rawValue: sender.selectedSegmentIndex) else { return }
        self.table = table
        updateTable()
    }
}

extension DatabaseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.dequeueReusableCell(withReuseIdentifier: "DatabaseCollectionCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DatabaseCollectionCell else { return }
        let row = rows[indexPath.section]
        cell.updateRow(row)
    }
}
