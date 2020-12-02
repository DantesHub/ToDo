//
//  TaskCell.swift
//  Todo
//
//  Created by Dante Kim on 11/6/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints
import RealmSwift
protocol TaskViewDelegate {
    func reloadTaskTableView(at: IndexPath, checked: Bool, repeats: String)
    func reloadTable()
    func createObservers()
    func resignResponder()
}

class TaskCell: UITableViewCell {
    var title = UILabel()
    var star = UIImageView()
    var circle = RoundView()
    var steps = UILabel()
    var allSteps = [Step]()
    var priority = UIImageView()
    var calendar = UIImageView()
    var plannedDate = UILabel()
    var bell = UIImageView()
    var reminderDate = UILabel()
    var repeatImage = UIImageView()
    var bottomView = UIView()
    var listLabel = UILabel()
    var prioritized = 0
    var path = IndexPath()
    var taskPlannedDate = ""
    var repeatTask  = ""
    var favorited = false
    var completed =  false
    var position = 0
    var id = ""
    var navigationController = UINavigationController()
    var parentList = ""
    var tasks = uiRealm.objects(TaskObject.self)
    var taskCellDelegate: TaskViewDelegate?
    let check: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 20, height: 20)).withTintColor(.red)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    func configureUI() {
        self.contentView.addSubview(circle)
        circle.width(28)
        circle.height(28)
        circle.leading(to: self, offset: 15)
        circle.top(to: self, offset: 15)
        let cellTapped = UITapGestureRecognizer(target: self, action: #selector(tappedCell))
        self.contentView.addGestureRecognizer(cellTapped)
        let circleGest = UITapGestureRecognizer(target: self, action: #selector(tappedCircle))
        circle.addGestureRecognizer(circleGest)
        
        self.addSubview(title)
        title.font = UIFont(name: "OpenSans-Regular", size: 18)
        title.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10).isActive = true
        title.top(to: self, offset: 15)
        
        self.contentView.addSubview(star)
        star.width(30)
        star.height(30)
        star.trailing(to: self, offset: -15)
        star.top(to: self, offset: 10)
        let starGest = UITapGestureRecognizer(target: self, action: #selector(tappedStar))
        star.isUserInteractionEnabled = true
        star.addGestureRecognizer(starGest)
        reminderDate.text = ""
        steps.text = ""
        plannedDate.text = ""
    }
    
    @objc func tappedCell() {
        let controller = TaskController()
        controller.plannedDate = taskPlannedDate
        controller.reminderDate = reminderDate.text ?? ""
        controller.taskTitle = title.text ?? ""
        controller.favorited = favorited
        controller.id = id
        controller.priority = prioritized
        controller.completed = completed
        controller.path = path
        controller.repeatTask = repeatTask
        controller.parentList = parentList
        controller.delegate = taskCellDelegate
        taskCellDelegate?.resignResponder()
        navigationController.view.layer.add(CATransition().popFromRight(), forKey: nil)
        navigationController.pushViewController(controller, animated: false)
    }
    
    func configureBottomView() {
        star.image = UIImage(named: favorited ? "starfilled" :"star")?.resize(targetSize: CGSize(width: 27, height: 27))
        var priColor = K.getColor(prioritized)
        if priColor == UIColor.clear {
            priColor = .white
        }
        circle.backgroundColor = priColor.modified(withAdditionalHue: 0.00, additionalSaturation: -0.70, additionalBrightness: 0.25)
        if priColor == .white { priColor = .gray}
        circle.layer.borderWidth = 2
        circle.layer.borderColor = priColor.cgColor
        
        if completed == true {
            configureCircle()
        }
        
        
        bottomView.frame = CGRect(x: 0, y: 48, width: UIScreen.main.bounds.width - 20, height: 28)
        bottomView.layer.cornerRadius = 10
        bottomView.backgroundColor = medGray
        self.contentView.addSubview(bottomView)
        let cellTapped = UITapGestureRecognizer(target: self, action: #selector(tappedCell))
        bottomView.addGestureRecognizer(cellTapped)
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
        var completed = 0
        if allSteps.count != 0 {
            for step in allSteps {
                if step.done {
                    completed += 1
                }
            }
            steps.text = String(completed) + " of " + String(allSteps.count)
        }
        bottomView.addSubview(steps)
        steps.leadingAnchor.constraint(equalTo: listLabel.text != "" ? dot.trailingAnchor : listLabel.trailingAnchor, constant: 0).isActive = true
        steps.top(to: bottomView, offset: 5)
        steps.font = UIFont(name: "OpenSans-Regular", size: 13)
        steps.textColor = .darkGray
        
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
                color = green
            case 3:
                color = gold
            case 4:
                color = .clear
            default:
                print("boon")
            }
            if color == UIColor.clear {
                priority.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 14, height: 16))
            } else {
                priority.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 14, height: 16)).withTintColor(color!)
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
        if prioritized != 0 && (taskPlannedDate != "" || reminderDate.text != "" || repeatTask != "") {
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
        if taskPlannedDate != "" {
            let newDatee = taskPlannedDate.replacingOccurrences(of: "-", with: " ")
            let newDate = Date().getDifference(date: newDatee, task: true)
            if let index = newDate.firstIndex(of: ",") {
                plannedDate.text = String(newDate[..<index])
            } else {
                plannedDate.text = newDate
            }

            calendar.image = UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 17, height: 17))
            plannedDate.leadingAnchor.constraint(equalTo: calendar.trailingAnchor, constant: 5).isActive = true
            plannedDate.top(to: bottomView, offset: 5)
            plannedDate.font = UIFont(name: "OpenSans-Regular", size: 12)
            plannedDate.textColor = .gray
            if reminderDate.text != "" || repeatTask != "" {
                bottomView.addSubview(dot4)
                dot4.width(5)
                dot4.height(5)
                dot4.leadingAnchor.constraint(equalTo: plannedDate.trailingAnchor, constant: 8).isActive = true
                dot4.top(to: bottomView, offset: 12)
                dot4.backgroundColor = .black
            }
        }
        
        let dot5 = RoundView()
        if reminderDate.text != "" {
            bell.image = UIImage(named: "bell")?.resize(targetSize: CGSize(width: 17, height: 17))
            if plannedDate.text != "" {
                bell.leadingAnchor.constraint(equalTo: dot4.trailingAnchor, constant: 5).isActive = true
            } else if prioritized != 0 {
                bell.leadingAnchor.constraint(equalTo: dot3.trailingAnchor, constant: 5).isActive = true
            } else if steps.text != "" {
                bell.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 5).isActive = true
            } else if listLabel.text != "" {
                bell.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5).isActive = true
            } else {
                bell.leadingAnchor.constraint(equalTo: plannedDate.trailingAnchor, constant: 20).isActive = true
            }
            
            if repeatTask != "" {
                bottomView.addSubview(dot5)
                dot5.width(5)
                dot5.height(5)
                dot5.leadingAnchor.constraint(equalTo: bell.trailingAnchor, constant: 8).isActive = true
                dot5.top(to: bottomView, offset: 12)
                dot5.backgroundColor = .black
            }
        }
        
        bottomView.addSubview(repeatImage)
        repeatImage.top(to: bottomView, offset: 7)
        if repeatTask != "" {
            repeatImage.image = UIImage(named: "repeat")?.resize(targetSize: CGSize(width: 13, height: 13))
            if reminderDate.text != "" {
                repeatImage.leadingAnchor.constraint(equalTo: dot5.trailingAnchor, constant: 5).isActive = true
            } else if plannedDate.text != "" {
                repeatImage.leadingAnchor.constraint(equalTo: dot4.trailingAnchor, constant: 5).isActive = true
            } else if prioritized != 0 {
                repeatImage.leadingAnchor.constraint(equalTo: dot3.trailingAnchor, constant: 5).isActive = true
            } else if steps.text != "" {
                repeatImage.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 5).isActive = true
            } else if listLabel.text != "" {
                repeatImage.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5).isActive = true
            } else {
                repeatImage.leadingAnchor.constraint(equalTo: plannedDate.trailingAnchor, constant: 15).isActive = true
            }
        }
    }
    
    func configureCircle() {
        circle.addSubview(check)
        check.width(28)
        check.height(28)
        check.top(to: circle)
        check.leadingAnchor.constraint(equalTo: circle.leadingAnchor).isActive = true
        let pri = K.getColor(prioritized)
        check.image = check.image?.withTintColor(pri == UIColor.clear ? .gray : pri)
        let checkGest = UITapGestureRecognizer(target: self, action: #selector(tappedCheck))
        check.addGestureRecognizer(checkGest)
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: title.text!)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        title.attributedText = attributeString
    }
    
    @objc func tappedCircle() {
        var repeats = ""
        configureCircle()
        var delTaskPosition = 0
        var totalTasks = tasksList.count
        for task in tasks {
            if task.id == id {
                try! uiRealm.write {
                    task.completed = true
                    delTaskPosition = task.position
                    task.position = -1
                    if task.repeated != "" {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM dd,yyyy-h:mm a"
                        repeats = task.repeated
                        task.completed = false
                        task.position = totalTasks
                        var newDate = Date()
                        if task.reminder != "" {
                            newDate = formatter.date(from: task.reminder)!
                        }
                        var modifiedDateReminder = Date()
                        var modifiedDatePlanned = Date()
                        switch repeats {
                        case "Day":
                            modifiedDateReminder = Calendar.current.date(byAdding: .day, value: 1, to: newDate)!
                        case "Week":
                            modifiedDateReminder = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: newDate)!
                        case "Month":
                            modifiedDateReminder = Calendar.current.date(byAdding: .month, value: 1, to: newDate)!
                        case "Weekday":
                            modifiedDateReminder = Calendar.current.date(byAdding: .weekday, value: 1, to: newDate)!
                        case "Year":
                            modifiedDateReminder = Calendar.current.date(byAdding: .year, value: 1, to: newDate)!
                        default:
                            break
                        }
                        if task.reminder != "" {
                            task.reminder = formatter.string(from: modifiedDateReminder)
                        }
                    }
                }
            }
        }
        
        for task in tasks {
            if task.parentList == parentList && task.completed == false && task.position > delTaskPosition {
                try! uiRealm.write {
                    task.position -= 1
                }
            }
        }
        
        taskCellDelegate?.reloadTaskTableView(at: path, checked: false, repeats: repeats)
    }
    
    @objc func tappedCheck() {
        check.removeFromSuperview()
        var totalTasks = 0
        for task in tasks {
            if task.completed == false && task.parentList == parentList {
                totalTasks += 1
            }
        }
        for task in tasks {
            if  task.id == id {
                try! uiRealm.write {
                    task.completed = false
                    task.position = totalTasks
                }
            }
        }
        
        let titleText = title.text
        title.attributedText = .none
        title.text = titleText
        taskCellDelegate?.reloadTaskTableView(at: path, checked: true, repeats: "")
    }
    
    
    @objc func tappedStar() {
        star.isHighlighted = true
        for task in tasks {
            if task.position == position && task.parentList == parentList && task.name == title.text {
                let isFavorited = task.favorited
                try! uiRealm.write {
                    task.favorited = !isFavorited
                }
                
                star.image = UIImage(named: task.favorited ? "starfilled" : "star")?.resize(targetSize: CGSize(width: 27, height: 27))
            }
        }
        if listTitle == "Important" {
            taskCellDelegate?.reloadTable()
        }
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
