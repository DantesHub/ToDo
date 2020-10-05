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
    let cellImage = UIImageView()
    let cellTitle = UILabel()
    let count = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(cellImage)
        self.addSubview(cellTitle)
        self.addSubview(count)
        
        cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        cellImage.centerY(to: self)
        
        cellTitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 20).isActive = true
        cellTitle.centerY(to: self)
        
        count.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        count.centerY(to: self)
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//    }

}
