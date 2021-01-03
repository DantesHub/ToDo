//
//  TCTextField.swift
//  Todo
//
//  Created by Dante Kim on 11/25/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

extension TaskController:  UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addStepField {
            createNewStep(textField: textField)
        }
        return true
    }
    
    func createNewStep(textField: UITextField) {
        if textField.text! != "" {
            for result in results {
                if result.id == id {
                    try! uiRealm.write {
                        let step = Step()
                        step.stepName = textField.text!
                        step.done = false
                        self.steps.append(step)
                        heightConstraint?.isActive = false
                        heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: CGFloat(130 + (60 * steps.count)))
                        heightConstraint?.isActive = true
                        self.stepsTableView.reloadData()
                        result.steps.append(step)
                        textField.text = ""
                        delegate?.reloadTable()
                    }
                }
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
