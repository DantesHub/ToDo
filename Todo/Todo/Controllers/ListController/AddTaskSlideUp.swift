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
        let lists = uiRealm.objects(ListObject.self)
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
            for list in lists {
                cell.nameLabel.text = list.name
            }
        case "Priority":
            if indexPath.row == 3 {
                cell.icon.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 40, height: 40))
            } else {
                cell.icon.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 40, height: 40)).withTintColor(priorities[indexPath.row])
            }
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
            cell.nameLabel.text = "Priority 1"
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
            let  lists = uiRealm.objects(ListObject.self)
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
                slideUpViewTapped()
                createSlider(createSlider: false)
                pickerView.backgroundColor = .white
                createCalendar()
            } else {
                addTaskField.addButton(leftButton: .addedReminder, toolBarDelegate: self)
                if !firstAppend {
                    scrollView.contentSize.width = scrollView.contentSize.width + 170
                } else {
                    firstAppend = false
                }
                slideUpViewTapped()
                addTaskField.becomeFirstResponder()
            }
        case "Due":
            selectedDueDate = dates[indexPath.row]
            if selectedDueDate == "Pick a Date & Time" {
                dueDateTapped = true
                slideUpViewTapped()
                createSlider(createSlider: false)
                pickerView.backgroundColor = .white
                createCalendar()
            } else {
                addTaskField.addButton(leftButton: .addedDueDate, toolBarDelegate: self)
                if !firstAppend {
                    scrollView.contentSize.width = scrollView.contentSize.width + 180
                } else {
                    firstAppend = false
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
        dateSelected = self.formatter.string(from: date)
//        self.configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        print("did deselect date \(self.formatter.string(from: date))")
//        self.configureVisibleCells()
    }
    
    @objc func tappedCalendarBack() {
        slideUpViewTapped()
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
        pickerTitle.removeFromSuperview()
        timePicker?.removeFromSuperview()
        backArrow.removeTarget(self, action: #selector(tappedPickerBack), for: .allEvents)
        set.removeTarget(self, action: #selector(pickerNext), for: .touchUpInside)
        set.removeFromSuperview()
        slideUpViewTapped()
        createSlider(createSlider: false, picker: false)
        createCalendar()
    }
    
    @objc func pickerNext() {
        let time = self.timePicker?.date
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        timeSelected = formatter.string(from: time!)
        pickerTitle.removeFromSuperview()
        backArrow.removeTarget(self, action: #selector(tappedPickerBack), for: .touchUpInside)
        backArrow.removeFromSuperview()
        set.removeTarget(self, action: #selector(pickerNext), for: .touchUpInside)
        set.removeFromSuperview()
        timePicker?.removeFromSuperview()
        pickerView.removeFromSuperview()
        
        if !firstAppend {
            scrollView.contentSize.width = scrollView.contentSize.width + 300
        } else {
            scrollView.contentSize.width = scrollView.contentSize.width + 50
            firstAppend = false
        }
        
        if dueDateTapped {
            addTaskField.addButton(leftButton: .addedDueDate, toolBarDelegate: self)
            dueDateTapped = false
        } else {
            addTaskField.addButton(leftButton: .addedReminder, toolBarDelegate: self)
        }
       
        slideUpViewTapped()
        addTaskField.becomeFirstResponder()
    }
    
    @objc func calendarNext() {
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
        pickerTitle.text = dateSelected
        pickerTitle.textColor = .blue
        pickerTitle.font = UIFont(name: "OpenSans-Regular", size: 20)
        pickerView.addSubview(pickerTitle)
        pickerView.addSubview(set)
        pickerView.addSubview(backArrow)
        pickerView.addSubview(timePicker!)
    }
    
}
