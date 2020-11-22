//
//  KeyboardToolbar.swift
//  Todo
//
//  Created by Dante Kim on 10/23/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
enum KeyboardToolbarButton: Int {
    
    case addToList
    case priority
    case dueDate
    case reminder
    case done
    case favorite
    case favorited
    case addedReminder
    case addedDueDate
    case prioritized
    case addedToList
    
    func createButton(target: Any?, action: Selector?) -> UIBarButtonItem {
        var button: UIBarButtonItem!
        switch self {
        case .addToList: button = UIBarButtonItem(image: UIImage(named: "list")?.resize(targetSize: CGSize(width: 30, height: 30)), style: .plain, target: target, action: action)
        case .favorite: button = UIBarButtonItem(image: UIImage(named: "star2")?.resize(targetSize: CGSize(width: 25, height: 25)), style: .plain, target: target, action: action)
            
        case .priority: button = UIBarButtonItem(image: UIImage(named: "flag")?.resize(targetSize: CGSize(width: 20, height: 22)), style: .plain, target: target, action: action)
        case .dueDate: button = UIBarButtonItem(image: UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 25, height: 25)), style: .plain, target: target, action: action)
        case .reminder: button = UIBarButtonItem(image: UIImage(named: "bell")?.resize(targetSize: CGSize(width: 25, height: 25)), style: .plain, target: target, action: action)
        case .done: button = UIBarButtonItem(image: UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 35, height: 35)), style: .plain, target: target, action: action)
        case .addedReminder:
            let  btn = UIButton()
            btn.addTarget(target, action: action!, for: .touchUpInside)
            btn.layer.cornerRadius = 20
            btn.backgroundColor = green
            var view = UIView()
            var label = ""
            if selectedDate == "Pick a Date & Time" {
                label = dateReminderSelected + " " + timeReminderSelected
                btn.frame = CGRect(x: 10, y: 5, width: 270, height: 40)
                view = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 50))
            } else if selectedDate == "Later Today" {
                label = timeReminderSelected
                btn.frame = CGRect(x: 10, y: 5, width: 180, height: 40)
                view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
            } else {
                label = selectedDate
                btn.frame = CGRect(x: 10, y: 5, width: 180, height: 40)
                view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
            }
            
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), left: UIImage(named: "bell")?.withTintColor(.white).resize(targetSize: CGSize(width: 20, height: 20)), label: label, width: 25, height: 25)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
            view.addSubview(btn)
            view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            button = .init(customView: view)
            
            btn.tag = rawValue
        case .favorited:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
            let  btn = UIButton()
            btn.frame = CGRect(x: 10, y: 5, width: 180, height: 40)
            btn.addTarget(target, action: action!, for: .touchUpInside)
            btn.layer.cornerRadius = 20
            btn.backgroundColor = .orange
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), left: UIImage(named: "star")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), label: "Important", width: 25, height: 25)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
            view.addSubview(btn)
            button = .init(customView: view)
            
            btn.tag = rawValue
        case .prioritized:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 50))
            let  btn = UIButton()
            btn.frame = CGRect(x: 10, y: 5, width: 160, height: 40)
            btn.layer.cornerRadius = 20
            btn.backgroundColor = selectedPriority
            var label = "Priority "
            switch selectedPriority {
            case .red:
                label += "1"
            case gold:
                label += "2"
            case .blue:
                label += "3"
            case .clear:
                label += "4"
            default:
                print("default")
            }
            btn.addTarget(target, action: action!, for: .touchUpInside)
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 20, height: 20)), left: UIImage(named: "flag")?.withTintColor(.white).resize(targetSize: CGSize(width: 16, height: 18)), label: label,  width: 25, height: 25)
            view.addSubview(btn)
            view.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
            button = .init(customView: view)
            btn.tag = rawValue
        case .addedDueDate:
            let  btn = UIButton()
            var view = UIView()
            btn.addTarget(target, action: action!, for: .touchUpInside)
            btn.layer.cornerRadius = 20
            btn.backgroundColor = .blue
            var label = ""
            if selectedDueDate == "Pick a Date & Time" {
                label = dateDueSelected + " " + timeDueSelected
                btn.frame = CGRect(x: 10, y: 5, width: 270, height: 40)
                view = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 50))
            } else if selectedDueDate == "Later Today" {
                label = timeDueSelected
                btn.frame = CGRect(x: 10, y: 5, width: 180, height: 40)
                view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
            } else {
                label = selectedDueDate
                btn.frame = CGRect(x: 10, y: 5, width: 180, height: 40)
                view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
            }
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), left: UIImage(named:  "calendarOne")?.withTintColor(.white).resize(targetSize: CGSize(width: 20, height: 20)), label: label, width: 25, height: 25)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
            
            view.addSubview(btn)
            view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            button = .init(customView: view)
            
            btn.tag = rawValue
        case .addedToList:
            let  btn = UIButton()
            let view =  UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
            btn.addTarget(target, action: action!, for: .touchUpInside)
            btn.layer.cornerRadius = 20
            btn.backgroundColor = .blue
            btn.frame = CGRect(x: 10, y: 5, width: 200, height: 40)
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), left: UIImage(named:  "list")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), label: selectedList, width: 25, height: 25)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
            view.addSubview(btn)
            view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            button = .init(customView: view)
            btn.tag = rawValue
        }
        button.tag = rawValue
        return button
    }
    
    static func detectType(barButton: UIButton) -> KeyboardToolbarButton? {
        return KeyboardToolbarButton(rawValue: barButton.tag)
    }
}

