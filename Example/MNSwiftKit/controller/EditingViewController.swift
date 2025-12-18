//
//  EditingViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/18.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class EditingViewController: UIViewController {
    //
    private var count: Int = 30
    // 四周约束
    private var contentInset: UIEdgeInsets = .init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    // 列表
    @IBOutlet weak var tableView: UITableView!
    // 最多可选择多少资源
    @IBOutlet weak var topTextField: UITextField!
    // 最长可导出的视频时长
    @IBOutlet weak var leftTextField: UITextField!
    // 最多可选择多少资源
    @IBOutlet weak var bottomTextField: UITextField!
    // 最长可导出的视频时长
    @IBOutlet weak var rightTextField: UITextField!
    
    @IBOutlet weak var listSegment: UISegmentedControl!
    
    @IBOutlet weak var directionSegment: UISegmentedControl!
    
    
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航高度约束
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        tableView.mn.editingOptions.cornerRadius = 8.0
        tableView.mn.editingOptions.contentInset = contentInset
        tableView.mn.editingOptions.backgroundColor = .systemRed
        
        tableView.rowHeight = 85.0
        tableView.register(UINib(nibName: "EditingTableCell", bundle: .main), forCellReuseIdentifier: "EditingTableCell")
        tableView.tableFooterView = UIView(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: MN_BOTTOM_SAFE_HEIGHT)))
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func topUp() {
        
        let number = NSDecimalNumber(string: topTextField.text)
        let value = number.intValue + 1
        topTextField.text = NSNumber(value: value).stringValue
        contentInset.top = CGFloat(value)
        updateContentInset()
    }
    
    @IBAction func topDown() {
        
        let number = NSDecimalNumber(string: topTextField.text)
        let value = max(0, number.intValue - 1)
        topTextField.text = NSNumber(value: value).stringValue
        contentInset.top = CGFloat(value)
        updateContentInset()
    }

    @IBAction func leftUp() {
        
        let number = NSDecimalNumber(string: leftTextField.text)
        let value = number.intValue + 1
        leftTextField.text = NSNumber(value: value).stringValue
        contentInset.left = CGFloat(value)
        updateContentInset()
    }
    
    @IBAction func leftDown() {
        
        let number = NSDecimalNumber(string: leftTextField.text)
        let value = max(0, number.intValue - 1)
        leftTextField.text = NSNumber(value: value).stringValue
        contentInset.left = CGFloat(value)
        updateContentInset()
    }
    
    @IBAction func bottomUp() {
        
        let number = NSDecimalNumber(string: bottomTextField.text)
        let value = number.intValue + 1
        bottomTextField.text = NSNumber(value: value).stringValue
        contentInset.bottom = CGFloat(value)
        updateContentInset()
    }
    
    @IBAction func bottomDown() {
        
        let number = NSDecimalNumber(string: bottomTextField.text)
        let value = max(0, number.intValue - 1)
        bottomTextField.text = NSNumber(value: value).stringValue
        contentInset.bottom = CGFloat(value)
        updateContentInset()
    }
    
    @IBAction func rightUp() {
        
        let number = NSDecimalNumber(string: rightTextField.text)
        let value = number.intValue + 1
        rightTextField.text = NSNumber(value: value).stringValue
        contentInset.right = CGFloat(value)
        updateContentInset()
    }
    
    @IBAction func rightDown() {
        
        let number = NSDecimalNumber(string: rightTextField.text)
        let value = max(0, number.intValue - 1)
        rightTextField.text = NSNumber(value: value).stringValue
        contentInset.right = CGFloat(value)
        updateContentInset()
    }
    
    private func updateContentInset() {
        
        tableView.mn.endEditing(animated: true)
        tableView.mn.editingOptions.contentInset = contentInset
    }
    
    @IBAction func listValueChanged(_ sender: UISegmentedControl) {
        
        tableView.mn.endEditing(animated: true)
    }
    
    @IBAction func directionValueChanged(_ sender: UISegmentedControl) {
        
        tableView.mn.endEditing(animated: true)
    }
}

