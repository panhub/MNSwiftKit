//
//  UITableView+MNEditing.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/22.
//

import UIKit
import Foundation
import CoreFoundation
import ObjectiveC.runtime

public protocol UITableViewEditingDelegate {
    
    /// 提交表格的编辑方向
    /// - Parameters:
    ///   - tableView: 集合视图
    ///   - indexPath: 索引
    /// - Returns: 支持的编辑方向
    func tableView(_ tableView: UITableView, editingDirectionsForRowAt indexPath: IndexPath) -> MNEditingView.Direction
    
    /// 提交编辑视图
    /// - Parameters:
    ///   - tableView: 集合视图
    ///   - indexPath: 索引
    ///   - direction: 编辑方向
    /// - Returns: 编辑视图
    func tableView(_ tableView: UITableView, editingActionsForRowAt indexPath: IndexPath, direction: MNEditingView.Direction) -> [UIView]
    
    /// 提交二次编辑视图
    /// - Parameters:
    ///   - tableView: 集合视图
    ///   - action: 点击的按钮
    ///   - indexPath: 索引
    ///   - direction: 编辑方向
    /// - Returns: 二次编辑视图
    func tableView(_ tableView: UITableView, commitEditing action: UIView, forRowAt indexPath: IndexPath, direction: MNEditingView.Direction) -> UIView?
}

extension UITableView {
    
    fileprivate struct MNEditingAssociated {
        // 是否处于编辑状态
        static var editing = "com.mn.table.view.editing"
        // 编辑配置选项
        static var options = "com.mn.table.view.editing.options"
        // 事件监听者
        static var observer = "com.mn.table.view.editing.observer"
    }
}

extension MNNameSpaceWrapper where Base: UITableView {
    
