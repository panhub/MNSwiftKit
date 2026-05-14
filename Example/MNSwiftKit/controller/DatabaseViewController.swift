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
        
        for table in Table.allCases {
            
            if database.create(table: table.tableName, using: table.modelType) == false {
                print("创建表失败")
            }
        }
        
        seedTablesIfEmpty()
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.register(UINib(nibName: "DatabaseCollectionCell", bundle: .main), forCellWithReuseIdentifier: "DatabaseCollectionCell")
        
        updateTable()
    }
    
    /// 各表示例数据（表为空时写入，避免重复进入页面无限插入）
    private func seedTablesIfEmpty() {
        
        if database.selectCount(from: Table.user.tableName) == 0 {
            
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
                
                if database.insert(into: Table.user.tableName, using: user) == false {
                    print("插入数据失败")
                }
            }
        }
        
        if database.selectCount(from: Table.order.tableName) == 0 {
            
            let users = database.selectRows(from: Table.user.tableName, type: User.self) ?? []
            let firstUid = users.first?.uid ?? 1
            let secondUid = users.count > 1 ? users[1].uid : firstUid
            
            let o1 = Order()
            o1.userId = firstUid
            o1.amount = 99.5
            o1.title = "示例订单一"
            o1.createdAt = "2026-01-10 10:00"
            
            let o2 = Order()
            o2.userId = secondUid
            o2.amount = 256
            o2.title = "示例订单二"
            o2.createdAt = "2026-02-15 14:30"
            
            for order in [o1, o2] {
                
                if database.insert(into: Table.order.tableName, using: order) == false {
                    print("插入订单失败")
                }
            }
        }
        
        if database.selectCount(from: Table.comment.tableName) == 0 {
            
            let users = database.selectRows(from: Table.user.tableName, type: User.self) ?? []
            let orders = database.selectRows(from: Table.order.tableName, type: Order.self) ?? []
            let uid = users.first?.uid ?? 1
            let oid = orders.first?.oid
            
            let c1 = Comment()
            c1.userId = uid
            c1.orderId = oid
            c1.content = "订单评价：发货很快"
            c1.createdAt = "2026-01-11 09:00"
            
            let c2 = Comment()
            c2.userId = uid
            c2.orderId = nil
            c2.content = "全局留言：示例评论（无关联订单）"
            c2.createdAt = "2026-03-01 16:20"
            
            for comment in [c1, c2] {
                
                if database.insert(into: Table.comment.tableName, using: comment) == false {
                    print("插入评论失败")
                }
            }
        }
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
                nameLabel.text = table.displayTitle(forColumn: column.name)
            } else {
                // 添加
                let nameLabel = UILabel()
                nameLabel.numberOfLines = 1
                nameLabel.textAlignment = .center
                nameLabel.font = .systemFont(ofSize: 14.0)
                nameLabel.textColor = .darkText
                nameLabel.backgroundColor = UIColor(mn_rgb: 238.0)
                nameLabel.text = table.displayTitle(forColumn: column.name)
                stackView.addArrangedSubview(nameLabel)
            }
        }
        
        if nameLabels.count > columns.count {
            nameLabels.suffix(from: columns.count).forEach { $0.isHidden = true }
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
                guard let users = self.database.selectRows(from: self.table.tableName, type: User.self) else { break }
                for user in users {
                    var contents: [String] = []
                    for column in self.columns {
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
                guard let orders = self.database.selectRows(from: self.table.tableName, type: Order.self) else { break }
                for order in orders {
                    var contents: [String] = []
                    for column in self.columns {
                        switch column.name {
                        case "oid":
                            contents.append("\(order.oid)")
                        case "userId":
                            contents.append("\(order.userId)")
                        case "amount":
                            contents.append("\(order.amount)")
                        case "title":
                            contents.append(order.title)
                        case "createdAt":
                            contents.append(order.createdAt)
                        default: break
                        }
                    }
                    rows.append(Table.Row(contents: contents))
                }
            case .comment:
                guard let comments = self.database.selectRows(from: self.table.tableName, type: Comment.self) else { break }
                for comment in comments {
                    var contents: [String] = []
                    for column in self.columns {
                        switch column.name {
                        case "cid":
                            contents.append("\(comment.cid)")
                        case "userId":
                            contents.append("\(comment.userId)")
                        case "orderId":
                            if let orderId = comment.orderId {
                                contents.append("\(orderId)")
                            } else {
                                contents.append("NULL")
                            }
                        case "content":
                            contents.append(comment.content)
                        case "createdAt":
                            contents.append(comment.createdAt)
                        default: break
                        }
                    }
                    rows.append(Table.Row(contents: contents))
                }
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
    
    @IBAction func appendRow() {
        
        let controller = DatabaseEditingController(database: database, table: table, columns: columns)
        controller.insertSucceededHandler = { [weak self] in
            self?.reloadTable()
        }
        navigationController?.pushViewController(controller, animated: true)
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
