//
//  DatePicker.swift
//  mellow
//
//  Created by wanneng on 2024/11/25.
//  账单统计-选择日期

import UIKit
import MNSwiftKit

class DatePicker: UIView {
    /// 内容视图
    @IBOutlet weak var dateView: UIView!
    /// 内容视图
    @IBOutlet weak var contentView: UIView!
    /// 取消按钮
    @IBOutlet weak var cancelButton: UIButton!
    /// 选择器
    private lazy var pickerView = MNDatePicker(frame: dateView.bounds)
    /// 选中回调
    private var selectionHandler: ((_ date: Date)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pickerView.textColor = .black
        pickerView.font = .systemFont(ofSize: 17.0, weight: .medium)
        pickerView.rowHeight = 50.0
        pickerView.spacing = 40.0
        pickerView.dateFormat = .iso24.year().separator("年").month().separator("月")
        pickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dateView.addSubview(pickerView)
    }
    
    private func update(formater: MNDatePicker.Formater) {
        pickerView.dateFormat = formater
    }
    
    @IBAction func cancel() {
        selectionHandler = nil
        dismiss()
    }
    
    @IBAction func confirm() {
        dismiss()
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        cancel()
    }
}

extension DatePicker {
    /// 选择日期视图
    /// - Parameters:
    ///   - superview: 展示的父视图
    ///   - format: 格式
    ///   - handler: 选中回调
    class func show(in superview: UIView, format: MNDatePicker.Formater = .iso24.year().separator("年").month().separator("月").day().separator("日"), selection handler: ((_ date: Date)->Void)?) {
        let view = DatePicker.mn.loadFromNib()!
        view.pickerView.dateFormat = format
        view.selectionHandler = handler
        view.frame = superview.bounds
        view.backgroundColor = .clear
        superview.addSubview(view)
        view.layoutIfNeeded()
        view.contentView.alpha = 0.0
        view.contentView.layer.mn.setRadius(25.0, by: [.topLeft, .topRight])
        view.contentView.transform = .init(translationX: 0.0, y: view.contentView.frame.height)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut) {
            view.contentView.alpha = 1.0
            view.contentView.transform = .identity
            view.backgroundColor = .black.withAlphaComponent(0.55)
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.backgroundColor = .clear
            self.contentView.alpha = 0.0
            self.contentView.transform = .init(translationX: 0.0, y: self.contentView.frame.height)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
            guard let selectionHandler = self.selectionHandler else { return }
            selectionHandler(self.pickerView.date)
        }
    }
}

extension DatePicker: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        return contentView.frame.contains(location) == false
    }
}
