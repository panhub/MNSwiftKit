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
    
    private var needsReloadTable: Bool = false
    
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
        
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        
        collectionView.bounces = false
        collectionView.register(UINib(nibName: "DatabaseCollectionCell", bundle: .main), forCellWithReuseIdentifier: "DatabaseCollectionCell")
        
        view.mn.dataEmptyDelegate = self
        view.mn.dataEmptyComponents = [.text]
        
        updateTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needsReloadTable {
            needsReloadTable = false
            reloadTable()
        }
    }
    
    /// 各表示例数据（表为空时写入，避免重复进入页面无限插入）
    private func seedTablesIfEmpty() {
        
        if database.selectCount(from: Table.user.tableName) == 0 {
            
            let u1 = User()
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
            
            let o1 = Order()
            o1.uid = "010"
            o1.amount = 99.5
            o1.title = "外卖订单"
            o1.subtitle = "副标题"
            o1.createdAt = "2026-01-10"
            
            let o2 = Order()
            o2.uid = "011"
            o2.amount = 256
            o2.title = "示例订单二"
            o2.createdAt = "2026-02-15"
            
            for order in [o1, o2] {
                if database.insert(into: Table.order.tableName, using: order) == false {
                    print("插入订单失败")
                }
            }
        }
        
        if database.selectCount(from: Table.comment.tableName) == 0 {
            
            let c1 = Comment()
            c1.uid = "0111"
            c1.favours = 13
            c1.content = "发货很快"
            c1.comment = "确实"
            c1.createdAt = "2026-01-11"
            
            let c2 = Comment()
            c2.uid = "1023"
            c2.favours = 0
            c2.content = "示例评论"
            c2.createdAt = "2026-03-01"
            
            for comment in [c1, c2] {
                if database.insert(into: Table.comment.tableName, using: comment) == false {
                    print("插入评论失败")
                }
            }
        }
    }

    /// 更新表字段
    private func updateTable() {
        
        rows.removeAll()
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        
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
                nameLabel.font = .systemFont(ofSize: 14.0, weight: .medium)
                nameLabel.textColor = .darkText
                nameLabel.backgroundColor = UIColor(mn_rgb: 238.0)
                nameLabel.text = column.name
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
        MNToast.showActivity("正在加载数据")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var rows: [Table.Row] = []
            if let dics = self.database.selectRows(self.table.tableName) {
                for dic in dics {
                    var contents: [String] = []
                    for column in self.columns {
                        if let value = dic[column.name], let value = value {
                            if column.name == "gender" {
                                if let rawValue = value as? Int, let gender = User.Gender(rawValue: rawValue) {
                                    contents.append(gender.stringValue)
                                } else {
                                    contents.append("--")
                                }
                            } else if column.name == "status" {
                                if let rawValue = value as? Int, let status = User.Status(rawValue: rawValue) {
                                    contents.append(status.stringValue)
                                } else {
                                    contents.append("--")
                                }
                            } else {
                                contents.append("\(value)")
                            }
                        } else {
                            contents.append("NULL")
                        }
                    }
                    let row = Table.Row(contents: contents)
                    rows.append(row)
                }
            }
            /*
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
                        case "birthday":
                            if let birthday = user.birthday {
                                contents.append(birthday)
                            } else {
                                contents.append("NULL")
                            }
                        case "gender":
                            contents.append(user.gender.stringValue)
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
                                contents.append(status.stringValue)
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
                        case "uid":
                            contents.append(order.uid)
                        case "amount":
                            contents.append("\(order.amount)")
                        case "title":
                            contents.append(order.title)
                        case "subtitle":
                            if let subtitle = order.subtitle {
                                contents.append(subtitle)
                            } else {
                                contents.append("NULL")
                            }
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
                        case "uid":
                            contents.append(comment.uid)
                        case "favours":
                            contents.append("\(comment.favours)")
                        case "content":
                            contents.append(comment.content)
                        case "comment":
                            contents.append(comment.comment)
                        case "createdAt":
                            contents.append(comment.createdAt)
                        default: break
                        }
                    }
                    rows.append(Table.Row(contents: contents))
                }
            }
            */
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.rows.removeAll()
                self.rows.append(contentsOf: rows)
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
                self.view.mn.showEmptyViewIfNeeded()
                MNToast.close()
            }
        }
    }

    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func appendRow() {
        
        let controller = DatabaseEditingController(database: database, table: table, columns: columns, action: .add) { [weak self] in
            guard let self = self else { return }
            self.needsReloadTable = true
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DatabaseCollectionCell", for: indexPath)
        cell.mn.allowsEditing = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DatabaseCollectionCell else { return }
        let row = rows[indexPath.section]
        cell.updateRow(row)
    }
}

