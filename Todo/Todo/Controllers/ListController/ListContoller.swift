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


extension ListController: KeyboardToolbarDelegate, ReloadSlider {
    func reloadSlider() {
        slideUpViewTapped()
        addTaskField.becomeFirstResponder()
    }
    
    func keyboardToolbar(button: UIBarButtonItem, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField) {
        slideUpView.reloadData()
        print("tapping")
        switch type {
        case .done:
            addTaskField.resignFirstResponder()
        case .addToList:
            print("inside here")
            tappedIcon = "Add to a List"
            addTaskField.resignFirstResponder()
            createSlider()
        case .priority:
            tappedIcon = "Priority"
            addTaskField.resignFirstResponder()
            createSlider()
        case .dueDate:
            tappedIcon = "Due"
            addTaskField.resignFirstResponder()
            createSlider()
        case .reminder:
            addTaskField.resignFirstResponder()
            createSlider()
            tappedIcon = "Reminder"
        case .favorite:
            //add it to input accessory bar
            addTaskField.addButton(leftButton: .favorited, toolBarDelegate: self)
        case .favorited:
            print("favorited")
        case .prioritized:
            print("prioritized")
        case .addedReminder:
            print("added reminder")
        }
    }
}
var keyboard = false
var lastKeyboardHeight: CGFloat = 0
var stabilize = false
let toolbar = KeyboardToolbar()
var selectedPriority = UIColor.white

class ListController: UIViewController {
    //MARK: - instance variables
    var premadeListTapped = false
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
    var addTaskField = TextFieldWithPadding()
    var frameView = UIView()
    var tappedIcon = ""
    var slideUpView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero
        , collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 85))
    var containerView = UIView()
    var priorities = [UIColor.red, gold, UIColor.blue, UIColor.clear]
    var dates = ["Later Today", "Tomorrow", "Next Week", "Pick a Date & Time"]
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //MARK: - helper variables
    func configureUI() {
        configureNavBar()
        createTableHeader()
        createTableView()
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutside))
        self.view.addGestureRecognizer(tapRecognizer)
        addTaskField.isHidden = false
        addTaskField.frame = CGRect(x: 0, y: view.frame.height + 10, width: view.frame.width, height: 65)
        let leftBarButtons: [KeyboardToolbarButton] = premadeListTapped ? [.addToList, .priority, .dueDate, .reminder, .favorite] : [.priority, .dueDate, .reminder, .favorite]
        addTaskField.addKeyboardToolBar(leftButtons: leftBarButtons, rightButtons: [], toolBarDelegate: self)
        view.addSubview(addTaskField)
        addTaskField.backgroundColor = .white
        addTaskField.delegate = self
        addTaskField.borderStyle = .none
        addTaskField.borderStyle = .roundedRect
        
        toolbar.textField = addTaskField
        toolbar.toolBarDelegate = self
        scrollView.addSubview(toolbar)
        scrollView.contentSize = CGSize(width: 600, height: 85)

        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        addTaskField.inputAccessoryView = scrollView
    }
    func createSlider() {
        let window = UIApplication.shared.keyWindow
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        containerView.frame = self.view.frame
        
        window?.addSubview(containerView)
        containerView.alpha = 0
        let screenSize = UIScreen.main.bounds.size
        let slideUpViewHeight: CGFloat = 350
        slideUpView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: screenSize.width, height: slideUpViewHeight)
        slideUpView.register(TaskSlideCell.self, forCellWithReuseIdentifier: K.taskSlideCell)
        slideUpView.register(SliderSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        slideUpView.dataSource = self
        slideUpView.delegate = self
        window?.addSubview(slideUpView)
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseOut, animations: {
                        self.containerView.alpha = 0.8
                        self.slideUpView.frame = CGRect(x: 0, y: screenSize.height - slideUpViewHeight, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height)
        }, completion: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(slideUpViewTapped))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func slideUpViewTapped() {
       let window = UIApplication.shared.keyWindow
         UIView.animate(withDuration: 0.4,
                        delay: 0, usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 1.0,
                        options: .curveEaseInOut, animations: {
                          self.containerView.alpha = 0
                          self.slideUpView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height
                          )
         }, completion: nil)

    }

    
    @objc func tappedAddTask() {
        addTaskField.becomeFirstResponder()
    }
    
    @objc func tappedOutside() {
        self.view.endEditing(true)
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
        
        var keyboardHeight: CGFloat = keyboardSize.height
        if keyboard && lastKeyboardHeight != keyboardHeight {
            keyboardHeight = lastKeyboardHeight
        }
        lastKeyboardHeight = keyboardHeight
        let _: CGFloat = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
        if stabilize {
            self.addTaskField.frame.origin.y = self.addTaskField.frame.origin.y - keyboardHeight - 65
        }
        stabilize = false
    }
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        if keyboard == false {
            keyboard = true
            lastKeyboardHeight = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.addTaskField.frame.origin.y = self.view.frame.height + 10
 
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



