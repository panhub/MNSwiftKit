//
//  UICollectionView+MNEditing.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/26.
//

import UIKit
import Foundation
import CoreFoundation
import ObjectiveC.runtime

// MARK: - UICollectionViewEditingDelegate
public protocol UICollectionViewEditingDelegate {
    
    /// 提交表格的编辑方向
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - indexPath: 索引
    /// - Returns: 编辑方向
    func collectionView(_ collectionView: UICollectionView, editingDirectionsForItemAt indexPath: IndexPath) -> MNEditingView.Direction
    
    /// 提交编辑视图
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - indexPath: 索引
    ///   - direction: 拖拽方向
    /// - Returns: 编辑视图
    func collectionView(_ collectionView: UICollectionView, editingActionsForItemAt indexPath: IndexPath, direction: MNEditingView.Direction) -> [UIView]
    
    /// 提交二次编辑视图
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - action: 点击的按钮
    ///   - indexPath: 索引
    ///   - direction: 拖拽方向
    /// - Returns: 二次编辑视图
    func collectionView(_ collectionView: UICollectionView, commitEditing action: UIView, forItemAt indexPath: IndexPath, direction: MNEditingView.Direction) -> UIView?
}

// MARK: - Collection Associated Key
extension UICollectionView {
    
    fileprivate struct MNEditingAssociated {
        // 是否处于编辑状态
        nonisolated(unsafe) static var editing: Void?
        // 编辑配置
        nonisolated(unsafe) static var options: Void?
        // 事件监听者
        nonisolated(unsafe) static var observer: Void?
    }
}

// MARK: - UICollectionView
extension MNNameSpaceWrapper where Base: UICollectionView {
    