    /// 是否处于编辑状态
    fileprivate var isEditing: Bool {
        get { objc_getAssociatedObject(base, &UITableView.MNEditingAssociated.editing) as? Bool ?? false }
        set { objc_setAssociatedObject(base, &UITableView.MNEditingAssociated.editing, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    /// 编辑视图的配置
    public var editingOptions: MNEditingOptions {
        if let options = objc_getAssociatedObject(base, &UITableView.MNEditingAssociated.options) as? MNEditingOptions { return options }
        if objc_getAssociatedObject(base, &UITableView.MNEditingAssociated.observer) == nil {
            let observer = MNEditingObserver(scrollView: base)
            observer.delegate = base
            objc_setAssociatedObject(base, &UITableView.MNEditingAssociated.observer, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        let options = MNEditingOptions()
        objc_setAssociatedObject(base, &UITableView.MNEditingAssociated.options, options, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return options
    }
    
    /// 结束编辑
    /// - Parameter animated: 是否动态显示过程
    public func endEditing(animated: Bool) {
        guard isEditing else { return }
        isEditing = false
        for cell in base.subviews.compactMap({ $0 as? UITableViewCell }) {
            cell.mn.endEditing(animated: animated)
        }
    }
}

// MARK: - MNEditingObserveDelegate
extension UITableView: MNEditingObserveDelegate {
    
    func scrollView(_ scrollView: UIScrollView, didChangeContentSize change: [NSKeyValueChangeKey : Any]?) {
        mn.endEditing(animated: false)
    }
    
    func scrollView(_ scrollView: UIScrollView, didChangeContentOffset change: [NSKeyValueChangeKey : Any]?) {
        mn.endEditing(animated: (scrollView.isDragging || scrollView.isDecelerating))
    }
}

extension UITableViewCell {
    
    fileprivate struct MNEditingAssociated {
        // 内容视图位置
        static var contentX = "com.mn.table.view.cell.content.view.x"
        // 编辑视图
        static var editingView = "com.mn.table.view.cell.editing.view"
        // 是否允许编辑
        static var allowsEditing = "com.mn.table.view.cell.allows.editing"
    }
}

// MARK: - 开启编辑
extension MNNameSpaceWrapper where Base: UITableViewCell {
    
    /// 记录编辑开始时的x
    fileprivate var contentViewX: CGFloat {
        get { objc_getAssociatedObject(base, &UITableViewCell.MNEditingAssociated.contentX) as? CGFloat ?? 0.0 }
        set { objc_setAssociatedObject(base, &UITableViewCell.MNEditingAssociated.contentX, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    /// 编辑视图
    fileprivate var editingView: MNEditingView? {
        get { objc_getAssociatedObject(base, &UITableViewCell.MNEditingAssociated.editingView) as? MNEditingView }
        set { objc_setAssociatedObject(base, &UITableViewCell.MNEditingAssociated.editingView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 是否处于编辑状态
    fileprivate var isEditing: Bool {
        guard let editingView = editingView, editingView.frame.width > 0.0 else { return false }
        return true
    }
    
    /// 是否允许编辑
    public var allowsEditing: Bool {
        get { (objc_getAssociatedObject(base, &UITableViewCell.MNEditingAssociated.allowsEditing) as? Bool) ?? false }
        set {
            if allowsEditing == newValue { return }
            objc_setAssociatedObject(base, &UITableViewCell.MNEditingAssociated.allowsEditing, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if newValue {
                let pan = MNEditingRecognizer(target: base, action: #selector(base.mn_handle_editing(_:)))
                base.contentView.addGestureRecognizer(pan)
            } else {
                guard let gestureRecognizers = base.contentView.gestureRecognizers else { return }
                for recognizer in gestureRecognizers.filter ({ $0 is MNEditingRecognizer }) {
                    recognizer.removeTarget(nil, action: nil)
                    base.contentView.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    /// 结束编辑状态
    /// - Parameter animated: 是否动态显示过程
    public func endEditing(animated: Bool) {
        guard isEditing else { return }
        updateEditing(false, animated: animated)
    }
    
    /// 约束编辑视图
    public func layoutEditingView() {
        guard let editingView = editingView else { return }
        layout(offset: editingView.frame.width, direction: editingView.direction)
    }
    
    /// 指定更新偏移量
    /// - Parameters:
    ///   - offset: 偏移量
    ///   - direction: 编辑方向
    fileprivate func layout(offset: CGFloat, direction: MNEditingView.Direction) {
        var rect = base.contentView.frame
        rect.origin.x = contentViewX
        if offset > 0.0 {
            if direction == .left || direction.contains(.left) {
                rect.origin.x -= offset
            } else {
                rect.origin.x += offset
            }
        }
        base.contentView.frame = rect
    }
}

// MARK: - 寻找集合视图
extension MNNameSpaceWrapper where Base: UITableViewCell {
    
    /// 当前行索引
    public var indexPath: IndexPath? {
        guard let tableView = tableView else { return nil }
        return tableView.indexPath(for: base)
    }
    
    /// 响应链上最近的列表集合视图
    public var tableView: UITableView? {
        var next = base.next
        while let responder = next {
            if responder is UITableView { return responder as? UITableView }
            next = responder.next
        }
        return nil
    }
    
    /// 更新编辑状态
    /// - Parameters:
    ///   - editing: 是否开启编辑
    ///   - animated: 是否显示动画过程
    fileprivate func updateEditing(_ editing: Bool, animated: Bool) {
        if let tableView = tableView {
            tableView.mn.isEditing = editing
        }
        guard let editingView = editingView else { return }
        base.willBeginUpdateEditing(editing, animated: animated)
        if animated {
            let cell = base
            editingView.isAnimating = true
            let completionHandler: (Bool)->Void = { [weak cell, weak editingView] _ in
                if let editingView = editingView {
                    editingView.isAnimating = false
                }
                if let cell = cell {
                    cell.didEndUpdateEditing(editing, animated: animated)
                }
            }
            if editing {
                UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.update(editing: true)
                }, completion: completionHandler)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.update(editing: false)
                }, completion: completionHandler)
            }
        } else {
            update(editing: editing)
            base.didEndUpdateEditing(editing, animated: animated)
        }
    }
    
    /// 更新编辑状态
    /// - Parameter editing: 是否编辑
    fileprivate func update(editing: Bool) {
        guard let editingView = editingView else { return }
        var rect = editingView.frame
        if editing {
            rect.size.width = editingView.constant
        } else {
            rect.size.width = 0.0
        }
        if editingView.direction == .left, let tableView = tableView {
            let spacing = tableView.mn.editingOptions.contentInset.right
            rect.origin.x = base.frame.width - rect.width - spacing
        }
        editingView.frame = rect
        editingView.update(width: rect.width)
        base.setNeedsLayout()
        base.layoutIfNeeded()
    }
}

// MARK: - 拖拽处理
extension UITableViewCell {
    
    /// 处理拖拽手势
    /// - Parameter recognizer: 手势
    @objc fileprivate func mn_handle_editing(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            guard let tableView = mn.tableView else { break }
            var editingView: MNEditingView! = mn.editingView
            let velocity = recognizer.velocity(in: recognizer.view)
            if editingView == nil || editingView.frame.width <= 0.0 {
                // 依据方向更新视图
                guard let indexPath = tableView.indexPath(for: self) else { break }
                guard let delegate = tableView.dataSource as? UITableViewEditingDelegate else { break }
                let direction: MNEditingView.Direction = velocity.x > 0.0 ? .right : .left
                let directions = delegate.tableView(tableView, editingDirectionsForRowAt: indexPath)
                guard direction == directions || directions.contains(direction) else { break }
                let actions = delegate.tableView(tableView, editingActionsForRowAt: indexPath, direction: direction)
                guard actions.isEmpty == false else { break }
                tableView.mn.endEditing(animated: true)
                if editingView == nil {
                    editingView = MNEditingView(options: tableView.mn.editingOptions)
                    editingView.delegate = self
                    insertSubview(editingView, aboveSubview: contentView)
                    mn.editingView = editingView
                    mn.contentViewX = contentView.frame.minX
                }
                editingView.update(direction: direction)
                editingView.update(actions: actions)
            }
            let translation = recognizer.translation(in: recognizer.view)
            recognizer.setTranslation(.zero, in: recognizer.view)
            var rect = editingView.frame
            var m: CGFloat = translation.x
            if rect.width >= editingView.constant {
                // 超过最优距离, 加阻尼, 减缓拖拽效果
                m = m/3.0*2.0
            }
            if editingView.direction == .left || editingView.direction.contains(.left) {
                let spacing = tableView.mn.editingOptions.contentInset.right
                rect.size.width = max(0.0, floor(rect.width - m))
                rect.origin.x = frame.width - rect.width - spacing
            } else {
                rect.size.width = max(0.0, floor(rect.width + m))
            }
            editingView.frame = rect
            editingView.update(width: rect.width)
            setNeedsLayout()
            layoutIfNeeded()
        case .ended:
            guard let editingView = mn.editingView else { break }
            let constant = editingView.constant
            let velocity = recognizer.velocity(in: recognizer.view)
            if editingView.frame.width <= 0.0 {
                mn.tableView?.mn.isEditing = false
            } else if editingView.frame.width == constant {
                mn.tableView?.mn.isEditing = true
            } else if editingView.frame.width > constant || (editingView.frame.width >= 40.0 && ((editingView.direction == .left && velocity.x < 0.0) || (editingView.direction == .right && velocity.x > 0.0))) {
                // 询问是否可以回归编辑状态
                mn.updateEditing(true, animated: true)
            } else {
                // 结束编辑
                mn.updateEditing(false, animated: true)
            }
        default: break
        }
    }
}

// MARK: - MNEditingViewDelegate
extension UITableViewCell: MNEditingViewDelegate {
    
    func editingView(_ editingView: MNEditingView, actionButtonTouchUpInside action: UIView, index: Int) {
        guard let tableView = mn.tableView else { return }
        guard let indexPath = tableView.indexPath(for: self) else { return }
        guard let delegate = tableView.dataSource as? UITableViewEditingDelegate else { return }
        guard let newAction = delegate.tableView(tableView, commitEditing: action, forRowAt: indexPath, direction: editingView.direction) else { return }
        let offset = newAction.frame.width
        let direction = editingView.direction
        editingView.replaceAction(with: newAction, at: index) { [weak self] in
            guard let self = self else { return }
            self.mn.layout(offset: offset, direction: direction)
        }
    }
}

// MARK: - Begin & End
extension UITableViewCell {
    
    /// 即将更新编辑状态
    /// - Parameters:
    ///   - editing: 指定编辑状态
    ///   - animated: 是否显示动画过程
    @objc public func willBeginUpdateEditing(_ editing: Bool, animated: Bool) {}
    
    /// 更新编辑状态结束
    /// - Parameters:
    ///   - editing: 编辑状态
    ///   - animated: 是否显示动画过程
    @objc public func didEndUpdateEditing(_ editing: Bool, animated: Bool) {}
}
