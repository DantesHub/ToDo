//
//  TaskOptionCell.swift
//  Todo
//
//  Created by Dante Kim on 11/20/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints
protocol TaskOptionProtocol {
    func createDone()
    func resetVariable(type: String)
    func reloadTable()
    func reloadStepsTable()
}
class TaskOptionCell: UITableViewCell {
    var cellImage = UIImageView()
    var cellTitle = UILabel()
    var x = UIImageView(image: UIImage(named: "plus")?.rotate(radians: -.pi/4)?.resize(targetSize: CGSize(width: 35, height: 35)).withTintColor(.gray))
    var needX = false
    var reminder = ""
    var dueDate = ""
    var repeatTask = ""
    var parentList = ""
    var type = ""
    var delegate: TaskOptionProtocol?
    var taskDelegate: TaskViewDelegate?
    var id = ""
    var addedBorder = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(cellImage)
        self.addSubview(cellTitle)
       
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        cellImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        
        cellTitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 25).isActive = true
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
        cellTitle.font = UIFont(name: "OpenSans-Regular", size: 20)
        cellTitle.textColor = UIColor.darkGray
    }
    func removeX() {
        x.removeFromSuperview()
    }
    func createX() {
        x.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(x)
        x.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        x.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
        let xTapped = UITapGestureRecognizer(target: self, action: #selector(tappedX))
        x.addGestureRecognizer(xTapped)
        x.isUserInteractionEnabled = true
    }
    
    @objc func tappedX() {
        let results = uiRealm.objects(TaskObject.self)
        for result in results {
            if result.id == id {
                switch type {
                case "Add to a List":
                    try! uiRealm.write {
                        result.parentList = "All Tasks"
                    }
                    cellTitle.text = "Add to a List"
                case "Priority":
                    try! uiRealm.write {
                        result.priority = 0
                    }
                    cellTitle.text = "Priority"
                case "Remind Me":
                    try! uiRealm.write {
                        result.reminder = ""
                    }
                    cellTitle.text = "Remind Me"
                case "Add Due Date":
                    try! uiRealm.write {
                        result.planned = ""
                        result.repeated = ""
                    }
                    delegate?.resetVariable(type: "Repeat")
                    cellTitle.text = "Add Due Date"
                case "Repeat":
                    try! uiRealm.write {
                        result.repeated = ""
                    }
                    cellTitle.text = "Repeat"
                case "Add File":
                    cellTitle.text = "Add File"
                default:
                    break
                }
            }
        }
        delegate?.resetVariable(type: type)
        delegate?.reloadTable()
        cellTitle.textColor = .gray
        cellImage.image = cellImage.image?.withTintColor(.gray)
        x.removeFromSuperview()
        taskDelegate?.reloadTable()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
