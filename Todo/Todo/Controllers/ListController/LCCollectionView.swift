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
            } else {
                return 4
            }
        }

    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
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
            switch tappedIcon {
            //only present in favorite, scheduled and all tasks
            case "Add to a List":
                let lists = uiRealm.objects(ListObject.self)
                cell.nameLabel.text = lists[indexPath.row].name
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
            default:
                print("default")
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("calling")
        if collectionView == customizeCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! CircleCell
            cell.isHighlighted = true
            collectionView.reloadData()
        } else {
            switch tappedIcon {
            //only present in favorite, scheduled and all tasks
            case "Add to a List":
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
                print("default")
            }
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
        
        tappedOutside2()
        addTaskField.becomeFirstResponder()
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