extension DatabaseViewController: UICollectionViewEditingDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editingDirectionsForItemAt indexPath: IndexPath) -> MNSwiftKit.MNEditingView.Direction {
        
        .left
    }
    
    func collectionView(_ collectionView: UICollectionView, editingActionsForItemAt indexPath: IndexPath, direction: MNSwiftKit.MNEditingView.Direction) -> [UIView] {
        
        let label1 = UILabel(frame: .init(origin: .zero, size: .init(width: 80.0, height: 50.0)))
        label1.textColor = .white
        label1.text = "编辑"
        label1.textAlignment = .center
        label1.font = .systemFont(ofSize: 15.0, weight: .regular)
        label1.backgroundColor = .systemYellow
        
        let label2 = UILabel(frame: .init(origin: .zero, size: .init(width: 80.0, height: 50.0)))
        label2.tag = 1
        label2.textColor = .white
        label2.text = "删除"
        label2.textAlignment = .center
        label2.font = .systemFont(ofSize: 15.0, weight: .regular)
        label2.backgroundColor = .systemRed
        
        return [label1, label2]
    }
    
    func collectionView(_ collectionView: UICollectionView, commitEditing action: UIView, forItemAt indexPath: IndexPath, direction: MNSwiftKit.MNEditingView.Direction) -> UIView? {
        // 如果无需确认视图，在这里处理事件即可，返回nil
        if action.tag == 0 {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.mn.endEditing(animated: true)
            }
            guard let column = columns.first(where: { $0.isPrimary }) else {
                MNToast.showMsg("获取主键失败")
                return nil
            }
            let row = rows[indexPath.item]
            guard let first = row.contents.first else {
                MNToast.showMsg("获取行失败")
                return nil
            }
            let value = first.mn.intValue
            let controller = DatabaseEditingController(database: database, table: table, columns: columns, action: .editing(row: row, key: column.name, value: value)) { [weak self] in
                guard let self = self else { return }
                self.needsReloadTable = true
            }
            navigationController?.pushViewController(controller, animated: true)
            return nil
        }
        let button = UIButton(type: .custom)
        button.tag = indexPath.item
        button.frame = .init(origin: .zero, size: .init(width: 180.0, height: 50.0))
        button.setTitle("确认删除", for: .normal)
        button.backgroundColor = .systemRed
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .regular)
        button.addTarget(self, action: #selector(deleteRow(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func deleteRow(_ sender: UIButton) {
        let indexPath = IndexPath(item: sender.tag, section: 0)
        guard let column = columns.first(where: { $0.isPrimary }) else {
            MNToast.showMsg("获取主键失败")
            return
        }
        let row = rows[indexPath.item]
        guard let first = row.contents.first else {
            MNToast.showMsg("获取行失败")
            return
        }
        let value = first.mn.intValue
        MNToast.showActivity("请稍后")
        database.delete(from: table.tableName, where: "\(column.name)=\(value)", on: .main) { [weak self] isSuccess in
            guard isSuccess else {
                MNToast.showMsg("操作失败")
                return
            }
            MNToast.close()
            guard let self = self else { return }
            self.rows.remove(at: indexPath.item)
            self.collectionView.reloadData()
            self.view.mn.showEmptyViewIfNeeded()
        }
    }
}

extension DatabaseViewController: MNDataEmptyDelegate {
    
    func dataEmptyViewShouldAppear() -> Bool {
        
        rows.isEmpty
    }
    
    func backgroundColorForDataEmptyView() -> UIColor? {
        
        UIColor(mn_rgb: 238.0)
    }
    
    func edgeInsetForDataEmptyView() -> UIEdgeInsets {
        
        .init(top: navHeight.constant + 92, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func attributedHintForDataEmptyView() -> NSAttributedString? {
        
        NSAttributedString(string: "表内无数据", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.lightGray])
    }
}

extension DatabaseViewController: MNDataEmptyHierarchyPositioning {
    
    func hierarchyPositionForDataEmptyView() -> MNDataEmptyHierarchyPosition {
        
        .front
    }
}
