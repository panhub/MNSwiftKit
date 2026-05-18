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
    
    enum Action {
        case add, editing(row: Table.Row)
    }
    
    private let table: Table
    private let database: MNDatabase
    private let columns: [MNTableColumn]
    private let action: DatabaseEditingController.Action
    private let successHandler: () -> Void
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
    
    init(database: MNDatabase, table: Table, columns: [MNTableColumn], action: DatabaseEditingController.Action, success: @escaping () -> Void) {
        self.database = database
        self.table = table
        self.columns = columns.filter({ $0.isPrimary == false })
        self.action = action
        self.successHandler = success
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
        
        titleLabel.text = table.navigationTitle
        
        let nameLabels = stackView.arrangedSubviews.compactMap { $0 as? UILabel }
        for (index, column) in columns.enumerated() {
            if nameLabels.count > index {
                let nameLabel = nameLabels[index]
                nameLabel.isHidden = false
                nameLabel.text = column.name
            } else {
                let nameLabel = UILabel()
                nameLabel.numberOfLines = 1
                nameLabel.textAlignment = .center
                nameLabel.font = .systemFont(ofSize: 14.0)
                nameLabel.textColor = .darkGray
                nameLabel.backgroundColor = UIColor(mn_rgb: 238.0)
                nameLabel.text = column.name
                stackView.addArrangedSubview(nameLabel)
            }
        }
        
        if nameLabels.count > columns.count {
            nameLabels.suffix(from: columns.count).forEach { $0.isHidden = true }
        }
        
        collectionLayout.itemSize = .init(width: MN_SCREEN_WIDTH - stackWidth.constant - 1.0, height: itemHeight.constant)
        
        collectionView.register(UINib(nibName: "DatabaseEditingCell", bundle: .main), forCellWithReuseIdentifier: "DatabaseEditingCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard mn.isFirstAccess else { return }
        guard case .editing(row: let row) = action else { return }
        for (index, column) in columns.enumerated() {
            guard let field = row.fields.first(where: { $0.name == column.name }) else { continue }
            guard let _ = field.value else { continue }
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = collectionView.cellForItem(at: indexPath) as? DatabaseEditingCell else { continue }
            cell.textField.text = field.displayEditingString
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done() {
        
        view.endEditing(true)
        
        var fields: [String: Any] = [:]
        for (index, column) in columns.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = collectionView.cellForItem(at: indexPath) as? DatabaseEditingCell, let textField = cell.textField else {
                MNToast.showMsg("数据错误")
                return
            }
            guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty == false else {
                if column.isNullable == false {
                    MNToast.showMsg(textField.placeholder!)
                    return
                }
                continue
            }
            if column.name == "gender" {
                guard let gender = User.Gender(rawString: text) else {
                    MNToast.showMsg("'\(column.name)'字段无效")
                    return
                }
                fields[column.name] = gender.rawValue
            } else if column.name == "status" {
                guard let status = User.Status(rawString: text) else {
                    MNToast.showMsg("'\(column.name)'字段无效")
                    return
                }
                fields[column.name] = status.rawValue
            } else {
                switch column.type {
                case .integer:
                    guard let value = Int(text) else {
                        MNToast.showMsg("'\(column.name)'字段无效")
                        return
                    }
                    fields[column.name] = value
                case .float:
                    guard let value = Double(text) else {
                        MNToast.showMsg("'\(column.name)'字段无效")
                        return
                    }
                    fields[column.name] = value
                case .text:
                    fields[column.name] = text
                case .blob:
                    guard let data = text.data(using: .utf8) else {
                        MNToast.showMsg("'\(column.name)'字段无效")
                        return
                    }
                    fields[column.name] = data
                }
            }
        }
        guard fields.isEmpty == false else {
            MNToast.showMsg("请至少填写一个字段")
            return
        }
        switch action {
        case .add:
            guard database.insert(into: table.tableName, using: fields) else {
                MNToast.showMsg("操作失败")
                return
            }
        case .editing(row: let row):
            guard let field = row.fields.first(where: { $0.isPrimary }) else {
                MNToast.showMsg("获取主键失败")
                return
            }
            guard let value = field.value else {
                MNToast.showMsg("主键标识不合法")
                return
            }
            guard database.update(table.tableName, where: "\(field.name)=\(value)", using: fields) else {
                MNToast.showMsg("操作失败")
                return
            }
        }
        successHandler()
        navigationController?.popViewController(animated: true)
    }
}

extension DatabaseEditingController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        columns.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.dequeueReusableCell(withReuseIdentifier: "DatabaseEditingCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DatabaseEditingCell else { return }
        let column = columns[indexPath.row]
        cell.updateColumn(column)
    }
}

extension DatabaseEditingController: DatabaseEditing {
    
    func cellShouldBeginEditing(_ cell: DatabaseEditingCell) -> Bool {
        guard let indexPath = collectionView.indexPath(for: cell), let textField = cell.textField else {
            MNToast.showMsg("视图错误")
            return false
        }
        let column = columns[indexPath.row]
        switch column.name {
        case "birthday", "createdAt":
            DatePicker.show(in: view) { date in
                textField.text = date.mn.string(format: "yyyy-MM-dd")
            }
            return false
        case "gender":
            let alertView = MNAlertView(title: "选择性别", message: nil, style: .actionSheet, cancelButtonTitle: "取消", otherButtonTitles: "未知", "男", "女") { tag, action in
                guard let gender = User.Gender(rawValue: tag) else { return }
                textField.text = gender.stringValue
            }
            alertView.show()
            return false
        case "status":
            let alertView = MNAlertView(title: "选择用户状态", message: nil, style: .actionSheet, cancelButtonTitle: "取消", destructiveButtonTitle: "清除", otherButtonTitles: "禁用", "正常", "不活跃") { tag, action in
                switch action.style {
                case .default:
                    guard let status = User.Status(rawValue: tag) else { break }
                    textField.text = status.stringValue
                case .destructive:
                    textField.text = nil
                default: break
                }
            }
            alertView.show()
            return false
        default: return true
        }
    }
}
