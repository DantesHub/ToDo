import UIKit

extension ListController: KeyboardToolbarDelegate, ReloadSlider {
    func reloadSlider() {
        slideUpViewTapped()
        addTaskField.becomeFirstResponder()
    }
    
    func keyboardToolbar(button: UIButton, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField) {
        slideUpView.reloadData()
        switch type {
        case .done:
            addTaskField.resignFirstResponder()
        case .addToList:
            tappedIcon = "Add to a List"
            addTaskField.resignFirstResponder()
            createSlider()
        case .priority:
            tappedIcon = "Priority"
            addTaskField.resignFirstResponder()
            createSlider()
        case .dueDate:
            planned = true
            tappedIcon = "Due"
            addTaskField.resignFirstResponder()
            dueDateTapped = false
            laterTapped = false
            dateDueSelected = ""
            timeDueSelected = ""
            selectedDueDate = ""
            createSlider()
        case .reminder:
            reminder = true
            addTaskField.resignFirstResponder()
            createSlider()
            dueDateTapped = false
            laterTapped = false
            dateDueSelected = ""
            timeDueSelected = ""
            selectedDueDate = ""
            tappedIcon = "Reminder"
        case .favorite:
            favorited = true
            //add it to input accessory bar
            addTaskField.addButton(leftButton: .favorited, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width + 170
            } else {
                firstAppend = false
            }
            
        case .favorited:
            favorited = false
            addTaskField.addButton(leftButton: .favorite, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width - 170
            } else {
                if scrollView.contentSize.width <= UIScreen.main.bounds.width {
                    firstAppend = true
                }
            }
        case .prioritized:
            addTaskField.addButton(leftButton: .priority, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width - 170
            } else {
                if scrollView.contentSize.width <= UIScreen.main.bounds.width {
                    firstAppend = true
                }
            }
        case .addedReminder:
            reminder = false
            addTaskField.addButton(leftButton: .reminder, toolBarDelegate: self)
            if scrollView.contentSize.width > UIScreen.main.bounds.width  {
                    if selectedDate == "Pick a Date & Time" {
                        if added50ToReminder == true {
                            scrollView.contentSize.width = scrollView.contentSize.width - 50
                            added50ToReminder = false
                            firstAppend = true
                        } else {
                            scrollView.contentSize.width = scrollView.contentSize.width - 300
                        }
                    } else {
                        scrollView.contentSize.width = scrollView.contentSize.width - 170
                    }
            } else {
                    firstAppend = true
            }
            laterTapped = false
            dateReminderSelected = ""
            timeReminderSelected = ""
            selectedDate = ""
            tomorrow = false
            nextWeek = false
        case .addedDueDate:
            planned = false
            addTaskField.addButton(leftButton: .dueDate, toolBarDelegate: self)
            if !firstAppend {
                if selectedDueDate == "Pick a Date & Time" {
                    if added50ToDueDate == true {
                        scrollView.contentSize.width = scrollView.contentSize.width - 50
                        added50ToDueDate = false
                        firstAppend = true
                    } else {
                        scrollView.contentSize.width = scrollView.contentSize.width - 300
                    }
                } else {
                    scrollView.contentSize.width = scrollView.contentSize.width - 170
                }
                
            } else {
                if scrollView.contentSize.width <= UIScreen.main.bounds.width {
                    firstAppend = true
                }
            }
            dueDateTapped = false
            laterTapped = false
            dateDueSelected = ""
            timeDueSelected = ""
            selectedDueDate = ""
            tomorrow = false
            nextWeek = false
            laterTapped = false
        case .addedToList:
            selectedList = ""
            addTaskField.addButton(leftButton: .addToList, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width - 200
            } else {
                scrollView.contentSize.width = scrollView.contentSize.width - 50
            }
        }
    }
}
