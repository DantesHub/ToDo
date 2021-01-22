//
//  TCTextField.swift
//  Todo
//
//  Created by Dante Kim on 11/25/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

extension TaskController:  UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addStepField {
            createNewStep(textField: textField)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let character = text.first, character.isNewline {
            textView.resignFirstResponder()
            try! uiRealm.write {
                taskObject.note = noteTextField.text ?? ""
            }
            return false
        }
        return true
    }
    
    func createNewStep(textField: UITextField) {
        if textField.text! != "" {
            try! uiRealm.write {
                let step = Step()
                step.stepName = textField.text!
                step.done = false
                self.steps.append(step)
                heightConstraint?.isActive = false
                heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: CGFloat(130 + (60 * steps.count)))
                heightConstraint?.isActive = true
                self.stepsTableView.reloadData()
                taskObject.steps.append(step)
                textField.text = ""
                delegate?.reloadTable()
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if keyboard == false {
            addedStep = true
        }
        return true
    }
}
