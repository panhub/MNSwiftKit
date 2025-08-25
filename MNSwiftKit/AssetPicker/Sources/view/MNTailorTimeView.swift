//
//  MNTailorTimeView.swift
//  MNTest
//
//  Created by 冯盼 on 2022/9/25.
//  裁剪时间

import UIKit
//#if canImport(MNSwiftKit_Layout)
//import MNSwiftKit_Layout
//#endif

class MNTailorTimeView: UIView {
    
    private let timeLabel: UILabel = UILabel()
    
    private let separator: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 11.0))
    
    var textColor: UIColor? {
        get { timeLabel.textColor }
        set { timeLabel.textColor = newValue }
    }
    
    override var backgroundColor: UIColor? {
        get { timeLabel.backgroundColor }
        set { timeLabel.backgroundColor = newValue }
    }
    
    override var tintColor: UIColor! {
        get { separator.backgroundColor }
        set { separator.backgroundColor = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        timeLabel.text = "00:00"
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 11.0)
        timeLabel.textColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        timeLabel.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        timeLabel.sizeToFit()
        timeLabel.mn_layout.width = ceil(timeLabel.frame.width)
        timeLabel.mn_layout.height = ceil(timeLabel.frame.height)
        timeLabel.mn_layout.size = timeLabel.bounds.inset(by: UIEdgeInsets(top: -4.0, left: -8.0, bottom: -3.0, right: -8.0)).size
        timeLabel.layer.cornerRadius = 3.0
        timeLabel.clipsToBounds = true
        addSubview(timeLabel)
        
        mn_layout.width = timeLabel.frame.width
        
        separator.mn_layout.minY = timeLabel.frame.maxY + 5.0
        separator.mn_layout.midX = timeLabel.frame.midX
        separator.backgroundColor = timeLabel.textColor
        addSubview(separator)
        
        mn_layout.height = separator.frame.maxY + 5.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(duration: TimeInterval) {
        
        timeLabel.text = Date(timeIntervalSince1970: duration).mn_picker.timeString
    }
}
