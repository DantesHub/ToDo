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

extension ListController: KeyboardToolbarDelegate {
   func keyboardToolbar(button: UIBarButtonItem, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField) {
        switch type {
        case .done:
            addTaskField.resignFirstResponder()
        case .addToList:
            print("bingo1")
        case .priority:
            print("bingo")
        case .dueDate:
            print("zingo")
        case .reminder:
            print("dingo")
        case .favorite:
            print("way up high")
    }
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
    var frameView = UIView()
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
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let center: NotificationCenter = NotificationCenter.default
          center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
          center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        view.addSubview(addTaskField)
        addTaskField.becomeFirstResponder()

        }

        private func createTextField(frame: CGRect, leftButtons: [KeyboardToolbarButton] = [], rightButtons: [KeyboardToolbarButton] = []) {
            print("for all time")
            addTaskField.removeFromSuperview()
            addTaskField = UITextField(frame: frame)
            view.addSubview(addTaskField)
            addTaskField.becomeFirstResponder()
            addTaskField.delegate = self
            addTaskField.borderStyle = .roundedRect
            addTaskField.addKeyboardToolBar(leftButtons: leftButtons, rightButtons: rightButtons, toolBarDelegate: self)
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
    @objc func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue

        let keyboardHeight: CGFloat = keyboardSize.height

        let _: CGFloat = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
        self.createTextField(frame: CGRect(x: 0, y: (keyboardHeight) + 100, width: self.view.bounds.width, height: 60), leftButtons: [.addToList, .priority, .dueDate, .reminder, .favorite], rightButtons: [.done])

        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
        }, completion: nil)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue

        let keyboardHeight: CGFloat = keyboardSize.height
        
        let _: CGFloat = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat

        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
            self.addTaskField.removeFromSuperview()
        }, completion: nil)
            

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