    /// 是否有表格处于编辑状态
    fileprivate var isEditing: Bool {
        get { objc_getAssociatedObject(base, &UICollectionView.MNEditingAssociated.editing) as? Bool ?? false }
        set { objc_setAssociatedObject(base, &UICollectionView.MNEditingAssociated.editing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 编辑视图的配置
    public var editingOptions: MNEditingOptions {
        if let options = objc_getAssociatedObject(base, &UICollectionView.MNEditingAssociated.options) as? MNEditingOptions { return options }
        if objc_getAssociatedObject(base, &UICollectionView.MNEditingAssociated.observer) == nil {
            let observer = MNEditingObserver(scrollView: base)
            observer.delegate = base
            objc_setAssociatedObject(base, &UICollectionView.MNEditingAssociated.observer, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        let options = MNEditingOptions()
        objc_setAssociatedObject(base, &UICollectionView.MNEditingAssociated.options, options, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return options
    }
    
    /// 结束编辑
    /// - Parameter animated: 是否动态显示过程
    public func endEditing(animated: Bool) {
        guard isEditing else { return }
        isEditing = false
        for cell in base.visibleCells {
            cell.mn.endEditing(animated: animated)
        }
    }
}

// MARK: - MNEditingObserveDelegate
extension UICollectionView: MNEditingObserveDelegate {
    
    func scrollView(_ scrollView: UIScrollView, didChangeContentSize change: [NSKeyValueChangeKey : Any]?) {
        mn.endEditing(animated: false)
    }
    
    func scrollView(_ scrollView: UIScrollView, didChangeContentOffset change: [NSKeyValueChangeKey : Any]?) {
        mn.endEditing(animated: (scrollView.isDragging || scrollView.isDecelerating))
    }
}

// MARK: - Cell Associated Key
extension UICollectionViewCell {
    
    fileprivate struct MNEditingAssociated {
        // 内容视图位置
        nonisolated(unsafe) static var contentX: Void?
        // 编辑视图
        nonisolated(unsafe) static var editingView: Void?
        // 是否允许编辑
        nonisolated(unsafe) static var allowsEditing: Void?
        // 拖拽手势交互前记录是否处于编辑状态, 交互后根据此状态决定是否更改 CollectionView 的编辑状态
        nonisolated(unsafe) static var referenceEditing: Void?
    }
}

// MARK: - UICollectionViewCell
extension MNNameSpaceWrapper where Base: UICollectionViewCell {
    
    /// 编辑开始时的x
    fileprivate var contentViewX: CGFloat {
        get { objc_getAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.contentX) as? CGFloat ?? 0.0 }
        set { objc_setAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.contentX, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 编辑视图
    fileprivate var editingView: MNEditingView? {
        get { objc_getAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.editingView) as? MNEditingView }
        set { objc_setAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.editingView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 记录编辑状态
    fileprivate var referenceEditing: Bool {
        get { objc_getAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.referenceEditing) as? Bool ?? false }
        set { objc_setAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.referenceEditing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 是否处于编辑状态
    fileprivate var isEditing: Bool {
        guard let editingView = editingView, editingView.frame.width > 0.0 else { return false }
        return true
    }
    
    /// 是否允许编辑
    public var allowsEditing: Bool {
        get { (objc_getAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.allowsEditing) as? Bool) ?? false }
        set {
            if allowsEditing == newValue { return }
            objc_setAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.allowsEditing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    
    /// 约束内容视图
    public func layoutContentView() {
        guard let editingView = editingView else { return }
        layoutContent(offset: editingView.frame.width, direction: editingView.direction)
    }
    
    /// 约束内容偏移量
    /// - Parameters:
    ///   - offset: 偏移量
    ///   - direction: 编辑方向
    fileprivate func layoutContent(offset: CGFloat, direction: MNEditingView.Direction) {
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

// MARK: - 集合视图
extension MNNameSpaceWrapper where Base: UICollectionViewCell {
    
    /// 所在集合视图的索引
    public var indexPath: IndexPath? {
        guard let collectionView = collectionView else { return nil }
        return collectionView.indexPath(for: base)
    }
    
    /// 在响应链上寻找集合视图
    public var collectionView: UICollectionView? {
        var next = base.next
        while let responder = next {
            if responder is UICollectionView { return responder as? UICollectionView }
            next = responder.next
        }
        return nil
    }
    
    /// 更新编辑状态
    /// - Parameters:
    ///   - editing: 是否开启编辑
    ///   - animated: 是否显示动画过程
    fileprivate func updateEditing(_ editing: Bool, animated: Bool) {
        if let collectionView = collectionView {
            collectionView.mn.isEditing = editing
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
                    self.layoutEditingView(true)
                }, completion: completionHandler)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.layoutEditingView(false)
                }, completion: completionHandler)
            }
        } else {
            layoutEditingView(editing)
            base.didEndUpdateEditing(editing, animated: animated)
        }
    }
    
    /// 根据编辑状态约束编辑视图
    /// - Parameter editing: 是否编辑
    fileprivate func layoutEditingView(_ editing: Bool) {
        guard let editingView = editingView else { return }
        var rect = editingView.frame
        if editing {
            rect.size.width = editingView.constant
        } else {
            rect.size.width = 0.0
        }
        if (editingView.direction == .left || editingView.direction.contains(.left)), let collectionView = collectionView {
            let spacing = collectionView.mn.editingOptions.contentInset.right
            rect.origin.x = base.frame.width - rect.width - spacing
        }
        editingView.frame = rect
        editingView.update(width: rect.width)
        base.setNeedsLayout()
        base.layoutIfNeeded()
    }
}

// MARK: - 拖拽处理
extension UICollectionViewCell {
    
    /// 处理拖拽手势
    /// - Parameter recognizer: 手势
    @objc fileprivate func mn_handle_editing(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // 开始拖拽, 记录此时是否处于编辑状态, 解决无效拖拽导致更改 CollectionView 编辑状态的问题
            mn.referenceEditing = mn.isEditing
        case .changed:
            guard let collectionView = mn.collectionView else { break }
            var editingView: MNEditingView! = mn.editingView
            let velocity = recognizer.velocity(in: recognizer.view)
            if editingView == nil || editingView.frame.width <= 0.0 {
                // 依据方向更新视图
                guard let indexPath = collectionView.indexPath(for: self) else { break }
                guard let delegate = collectionView.dataSource as? UICollectionViewEditingDelegate else { break }
                let direction: MNEditingView.Direction = velocity.x > 0.0 ? .right : .left
                let directions = delegate.collectionView(collectionView, editingDirectionsForItemAt: indexPath)
                guard direction == directions || directions.contains(direction) else { break }
                let actions = delegate.collectionView(collectionView, editingActionsForItemAt: indexPath, direction: direction)
                guard actions.isEmpty == false else { break }
                collectionView.mn.endEditing(animated: true)
                if editingView == nil {
                    editingView = MNEditingView(options: collectionView.mn.editingOptions)
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
                let spacing = collectionView.mn.editingOptions.contentInset.right
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
                // 解决无效拖拽导致更改 CollectionView 编辑状态的问题
                guard mn.referenceEditing else { break }
                if let collectionView = mn.collectionView {
                    collectionView.mn.isEditing = false
                }
            } else if editingView.frame.width == constant {
                if let collectionView = mn.collectionView {
                    collectionView.mn.isEditing = true
                }
            } else if editingView.frame.width > constant || (editingView.frame.width >= 40.0 && ((editingView.direction == .left && velocity.x < 0.0) || (editingView.direction == .right && velocity.x > 0.0))) {
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
extension UICollectionViewCell: MNEditingViewDelegate {
    
    func editingView(_ editingView: MNEditingView, actionButtonTouchUpInside action: UIView, index: Int) {
        guard let collectionView = mn.collectionView else { return }
        guard let indexPath = collectionView.indexPath(for: self) else { return }
        guard let delegate = collectionView.dataSource as? UICollectionViewEditingDelegate else { return }
        guard let newAction = delegate.collectionView(collectionView, commitEditing: action, forItemAt: indexPath, direction: editingView.direction) else { return }
        let offset = newAction.frame.width
        let direction = editingView.direction
        editingView.replaceAction(with: newAction, at: index) { [weak self] in
            guard let self = self else { return }
            self.mn.layoutContent(offset: offset, direction: direction)
        }
    }
}

// MARK: -
@objc extension UICollectionViewCell {
    
    /// 即将更新编辑状态
    /// - Parameters:
    ///   - editing: 指定编辑状态
    ///   - animated: 是否显示动画过程
    @objc func willBeginUpdateEditing(_ editing: Bool, animated: Bool) {}
    
    /// 更新编辑状态结束
    /// - Parameters:
    ///   - editing: 编辑状态
    ///   - animated: 是否显示动画过程
    @objc func didEndUpdateEditing(_ editing: Bool, animated: Bool) {}
}
