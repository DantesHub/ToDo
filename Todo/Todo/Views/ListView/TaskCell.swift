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
import AppsFlyerLib

protocol TaskViewDelegate {
    func reloadTaskTableView(at: IndexPath, checked: Bool, repeats: String)
    func reloadTable()
    func createObservers()
    func resignResponder()
    func reloadMainTable()
}

class TaskCell: UITableViewCell {
    var title = UILabel()
    var star = UIImageView()
    var circle = RoundView()
    var bullet = RoundView()
    var steps = UILabel()
    var allSteps = [Step]()
    var priority = UIImageView()
    var calendar = UIImageView()
    var plannedDate = UILabel()
    var bell = UIImageView()
    var reminderDate = UILabel()
    var createdAt = ""
    var repeatImage = UIImageView()
    var bottomView = UIView()
    var listLabel = UILabel()
    var prioritized = 0
    var taskObject = TaskObject()
    var path = IndexPath()
    var taskPlannedDate = ""
    var repeatTask  = ""
    var favorited = false
    var completed =  false
    var position = 0
    var selectedCell = false
    var listTextColor = UIColor.white
    var id = ""
    var notes = ""
    var notesView = UIImageView()
    override var frame: CGRect {
            get {
                return super.frame
            }
            set (newFrame) {
                var frame =  newFrame
                frame.origin.y += 4
                frame.size.height -= 2 * 3
                super.frame = frame
            }
        }

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
        circle.centerY(to: self, offset: -10)
        circle.isUserInteractionEnabled = true
        let cellTapped = UITapGestureRecognizer(target: self, action: #selector(tappedCell))
        cellTapped.cancelsTouchesInView = false
        self.contentView.addGestureRecognizer(cellTapped)
        let circleGest = UITapGestureRecognizer(target: self, action: #selector(tappedCircle))
        circle.addGestureRecognizer(circleGest)
        
        self.addSubview(title)
        title.font = UIFont(name: "OpenSans-Regular", size: 16)
        title.top(to: self, offset: 14)
        title.trailing(to: self, offset: -40)
        title.leadingToTrailing(of: circle, offset: 5)
       
        
        if !editingCell {
            self.contentView.addSubview(star)
            star.width(30)
            star.height(30)
            star.trailing(to: self, offset: -15)
            star.centerY(to: self, offset: -8)
            let starGest = UITapGestureRecognizer(target: self, action: #selector(tappedStar))
            star.isUserInteractionEnabled = true
            star.addGestureRecognizer(starGest)
        }
        
        reminderDate.text = ""
        steps.text = ""
        plannedDate.text = ""
    }
    
    @objc func tappedCell() {
        if !editingCell {
            if title.text == "Click here 🎯 to edit task" {
                AppsFlyerLib.shared().logEvent(name: "Onboarding_Step4_1st_task_Clicked", values: [AFEventParamContent: "true"])
            } else if title.text == "This task is completed 💯" {
                AppsFlyerLib.shared().logEvent(name: "Onboarding_Step4_2nd_task_Clicked", values: [AFEventParamContent: "true"])
            }
            let controller = TaskController()
            controller.notes = notes
            controller.plannedDate = taskPlannedDate
            controller.reminderDate = reminderDate.text ?? ""
            controller.taskTitle = title.text ?? ""
            controller.favorited = favorited
            controller.id = id
            controller.taskObject = taskObject
            controller.priority = prioritized
            controller.completed = completed
            controller.listTextColor = listTextColor
            controller.path = path
            controller.createdAt = createdAt
            controller.repeatTask = repeatTask
            controller.parentList = parentList
            controller.delegate = taskCellDelegate
            taskCellDelegate?.resignResponder()
            navigationController.view.layer.add(CATransition().popFromRight(), forKey: nil)
            navigationController.pushViewController(controller, animated: false)
        } else {
            print("janke")
        }

    }
    
    func configureBottomView() {
        star.image = UIImage(named: favorited ? "starfilled" :"star")?.resize(targetSize: CGSize(width: 27, height: 27)).withTintColor(.gray)
        var priColor = K.getColor(prioritized)
        if priColor == UIColor.clear {
            priColor = .white
        }
        circle.backgroundColor = priColor.modified(withAdditionalHue: 0.00, additionalSaturation: -0.70, additionalBrightness: 0.25)
        if priColor == .white { priColor = .gray}
        circle.layer.borderWidth = 2
        circle.layer.borderColor = priColor.cgColor
        
        if completed == true && !editingCell {
            configureCircle()
        }
        
        bottomView.frame = CGRect(x: 0, y: title.text!.count <= 33 ? 48 : title.text!.count <= 66 ? 68 : 88 , width: UIScreen.main.bounds.width - 20 , height: 28)
        bottomView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10)
        bottomView.backgroundColor = medGray
        self.contentView.addSubview(bottomView)
        let cellTapped = UITapGestureRecognizer(target: self, action: #selector(tappedCell))
        cellTapped.cancelsTouchesInView = false
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
            dot.width(3)
            dot.height(3)
            dot.leadingAnchor.constraint(equalTo: listLabel.trailingAnchor, constant: 5).isActive = true
            dot.top(to: bottomView, offset: 12)
            dot.backgroundColor = .gray
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
        steps.top(to: bottomView, offset: 2)
        steps.font = UIFont(name: "OpenSans-Regular", size: 13)
        steps.textColor = .gray
        
        let dot2 = RoundView()
        if steps.text != "" {
            bottomView.addSubview(dot2)
            dot2.width(3)
            dot2.height(3)
            dot2.leadingAnchor.constraint(equalTo: steps.trailingAnchor, constant: 8).isActive = true
            dot2.top(to: bottomView, offset: 12)
            dot2.backgroundColor = .gray
        }
        
        if prioritized != 0 {
            var color: UIColor?
            switch prioritized {
            case 1:
                color = .red
            case 2:
                color = orange
            case 3:
                color = blue
            case 4:
                color = .clear
            default:
                break
            }
            if color == UIColor.clear {
                priority.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 8, height: 10))
            } else {
                priority.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 8, height: 10)).withTintColor(color!)
            }
        }
        
        bottomView.addSubview(priority)
        priority.top(to: bottomView, offset: 7)
        if steps.text != "" {
            priority.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 5).isActive = true
        } else if listLabel.text != "" {
            priority.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5).isActive = true
        } else {
            priority.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 20).isActive = true
        }
        
        
        let dot3 = RoundView()
        bottomView.addSubview(calendar)
        calendar.top(to: bottomView, offset: 6)
        if prioritized != 0 && (taskPlannedDate != "" || reminderDate.text != "" || repeatTask != "") {
            bottomView.addSubview(dot3)
            dot3.width(3)
            dot3.height(3)
            dot3.leadingAnchor.constraint(equalTo: priority.trailingAnchor, constant: 8).isActive = true
            dot3.top(to: bottomView, offset: 12)
            dot3.backgroundColor = .gray
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
        bell.top(to: bottomView, offset: 6)
        if taskPlannedDate != "" {
            let newDatee = taskPlannedDate.replacingOccurrences(of: "-", with: " ")
            let newDate = Date().getDifference(date: newDatee, task: true)
            if let index = newDate.firstIndex(of: ",") {
                plannedDate.text = String(newDate[..<index])
            } else {
                plannedDate.text = newDate
            }

            calendar.image = UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 12, height: 12)).withTintColor(.gray)
            plannedDate.leadingAnchor.constraint(equalTo: calendar.trailingAnchor, constant: 5).isActive = true
            plannedDate.top(to: bottomView, offset: 3)
            plannedDate.font = UIFont(name: "OpenSans-Regular", size: 12)
            plannedDate.textColor = .gray
            bottomView.addSubview(dot4)
            dot4.width(3)
            dot4.height(3)
            dot4.leadingAnchor.constraint(equalTo: plannedDate.trailingAnchor, constant: 8).isActive = true
            dot4.top(to: bottomView, offset: 12)
            dot4.backgroundColor = medGray
            if reminderDate.text != "" || repeatTask != "" {
                dot4.backgroundColor = .gray
            }
        }
        
        let dot5 = RoundView()
        if reminderDate.text != "" {
            bell.image = UIImage(named: "bell")?.resize(targetSize: CGSize(width: 12, height: 12)).withTintColor(.gray)
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
            
            if repeatTask != "" || notes != "" {
                bottomView.addSubview(dot5)
                dot5.width(3)
                dot5.height(3)
                dot5.leadingAnchor.constraint(equalTo: bell.trailingAnchor, constant: 8).isActive = true
                dot5.top(to: bottomView, offset: 12)
                dot5.backgroundColor = .gray
            }
        }
        
        bottomView.addSubview(repeatImage)
        repeatImage.top(to: bottomView, offset: 7)
        if repeatTask != "" {
            repeatImage.image = UIImage(named: "repeat")?.resize(targetSize: CGSize(width: 11, height: 11)).withTintColor(.gray)
            
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
        
        let dot6 = RoundView()
        bottomView.addSubview(notesView)
        notesView.image = UIImage(named: "notes")?.resize(targetSize: CGSize(width: 14, height: 14)).withTintColor(.gray)
        if notes != "" {
            notesView.top(to: bottomView, offset: 5)
            if repeatTask != "" {
                bottomView.addSubview(dot6)
                dot6.width(3)
                dot6.height(3)
                dot6.top(to: bottomView, offset: 12)
                dot6.backgroundColor = .gray
                dot6.leadingToTrailing(of: repeatImage, offset: 8)
                notesView.leadingToTrailing(of: dot6, offset: 5)
            } else if reminderDate.text != "" {
                notesView.leadingAnchor.constraint(equalTo: dot5.trailingAnchor, constant: 5).isActive = true
            } else if plannedDate.text != "" {
                dot4.backgroundColor = .gray
                notesView.leadingAnchor.constraint(equalTo: dot4.trailingAnchor, constant: 5).isActive = true
            } else if prioritized != 0 {
                notesView.leadingAnchor.constraint(equalTo: dot3.trailingAnchor, constant: 5).isActive = true
            } else if steps.text != "" {
                notesView.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 5).isActive = true
            } else if listLabel.text != "" {
                notesView.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5).isActive = true
            } else {
                notesView.leadingAnchor.constraint(equalTo: plannedDate.trailingAnchor, constant: 15).isActive = true
            }
        }
        if selectedCell {
            createSelectedCell()
        }
    }
    
    func configureCircle() {
        if editingCell {
            
        } else {
            circle.addSubview(check)
            check.width(28)
            check.height(28)
            check.top(to: circle)
            check.leadingAnchor.constraint(equalTo: circle.leadingAnchor).isActive = true
            let pri = K.getColor(prioritized)
            check.image = check.image?.withTintColor(pri == UIColor.clear ? .gray : pri)
            let checkGest = UITapGestureRecognizer(target: self, action: #selector(tappedCheck))
            checkGest.cancelsTouchesInView = false
            check.addGestureRecognizer(checkGest)
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: title.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            title.attributedText = attributeString
        }
    }
    
     func createSelectedCell() {
        self.contentView.alpha = 0.6
        self.circle.addSubview(bullet)
        self.title.alpha = 0.6
        self.selectedCell = true
        let bulletRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedBullet))
        bullet.addGestureRecognizer(bulletRecognizer)
        bullet.width(25)
        bullet.height(25)
        bullet.layer.borderWidth = 4
        bullet.layer.borderColor = UIColor.white.cgColor
        bullet.backgroundColor = .black
        bullet.center(in: circle)
    }
    
    @objc func tappedBullet() {
        self.contentView.alpha = 1
        self.title.alpha = 1
        self.selectedCell = false
        bullet.removeFromSuperview()
        selectedDict[id] = false
    }
    
    @objc func tappedCircle() {
        selectedDict[id] = true
        if editingCell || selectedCell {
            createSelectedCell()
        } else {
            configureCircle()
            var delTaskPosition = 0
            var repeats = ""
            let totalTasks = tasksList.count
            //delete any pending notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            for task in tasks {
                if task.id == id {
                    try! uiRealm.write {
                        task.completed = true
                        delTaskPosition = task.position
                        task.position = -1
                        if task.repeated != "" {
                            repeats = taskRepeats(task: task, totalTasks: totalTasks)
                        } else {
                            task.completedDate = Date()
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
       
    }
    
     func taskRepeats(task: TaskObject, totalTasks: Int) -> String {
        var repeats = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy-h:mm a"
        repeats = task.repeated
        task.completed = false
        task.position = totalTasks
        var newDate = Date()
        if task.reminder != "" {
            newDate = formatter.date(from: task.reminder)!
        }
        let plannedDate = formatter.date(from: task.planned)!
        var modifiedDateReminder = Date()
        var modifiedDatePlanned = Date()
        var val = 1
        
        if repeats.containsWhiteSpace() {
            let components = repeats.components(separatedBy: " ")
            val = Int(components[0])!
            repeats = components[1]
            repeats.removeAll(where: {$0 == "s"})
        }
        
        switch repeats {
        case "Day":
            modifiedDateReminder = Calendar.current.date(byAdding: .day, value: val, to: newDate)!
            modifiedDatePlanned = Calendar.current.date(byAdding: .day, value: val, to: plannedDate)!
        case "Week":
            modifiedDateReminder = Calendar.current.date(byAdding: .weekOfMonth, value: val, to: newDate)!
            modifiedDatePlanned = Calendar.current.date(byAdding: .weekOfMonth, value: val, to: plannedDate)!
        case "Month":
            modifiedDateReminder = Calendar.current.date(byAdding: .month, value: val, to: newDate)!
            modifiedDatePlanned = Calendar.current.date(byAdding: .month, value: val, to: plannedDate)!
        case "Weekday":
            let calendar = Calendar(identifier: .gregorian)
            let componentsReminder = calendar.dateComponents([.weekday], from: newDate)
            let componentsPlanned = calendar.dateComponents([.weekday], from: plannedDate)
            if componentsReminder.weekday == 6 || !Date().checkIfWeekday(date: newDate){
                //set to monday
                modifiedDateReminder = newDate.next(.monday)
            } else {
                modifiedDateReminder = Calendar.current.date(byAdding: .weekday, value: val, to: newDate)!
            }
            
            if componentsPlanned.weekday == 6 || !Date().checkIfWeekday(date: plannedDate) {
                //set to monday
                modifiedDatePlanned = plannedDate.next(.monday)
            } else {
                modifiedDatePlanned = Calendar.current.date(byAdding: .weekday, value: val, to: plannedDate)!
            }
        case "Year":
            modifiedDateReminder = Calendar.current.date(byAdding: .year, value: val, to: newDate)!
            modifiedDatePlanned = Calendar.current.date(byAdding: .year, value: val, to: plannedDate)!
        default:
            break
        }
        
        task.planned = formatter.string(from: modifiedDatePlanned)
        if task.reminder != "" {
            //create new notification and reset reminder in realm
            let content = UNMutableNotificationContent()
            content.title = task.name
            content.body = "Let's Get To It!"
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: modifiedDateReminder)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let request = UNNotificationRequest(identifier: task.id,
                        content: content, trigger: trigger)
            task.reminder = formatter.string(from: modifiedDateReminder)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil { }
            }
        }
        return repeats
    }
    
    @objc func tappedCheck() {
        if !editingCell {
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
                        task.completedDate = Date(timeIntervalSince1970: 0)
                    }
                }
            }
            
            let titleText = title.text
            title.attributedText = .none
            title.text = titleText
            taskCellDelegate?.reloadTaskTableView(at: path, checked: true, repeats: "")
        }
    }
    
    
    @objc func tappedStar() {
        star.isHighlighted = true
        for task in tasks {
            if task.position == position && task.parentList == parentList && task.name == title.text {
                let isFavorited = task.favorited
                try! uiRealm.write {
                    task.favorited = !isFavorited
                }
                
                star.image = UIImage(named: task.favorited ? "starfilled" : "star")?.resize(targetSize: CGSize(width: 27, height: 27)).withTintColor(.gray)
            }
        }
        taskCellDelegate?.reloadTable()
        taskCellDelegate?.reloadMainTable()
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
