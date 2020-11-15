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
extension ListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FSCalendarDataSource, FSCalendarDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tappedIcon == "Add to a List" {
            return lists.count
        } else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.taskSlideCell, for: indexPath) as! TaskSlideCell
        switch tappedIcon {
        //only present in favorite, scheduled and all tasks
        case "Add to a List":
            let lists = uiRealm.objects(ListObject.self)
            cell.nameLabel.text = lists[indexPath.row].name
        case "Priority":
            if indexPath.row == 3 {
                cell.icon.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 30, height: 30))
            } else {
                cell.icon.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(priorities[indexPath.row])
            }
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
            cell.nameLabel.text = "Priority " + String(indexPath.row + 1)
        case "Reminder":
            cell.nameLabel.text = dates[indexPath.row]
            cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
        case "Due":
            cell.nameLabel.text = dates[indexPath.row]
            cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
        default:
            print("default")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
            selectedDate = dates[indexPath.row]
            if selectedDate == "Pick a Date & Time" {
                dateReminderSelected = self.formatter.string(from: Date())
                slideUpViewTapped()
                createSlider(createSlider: false)
                pickerView.backgroundColor = .white
                createCalendar()
            } else if selectedDate == "Later Today" {
                laterTapped = true
                calendarNext()
            } else {
                addTaskField.addButton(leftButton: .addedReminder, toolBarDelegate: self)
                if !firstAppend {
                    scrollView.contentSize.width = scrollView.contentSize.width + 170
                    print("plan, week \(scrollView.contentSize.width)")
                } else {
                    firstAppend = false
                }
                if selectedDate == "Tomorrow" {
                    let calendar = Calendar.current
                    let addOneWeekToCurrentDate = calendar.date(byAdding: .day, value: 1, to: Date())
                    dateReminderSelected = formatter.string(from: addOneWeekToCurrentDate!)
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "hh:mm a"
                    timeReminderSelected = timeFormatter.string(from: Date())
                } else if selectedDate == "Next Week" {
                    let calendar = Calendar.current
                    let addOneWeekToCurrentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
                    dateReminderSelected = formatter.string(from: addOneWeekToCurrentDate!)
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "hh:mm a"
                    timeReminderSelected = timeFormatter.string(from: Date())
                }
                slideUpViewTapped()
                addTaskField.becomeFirstResponder()
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
                    print("plan, week \(scrollView.contentSize.width)")
                } else {
                    firstAppend = false
                }
                    if selectedDueDate == "Tomorrow" {
                        let calendar = Calendar.current
                        let addOneWeekToCurrentDate = calendar.date(byAdding: .day, value: 1, to: Date())
                        dateDueSelected = formatter.string(from: addOneWeekToCurrentDate!)
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "hh:mm a"
                        timeDueSelected = timeFormatter.string(from: Date())
                    } else if selectedDueDate == "Next Week" {
                        let calendar = Calendar.current
                        let addOneWeekToCurrentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
                        dateDueSelected = formatter.string(from: addOneWeekToCurrentDate!)
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "hh:mm a"
                        timeDueSelected = timeFormatter.string(from: Date())
                    }
                slideUpViewTapped()
                addTaskField.becomeFirstResponder()
            }
            
        default:
            print("default")
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SliderSectionHeader
            sectionHeader.label.text = tappedIcon
            sectionHeader.reloadDelegate = self
            return sectionHeader
        } else { //No footer in this case but can add option for that
            return UICollectionReusableView()
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
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
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
        pickerView.removeFromSuperview()
        addTaskField.becomeFirstResponder()
        calendar.removeFromSuperview()
        backArrow.removeFromSuperview()
        set.removeFromSuperview()
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
        formatter.dateFormat = "hh:mm a"
        pickerTitle.removeFromSuperview()
        backArrow.removeTarget(self, action: #selector(tappedPickerBack), for: .touchUpInside)
        backArrow.removeFromSuperview()
        set.removeTarget(self, action: #selector(pickerNext), for: .touchUpInside)
        set.removeFromSuperview()
        timePicker?.removeFromSuperview()
        pickerView.removeFromSuperview()
        if !laterTapped {
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width + 300
                print(scrollView.contentSize.width)
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
            dateDueSelected = self.formatter.string(from: Date())
            addTaskField.addButton(leftButton: .addedDueDate, toolBarDelegate: self)
            dueDateTapped = false
        } else {
            timeReminderSelected = formatter.string(from: time!)
            dateReminderSelected = self.formatter.string(from: Date())
            addTaskField.addButton(leftButton: .addedReminder, toolBarDelegate: self)
        }
       
        slideUpViewTapped()
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
