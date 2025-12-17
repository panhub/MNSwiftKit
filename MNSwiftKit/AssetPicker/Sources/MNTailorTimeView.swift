//
//  MNTailorTimeView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/9/25.
//  裁剪时间

import UIKit

class MNTailorTimeView: UIView {
    
    private let divider: UIView = UIView()
    
    private let timeLabel: UILabel = UILabel()
    
    var textColor: UIColor? {
        get { timeLabel.textColor }
        set { timeLabel.textColor = newValue }
    }
    
    override var backgroundColor: UIColor? {
        get { timeLabel.backgroundColor }
        set { timeLabel.backgroundColor = newValue }
    }
    
    override var tintColor: UIColor! {
        get { divider.backgroundColor }
        set { divider.backgroundColor = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        timeLabel.text = "00:00"
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .center
        timeLabel.clipsToBounds = true
        timeLabel.layer.cornerRadius = 3.0
        timeLabel.font = .systemFont(ofSize: 10.0, weight: .medium)
        timeLabel.textColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        timeLabel.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: topAnchor),
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor),
            timeLabel.rightAnchor.constraint(equalTo: rightAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 16.0)
        ])
        
        divider.backgroundColor = timeLabel.textColor
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1.0),
            divider.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 3.0),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.0),
            divider.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新时间
    /// - Parameter time: 时间
    func update(time: TimeInterval) {
        
        timeLabel.text = Date(timeIntervalSince1970: time).mn.playTime
    }
}
