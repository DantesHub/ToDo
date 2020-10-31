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
    case prioritized

    func createButton(target: Any?, action: Selector?) -> UIBarButtonItem {
        var button: UIBarButtonItem!
        switch self {
        case .addToList: button = UIBarButtonItem(image: UIImage(named: "list")?.resize(targetSize: CGSize(width: 30, height: 30)), style: .plain, target: target, action: action)
        case .favorite: button = UIBarButtonItem(image: UIImage(named: "star")?.resize(targetSize: CGSize(width: 30, height: 30)), style: .plain, target: target, action: action)
            
        case .priority: button = UIBarButtonItem(image: UIImage(named: "flag")?.resize(targetSize: CGSize(width: 50, height: 50)), style: .plain, target: target, action: action)
        case .dueDate: button = UIBarButtonItem(image: UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 35, height: 35)), style: .plain, target: target, action: action)
        case .reminder: button = UIBarButtonItem(image: UIImage(named: "bell")?.resize(targetSize: CGSize(width: 50, height: 50)), style: .plain, target: target, action: action)
        case .done: button = UIBarButtonItem(image: UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 35, height: 35)), style: .plain, target: target, action: action)
        case .addedReminder:  button = .init(title: "reminder", style: .plain, target: target, action: action)
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
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 20, height: 20)), left: UIImage(named: "flag")?.withTintColor(.white).resize(targetSize: CGSize(width: 35, height: 35)), label: label,  width: 25, height: 25)
             view.addSubview(btn)
            view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
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

    func setup(leftButtons: [KeyboardToolbarButton], rightButtons: [KeyboardToolbarButton]) {
        var leftBarButtons = [UIBarButtonItem]()
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 5
        for button in leftButtons {
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
            self.leftButtons?.insert(button, at: 0)
        } else if button == .prioritized {
            self.leftButtons.removeAll(where: {$0 == .priority})
            self.leftButtons?.append(button)
        } else if button == .priority {
            self.leftButtons.removeAll(where: {$0 == .prioritized})
            self.leftButtons?.insert(button, at: 0)
        }
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        var leftBarButtons = [UIBarButtonItem]()
        for button in self.leftButtons {
            leftBarButtons.append(button.createButton(target: self, action:  #selector(buttonTapped)))
            if button == .favorited || button == .prioritized {
                space.width = 10
                leftBarButtons.append(space)
            }

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