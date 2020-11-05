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
            createSlider()
        case .reminder:
            reminder = true
            addTaskField.resignFirstResponder()
            createSlider()
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
                if scrollView.contentSize.width <= 600 {
                    firstAppend = true
                }
            }
        case .prioritized:
            addTaskField.addButton(leftButton: .priority, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width - 170
            } else {
                if scrollView.contentSize.width <= 600 {
                    firstAppend = true
                }
            }
        case .addedReminder:
            reminder = false
            addTaskField.addButton(leftButton: .reminder, toolBarDelegate: self)
            if !firstAppend {
                if scrollView.contentSize.width > 600 {
                    if selectedDate == "Pick a Date & Time" {
                        scrollView.contentSize.width = scrollView.contentSize.width - 300
                    } else {
                        scrollView.contentSize.width = scrollView.contentSize.width - 170
                    }
                }
            } else {
                if scrollView.contentSize.width <= 600 {
                    firstAppend = true
                }
            }
            print("after")
            print(scrollView.contentSize)
            dateReminderSelected = ""
            timeReminderSelected = ""
        case .addedDueDate:
            planned = false
            addTaskField.addButton(leftButton: .dueDate, toolBarDelegate: self)
            if !firstAppend {
                if selectedDueDate == "Pick a Date & Time" {
                    scrollView.contentSize.width = scrollView.contentSize.width - 300
                } else {
                    scrollView.contentSize.width = scrollView.contentSize.width - 170
                }
                
            } else {
                if scrollView.contentSize.width <= 600 {
                    firstAppend = true
                }
            }
            dateDueSelected = ""
            timeDueSelected = ""
        }
    }
}
