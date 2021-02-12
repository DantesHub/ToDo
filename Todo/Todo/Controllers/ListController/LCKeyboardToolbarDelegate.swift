import UIKit
import AppsFlyerLib
//TODOman
// - BUG
// - fast adding task makes it go flying up
var setKeyboard = false
var smallKeyboard:CGFloat = 0

extension ListController: KeyboardToolbarDelegate, ReloadSlider {
    @objc func keyboardWillShow(notification: NSNotification) {
         let info:NSDictionary = notification.userInfo! as NSDictionary
         let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
         if !creating {
             let _: CGFloat = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
             if stabilize {
                print(self.addTaskField.frame.origin.y, lastKeyboardHeight, keyboardSize.height, "fdas")
                var h: CGFloat = 13.784
                switch UIScreen.main.nativeBounds.height {
                case 1136: h = 13
                default:
                    h = 13.784
                }
                if UIDevice.current.userInterfaceIdiom == .pad {
                    h = 18
                }
                self.addTaskField.frame.origin.y = self.addTaskField.frame.origin.y - keyboardHeight - view.frame.height/(h)
             }
             addedStep = true
             keyboard2 = true
             stabilize = false
         } else {
            var lastKeyboardHeight2: CGFloat = 0
             if keyboard == true || keyboard2 || addedStep {
                lastKeyboardHeight2 = keyboardSize.height + (view.frame.height/10.5)
             } else {
                 lastKeyboardHeight2 = keyboardSize.height
                 keyboard2 = true
             }
            if stabilize {
                var height: CGFloat =  6.5
                switch UIScreen.main.nativeBounds.height {
               case 1136:
                   height = 6
               case 1334:
                   height = 6.5
               case 1920, 2208:
                    height =  6.5
               case 2436:
                height = 5.5
                case 2532:
                    height = 6
                case 2778:
                    height = 5.7
               case 2688:
                   height = 5.7
                case 2732:
                    height = 7
               case 1792:
                    height = 5.7
                case 2388:
                    height = 8
               default:
                 height = 8
               }
                switch UIScreen.main.bounds.height {
                case 1366:
                    height = 8
                case 1194:
                    height = 7
                default:
                    print("yoman")
                }
                if self.customizeListView.frame.origin.y == view.frame.height {
                }
                self.customizeListView.frame.origin.y = self.customizeListView.frame.origin.y - lastKeyboardHeight2 - (view.frame.height/height)

            }
            createdNewList = true
            stabilize = false
         }
     }
     
//     @objc func keyboardWillChangeFrame(notification: NSNotification) {
//         let info:NSDictionary = notification.userInfo! as NSDictionary
//         let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//         if !creating {
//             if addedStep || createdNewList  {
//             } else {
//                //first add task
//                lastKeyboardHeight = keyboardSize.height
//                smallKeyboard = keyboardSize.height
//                print(smallKeyboard)
//             }
//         }
//     }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        hideKeyboard()
    }
    func hideKeyboard() {
        self.addTaskField.frame.origin.y = self.view.frame.height
        self.customizeListView.frame.origin.y = self.view.frame.height
    
    }
    func reloadSlider() {
        if tappedIcon == "List Options" {
            slideUpViewTapped()
        } else if tappedIcon == "Sort Options" {
            slideUpViewTapped()
            ellipsisTapped()
        } else if tappedIcon == "Add to a List" {
            slideUpViewTapped()
        } else {
            slideUpViewTapped()
            addTaskField.becomeFirstResponder()
        }
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
            createSlider()
        case .reminder:
            addTaskField.resignFirstResponder()
            if UserDefaults.standard.bool(forKey: "isPro") == false {
                AppsFlyerLib.shared().logEvent(name: "Sub_From_Reminder", values: [AFEventParamContent: "true"])
                let controller = SubscriptionController()
                controller.tappedStar = true
                self.navigationController?.present(controller, animated: true, completion: nil)
                let sub = SubscriptionController()
                sub.idx = 3
                tappedOutside3()
                self.navigationController?.present(sub, animated: true, completion: nil)
                return
            }
            reminder = true
            createSlider()
            dueDateTapped = false
            laterTapped = false
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
