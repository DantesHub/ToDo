//
//  TaskOptionCell.swift
//  Todo
//
//  Created by Dante Kim on 11/20/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints

class StepCell: UITableViewCell {
    var circleView = RoundView()
    var cellTitle = UILabel()
    var done = false
    var x = UIImageView(image: UIImage(named: "plus")?.rotate(radians: -.pi/4)?.resize(targetSize: CGSize(width: 35, height: 35)).withTintColor(.gray))
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(circleView)
        self.addSubview(cellTitle)
        circleView.width(25)
        circleView.height(25)
        circleView.backgroundColor = .white
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.darkGray.cgColor
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        circleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        
        cellTitle.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 13).isActive = true
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        cellTitle.font = UIFont(name: "OpenSans-Regular", size: 18)
        cellTitle.textColor = UIColor.darkGray
        
        x.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(x)
        x.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        x.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