protocol KeyboardToolbarDelegate: class {
    func keyboardToolbar(button: UIButton, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField)
}

class KeyboardToolbar: UIToolbar {
    
    weak var toolBarDelegate: KeyboardToolbarDelegate?
    weak var textField: UITextField!
    var leftButtons: [KeyboardToolbarButton]!
    var rightButtons: [KeyboardToolbarButton]!
    init() {
        super.init(frame: .init(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width + 1000, height: 85)))
        barStyle = .default
        isTranslucent = true
    }
    
    let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    func setup(leftButtons: [KeyboardToolbarButton], rightButtons: [KeyboardToolbarButton]) {
        var leftBarButtons = [UIBarButtonItem]()
        for (idx,button) in leftButtons.enumerated() {
            space.width = 10
            if idx == 0 {
                leftBarButtons.append(space)
            }
            leftBarButtons.append(button.createButton(target: self, action:  #selector(buttonTapped)))
            leftBarButtons.append(space)
        }
        self.leftButtons = leftButtons
        self.rightButtons = rightButtons
        setItems(leftBarButtons, animated: false)
    }
    func addButton(button: KeyboardToolbarButton) {
        if button == .favorited {
            self.leftButtons.removeAll(where: {$0 == .favorite})
            self.leftButtons?.append(button)
        } else if button == .favorite {
            self.leftButtons.removeAll(where: {$0 == .favorited})
            if leftButtons.contains(where: {$0 == .priority}) || leftButtons.contains(where: {$0 == .reminder}) || leftButtons.contains(where: {$0 == .dueDate}) || leftButtons.contains(where: {$0 == .addToList}) {
                self.leftButtons?.insert(button, at: 1)
            } else {
                self.leftButtons?.insert(button, at: 0)
            }
        } else if button == .prioritized {
            self.leftButtons.removeAll(where: {$0 == .priority})
            self.leftButtons?.append(button)
        } else if button == .priority {
            self.leftButtons.removeAll(where: {$0 == .prioritized})
            self.leftButtons?.insert(button, at: 0)
        } else if button == .reminder {
            self.leftButtons.removeAll(where: {$0 == .addedReminder})
            if leftButtons.contains(where: {$0 == .priority}) || leftButtons.contains(where: {$0 == .favorite}) || leftButtons.contains(where: {$0 == .dueDate}) || leftButtons.contains(where: {$0 == .addToList}) {
                self.leftButtons?.insert(button, at: 1)
            } else {
                self.leftButtons?.insert(button, at: 0)
            }
        }  else if button == .addedReminder {
            self.leftButtons.removeAll(where: {$0 == .reminder})
            self.leftButtons?.append(button)
        } else if button == .dueDate {
            self.leftButtons.removeAll(where: {$0 == .addedDueDate})
            if leftButtons.contains(where: {$0 == .priority}) || leftButtons.contains(where: {$0 == .favorite}) || leftButtons.contains(where: {$0 == .reminder}) || leftButtons.contains(where: {$0 == .addToList}) {
                self.leftButtons?.insert(button, at: 1)
            } else {
                self.leftButtons?.insert(button, at: 0)
            }
        } else if button == .addedDueDate {
            self.leftButtons.removeAll(where: {$0 == .dueDate})
            self.leftButtons?.append(button)
        } else if button == .addToList {
            self.leftButtons.removeAll(where: {$0 == .addedToList})
            //            if leftButtons.contains(where: {$0 == .priority}) || leftButtons.contains(where: {$0 == .favorite}) || leftButtons.contains(where: {$0 == .reminder}) || leftButtons.contains(where: {$0 == .dueDate}) {
            //                self.leftButtons?.insert(button, at: 1)
            //            } else {
                        self.leftButtons?.insert(button, at: 0)
        } else if button == .addedToList {
            self.leftButtons.removeAll(where: {$0 == .addToList})
            self.leftButtons?.append(button)
        }
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        var leftBarButtons = [UIBarButtonItem]()
        for (idx,button) in self.leftButtons.enumerated() {
            space.width = 10
            if idx == 0 {
                leftBarButtons.append(space)
            }
            leftBarButtons.append(button.createButton(target: self, action:  #selector(buttonTapped)))
            leftBarButtons.append(space)
        }
        
        setItems(leftBarButtons, animated: false)
        }
        
        required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
        @objc func buttonTapped(sender: UIButton) {
            guard let type = KeyboardToolbarButton.detectType(barButton: sender) else { return }
            
            toolBarDelegate?.keyboardToolbar(button: sender, type: type, isInputAccessoryViewOf: textField)
        }
    }
    extension UITextField {
        func addKeyboardToolBar(leftButtons: [KeyboardToolbarButton],
                                rightButtons: [KeyboardToolbarButton],
                                toolBarDelegate: KeyboardToolbarDelegate) {
            toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
            toolbar.barTintColor = .white
            toolbar.setup(leftButtons: leftButtons, rightButtons: rightButtons)
        }
        func addButton(leftButton: KeyboardToolbarButton, toolBarDelegate: KeyboardToolbarDelegate) {
            toolbar.barTintColor = .white
            toolbar.addButton(button: leftButton)
        }
    }
