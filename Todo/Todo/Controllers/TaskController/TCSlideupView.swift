import Foundation
import UIKit
import RealmSwift
import FSCalendar

extension TaskController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FSCalendarDataSource, FSCalendarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tappedIcon == "Add to a List" {
            return lists.count
        } else if tappedIcon == "Repeat" {
            return 6
        } else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 10, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 65)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: slideUpView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.taskSlideCell, for: indexPath) as! TaskSlideCell
        switch tappedIcon {
        case "Add to a List":
            cell.nameLabel.text = parentLists[indexPath.row].name
        case "Priority":
            if indexPath.row == 3 {
                cell.icon.image = UIImage(named: "flag2")?.resize(targetSize: CGSize(width: 30, height: 30))
            } else {
                cell.icon.image = UIImage(named: "flagFilled2")?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(priorities[indexPath.row])
            }
            cell.nameLabel.text = "Priority " + String(indexPath.row + 1)
        case "Remind Me":
            cell.nameLabel.text = dates[indexPath.row]
            cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
        case "Add Due Date":
            cell.nameLabel.text = dates[indexPath.row]
            cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
        case "Repeat":
            cell.nameLabel.text = repeatList[indexPath.row]
            cell.icon.image = UIImage(named: repeatList[indexPath.row])?.resize(targetSize: CGSize(width: 23, height: 23))
        case "Add File":
            print("add file")
        default:
            break
        }
        cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch tappedIcon {
        case "Remind Me":
            var grantedd = false
            let center = UNUserNotificationCenter.current()
            let semasphore = DispatchSemaphore(value: 0)
            DispatchQueue.global().async {
                center.requestAuthorization(options: [.alert, .sound, .badge]) {  granted, error in
                    if let _ = error { return }
                    if granted { grantedd = true }
                    semasphore.signal()
                }
            }
            getAccessBool()
            semasphore.wait()
            if accessBool2 || grantedd {
                selectedDateOption = dates[indexPath.row]
                dateHelper()
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
                    present(alertController, animated: true, completion: nil)
                    return
                } else {
                    UserDefaults.standard.setValue(true, forKey: "askForPermission")
                    slideUpViewTapped()
                }
            }
            selectedDateOption = dates[indexPath.row]
            dateHelper()
            return
        case "Add Due Date":
            selectedDateOption = dates[indexPath.row]
            dateHelper()
        case "Priority":
            switch priorities[indexPath.row] {
            case UIColor.red:
                priority = 1
            case orange:
                priority = 2
            case .blue:
                priority = 3
            case UIColor.clear:
                priority = 4
            default:
                priority = 0
            }
            for task in tasks {
                if task.id == id {
                    try! uiRealm.write {
                        task.priority = priority
                    }
                }
            }
            slideUpViewTapped()
            stepsTableView.reloadData()
            tableView.reloadData()
            delegate?.reloadTable()
        case "Add to a List":
            var totalTasks = 0
            for task in tasks {
                if task.parentList == parentLists[indexPath.row].name && !task.completed {
                    totalTasks += 1
                }
            }
            for task in tasks {
                if task.id == id {
                    try! uiRealm.write {
                        if task.completed {
                            task.position = -1
                        } else {
                            task.position = totalTasks
                        }
                        task.parentList = parentLists[indexPath.row].name
                        parentList = parentLists[indexPath.row].name
                    }
                }
            }
            slideUpViewTapped()
            tableView.reloadData()
            delegate?.reloadTable()
        case "Repeat":
            repeatSwitch(choice: repeatList[indexPath.row])
        default:
            break
        }
    }
    
    //MARK: - Repeat
    func repeatSwitch(choice: String) {
        switch choice {
        case "Daily":
            if plannedDate == "" { plannedDate = fullFormatter.string(from: Date()) }
            repeatTask = "Day"
        case "Weekly":
            if plannedDate == "" { plannedDate = fullFormatter.string(from: Date()) }
            repeatTask = "Week"
        case "Weekdays":
            if plannedDate == "" {
                let isWeekday = Date().checkIfWeekday(date: Date())
                if isWeekday {
                    plannedDate = fullFormatter.string(from: Date())
                } else {
                    plannedDate = fullFormatter.string(from: Date.today().next(.monday))
                }
            }
            repeatTask = "Weekday"
        case "Monthly":
            if plannedDate == "" { plannedDate = fullFormatter.string(from: Date()) }
            repeatTask = "Month"
        case "Yearly":
            if plannedDate == "" { plannedDate = fullFormatter.string(from: Date()) }
            repeatTask = "Year"
        case "Custom":
            createCustomRepeat()
            return
        default:
            break
        }
        if plannedDate == "" {
            plannedDate = fullFormatter.string(from: Date())
        }
        
        for task in tasks {
            if task.id == id {
                try! uiRealm.write {
                    task.repeated = repeatTask
                    task.planned = plannedDate
                }
            }
        }
        
    
        
        tappedOutside2()
        tableView.reloadData()
    }
    
    func createCustomRepeat() {
        slideUpViewTapped()
        createSlider(createSlider: false, picker: true)
        createSetAndBack()
        backArrow.addTarget(self, action: #selector(tappedRepeatPickerBack), for: .touchUpInside)
        set.addTarget(self, action: #selector(tappedRepeatPickerNext), for: .touchUpInside)
        set.setTitle("Done", for: .normal)
        pickerView.addSubview(set)
        pickerView.addSubview(backArrow)
        repeatTitle.text = "Repeat"
        repeatTitle.font = UIFont(name: "OpenSans-Regular", size: 20)
        repeatTitle.frame.origin.x = view.frame.maxX/2 - 40
        pickerView.addSubview(repeatTitle)
        repeatPicker?.sizeToFit()
        repeatPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: pickerView.frame.height))
        repeatPicker?.delegate = self
        repeatPicker?.dataSource = self
        pickerView.insertSubview(repeatPicker!, belowSubview: set)
    }
    
    @objc func tappedRepeatPickerBack() {
        slideUpViewTapped()
        repeatTitle.removeFromSuperview()
        pickerView.removeFromSuperview()
        calendar.removeFromSuperview()
        backArrow.removeFromSuperview()
        set.removeFromSuperview()
        createSlider(repeatt: true)
    }
    
    @objc func tappedRepeatPickerNext() {
        let num = (repeatPicker?.selectedRow(inComponent: 0))! + 1
        var units = repeatPickerList[(repeatPicker?.selectedRow(inComponent: 1))!]
        if num == 1 {
            units.removeAll(where: {$0 == "s"})
            repeatTask = units
        } else {
            repeatTask = String(num) + " " + units
        }
        for task in tasks {
            if task.id == id {
                try! uiRealm.write {
                    task.repeated = repeatTask
                }
            }
        }
        
        repeatPickerDone()
        tableView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 1500
        } else {
            return 4
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row + 1)"
        } else {
            return repeatPickerList[row]
        }
    }
    
    func dateHelper() {
        if selectedDateOption == "Pick a Date & Time" {
            pickerView.backgroundColor = .white
            pickerView.overrideUserInterfaceStyle = .light
            selectedTaskDate = self.formatter.string(from: Date())
            slideUpViewTapped()
            createSlider(createSlider: false)
            createCalendar()
            return
        } else if selectedDateOption == "Later Today" {
            selectedTaskDate = formatter.string(from: Date())
            calendarNext()
            return
        } else {
            let calendar = Calendar.current
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            var newDate = ""
            if selectedDateOption == "Tomorrow" {
                let addOneDayToCurrentDate = calendar.date(byAdding: .day, value: 1, to: Date())
                selectedTaskDate = formatter.string(from: addOneDayToCurrentDate!)
                selectedTaskTime = timeFormatter.string(from: Date())
                newDate = selectedTaskDate + "-" + selectedTaskTime
            } else if selectedDateOption == "Next Week" {
                let addOneWeekToCurrentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
                selectedTaskDate = formatter.string(from: addOneWeekToCurrentDate!)
                selectedTaskTime = timeFormatter.string(from: Date())
                newDate = selectedTaskDate + "-" + selectedTaskTime
            }
            
            if tappedIcon == "Remind Me" {
                reminderDate = newDate
            } else {
                plannedDate = newDate
            }
            
            slideUpViewTapped()
            for task in tasks {
                if task.id == id {
                    try! uiRealm.write {
                        if tappedIcon == "Remind Me" {
                            task.reminder = newDate
                        } else {
                            task.planned = newDate
                        }
                    }
                }
            }
            delegate?.reloadTable()
            tableView.reloadData()
        }
    }
    
    func createReminderNotification(date: String) {
        if UserDefaults.standard.bool(forKey: "notif") {
            let content = UNMutableNotificationContent()
            content.title = taskTitle
            content.body = "Let's Get To It!"
            let newDate = date.replacingOccurrences(of: "-", with: " ")
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            let dat = fullFormatter.date(from: newDate)
       
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dat!)
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: comps, repeats: true)
            
            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                        content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil { }
            }
        }
    }
    
    //MARK: - Calendar
    func createCalendar() {
        calendar = FSCalendar(frame: CGRect(x: 25, y: 35, width: pickerView.frame.width - 50, height: pickerView.frame.height - 50))
        calendar.delegate = self
        calendar.dataSource = self
        createSetAndBack()
        backArrow.addTarget(self, action: #selector(tappedCalendarBack), for: .touchUpInside)
        set.addTarget(self, action: #selector(calendarNext), for: .touchUpInside)
        pickerView.layer.cornerRadius = 15
        pickerView.addSubview(set)
        pickerView.addSubview(backArrow)
        pickerView.addSubview(calendar)
    }
    func createSetAndBack() {
        backArrow.setBackgroundImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 25, height: 25)).rotate(radians: -.pi/2)?.withTintColor(.blue), for: .normal)
        set = UIButton(frame: CGRect(x: pickerView.frame.width - 80, y: 10, width: 75, height: 25))
        set.setTitle("Next", for: .normal)
        set.titleLabel?.font = UIFont(name: "OpenSans", size: 23)
        set.setTitleColor(.blue, for: .normal)
    
    }
    @objc func calendarNext() {
        pickerView.backgroundColor = .white
        slideUpViewTapped()
        createSlider(createSlider: false, picker: true)
        timePicker?.sizeToFit()
        timePicker = UIDatePicker(frame: CGRect(x: 25, y: 25, width: self.view.bounds.width, height: pickerView.frame.height))
        timePicker?.datePickerMode = .time
        
        if #available(iOS 13.4, *) {
            timePicker?.preferredDatePickerStyle = .wheels
        } else {}
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
        pickerTitle.text = "Select Time"
        pickerTitle.textColor = .blue
        pickerTitle.font = UIFont(name: "OpenSans-Regular", size: 20)
        pickerView.addSubview(pickerTitle)
        pickerView.addSubview(set)
        pickerView.addSubview(backArrow)
        pickerView.addSubview(timePicker!)
    }
    
    @objc func pickerNext() {
        let time = self.timePicker?.date
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: time!)
        let fullDate = selectedTaskDate + "-" + timeString
        if tappedIcon == "Remind Me" {
            reminderDate = fullDate
            createReminderNotification(date: fullDate)
        } else if tappedIcon == "Add Due Date" {
            plannedDate = fullDate
        }
        pickerTitle.removeFromSuperview()
        backArrow.removeTarget(self, action: #selector(tappedPickerBack), for: .touchUpInside)
        backArrow.removeFromSuperview()
        set.removeTarget(self, action: #selector(pickerNext), for: .touchUpInside)
        set.removeFromSuperview()
        timePicker?.removeFromSuperview()
        slideUpView.removeFromSuperview()
        
        for task in tasks {
            if task.id == id {
                try! uiRealm.write {
                    if tappedIcon == "Remind Me" {
                        task.reminder = fullDate
                    } else {
                        task.planned = fullDate
                    }
                }
            }
        }
        
        tappedOutside2()
        tableView.reloadData()
        delegate?.reloadTable()
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
    @objc func tappedCalendarBack() {
        slideUpViewTapped()
        createSlider()
        pickerView.removeFromSuperview()
        calendar.removeFromSuperview()
        backArrow.removeFromSuperview()
        set.removeFromSuperview()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SliderSectionHeader
            sectionHeader.keyboard = false
            sectionHeader.reloadDelegate = self
            sectionHeader.createButton()
            sectionHeader.label.text = tappedIcon
            return sectionHeader
        } else { //No footer in this case but can add option for that
            return UICollectionReusableView()
        }
    }
    
    func reloadSlider() {
        slideUpViewTapped()
    }


    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedTaskDate = self.formatter.string(from: date)
    }
}
