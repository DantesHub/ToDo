//
//  MainPopUpcell.swift
//  Todo
//
//  Created by Dante Kim on 10/13/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints

class MainPopUpcell: BaseCell {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Add List"
        return label
    }()
    let icon = UIImageView()
    override func setUpViews() {
        super.setUpViews()
        self.addSubview(icon)
        icon.bottom(to: self)
        icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        icon.width(30)
        icon.height(30)

        self.addSubview(nameLabel)
        nameLabel.bottom(to: self)
        nameLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 20).isActive = true
        nameLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
    }
}
