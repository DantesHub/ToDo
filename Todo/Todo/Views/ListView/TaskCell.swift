//
//  TaskCell.swift
//  Todo
//
//  Created by Dante Kim on 11/6/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints
class TaskCell: UITableViewCell {
    var title = UILabel()
    var star = UIImageView()
    var circle = UIImageView()
    var steps = UILabel()
    var priority = UIImageView()
    var calendar = UIImageView()
    var planendDate = UILabel()
    var bell = UIImageView()
    var reminderDate = UILabel()
    var repeatImage = UIImageView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
     }

     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

}
