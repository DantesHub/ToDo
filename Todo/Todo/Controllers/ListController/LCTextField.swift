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
            listTitle = bigTextField.text ?? "Untitled List"
            let list = ListObject()
            list.name = listTitle
            //need to update realmData, maybe send notification
            list.position = (lists.count - 1) + 1
            let results = uiRealm.objects(ListObject.self)
            nameTaken = false
            for result in results {
                if result.name == list.name {
                    //we need to tell user that name is taken
                    nameTaken = true
                    let alertController = UIAlertController(title: "Name is already in use, please use a different name", message: "", preferredStyle: UIAlertController.Style.alert)
                    let okayAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {
                        (action : UIAlertAction!) -> Void in })
                    
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            if !nameTaken {
                bigTextField.resignFirstResponder()
                bigTextField.isUserInteractionEnabled = false
                try! uiRealm.write {
                    uiRealm.add(list)
                }
                creating = false
                if keyboard == false { createdNewList = true }
                addTaskField.isHidden = false
                reloadDelegate?.reloadTableView()
            }
            
        default:
            break
        }
        return true
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
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        stabilize = true
        return true
    }
}
