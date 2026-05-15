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
    private let table: Table
    private let database: MNDatabase
    private let columns: [MNTableColumn]
    /// 插入成功后由列表页刷新
    var insertSucceededHandler: (() -> Void)?
    
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
    
    init(database: MNDatabase, table: Table, columns: [MNTableColumn]) {
        self.table = table
        self.database = database
        self.columns = columns
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
        
        titleLabel.text = table.editingNavigationTitle
        
        let nameLabels = stackView.arrangedSubviews.compactMap { $0 as? UILabel }
        for (index, column) in columns.enumerated() {
            if nameLabels.count > index {
                let nameLabel = nameLabels[index]
                nameLabel.isHidden = false
                nameLabel.text = table.displayTitle(forColumn: column.name)
            } else {
                let nameLabel = UILabel()
                nameLabel.numberOfLines = 1
                nameLabel.textAlignment = .center
                nameLabel.font = .systemFont(ofSize: 14.0)
                nameLabel.textColor = .darkGray
                nameLabel.backgroundColor = UIColor(mn_rgb: 238.0)
                nameLabel.text = table.displayTitle(forColumn: column.name)
                stackView.addArrangedSubview(nameLabel)
            }
        }
        
        if nameLabels.count > columns.count {
            nameLabels.suffix(from: columns.count).forEach { $0.isHidden = true }
        }
        
        collectionLayout.itemSize = .init(width: MN_SCREEN_WIDTH - stackWidth.constant - 1.0, height: itemHeight.constant)
        
        collectionView.register(UINib(nibName: "DatabaseEditingCell", bundle: .main), forCellWithReuseIdentifier: "DatabaseEditingCell")
    }
    
    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done() {
        
        view.endEditing(true)
        
        var fields: [String: Any] = [:]
        for index in 0..<columns.count {
            let indexPath = IndexPath(item: 0, section: index)
            guard let cell = collectionView.cellForItem(at: indexPath) as? DatabaseEditingCell else { continue }
            let column = columns[index]
            let text = cell.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if text.isEmpty {
                continue
            }
            switch column.type {
            case .integer:
                if let value = Int(text) {
                    fields[column.name] = value
                }
            case .float:
                if let value = Double(text) {
                    fields[column.name] = value
                }
            case .text:
                fields[column.name] = text
            case .blob:
                fields[column.name] = text.data(using: .utf8) ?? Data()
            }
        }
        
        guard fields.isEmpty == false else {
            MNToast.showMsg("请至少填写一个字段")
            return
        }
        
        if database.insert(into: table.tableName, using: fields) {
            MNToast.showMsg("添加成功")
            let handler = insertSucceededHandler
            navigationController?.popViewController(animated: true)
            DispatchQueue.main.async {
                handler?()
            }
        } else {
            MNToast.showMsg("添加失败")
        }
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
        case "birthday":
            DatePicker.show(in: view) { date in
                textField.text = date.mn.string(format: "yyyy-MM-dd")
            }
            return false
        case "gender":
            //MNAlertView(title: <#T##String?#>, message: <#T##String?#>, style: <#T##MNAlertView.Style#>, cancelButtonTitle: <#T##String?#>, otherButtonTitles: <#T##String?...##String?#>)
            return false
        default: break
        }
        
        
        
        return true
    }
}
