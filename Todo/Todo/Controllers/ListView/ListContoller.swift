//
//  TestViewController.swift
//  Todo
//
//  Created by Dante Kim on 10/2/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import Layoutless
import TinyConstraints
import RealmSwift
protocol ReloadDelegate {
    func reloadTableView()
}
enum KeyboardToolbarButton: Int {

    case done = 0
    case cancel
    case back, backDisabled
    case forward, forwardDisabled

    func createButton(target: Any?, action: Selector?) -> UIBarButtonItem {
        var button: UIBarButtonItem!
        switch self {
        case .back: button = UIBarButtonItem(image: UIImage(named: "star")?.resize(targetSize: CGSize(width: 25, height: 25)), style: .plain, target: target, action: action)
       case .backDisabled:
       button = .init(title: "back", style: .plain, target: target, action: action)
       button.isEnabled = false
            case .forward: button = .init(title: "forward", style: .plain, target: target, action: action)
            case .forwardDisabled:
                button = .init(title: "forward", style: .plain, target: target, action: action)
                button.isEnabled = false
            case .done: button = .init(title: "done", style: .plain, target: target, action: action)
            case .cancel: button = .init(title: "cancel", style: .plain, target: target, action: action)
        
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

    private weak var toolBarDelegate: KeyboardToolbarDelegate?
    private weak var textField: UITextField!

    init(for textField: UITextField, toolBarDelegate: KeyboardToolbarDelegate) {
        super.init(frame: .init(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        barStyle = .default
        isTranslucent = true
        self.textField = textField
        self.toolBarDelegate = toolBarDelegate
        textField.inputAccessoryView = self
    }

    func setup(leftButtons: [KeyboardToolbarButton], rightButtons: [KeyboardToolbarButton]) {
        let leftBarButtons = leftButtons.map {
            $0.createButton(target: self, action: #selector(buttonTapped))
        }
        let rightBarButtons = rightButtons.map {
            $0.createButton(target: self, action: #selector(buttonTapped(sender:)))
        }
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
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
        let toolbar = KeyboardToolbar(for: self, toolBarDelegate: toolBarDelegate)
        toolbar.setup(leftButtons: leftButtons, rightButtons: rightButtons)
    }
}
extension ListController: KeyboardToolbarDelegate {
   func keyboardToolbar(button: UIBarButtonItem, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField) {
        print("Tapped button type: \(type)")
    }
}
class ListController: UIViewController {
    //MARK: - instance variables
    var reloadDelegate: ReloadDelegate?
    var creating = false;
    let bigTextField = UITextField()
    let titleLabel = UILabel()
    let tableView = UITableView(frame: .zero, style: .grouped)
    var tableHeader = UIView()
    var lastKnowContentOfsset: CGFloat = 0
    var scrolledUp = false
    var tableViewTop : NSLayoutConstraint?
    var listTitle = "Untitled List"
    var nameTaken = false
    var plusTaskView = UIImageView()
    var addTaskField = UITextField()
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = .white
        configureUI()
        createTableHeader()
    }
    var scrollHeight: CGFloat = 100
    override func viewDidLayoutSubviews() {
        tableView.delegate = self
    }
    
    //MARK: - helper variables
    func configureUI() {
        configureNavBar()
        createTableHeader()
        createTableView()
        plusTaskView = UIImageView(frame: CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 130 , width: 60, height: 60))
        view.addSubview(plusTaskView)
        let padding:CGFloat = 10
        plusTaskView.contentMode = .scaleAspectFit
        plusTaskView.image = UIImage(named: "plus")?.resize(targetSize: CGSize(width: 50, height: 50)).withTintColor(.white).imageWithInsets(insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        plusTaskView.layer.cornerRadius = plusTaskView.frame.height / 2
        plusTaskView.backgroundColor = .black
        plusTaskView.layer.borderWidth = 1
        plusTaskView.layer.masksToBounds = false
        plusTaskView.layer.borderColor = UIColor.black.cgColor
        plusTaskView.clipsToBounds = true
        let addTaskRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddTask))
        plusTaskView.addGestureRecognizer(addTaskRecognizer)
        plusTaskView.isUserInteractionEnabled = true
        plusTaskView.dropShadow()
    }
    
    @objc func tappedAddTask() {
        print("tappedAddTask")
        createTextField(frame: CGRect(x: 50, y: 50, width: 200, height: 40), leftButtons: [.backDisabled, .forward], rightButtons: [.cancel])
            createTextField(frame: CGRect(x: 50, y: 120, width: 200, height: 40), leftButtons: [.back, .forwardDisabled], rightButtons: [.done])
        }

        private func createTextField(frame: CGRect, leftButtons: [KeyboardToolbarButton] = [], rightButtons: [KeyboardToolbarButton] = []) {
            let textField = UITextField(frame: frame)
            textField.borderStyle = .roundedRect
            view.addSubview(textField)
            textField.addKeyboardToolBar(leftButtons: leftButtons, rightButtons: rightButtons, toolBarDelegate: self)
        }
    
    func createTableHeader() {
        let headerView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        view.addSubview(headerView)
        headerView.addSubview(bigTextField)
        bigTextField.becomeFirstResponder()
        bigTextField.delegate = self
        bigTextField.font = UIFont(name: "OpenSans-Regular", size: 40)
        bigTextField.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        bigTextField.centerY(to: headerView)
        bigTextField.height(100)
        bigTextField.placeholder = listTitle
        bigTextField.textColor = .black
        bigTextField.text = listTitle
        if !creating {
            bigTextField.isUserInteractionEnabled = false
        }
        
        self.tableView.tableHeaderView = headerView
    }
    func createTableView(top: CGFloat = -10) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "list")
        tableView.dataSource = self
        tableView.separatorStyle = .none
   
        view.addSubview(tableView)
        tableView.leadingToSuperview()
        tableView.trailingToSuperview()
        tableView.bottomToSuperview()
        tableViewTop = tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: top)
        tableViewTop?.isActive = true
        tableView.tableHeaderView = tableHeader
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.tableView.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
          swipeUp.direction = .up
          self.tableView.addGestureRecognizer(swipeUp)
        tableView.isUserInteractionEnabled = true
        swipeUp.delegate = self
        swipeDown.delegate = self
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .down:
                self.tableView.tableHeaderView?.isHidden = false
                tableViewTop?.constant = -10
                self.navigationItem.title = ""
            case .up:
                self.tableView.tableHeaderView?.isHidden = true
                tableViewTop?.constant = -100
                self.navigationItem.title = listTitle
            default:
                break
            }
        }
    }
    
    func configureNavBar() {
//          titleLabel.font = UIFont(name: "OpenSans-Regular", size: 18)
//          self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
//          titleLabel.textColor = .blue
//          navigationController?.navigationBar.barTintColor = .white
    }
}
//MARK: - UITextField
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
                reloadDelegate?.reloadTableView()
            }
            
           default:
               break
           }
           return true
       }

       func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
           return true
       }
}

//MARK: - TableView
extension ListController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "list")
        cell.textLabel?.text = "ghibli"
        cell.selectionStyle = .none
        cell.backgroundColor = .red
        return cell
    }
    
}
