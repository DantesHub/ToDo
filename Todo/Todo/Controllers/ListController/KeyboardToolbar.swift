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
            print("creating favorited")
//            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 75, height: 35))
//            circleView.backgroundColor = .black
//            circleView.layer.cornerRadius = 15
//            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
//            label.text = "bingo bingo"
//            label.textColor = .white
//            circleView.addSubview(label)
//            circleView.sizeToFit()
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
             let  btn = UIButton()
             btn.frame = CGRect(x: 25, y: 5, width: 184, height: 40)
            btn.setTitle("bingo lin", for: .normal)
            btn.layer.cornerRadius = 15
            btn.backgroundColor = .black
            btn.addTarget(self, action: action!, for: .touchUpInside)
            btn.setImages(right: UIImage(named: "star")?.withTintColor(.white), left: UIImage(named: "star")?.withTintColor(.white))
             view.addSubview(btn)
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
        self.leftButtons?.append(button)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let leftBarButtons = self.leftButtons.map {
            $0.createButton(target: self, action: #selector(buttonTapped))
        }
        let rightBarButtons = rightButtons.map {
            $0.createButton(target: self, action: #selector(buttonTapped(sender:)))
        }

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
