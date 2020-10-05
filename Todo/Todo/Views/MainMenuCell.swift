//
//  MainMenuCell.swift
//  Todo
//
//  Created by Dante Kim on 10/5/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints

class MainMenuCell: UITableViewCell {
    var cellImage = UIImageView()
    var cellTitle = UILabel()
    var count = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(cellImage)
        self.addSubview(cellTitle)
        self.addSubview(count)
        
        cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        cellImage.centerY(to: self)
        
        cellTitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 20).isActive = true
        cellTitle.centerY(to: self)
        cellTitle.font = UIFont(name: "OpenSans-Regular", size: 20)
        cellTitle.textColor = UIColor.black
        
        count.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        count.font = UIFont(name: "OpenSans-Regular", size: 15)
        count.text = "2"
        count.textColor = UIColor.gray
        count.centerY(to: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
