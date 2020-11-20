//
//  TaskOptionCell.swift
//  Todo
//
//  Created by Dante Kim on 11/20/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints

class TaskOptionCell: UITableViewCell {
    var cellImage = UIImageView()
    var cellTitle = UILabel()
    var x = UIImageView(image: UIImage(named: "plus")?.rotate(radians: -.pi/4)?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(.gray))
    var needX = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(cellImage)
        self.addSubview(cellTitle)
       
        
        cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        cellImage.centerY(to: self)
        
        cellTitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 20).isActive = true
        cellTitle.centerY(to: self)
        cellTitle.font = UIFont(name: "OpenSans-Regular", size: 17)
        cellTitle.textColor = UIColor.gray
        
        if needX {
            self.addSubview(x)
            x.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            x.centerY(to: self)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
