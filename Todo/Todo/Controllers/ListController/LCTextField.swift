//
//  ListControllerTextField.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
extension ListController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case bigTextField:
            if bigTextField.isEditing {
                createNewList(tag: 1)
            } else {
                createNewList()
            }
        default:
            tappedDone()
            break
        }
        textField.resignFirstResponder()
        return true
    }
    func createNewList(tag: Int = 0) {
        listTitle = bigTextField.text ?? "Untitled List"
        let oldTitle = listTitle
        let list = ListObject()
        list.name = listTitle
        //need to update realmData, maybe send notification
        list.position = (lists.count - 1) + 1
        let results = uiRealm.objects(ListObject.self)
        nameTaken = false
        for result in results {
            if result.name == list.name {
                //we need to tell user that name is taken
                if list.name == oldTitle || list.name == "Important" || list.name == "Planned" || list.name == "All Tasks" {
                    nameTaken = true
                    let alertController = UIAlertController(title: "Name is already in use, please use a different name", message: "", preferredStyle: UIAlertController.Style.alert)
                    let okayAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {
                                                    (action : UIAlertAction!) -> Void in })
                    
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    createTappedDone()
                }
            }
        }
        
        if !nameTaken {
            bigTextField.resignFirstResponder()
            bigTextField.isUserInteractionEnabled = false
            if tag == 0 {
                try! uiRealm.write {
                    listObject = list
                    uiRealm.add(list)
                }
            } else {
                let tasks = uiRealm.objects(TaskObject.self)
                try! uiRealm.write {
                    listObject.name = listTitle
                }
        
                for task in tasks {
                    if task.parentList == oldTitle {
                        try! uiRealm.write {
                            task.parentList = listTitle
                        }
                    }
                }
            }
            
            creating = false
    
            if keyboard == false {
                createdNewList = true                
            }
            addTaskField.isHidden = false
            configureNavBar()
            reloadDelegate?.reloadTableView()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                if bigTextField.text == "Untitled List" {
                    bigTextField.text = ""
                }
            }
        }
        return true
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("yoma")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        stabilize = true
        print("jolo")
        return true
    }
}
