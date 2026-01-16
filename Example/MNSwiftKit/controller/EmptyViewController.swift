//
//  EmptyViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/14.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

extension MNDataEmptyComponent {
    
    var text: String {
        switch self {
        case .image: return "image"
        case .text: return "text"
        case .button: return "button"
        }
    }
}

class EmptyViewController: UIViewController {
    // 组件
    private var components: [MNDataEmptyComponent] = [.image, .text, .button]
    // 列表
    @IBOutlet weak var tableView: UITableView!
    // 开关按钮
    @IBOutlet weak var switchButton: UISwitch!
    // 布局调整
    @IBOutlet weak var collectionView: UICollectionView!
    // 布局
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航高度约束
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    // collectionView的高度
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        let sectionInset = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
        collectionLayout.sectionInset = sectionInset
        collectionLayout.minimumLineSpacing = 15.0
        collectionLayout.headerReferenceSize = .zero
        collectionLayout.footerReferenceSize = .zero
        let itemWidth = floor((MN_SCREEN_WIDTH - sectionInset.left - sectionInset.right - collectionLayout.minimumLineSpacing*2.0)/3.0*10.0)/10.0
        let itemHeight = collectionHeight.constant - sectionInset.top - sectionInset.bottom
        collectionLayout.itemSize = .init(width: itemWidth, height: itemHeight)
        
        collectionView.reorderingCadence = .immediate
        collectionView.dragInteractionEnabled = true
        collectionView.register(UINib(nibName: "EmptySortedCollectionCell", bundle: .main), forCellWithReuseIdentifier: "EmptySortedCollectionCell")
        
        tableView.rowHeight = 85.0
        tableView.register(UINib(nibName: "EditingTableCell", bundle: .main), forCellReuseIdentifier: "EditingTableCell")
        tableView.tableFooterView = UIView(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: MN_BOTTOM_SAFE_HEIGHT)))
        
        // 开启空数据管理
        tableView.mn.dataEmptyDelegate = self
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        
        tableView.reloadData()
    }
}

// MARK: - UITableView
extension EmptyViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switchButton.isOn ? 0 : 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.dequeueReusableCell(withIdentifier: "EditingTableCell", for: indexPath)
    }
}

extension EmptyViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let component = components[indexPath.item]
        let itemProvider = NSItemProvider(object: component.text as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = component
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let previewParameters = UIDragPreviewParameters()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        previewParameters.visiblePath = UIBezierPath(roundedRect: .init(origin: .zero, size: layout.itemSize), cornerRadius: 8.0)
        previewParameters.backgroundColor = .clear
        return previewParameters
    }
}

extension EmptyViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: any UIDropSession) -> Bool {
        
        session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // 如果没有指定位置，放到最后
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        // 处理不同的拖拽操作
        switch coordinator.proposal.operation {
        case .move:
            reorderItems(coordinator: coordinator,
                                destinationIndexPath: destinationIndexPath,
                                collectionView: collectionView)
        case .copy:
            copyItems(coordinator: coordinator,
                             destinationIndexPath: destinationIndexPath)
        default: break
        }
        // 更新空数据视图
        tableView.mn.dataEmptyComponents = components
    }
    
    // 重新排序项目
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
            collectionView.performBatchUpdates({
                // 更新数据源
                let movedItem = components.remove(at: sourceIndexPath.item)
                components.insert(movedItem, at: destinationIndexPath.item)
                // 移动Cell
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
        
        // 复制项目（从外部拖拽进来时）
    private func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
        coordinator.session.loadObjects(ofClass: NSString.self) { [weak self] items in
            guard let self = self, let stringItems = items as? [String] else { return }
            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                var component: MNDataEmptyComponent
                if item == MNDataEmptyComponent.image.text {
                    component = .image
                } else if item == MNDataEmptyComponent.text.text {
                    component = .text
                } else {
                    component = .button
                }
                let indexPath = IndexPath(item: destinationIndexPath.item + index, section: destinationIndexPath.section)
                self.components.insert(component, at: indexPath.item)
                indexPaths.append(indexPath)
            }
            collectionView.insertItems(at: indexPaths)
        }
    }
}

// MARK: - UICollectionView
extension EmptyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        components.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.dequeueReusableCell(withReuseIdentifier: "EmptySortedCollectionCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? EmptySortedCollectionCell else { return }
        let component = components[indexPath.item]
        cell.update(text: component.text)
    }
}

// MARK: - MNDataEmptySource
extension EmptyViewController: MNDataEmptyDelegate {
    
    func offsetForDataEmptyView() -> UIOffset {
        
        .init(horizontal: 0.0, vertical: -55.0)
    }
    
    func imageForDataEmptyView() -> UIImage? {
        
        UIImage(named: "network_error_dark")
    }
    
    func imageSizeForDataEmptyView() -> CGSize {
        
        CGSize(width: 150.0, height: 150.0)
    }
    
    func attributedHintForDataEmptyView() -> NSAttributedString? {
        
        NSAttributedString(string: "网络错误，请稍后重试", attributes: [.font:UIFont.systemFont(ofSize: 16.0, weight: .regular), .foregroundColor:UIColor(red: 139.0/255.0, green: 139.0/255.0, blue: 139.0/255.0, alpha: 1.0)])
    }
    
    func buttonSizeForDataEmptyView() -> CGSize {
        
        CGSize(width: 85.0, height: 35.0)
    }
    
    func buttonRadiusForDataEmptyView() -> CGFloat {
        
        5.0
    }
    
    func buttonAttributedTitleForDataEmptyView(for state: UIControl.State) -> NSAttributedString? {
        
        NSAttributedString(string: "检查网络", attributes: [.font:UIFont.systemFont(ofSize: 15.0, weight: .medium), .foregroundColor:UIColor.white])
    }
    
    func buttonBackgroundColorForDataEmptyView() -> UIColor? {
        
        .systemOrange
    }
    
    func dataEmptyViewButtonTouchUpInside() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            MNToast.showMsg("无法跳转设置界面\n请前往[设置]手动打开")
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            _ = UIApplication.shared.openURL(url)
        }
    }
}
