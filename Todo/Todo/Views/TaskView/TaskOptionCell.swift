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
    let hr = UIView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(cellImage)
        self.addSubview(cellTitle)
       
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        cellImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        
        cellTitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 25).isActive = true
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 3).isActive = true
        cellTitle.font = UIFont(name: "OpenSans-Regular", size: 20)
        cellTitle.textColor = UIColor.darkGray
        
        if needX {
            x.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(x)
            x.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            x.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
