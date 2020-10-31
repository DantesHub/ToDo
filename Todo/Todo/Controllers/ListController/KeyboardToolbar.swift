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
        case .priority: button = UIBarButtonItem(image: UIImage(named: "flag")?.resize(targetSize: CGSize(width: 45, height: 45)), style: .plain, target: target, action: action)
        case .dueDate: button = UIBarButtonItem(image: UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 30, height: 30)), style: .plain, target: target, action: action)
        case .reminder: button = UIBarButtonItem(image: UIImage(named: "bell")?.resize(targetSize: CGSize(width: 45, height: 45)), style: .plain, target: target, action: action)
        case .done: button = UIBarButtonItem(image: UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 35, height: 35)), style: .plain, target: target, action: action)
        case .addedReminder:  button = .init(title: "reminder", style: .plain, target: target, action: action)
        case .favorited:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
             let  btn = UIButton()
             btn.frame = CGRect(x: 15, y: 5, width: 380, height: 40)
        
            btn.layer.cornerRadius = 20
            btn.backgroundColor = .orange
            btn.addTarget(self, action: action!, for: .touchUpInside)
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), left: UIImage(named: "star")?.withTintColor(.white).resize(targetSize: CGSize(width: 25, height: 25)), label: "Important", width: 25, height: 25)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
             view.addSubview(btn)
            button = .init(customView: view)
        case .prioritized:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
             let  btn = UIButton()
             btn.frame = CGRect(x: 15, y: 5, width: 160, height: 40)
        
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
            btn.addTarget(self, action: action!, for: .touchUpInside)
            btn.setImages(right: UIImage(named: "close")?.withTintColor(.white).resize(targetSize: CGSize(width: 20, height: 20)), left: UIImage(named: "flag")?.withTintColor(.white).resize(targetSize: CGSize(width: 35, height: 35)), label: label,  width: 25, height: 25)
             view.addSubview(btn)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
            button = .init(customView: view)
        }
        button.tag = rawValue
        return button
    }

    static func detectType(barButton: UIBarButtonItem) -> KeyboardToolbarButton? {
        return KeyboardToolbarButton(rawValue: barButton.tag)
    }
}

protocol KeyboardToolbarDelegate: class {
    func keyboardToolbar(button: UIBarButtonItem, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField)
}

class KeyboardToolbar: UIToolbar {

     weak var toolBarDelegate: KeyboardToolbarDelegate?
     weak var textField: UITextField!
    var leftButtons: [KeyboardToolbarButton]!
    var rightButtons: [KeyboardToolbarButton]!
    init() {
        super.init(frame: .init(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 85)))
        barStyle = .default
        isTranslucent = true
    }

    func setup(leftButtons: [KeyboardToolbarButton], rightButtons: [KeyboardToolbarButton]) {
        let leftBarButtons = leftButtons.map {
            $0.createButton(target: self, action: #selector(buttonTapped))
        }
        let rightBarButtons = rightButtons.map {

            $0.createButton(target: self, action: #selector(buttonTapped(sender:)))
        }
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.leftButtons = leftButtons
        self.rightButtons = rightButtons
        setItems(leftBarButtons + [spaceButton] + rightBarButtons, animated: false)
    }
    func addButton(button: KeyboardToolbarButton) {
        if button == .favorited {
            self.leftButtons.removeAll(where: {$0 == .favorite})
        } else if button == .prioritized {
            self.leftButtons.removeAll(where: {$0 == .priority})
        }
        self.leftButtons?.append(button)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let leftBarButtons = self.leftButtons.map {
            $0.createButton(target: self, action: #selector(buttonTapped))
        }
        let rightBarButtons = rightButtons.map {
            $0.createButton(target: self, action: #selector(buttonTapped(sender:)))
        }
        print(leftBarButtons.count)

        setItems(leftBarButtons + [spaceButton] + rightBarButtons, animated: false)
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    @objc func buttonTapped(sender: UIBarButtonItem) {
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
