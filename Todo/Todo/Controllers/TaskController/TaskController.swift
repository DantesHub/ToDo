//
//  AddTaskController.swift
//  Todo
//
//  Created by Dante Kim on 10/23/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import RealmSwift
import TinyConstraints
import FSCalendar
class TaskController: UIViewController, ReloadSlider {
    //MARK: - instance variables
    var plannedDate = ""
    var completed = false
    var reminderDate = ""
    var taskTitle = ""
    var favorited = false
    var repeatTask = ""
    let titleTextField = UITextField()
    let addStepField = UITextField()
    let noteTextField = PaddedTextField()
    let tableView = UITableView(frame: .zero, style: .grouped)
    let stepsTableView = SelfSizedTableView()
    var tableViewTop : NSLayoutConstraint?
    var steps = [Step]()
    var parentList = ""
    var heightConstraint: NSLayoutConstraint?
    let circle = RoundView()
    let star = UIImageView()
    let check: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 35, height: 35)).withTintColor(.red)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    var path = IndexPath()
    let headerTitle = UILabel()
    var id = ""
    let parentLists = uiRealm.objects(ListObject.self)
    let stackView = UIStackView()
    var delegate: TaskViewDelegate?
    lazy var scrollView: UIScrollView = {
       let view = UIScrollView()
       view.showsVerticalScrollIndicator = false
       return view
    }()
    var priority = 0
    var defaultList = ["Add to a List", "Priority", "Remind Me", "Add Due Date", "Repeat", "Add File"]
    var footer = UIView()
    let results = uiRealm.objects(TaskObject.self)
    var stepsFooterView = UIView()
    let plus = UIImageView(image: UIImage(named: "plus")?.resize(targetSize: CGSize(width: 45, height: 45)).withTintColor(.blue))
    let addStepLabel = UILabel()
    var slideUpView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero
        , collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    var accessBool2 = false
    var laterTapped = false
    var selectedTaskDate = ""
    var selectedTaskTime = ""
    var containerView = UIView()
    var set = UIButton()
    var calendar = FSCalendar()
    var timePicker: UIDatePicker?
    let backArrow = UIButton(frame: CGRect(x: 10, y: 15, width: 25, height: 25))
    let window = UIApplication.shared.keyWindow
    let screenSize = UIScreen.main.bounds.size
    let slideUpViewHeight: CGFloat = 350
    var pickerView  = UIView()
    var pickerTitle = UILabel()
    var selectedDateOption = ""
    var tappedIcon = ""
    var dates = ["Later Today", "Tomorrow", "Next Week", "Pick a Date & Time"]
    var priorities = [UIColor.red, gold, UIColor.blue, UIColor.clear]
    var accessBool = false
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter
    }()
    let tasks = uiRealm.objects(TaskObject.self)

    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        selectedDate = ""
    }
    
    //MARK: - Helper functions
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        configureNavBar()
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -90).isActive = true
        scrollView.topToSuperview()
        
        self.scrollView.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.axis = .vertical
        self.stackView.spacing = 10;
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true;
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true;
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true;
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true;
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true;
        
        createStepsTable()
        createTableView()
       createNoteTextField()
        createFooter()
    }
    func createTableView() {
        self.stackView.addArrangedSubview(tableView)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskOptionCell.self, forCellReuseIdentifier: "taskOptionCell")
        tableView.isScrollEnabled = false
        tableView.height(385)
        tableView.backgroundColor = .red
    }
    
    func createNoteTextField() {
        self.stackView.addArrangedSubview(noteTextField)
        noteTextField.height(UIScreen.main.bounds.height/6)
        noteTextField.backgroundColor = .white
        noteTextField.placeholder = "Add Note"
        noteTextField.font = UIFont(name: "OpenSans-Regular", size: 20)
        let hr = UIView()
        self.view.addSubview(hr)
        hr.topToBottom(of: noteTextField)
        hr.leadingToSuperview(offset: 25)
        hr.trailingToSuperview(offset: 25)
        hr.height(0.5)
        hr.backgroundColor = .lightGray
        noteTextField.delegate = self
    }
    func createStepsTable() {
        self.stackView.addArrangedSubview(stepsTableView)
        stepsTableView.register(StepCell.self, forCellReuseIdentifier: "stepCell")
        stepsTableView.delegate = self
        heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: 130)
        heightConstraint?.isActive = true
        stepsTableView.dataSource = self
        stepsTableView.backgroundColor = .white
        stepsTableView.estimatedRowHeight = 60
        stepsTableView.separatorStyle = .none
    }
    
    func configureNavBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(tappedBack))
        backButton.image = UIImage(named: "arrow")?.rotate(radians: -.pi/2)?.resize(targetSize: CGSize(width: 25, height: 25))
        backButton.title = "Back"
        self.navigationItem.leftBarButtonItem = backButton
    }
    func createSlider(createSlider: Bool = true, picker: Bool = false) {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        containerView.frame = self.view.frame
        window?.addSubview(containerView)
        containerView.alpha = 0
        if createSlider {
            slideUpView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: screenSize.width, height: slideUpViewHeight)
            slideUpView.register(TaskSlideCell.self, forCellWithReuseIdentifier: K.taskSlideCell)
            slideUpView.register(SliderSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
            slideUpView.layer.cornerRadius = 15
            slideUpView.dataSource = self
            slideUpView.delegate = self
            window?.addSubview(slideUpView)
            UIView.animate(withDuration: 0.5,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseOut, animations: { [self] in
                            self.containerView.alpha = 0.8
                            self.slideUpView.frame = CGRect(x: 0, y: self.screenSize.height - slideUpViewHeight, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height)
                           }, completion: nil)
        } else {
            if picker == true {
                calendar.removeFromSuperview()
                set.removeFromSuperview()
                backArrow.removeFromSuperview()
                pickerView.frame = CGRect(x: 0, y: ((window?.frame.height)! + 40), width: screenSize.width, height: slideUpViewHeight - 40)
                window?.addSubview(pickerView)
                animateSlider(height: slideUpViewHeight - 40, containerView: containerView, pickerView: pickerView)
                
            } else {
                print("right here")
                pickerView.frame = CGRect(x: 0, y: ((window?.frame.height)! - 50), width: screenSize.width, height: slideUpViewHeight + 50)
                window?.addSubview(pickerView)
                animateSlider(height: slideUpViewHeight + 25, containerView: containerView, pickerView: pickerView)
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tappedOutside2))
        containerView.addGestureRecognizer(tapGesture)
    }
    @objc func tappedOutside2() {
        if window!.subviews.contains(pickerView) {
            print("lomain")
            UIView.animate(withDuration: 0.4,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseInOut, animations: { [self] in
                            self.containerView.alpha = 0
                            pickerView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: pickerView.frame.width, height: pickerView.frame.height
                            )
                }, completion: nil)
        }
        slideUpViewTapped()
    }
    @objc func slideUpViewTapped() {
        UIView.animate(withDuration: 0.4,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.containerView.alpha = 0
                        self.slideUpView.frame = CGRect(x: 0, y: (self.window?.frame.height)!, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height
                        )
            }, completion: nil)
    }

    
    @objc func tappedBack() {
        _ = navigationController?.popViewController(animated: true)
        delegate?.createObservers()
    }

    
    @objc func addStep() {
        plus.removeFromSuperview()
        let circle = RoundView()
        circle.width(25)
        circle.height(25)
        circle.backgroundColor = .white
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.darkGray.cgColor
        stepsFooterView.addSubview(circle)
        circle.leading(to: stepsFooterView, offset: 30)
        circle.top(to: stepsFooterView)
        
        addStepLabel.removeFromSuperview()
        stepsFooterView.addSubview(addStepField)
        addStepField.delegate = self
        addStepField.top(to: stepsFooterView, offset: 3)
        addStepField.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 15).isActive = true
        addStepField.becomeFirstResponder()
    }
    
    @objc func tappedStar() {
        for result in results {
            if result.id == id {
                let isFavorited = result.favorited
                try! uiRealm.write {
                    result.favorited = !isFavorited
                }
                star.image = UIImage(named: result.favorited ? "starfilled" : "star")?.resize(targetSize: CGSize(width: 30, height: 30))
            }
        }
        delegate?.reloadTable()
    }
    
    @objc func tappedCheck() {
        check.removeFromSuperview()
        var totalTasks = 0
        for task in results {
            if task.completed == false && task.parentList == parentList {
                totalTasks += 1
            }
        }
        
        for result in results {
            if result.id == id {
                try! uiRealm.write {
                    result.completed = false
                    result.position = totalTasks
                    result.completedDate = Date(timeIntervalSince1970: 0)
                }
            }
        }
        let titleText = taskTitle
        headerTitle.attributedText = .none
        headerTitle.text = titleText
        delegate?.reloadTaskTableView(at: path, checked: true)
    }
    
    @objc func tappedCircle() {
        configureCircle()
        var delTaskPosition = 0
        for result in results {
            if result.id == id {
                try! uiRealm.write {
                    result.completed = true
                    delTaskPosition = result.position
                    result.position = -1
                    result.completedDate = Date()
                }
            }
        }
        
        for task in results {
            if task.parentList == parentList && task.completed == false && task.position > delTaskPosition {
                try! uiRealm.write {
                    task.position -= 1
                }
            }
        }
       
        delegate?.reloadTaskTableView(at: path, checked: false)
    }
    
    func configureCircle() {
        circle.addSubview(check)
        check.width(35)
        check.height(35)
        check.leadingAnchor.constraint(equalTo: circle.leadingAnchor).isActive = true
        let checkGest = UITapGestureRecognizer(target: self, action: #selector(tappedCheck))
        check.addGestureRecognizer(checkGest)
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskTitle)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        headerTitle.attributedText = attributeString
    }
    
    func createFooter() {
        view.insertSubview(footer, at: 1000)
        footer.leadingToSuperview()
        
        footer.trailingToSuperview()
        footer.bottomToSuperview()
        footer.height(75)
        footer.backgroundColor = .white
        
        
        let createdLabel = UILabel()
        createdLabel.font = UIFont(name: "OpenSans-Regular", size: 18)
        createdLabel.textColor = .gray
        createdLabel.text = "Completed on Nov 19, 2020"
        footer.addSubview(createdLabel)
        createdLabel.center(in: footer)
    }
}


