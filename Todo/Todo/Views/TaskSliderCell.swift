//
//  CreateTaskSlideCell.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints

class TaskSliderCell: BaseCell {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Add List"
        return label
    }()
    let hr = UIView()
    let dateLabel = UILabel()
    let icon = UIImageView()
    override func setUpViews() {
        super.setUpViews()
        self.addSubview(icon)
        icon.centerY(to: self)
        icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true

        self.addSubview(nameLabel)
        nameLabel.centerY(to: self)
        nameLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 25).isActive = true
        nameLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
        
        self.addSubview(dateLabel)
        dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        dateLabel.textColor = .gray
        dateLabel.centerY(to: self)
        dateLabel.font = UIFont(name: "OpenSans-Regular", size: 14)
        
        self.addSubview(hr)
        let hr = UIView(frame: CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 0.5))
        hr.backgroundColor = .gray
        
        
    }
}