extension EditingViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditingTableCell", for: indexPath)
        cell.mn.allowsEditing = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? EditingTableCell else { return }
        cell.update(row: indexPath.row)
    }
}

extension EditingViewController: UITableViewEditingDelegate {
    
    func tableView(_ tableView: UITableView, editingDirectionsForRowAt indexPath: IndexPath) -> MNSwiftKit.MNEditingView.Direction {
        
        switch directionSegment.selectedSegmentIndex {
        case 0: return .left
        case 1: return .right
        default: return .all
        }
    }
    
    func tableView(_ tableView: UITableView, editingActionsForRowAt indexPath: IndexPath, direction: MNSwiftKit.MNEditingView.Direction) -> [UIView] {
        
        if direction == .left {
            
            let label1 = UILabel(frame: .init(origin: .zero, size: .init(width: 80.0, height: tableView.rowHeight)))
            label1.textColor = .white
            label1.text = "备注"
            label1.textAlignment = .center
            label1.font = .systemFont(ofSize: 15.0, weight: .regular)
            label1.backgroundColor = .systemYellow
            
            let label2 = UILabel(frame: .init(origin: .zero, size: .init(width: 80.0, height: tableView.rowHeight)))
            label2.tag = 1
            label2.textColor = .white
            label2.text = "删除"
            label2.textAlignment = .center
            label2.font = .systemFont(ofSize: 15.0, weight: .regular)
            label2.backgroundColor = .systemRed
            
            return [label1, label2]
        }
        
        var subviews: [UIView] = []
        
        for (tag, img) in ["e_remark", "e_delete"].enumerated() {
            
            let view = UIView(frame: .init(origin: .zero, size: .init(width: 80.0, height: tableView.rowHeight)))
            view.tag = tag
            view.isUserInteractionEnabled = false
            view.backgroundColor = tag == 0 ? .systemYellow : .systemRed
            
            let imageView = UIImageView(image: UIImage(named: img)?.withRenderingMode(.alwaysTemplate))
            imageView.contentMode = .scaleAspectFit
            imageView.frame = .init(origin: .init(x: (view.frame.width - 23.0)/2.0, y: (view.frame.height - 23.0)/2.0), size: .init(width: 23.0, height: 23.0))
            imageView.tintColor = .white
            imageView.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            view.addSubview(imageView)
            
            subviews.append(view)
        }
        
        return subviews
    }
    
    func tableView(_ tableView: UITableView, commitEditing action: UIView, forRowAt indexPath: IndexPath, direction: MNSwiftKit.MNEditingView.Direction) -> UIView? {
        if action.tag == 0 {
            let button = UIButton(type: .custom)
            button.tag = indexPath.row
            button.frame = .init(origin: .zero, size: .init(width: 180.0, height: tableView.rowHeight))
            //button.setBackgroundImage(UIImage(color: .systemYellow), for: .normal)
            button.setTitle("修改备注", for: .normal)
            button.backgroundColor = .systemYellow
            button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .regular)
            button.addTarget(self, action: #selector(remarkEvent(_:)), for: .touchUpInside)
            return button
        }
        let button = UIButton(type: .custom)
        button.tag = indexPath.row
        button.frame = .init(origin: .zero, size: .init(width: 180.0, height: tableView.rowHeight))
        //button.setBackgroundImage(UIImage(color: .systemRed), for: .normal)
        button.setTitle("确认删除", for: .normal)
        button.backgroundColor = .systemRed
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .regular)
        button.addTarget(self, action: #selector(deleteEvent(_:)), for: .touchUpInside)
        return button
    }
}


extension EditingViewController {
    
    @objc private func deleteEvent(_ sender: UIButton) {
        print("点击了索引: \(sender.tag)")
        count -= 1
        tableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: .left)
    }
    
    @objc private func remarkEvent(_ sender: UIButton) {
        print("点击了索引: \(sender.tag)")
    }
}
