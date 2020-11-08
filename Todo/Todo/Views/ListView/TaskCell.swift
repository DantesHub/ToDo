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
    var circle = RoundView()
    var steps = UILabel()
    var priority = UIImageView()
    var calendar = UIImageView()
    var plannedDate = UILabel()
    var bell = UIImageView()
    var reminderDate = UILabel()
    var repeatImage = UIImageView()
    var bottomView = UIView()
    var listLabel = UILabel()
    var prioritized = 0
    var reminder = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
     }
    
    func configureUI() {
        self.addSubview(circle)
        circle.width(25)
        circle.height(25)
        circle.backgroundColor = .white
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.red.cgColor
        circle.leading(to: self, offset: 15)
        circle.top(to: self, offset: 15)
        
        let circleGest = UITapGestureRecognizer(target: self, action: #selector(tappedCircle))
        circle.addGestureRecognizer(circleGest)
        
        self.addSubview(title)
        title.font = UIFont(name: "OpenSans-Regular", size: 18)
        title.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10).isActive = true
        title.top(to: self, offset: 15)
        
        self.addSubview(star)
        star.image = UIImage(named: "star")?.resize(targetSize: CGSize(width: 25, height: 25))
        star.trailing(to: self, offset: -15)
        star.top(to: self, offset: 10)
        let starGest = UITapGestureRecognizer(target: self, action: #selector(tappedStar))
        star.isUserInteractionEnabled = true
        star.addGestureRecognizer(starGest)
        reminderDate.text = ""
        steps.text = ""
        plannedDate.text = ""
        
    }
    func configureBottomView() {
        bottomView.frame = CGRect(x: 0, y: 48, width: UIScreen.main.bounds.width - 20, height: 28)
        bottomView.layer.cornerRadius = 10
        bottomView.backgroundColor = medGray
        self.addSubview(bottomView)
        
        bottomView.addSubview(listLabel)
        listLabel.leading(to: bottomView, offset: 20)
        listLabel.top(to: bottomView, offset: 5)
        listLabel.font = UIFont(name: "OpenSans-Regular", size: 12)
        listLabel.textColor = .gray
        listLabel.text = ""
        let dot = RoundView()
        if listLabel.text != "" {
            bottomView.addSubview(dot)
            dot.width(5)
            dot.height(5)
            dot.leadingAnchor.constraint(equalTo: listLabel.trailingAnchor, constant: 5).isActive = true
            dot.top(to: bottomView, offset: 12)
            dot.backgroundColor = .black
        }
        bottomView.addSubview(steps)
        steps.leadingAnchor.constraint(equalTo: listLabel.text != "" ? dot.trailingAnchor : listLabel.trailingAnchor, constant: 5).isActive = true
        steps.top(to: bottomView, offset: 5)
        steps.font = UIFont(name: "OpenSans-Regular", size: 12)
        steps.text = ""
        steps.textColor = .gray
        
        let dot2 = RoundView()
        if steps.text != "" {
            bottomView.addSubview(dot2)
            dot2.width(5)
            dot2.height(5)
            dot2.leadingAnchor.constraint(equalTo: steps.trailingAnchor, constant: 8).isActive = true
            dot2.top(to: bottomView, offset: 12)
            dot2.backgroundColor = .black
        }
        
        if prioritized != 0 {
            var color: UIColor?
            switch prioritized {
            case 1:
                color = .red
            case 2:
                color = gold
            case 3:
                color = .blue
            case 4:
                color = .clear
            default:
                print("boomg")
            }
            if color == UIColor.clear {
                priority.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 20, height: 20))
            } else {
                priority.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 20, height: 20)).withTintColor(color!)
            }
        }
        
        bottomView.addSubview(priority)
        priority.top(to: bottomView, offset: 5)
        if steps.text != "" {
            priority.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 5).isActive = true
        } else if listLabel.text != "" {
            priority.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5).isActive = true
        } else {
            priority.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 20).isActive = true
        }
        
        
        let dot3 = RoundView()
        bottomView.addSubview(calendar)
        calendar.top(to: bottomView, offset: 5)
        if prioritized != 0 && (plannedDate.text != "" || reminderDate.text != "") {
            bottomView.addSubview(dot3)
            dot3.width(5)
            dot3.height(5)
            dot3.leadingAnchor.constraint(equalTo: priority.trailingAnchor, constant: 8).isActive = true
            dot3.top(to: bottomView, offset: 12)
            dot3.backgroundColor = .black
            calendar.leadingAnchor.constraint(equalTo: dot3.trailingAnchor, constant: 5).isActive = true
        } else if steps.text != "" {
            calendar.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 5).isActive = true
        } else if listLabel.text != "" {
            calendar.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5).isActive = true
        } else {
            calendar.leadingAnchor.constraint(equalTo: priority.leadingAnchor).isActive = true
        }
        
        let dot4 = RoundView()
        bottomView.addSubview(plannedDate)
        bottomView.addSubview(bell)
        bell.top(to: bottomView, offset: 5)
        if plannedDate.text != "" {
            calendar.image = UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 20, height: 20))
            plannedDate.leadingAnchor.constraint(equalTo: calendar.trailingAnchor, constant: 5).isActive = true
            plannedDate.top(to: bottomView, offset: 5)
            plannedDate.font = UIFont(name: "OpenSans-Regular", size: 12)
            plannedDate.textColor = .gray
            if reminderDate.text != "" || reminder != false{
                bottomView.addSubview(dot4)
                dot4.width(5)
                dot4.height(5)
                dot4.leadingAnchor.constraint(equalTo: plannedDate.trailingAnchor, constant: 8).isActive = true
                dot4.top(to: bottomView, offset: 12)
                dot4.backgroundColor = .black
            }
        }
        
        if reminderDate.text != "" {
            bell.image = UIImage(named: "bell")?.resize(targetSize: CGSize(width: 20, height: 20))
            if plannedDate.text != "" {
                bell.leadingAnchor.constraint(equalTo: dot4.trailingAnchor, constant: 5).isActive = true
            } else if prioritized != 0 {
                bell.leadingAnchor.constraint(equalTo: dot3.trailingAnchor, constant: 5).isActive = true
            } else if steps.text != "" {
                bell.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 5).isActive = true
            } else if listLabel.text != "" {
                bell.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5).isActive = true
            } else {
                bell.trailingAnchor.constraint(equalTo: plannedDate.trailingAnchor).isActive = true
            }
        }

        
    }
    @objc func tappedCircle() {
        print("tapped Circle")
    }
    
    @objc func tappedStar() {
        print("tapped Star")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

}
