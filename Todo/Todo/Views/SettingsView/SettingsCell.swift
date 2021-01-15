//
//  SettingsCell.swift
//  Todo
//
//  Created by Dante Kim on 1/14/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    var cellImage = UIImageView()
    var cellTitle = UILabel()
    var count = UILabel()
    let defaults: UserDefaults = UserDefaults.standard
    var rowNum = 0
    var bottomText = UILabel()
    var sectionNumber = 0
    lazy var mode = sectionNumber == 1 && rowNum == 0 ? defaults.bool(forKey: "toTop") : defaults.bool(forKey: "notif")
    lazy var toggler: UISwitch = {
          let dswitch = UISwitch()
          dswitch.isUserInteractionEnabled = true
          dswitch.translatesAutoresizingMaskIntoConstraints = false
         dswitch.onTintColor = .blue
          if mode {
              dswitch.setOn(true, animated: false)
          }
          dswitch.addTarget(self, action: #selector(stateChanged(_:)), for: .valueChanged)
          return dswitch
      }()
    var arrowView : UIImageView = {
        let image = UIImage(named: "arrow")?.rotate(radians: .pi/2)?.resize(targetSize: CGSize(width: 25, height: 25))
        let iv = UIImageView()
        iv.image = image
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(cellImage)
        self.addSubview(cellTitle)
        self.addSubview(count)
        
        cellImage.centerY(to: self)
        
 

        
        }

    func configureSide() {
        if !(sectionNumber == 1 && rowNum == 0) && !(sectionNumber == 2 && rowNum == 0){
            cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        }
        if !(sectionNumber == 2 && rowNum == 0) {
            cellTitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 20).isActive = true
        }
        if sectionNumber != 0 {
            cellTitle.centerY(to: self)
        }
   
        cellTitle.font = UIFont(name: "OpenSans-Regular", size: 18)
        cellTitle.textColor = UIColor.black
        if sectionNumber == 1 {
            self.addSubview(toggler)
            toggler.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            toggler.centerY(to: self)
            toggler.isUserInteractionEnabled = true
            toggler.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
            if rowNum == 0 {
                cellTitle.text = "Add New Tasks To Top"
                cellImage.image = UIImage(named: "newTaskTop")?.resize(targetSize: CGSize(width: 30, height: 30))
                cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
            } else {
                cellTitle.text = "Notification Reminder"
                cellImage.image = UIImage(named: "notification")?.resize(targetSize: CGSize(width: 25, height: 25))
            }
        } else if sectionNumber == 0 {
            self.addSubview(arrowView)
            arrowView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            arrowView.centerY(to: self)
            let arrowGest = UIGestureRecognizer(target: self, action: #selector(tappedArrow))
            arrowView.addGestureRecognizer(arrowGest)
            cellImage.image = UIImage(named: "star")?.resize(targetSize: CGSize(width: 40, height: 40)).withTintColor(gold)
            cellTitle.top(to: self, offset: 25)
            cellTitle.text = "To Do Premium"
            cellTitle.font = UIFont(name: "OpenSans-Bold", size: 20)
            
            self.addSubview(bottomText)
            bottomText.topToBottom(of: cellTitle)
            bottomText.text = "Upgrade for Groups, Themes and more..."
            bottomText.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 20).isActive = true
            bottomText.font = bottomText.font.withSize(18)
            bottomText.width(self.contentView.frame.width * 0.65)
            
        } else if sectionNumber == 2 {
            if rowNum == 0 {
                cellTitle.text = "Leave Review"
                cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
                cellTitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 10).isActive = true
                cellImage.image = UIImage(named: "edit")?.resize(targetSize: CGSize(width: 40, height: 40))
            } else {
                cellTitle.text = "Contact"
                cellImage.image = UIImage(named: "mail")?.resize(targetSize: CGSize(width: 25, height: 25))
            }
        }
    }
    
    @objc func tappedArrow() {
        print("tapped Arrow")
    }
    @objc func stateChanged(_ sender: UISwitch) {
        if sender.isOn {
            if rowNum == 0 {
                defaults.set(true, forKey: "toTop")
            } else {
                defaults.set(true, forKey: "notif")
            }
          } else {
            if rowNum == 0 {
                defaults.set(false, forKey: "toTop")
            } else {
                defaults.set(false, forKey: "notif")
            }
          }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
