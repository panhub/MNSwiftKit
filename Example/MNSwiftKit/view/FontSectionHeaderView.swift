//
//  FontSectionHeaderView.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/12.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class FontSectionHeaderView: UITableViewHeaderFooterView {
    
    private let familyLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backgroundView = BackgroundView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        familyLabel.numberOfLines = 1
        familyLabel.font = UIFont(name: "AlNile", size: 16.0)
        familyLabel.textColor = UIColor(mn_hex: 0x4699D9)
        familyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(familyLabel)
        NSLayoutConstraint.activate([
            familyLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15.0),
            familyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(family: FontFamily) {
        
        familyLabel.text = family.name
    }
}
