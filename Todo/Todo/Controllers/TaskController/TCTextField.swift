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
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == headerTitle {
            createTappedDone(title: true)
        } else if textView == noteTextField {
            createTappedDone(note: true)
        }
    }
    public func createTappedDone(title: Bool = false, step: Bool = false, note: Bool = false) {
        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.systemBlue, for: .normal)
        done.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 18)
        done.setImage(UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 25, height: 25)), for: .normal)
        done.tintColor = .systemBlue
        if title {
            done.addTarget(self, action: #selector(doneEditingList), for: .touchUpInside)
        } else if step {
            done.addTarget(self, action: #selector(doneEditingStep), for: .touchUpInside)
        } else if note {
            done.addTarget(self, action: #selector(doneEditingNote), for: .touchUpInside)
        }
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: done)]
    }
    @objc func doneEditingNote() {
        noteTextField.resignFirstResponder()
        try! uiRealm.write {
            taskObject.note = noteTextField.text ?? ""
        }
        configureNavBar()

    }
    @objc func doneEditingStep() {
        view.endEditing(true)
        try! uiRealm.write {
            editingStep.stepName = editingStepText
        }
        configureNavBar()
    }
    @objc func doneEditingList() {
        headerTitle.resignFirstResponder()
        taskTitle = headerTitle.text
        try! uiRealm.write {
            taskObject.name = headerTitle.text ?? ""
        }
        stepsTableView.reloadData()
        delegate?.reloadTable()
        configureNavBar()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == noteTextField {
            if UserDefaults.standard.bool(forKey: "isPro") == false {
                let sub = SubscriptionController()
                sub.idx = 5
                noteTextField.resignFirstResponder()
                view.endEditing(true)
                self.navigationController?.present(sub, animated: true, completion: nil)
                return true
            }
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
                heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: CGFloat(150 + (60 * steps.count)))
                heightConstraint?.isActive = true
                self.stepsTableView.reloadData()
                taskObject.steps.append(step)
                textField.text = ""
                delegate?.reloadTable()
            }
            stepsTableView.scrollToRow(at: IndexPath(row: steps.count - 1, section: 0), at: .bottom, animated: true)

        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if keyboard == false {
            addedStep = true
        }
        return true
    }
}
