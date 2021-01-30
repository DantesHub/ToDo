//
//  AddTaskSlideUp.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import RealmSwift
import FSCalendar
import Photos
class MyImageBlob {
    var data: NSData?
}
extension ListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FSCalendarDataSource, FSCalendarDelegate, ReloadCollection {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == customizeCollectionView {
            if customizeSelection == "Photo" {
                return photos.count
            } else if customizeSelection == "Background Color" {
                return backgroundColors.count
            } else {
                return textColors.count
            }
        } else {
            if tappedIcon == "Add to a List" {
                return lists.count
            } else if tappedIcon == "List Options" {
                return 5
            } else if tappedIcon == "Sort Options" {
                return 5
            } else {
                return 4
            }
        }

    }
 
    func reloadCollection() {
        self.customizeCollectionView.reloadData()
    }
    
 
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SliderSectionHeader
        if collectionView == customizeCollectionView {
            return UICollectionReusableView()
        } else {
            if kind == UICollectionView.elementKindSectionHeader {
                sectionHeader.createButton()
                sectionHeader.label.text = tappedIcon
                sectionHeader.reloadDelegate = self
                return sectionHeader
            } else { //No footer in this case but can add option for that
                return UICollectionReusableView()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == customizeCollectionView {
                return UIEdgeInsets (top: 0, left: 20, bottom: 20, right: 12)
        } else {
            return UIEdgeInsets (top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == customizeCollectionView {
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(width: collectionView.frame.width, height: 65)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == customizeCollectionView {
                return CGSize(width: collectionView.frame.width/8.5, height: collectionView.frame.width/8.5)
        } else {
            return CGSize(width: slideUpView.frame.width, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if collectionView == customizeCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! CircleCell
            if customizeSelection == "Photo" {
                cell.tappedImage()
                selectedListImage = photos[indexPath.row]
                selectedListBackground = UIColor.clear
            } else {
                cell.tappedColor()
                if customizeSelection == "Background Color" {
                    selectedListBackground = backgroundColors[indexPath.row]
                    selectedListImage = ""
                } else {
                    selectedListTextColor = textColors[indexPath.row]
                }
            }
            return true
        } else {
            return true
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == customizeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.circleCell, for: indexPath) as! CircleCell
            cell.type = customizeSelection
            cell.delegate = self
            cell.removeBase()
            if customizeSelection == "Photo" {
                cell.image = photos[indexPath.row]
                cell.color = UIColor.clear
                cell.baseView.backgroundColor = .clear
            } else {
                cell.baseView.backgroundColor = .clear
                cell.image = ""
                cell.imgView.image = UIImage()
                cell.baseView.layer.borderColor = UIColor.clear.cgColor
                if customizeSelection == "Background Color" {
                    cell.color = backgroundColors[indexPath.row]
                } else {
                    cell.color = textColors[indexPath.row]
                }
            }
            cell.isUserInteractionEnabled = true
            cell.configureUI()
            if customizeSelection == "Background Color" && selectedListBackground == backgroundColors[indexPath.row] {
                cell.isHighlighted = true

            } else if customizeSelection == "Text Color" && selectedListTextColor == textColors[indexPath.row] {
                cell.isHighlighted = true
            } else if customizeSelection == "Photo" && selectedListImage == photos[indexPath.row] {
                cell.isHighlighted = true
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.taskSlideCell, for: indexPath) as! TaskSlideCell
            cell.nameLabel.textColor = .black
            switch tappedIcon {
            //only present in favorite, scheduled and all tasks
            case "Add to a List":
                let lists = uiRealm.objects(ListObject.self)
                cell.nameLabel.text = lists[indexPath.row].name
                var cellImage = ""
                var colorIn = false
                let bg = lists[indexPath.row].backgroundImage
                let bc = lists[indexPath.row].backgroundColor
                if bg != "" {
                    cellImage = bg == "addPicture" ? lists[indexPath.row].name : bg
                } else if bc != "" {
                    cellImage = "circle"
                    colorIn = true
                } else {
                    cellImage = "mountain"
                }
                
                if bg == "addPicture" {
                    cell.icon.image = getSavedImage(named: cellImage)?.resize(targetSize: CGSize(width: 35, height: 35))
                    cell.rounded = true
                    cell.layoutSubviews()
                } else {
                    cell.icon.image = UIImage(named: cellImage)?.resize(targetSize: CGSize(width: 35, height: 35))
                }
                if colorIn { cell.icon.image = cell.icon.image?.withTintColor(K.getListColor(bc))}
            case "Priority":
                if indexPath.row == 3 {
                    cell.icon.image = UIImage(named: "flag2")?.resize(targetSize: CGSize(width: 30, height: 30))
                } else {
                    cell.icon.image = UIImage(named: "flagFilled2")?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(priorities[indexPath.row])
                }
                cell.nameLabel.text = "Priority " + String(indexPath.row + 1)
            case "Reminder":
                cell.nameLabel.text = dates[indexPath.row]
                cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
            case "Due":
                cell.nameLabel.text = dates[indexPath.row]
                cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
            case "List Options":
                cell.nameLabel.text = listOptions[indexPath.row]
                if listOptions[indexPath.row] == "Delete List" {
                    cell.nameLabel.textColor = .red
                    cell.icon.image = UIImage(named: listOptions[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(.red)
                } else {
                    cell.icon.image = UIImage(named: listOptions[indexPath.row])?.resize(targetSize: CGSize(width: 35, height: 35))
                }
            case "Sort Options":
                cell.nameLabel.text = sortOptions[indexPath.row]
                var imgName = ""
                switch sortOptions[indexPath.row] {
                case "Important":
                    imgName = "star"
                case "Priority":
                    imgName = "flag2"
                case "Alphabetically":
                    imgName = "Alphabetically"
                case "Creation Date":
                    imgName = "calendarPlus"
                case "Due Date":
                    imgName = "calendarOne2"
                default:
                    break
                }
                cell.icon.image = UIImage(named: imgName)?.resize(targetSize: CGSize(width: 35, height: 35))
            default:
                break
            }
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CircleCell {
            if collectionView == customizeCollectionView {
                cell.isHighlighted = false
            }
    }
}


    //MARK: -
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == customizeCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! CircleCell
            if customizeSelection == "Photo" {
                //upload custom photo
                if indexPath.row == 0 {
                    uploadPhoto()
                }
            }
            cell.isHighlighted = true
            collectionView.reloadData()
  
        } else {
            switch tappedIcon {
            //only present in favorite, scheduled and all tasks
            case "Add to a List":
                if !editingCell {
                    selectedList = lists[indexPath.row].name
                    addTaskField.addButton(leftButton: .addedToList, toolBarDelegate: self)
                    if !firstAppend {
                        scrollView.contentSize.width = scrollView.contentSize.width + 200
                    } else {
                        scrollView.contentSize.width = scrollView.contentSize.width + 50
                        firstAppend = false
                    }
                    slideUpViewTapped()
                    addTaskField.becomeFirstResponder()
                } else {
                    selectedList = lists[indexPath.row].name
                    if selectedList == listTitle {
                        tappedDoneEditing()
                        slideUpViewTapped()
                        return
                    }
                    let tasks = uiRealm.objects(TaskObject.self)
                    var count = 0
                    var count2 = 0
                    for task in tasks {
                        if task.parentList == selectedList && task.completed == false{
                            count += 1
                        }
                    }
                    for task in tasksList{
                        //if task is selected we want to delete it from our lists
                        // and move it to new list
                        if (selectedDict[task.id] == true) {
                                try! uiRealm.write {
                                    task.parentList = selectedList
                                    if task.completed {
                                        task.position = -1
                                    } else {
                                        task.position = UserDefaults.standard.bool(forKey: "toTop") ? count2 : count
                                    }
                                    count2 += 1
                                    count += 1
                                }
                            tasksList.removeAll { (t) -> Bool in
                                return t.id == task.id
                            }
                        }
                    }
                    if UserDefaults.standard.bool(forKey: "toTop") {
                        for task2 in  tasks {
                            if task2.parentList == selectedList && selectedDict[task2.id] == nil {
                                try! uiRealm.write {
                                    task2.position = task2.position + count2
                                }
                            }
                        }
                    }
                
                    for (idx, task) in completedTasks.enumerated() {
                        if selectedDict[task.id] == true {
                                try! uiRealm.write {
                                    task.parentList = selectedList
                                }
                                completedTasks.remove(at: idx)
                            }
                    }
                    for (idx,task) in tasksList.enumerated() {
                        try! uiRealm.write {
                            task.position = idx
                        }
                    }
                    tappedDoneEditing()
                    slideUpViewTapped()
                    reloadDelegate?.reloadTableView()
                }
                
            case "Priority":
                selectedPriority = priorities[indexPath.row]
                addTaskField.addButton(leftButton: .prioritized, toolBarDelegate: self)
                if !firstAppend {
                    scrollView.contentSize.width = scrollView.contentSize.width + 170
                } else {
                    firstAppend = false
                }
                slideUpViewTapped()
                addTaskField.becomeFirstResponder()
            case "Reminder":
                var grantedd = false
                let center = UNUserNotificationCenter.current()
                let semasphore = DispatchSemaphore(value: 0)
                DispatchQueue.global().async {
                    center.requestAuthorization(options: [.alert, .sound, .badge]) {  granted, error in
                        if let _ = error {
                            return
                        }
                        
                        if granted {
                            grantedd = true
                        }
                        semasphore.signal()
                    }
                }
                getAccessBool()
                semasphore.wait()
                if accessBool || grantedd {
                    selectedDate = dates[indexPath.row]
                    reminderHelper()
                    return
                } else {
                    let asked = UserDefaults.standard.bool(forKey: "askForPermission")
                    if asked {
                        let alertController = UIAlertController (title: "Please Enable Notifications", message: "You need to turn on notifications in your settings to add reminders", preferredStyle: .alert)
                        
                        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        }
                        alertController.addAction(settingsAction)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {_ in
                        })
                        alertController.addAction(cancelAction)
                        slideUpViewTapped()
                        addTaskField.becomeFirstResponder()
                        present(alertController, animated: true, completion: nil)
                        return
                    } else {
                        UserDefaults.standard.setValue(true, forKey: "askForPermission")
                        slideUpViewTapped()
                        addTaskField.becomeFirstResponder()
                    }
                }
            case "List Options":
                selectedListOption(row: indexPath.row)
            case "Sort Options":
                selectedSortOption(row: indexPath.row)
            case "Due":
                selectedDueDate = dates[indexPath.row]
                dueDateTapped = true
                if selectedDueDate == "Pick a Date & Time" {
                    dateDueSelected = self.formatter.string(from: Date())
                    slideUpViewTapped()
                    createSlider(createSlider: false)
                    pickerView.backgroundColor = .white
                    createCalendar()
                } else if selectedDueDate == "Later Today"  {
                    laterTapped = true
                    calendarNext()
                } else {
                    addTaskField.addButton(leftButton: .addedDueDate, toolBarDelegate: self)
                    if !firstAppend {
                        scrollView.contentSize.width = scrollView.contentSize.width + 170
                    } else {
                        firstAppend = false
                    }
                    if selectedDueDate == "Tomorrow" {
                        let calendar = Calendar.current
                        let addOneWeekToCurrentDate = calendar.date(byAdding: .day, value: 1, to: Date())
                        dateDueSelected = formatter.string(from: addOneWeekToCurrentDate!)
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "h:mm a"
                        timeDueSelected = timeFormatter.string(from: Date())
                    } else if selectedDueDate == "Next Week" {
                        let calendar = Calendar.current
                        let addOneWeekToCurrentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
                        dateDueSelected = formatter.string(from: addOneWeekToCurrentDate!)
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "h:mm a"
                        timeDueSelected = timeFormatter.string(from: Date())
                    }
                    slideUpViewTapped()
                    addTaskField.becomeFirstResponder()
                }
                
            default:
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    //MARK: - Sort Options
    func selectedSortOption(row: Int) {
        //update positions in realm
        let  formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy-h:mm a"
        let farDate  = formatter.date(from: "Jan 01, 2100-4:50 PM")!

        switch sortOptions[row] {
        case "Important":
            tasksList.sort { !$0.favorited && $1.favorited }
        case "Alphabetically":
            tasksList.sort { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) > $1.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        case "Priority":
            tasksList.sort { $0.priority < $1.priority }
        case "Due Date":
                tasksList.sort { formatter.date(from: $0.planned) ?? farDate > formatter.date(from: $1.planned) ?? farDate }
        case "Creation Date":
            tasksList.sort { formatter.date(from: $0.createdAt) ?? farDate < formatter.date(from: $1.createdAt) ?? farDate }
        default:
            break
        }
        for (idx, task) in tasksList.enumerated() {
            try! uiRealm.write {
                task.position = idx
            }
        }
        try! uiRealm.write {
            sortType = sortOptions[row]
            listObject.sortType = sortOptions[row]
        }
        self.tableViewTop?.constant = 120
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        slideUpViewTapped()
    }
    //MARK: - List Options
    func selectedListOption(row: Int) {
        switch listOptions[row] {
        case "Rename List":
            slideUpViewTapped()
            if headerView.isHidden {
                self.navigationItem.title = ""
                tableViewTop?.constant = sortType != "" ? 120 : 80
                tableView.setContentOffset(.init(x: 0, y: -80), animated: true)
                self.headerView.isHidden = false
            }
            tableView.isEditing = false
            bigTextField.isUserInteractionEnabled = true
            addTaskField.isHidden = true
            bigTextField.becomeFirstResponder()
            createTappedDone(tag: 1)
        case "Select Tasks":
            editingCell = true
            slideUpViewTapped()
            self.headerView.isHidden = true
            tableViewTop?.constant = -60
            tableView.setContentOffset(.init(x: -45, y: -80), animated: true)
            plusTaskView.isHidden = true
            tableView.isEditing = true
            addBottomView()
            createTappedDone(editingList: true)
            navigationItem.title = listTitle
            self.view.removeGestureRecognizer(swipeUp)
            self.view.removeGestureRecognizer(swipeDown)
            for task in tasksList + completedTasks {
                selectedDict[task.id] = false
            }
            tableView.reloadData()
        case "Sort":
            tappedIcon = "Sort Options"
            slideUpView.reloadData()
            createSlider(sortOptions: true)
        case "Change Theme & Color":
            creating = true
            slideUpViewTapped()
            createCustomListView(change: true)
        case "Print List":
            print("row")
        case  "Delete List":
            let alertController = UIAlertController(title: "Are you sure you want to delete \(listTitle)?", message: "", preferredStyle: UIAlertController.Style.alert)
            let okayAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { [self] (action) in
                self.slideUpViewTapped(deleting: true)
            }
            
            let no = UIAlertAction(title: "No", style: UIAlertAction.Style.default)
            alertController.addAction(okayAction)
            alertController.addAction(no)
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }

    
    //MARK: calendar + time picker
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    func reminderHelper() {
        if selectedDate == "Pick a Date & Time" {
            dateReminderSelected = self.formatter.string(from: Date())
            slideUpViewTapped()
            createSlider(createSlider: false)
            pickerView.backgroundColor = .white
            createCalendar()
            return
        } else if selectedDate == "Later Today" {
            laterTapped = true
            calendarNext()
            return
        } else {
            addTaskField.addButton(leftButton: .addedReminder, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width + 170
            } else {
                firstAppend = false
            }
            if selectedDate == "Tomorrow" {
                let calendar = Calendar.current
                let addOneWeekToCurrentDate = calendar.date(byAdding: .day, value: 1, to: Date())
                dateReminderSelected = formatter.string(from: addOneWeekToCurrentDate!)
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                timeReminderSelected = timeFormatter.string(from: Date())
            } else if selectedDate == "Next Week" {
                let calendar = Calendar.current
                let addOneWeekToCurrentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
                dateReminderSelected = formatter.string(from: addOneWeekToCurrentDate!)
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                timeReminderSelected = timeFormatter.string(from: Date())
            }
            addTaskField.becomeFirstResponder()
        }
        slideUpViewTapped()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if dueDateTapped {
            dateDueSelected = self.formatter.string(from: date)
        } else {
            dateReminderSelected = self.formatter.string(from: date)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        print("did deselect date \(self.formatter.string(from: date))")
    }
    
    @objc func tappedCalendarBack() {
        slideUpViewTapped()
        if dueDateTapped {
            dateDueSelected = ""
            selectedDueDate = ""
        } else {
            dateReminderSelected = ""
            selectedDate = ""
        }
        planned = false
        reminder = false
        dueDateTapped = false
        pickerView.removeFromSuperview()
        calendar.removeFromSuperview()
        backArrow.removeFromSuperview()
        set.removeFromSuperview()
        createSlider()
    }
    @objc func startTimeDiveChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timePicker?.removeFromSuperview() // if you want to remove time picker
    }
    func createCalendar() {
        calendar = FSCalendar(frame: CGRect(x: 25, y: 35, width: pickerView.frame.width - 50, height: pickerView.frame.height - 50))
        calendar.delegate = self
        calendar.dataSource = self
        
        backArrow.setBackgroundImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 25, height: 25)).rotate(radians: -.pi/2)?.withTintColor(.blue), for: .normal)
        backArrow.addTarget(self, action: #selector(tappedCalendarBack), for: .touchUpInside)
        
        set = UIButton(frame: CGRect(x: pickerView.frame.width - 80, y: 10, width: 75, height: 25))
        set.setTitle("Next", for: .normal)
        set.titleLabel?.font = UIFont(name: "OpenSans", size: 23)
        set.setTitleColor(.blue, for: .normal)
        set.addTarget(self, action: #selector(calendarNext), for: .touchUpInside)
        pickerView.addSubview(set)
        pickerView.addSubview(backArrow)
        pickerView.addSubview(calendar)
    }
    @objc func tappedPickerBack() {
        if !laterTapped {
            pickerTitle.removeFromSuperview()
            timePicker?.removeFromSuperview()
            backArrow.removeTarget(self, action: #selector(tappedPickerBack), for: .allEvents)
            set.removeTarget(self, action: #selector(pickerNext), for: .touchUpInside)
            set.removeFromSuperview()
            slideUpViewTapped()
            createSlider(createSlider: false, picker: false)
            createCalendar()
        } else {
            tappedCalendarBack()
            timePicker?.removeFromSuperview()
            laterTapped = false
        }
    }
    
    @objc func pickerNext() {
        let time = self.timePicker?.date
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        pickerTitle.removeFromSuperview()
        backArrow.removeTarget(self, action: #selector(tappedPickerBack), for: .touchUpInside)
        backArrow.removeFromSuperview()
        set.removeTarget(self, action: #selector(pickerNext), for: .touchUpInside)
        set.removeFromSuperview()
        timePicker?.removeFromSuperview()
        if !laterTapped {
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width + 300
            } else {
                if dueDateTapped {
                    added50ToDueDate = true
                } else {
                    added50ToReminder = true
                }
                scrollView.contentSize.width = scrollView.contentSize.width + 50
                firstAppend = false
            }
        } else {
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width + 170
            } else {
                firstAppend = false
            }
            laterTapped = false
        }
        
        if dueDateTapped {
            timeDueSelected = formatter.string(from: time!)
            addTaskField.addButton(leftButton: .addedDueDate, toolBarDelegate: self)
            dueDateTapped = false
        } else {
            timeReminderSelected = formatter.string(from: time!)
            addTaskField.addButton(leftButton: .addedReminder, toolBarDelegate: self)
        }
        
        slideUpViewTapped()
        pickerView.removeFromSuperview()
        addTaskField.becomeFirstResponder()
    
    }
    
    @objc func calendarNext() {
        pickerView.backgroundColor = .white
        pickerView.overrideUserInterfaceStyle = .light
        slideUpViewTapped()
        createSlider(createSlider: false, picker: true)
        timePicker?.sizeToFit()
        timePicker = UIDatePicker(frame: CGRect(x: 25, y: 25, width: self.view.bounds.width, height: pickerView.frame.height))
        timePicker?.datePickerMode = .time
        
        if #available(iOS 13.4, *) {
            timePicker?.preferredDatePickerStyle = .wheels
        } else {
            
        }
        backArrow.setBackgroundImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 25, height: 25)).rotate(radians: -.pi/2)?.withTintColor(.blue), for: .normal)
        backArrow.removeTarget(self, action: #selector(tappedCalendarBack), for: .allEvents)
        backArrow.addTarget(self, action: #selector(tappedPickerBack), for: .touchUpInside)
        
        set = UIButton(frame: CGRect(x: pickerView.frame.width - 80, y: 10, width: 75, height: 25))
        set.setTitle("Set", for: .normal)
        set.titleLabel?.font = UIFont(name: "OpenSans", size: 23)
        set.setTitleColor(.blue, for: .normal)
        set.removeTarget(self, action: #selector(calendarNext), for: .touchUpInside)
        set.addTarget(self, action: #selector(pickerNext), for: .touchUpInside)
        pickerTitle = UILabel(frame: CGRect(x: pickerView.center.x - 60, y: 15, width: 150, height: 25))
        if !laterTapped {
            if dueDateTapped {
                pickerTitle.text = dateDueSelected
            } else {
                pickerTitle.text = dateReminderSelected
            }
        }
        
        pickerTitle.textColor = .blue
        pickerTitle.font = UIFont(name: "OpenSans-Regular", size: 20)
        pickerView.addSubview(pickerTitle)
        pickerView.addSubview(set)
        pickerView.addSubview(backArrow)
        pickerView.addSubview(timePicker!)
    }
    
}
