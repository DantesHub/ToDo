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
import IQKeyboardManagerSwift

var editingStep = Step()
var editingStepText = ""
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
    let noteTextField = UITextView()
    let tableView = UITableView(frame: .zero, style: .grouped)
    let stepsTableView = SelfSizedTableView()
    var tableViewTop : NSLayoutConstraint?
    var steps = [Step]()
    var parentList = ""
    var heightConstraint: NSLayoutConstraint?
    let circleStep = RoundView()
    let circle = RoundView()
    let star = UIImageView()
    let check: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 35, height: 35))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    var path = IndexPath()
    let headerTitle = UITextView()
    var id = ""
    var notes = ""
    var selectedRepeat = ""
    let parentLists = uiRealm.objects(ListObject.self)
    let stackView = UIStackView()
    var delegate: TaskViewDelegate?
    lazy var scrollView: UIScrollView = {
       let view = UIScrollView()
       view.showsVerticalScrollIndicator = false
       return view
    }()
    var priority = 0
    var defaultList = ["Add to a List", "Priority", "Remind Me", "Add Due Date", "Repeat"]
    var footer = UIView()
    let results = uiRealm.objects(TaskObject.self)
    var stepsFooterView = UIView()
    let plus = UIImageView(image: UIImage(named: "plus")?.resize(targetSize: CGSize(width: 45, height: 45)))
    let addStepLabel = UILabel()
    var slideUpView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero
        , collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    var repeatList = ["Daily", "Weekly", "Weekdays", "Monthly", "Yearly", "Custom"]
    var accessBool2 = false
    var laterTapped = false
    var selectedTaskDate = ""
    var selectedTaskTime = ""
    var containerView = UIView()
    var set = UIButton()
    var createdAt = ""
    var calendar = FSCalendar()
    var timePicker: UIDatePicker?
    var repeatPicker: UIPickerView?
    let backArrow = UIButton(frame: CGRect(x: 10, y: 15, width: 25, height: 25))
    let repeatTitle = UILabel(frame: CGRect(x: 200, y: 15, width: 200, height: 25))
    let window = UIApplication.shared.keyWindow
    let screenSize = UIScreen.main.bounds.size
    let slideUpViewHeight: CGFloat = 350
    var repeatPickerList = ["Days", "Weeks", "Months", "Years"]
    var pickerView  = UIView()
    var pickerTitle = UILabel()
    var selectedDateOption = ""
    var tappedIcon = ""
    var dates = ["Later Today", "Tomorrow", "Next Week", "Pick a Date & Time"]
    var priorities = [UIColor.red, orange, .blue, UIColor.clear]
    var accessBool = false
    var taskObject = TaskObject()
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter
    }()
    let fullFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy-h:mm a"
        return formatter
    }()
    let tasks = uiRealm.objects(TaskObject.self)
    var addedBorder = false
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        IQKeyboardManager.shared.enable = true
        getSteps()
        configureUI()
        createObserver()
    }
    
    func createObserver() {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        addedStep = true
    }
        
    func getSteps() {
        steps = []
        for task in tasks {
            if task.id == id {
                steps = task.steps.map { $0 }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        selectedDate = ""
        selectedTaskDate = ""
        selectedRepeat = ""
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .clear
    }
    
    //MARK: - Helper functions
    func configureUI() {
        for result in results {
            if result.id == id {
                taskObject = result
            }
        }
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
        tableView.height(320)
        tableView.backgroundColor = .red
    }
    
    func createNoteTextField() {
        self.stackView.addArrangedSubview(noteTextField)
        noteTextField.height(UIScreen.main.bounds.height/6)
        noteTextField.backgroundColor = .white
        noteTextField.text = notes == "" ? "Notes" : notes
        noteTextField.font = UIFont(name: "OpenSans-Regular", size: 20)
        noteTextField.textContainerInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)

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
        heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: CGFloat(130 + steps.count * 60))
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
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = .none
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }
    func createSlider(createSlider: Bool = true, picker: Bool = false, repeatt: Bool = false) {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.9)
        navigationController?.navigationBar.isTranslucent = true
        containerView.frame = self.view.frame
        window?.addSubview(containerView)
        containerView.alpha = 0
        if createSlider {
            slideUpView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: screenSize.width, height: slideUpViewHeight + (repeatt ? 100 : 0))
            slideUpView.register(TaskSlideCell.self, forCellWithReuseIdentifier: K.taskSlideCell)
            slideUpView.register(SliderSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
            slideUpView.layer.cornerRadius = 15
            slideUpView.dataSource = self
            slideUpView.isScrollEnabled = false
            slideUpView.delegate = self
            window?.addSubview(slideUpView)
            UIView.animate(withDuration: 0.5,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseOut, animations: { [self] in
                            self.containerView.alpha = 0.3
                            self.slideUpView.frame = CGRect(x: 0, y: self.screenSize.height - slideUpViewHeight - (repeatt ? 100 : 0), width: self.slideUpView.frame.width, height: self.slideUpView.frame.height)
                           }, completion: nil)
        } else {
            if picker == true {
                calendar.removeFromSuperview()
                set.removeFromSuperview()
                backArrow.removeFromSuperview()
                pickerView.frame = CGRect(x: 0, y: ((window?.frame.height)! + 40), width: screenSize.width, height: slideUpViewHeight - 40)
                pickerView.layer.cornerRadius = 15
                pickerView.backgroundColor = .white
                window?.addSubview(pickerView)
                animateSlider(height: slideUpViewHeight - 40, containerView: containerView, pickerView: pickerView)
                
            } else {
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
        self.view.endEditing(true)
        if window!.subviews.contains(pickerView) {
            UIView.animate(withDuration: 0.4,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseInOut, animations: { [self] in
                            self.containerView.alpha = 0
                            pickerView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: pickerView.frame.width, height: pickerView.frame.height
                            )
                }, completion: nil)
        }
        removals()
    }
    @objc func repeatPickerDone() {
        if window!.subviews.contains(repeatPicker!) {
            UIView.animate(withDuration: 0.4,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseInOut, animations: { [self] in
                            self.containerView.alpha = 0
                            repeatPicker!.frame = CGRect(x: 0, y: (window?.frame.height)!, width: repeatPicker!.frame.width, height: repeatPicker!.frame.height
                            )
                }, completion: nil)
        }
        removals()
    }
    func removals() {
        timePicker?.removeFromSuperview()
        calendar.removeFromSuperview()
        pickerView.removeFromSuperview()
        repeatPicker?.removeFromSuperview()
        set.removeFromSuperview()
        backArrow.removeFromSuperview()
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
        tappedOutside2()
        _ = navigationController?.popViewController(animated: true)
        delegate?.createObservers()
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
        let toTop = UserDefaults.standard.bool(forKey: "toTop")
        check.removeFromSuperview()
        var totalTasks = 0
        for task in results {
            if task.completed == false && task.parentList == parentList {
                totalTasks += 1
            }
        }
        
        for result in results {
            try! uiRealm.write {

            if result.id == id {
                    result.completed = false
                    result.position = toTop ? 0 : totalTasks
                    result.completedDate = Date(timeIntervalSince1970: 0)
            } else {
                result.position = result.position + 1
            }
            }
        }
        
        let titleText = taskTitle
        headerTitle.attributedText = .none
        headerTitle.text = titleText
        delegate?.reloadTable()
        completed = false
        path = IndexPath(row: toTop ? 0 : tasksList.count - 1, section: 0)
    }
    
    @objc func tappedCircle() {

        configureCircle(K.getColor(priority))
        var delTaskPosition = 0
        let totalTasks = tasksList.count
        var repeats = ""
        print(tasksList.count, "aloha")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                try! uiRealm.write {
                    taskObject.completed = true
                    delTaskPosition = taskObject.position
                    taskObject.position = -1
                    if taskObject.repeated != "" {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM dd,yyyy-h:mm a"
                        repeats = taskObject.repeated
                        taskObject.completed = false
                        taskObject.position = totalTasks
                        var newDate = Date()
                        if taskObject.reminder != "" {
                            newDate = formatter.date(from: taskObject.reminder)!
                        }
                        let plannedDate = formatter.date(from: taskObject.planned)!
                        var modifiedDateReminder = Date()
                        var modifiedDatePlanned = Date()
                        var val = 1
                        
                        if repeats.containsWhiteSpace() {
                            let components = repeats.components(separatedBy: " ")
                            val = Int(components[0])!
                            repeats = components[1]
                            repeats.removeAll(where: {$0 == "s"})
                        }
                        
                        switch repeats {
                        case "Day":
                            modifiedDateReminder = Calendar.current.date(byAdding: .day, value: val, to: newDate)!
                            modifiedDatePlanned = Calendar.current.date(byAdding: .day, value: val, to: plannedDate)!
                        case "Week":
                            modifiedDateReminder = Calendar.current.date(byAdding: .weekOfMonth, value: val, to: newDate)!
                            modifiedDatePlanned = Calendar.current.date(byAdding: .weekOfMonth, value: val, to: plannedDate)!
                        case "Month":
                            modifiedDateReminder = Calendar.current.date(byAdding: .month, value: val, to: newDate)!
                            modifiedDatePlanned = Calendar.current.date(byAdding: .month, value: val, to: plannedDate)!
                        case "Weekday":
                            let calendar = Calendar(identifier: .gregorian)
                            let componentsReminder = calendar.dateComponents([.weekday], from: newDate)
                            let componentsPlanned = calendar.dateComponents([.weekday], from: plannedDate)
                            if componentsReminder.weekday == 6 || !Date().checkIfWeekday(date: newDate){
                                //set to monday
                                modifiedDateReminder = newDate.next(.monday)
                            } else {
                                modifiedDateReminder = Calendar.current.date(byAdding: .weekday, value: val, to: newDate)!
                            }
                            
                            if componentsPlanned.weekday == 6 || !Date().checkIfWeekday(date: plannedDate) {
                                //set to monday
                                modifiedDatePlanned = plannedDate.next(.monday)
                            } else {
                                modifiedDatePlanned = Calendar.current.date(byAdding: .weekday, value: val, to: plannedDate)!
                            }
                        case "Year":
                            modifiedDateReminder = Calendar.current.date(byAdding: .year, value: val, to: newDate)!
                            modifiedDatePlanned = Calendar.current.date(byAdding: .year, value: val, to: plannedDate)!
                        default:
                            break
                        }
                        
                        taskObject.planned = formatter.string(from: modifiedDatePlanned)
                        self.plannedDate = formatter.string(from: modifiedDatePlanned)
                        if taskObject.reminder != "" {
                            //create new notification and reset reminder in realm
                            let content = UNMutableNotificationContent()
                            content.title = taskObject.name
                            content.body = "Let's Get To It!"
                            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: modifiedDateReminder)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                            let request = UNNotificationRequest(identifier: taskObject.id,
                                        content: content, trigger: trigger)
                            taskObject.reminder = formatter.string(from: modifiedDateReminder)
                            self.reminderDate = formatter.string(from: modifiedDateReminder)
                            let notificationCenter = UNUserNotificationCenter.current()
                            notificationCenter.add(request) { (error) in
                               if error != nil { }
                            }
                        }
                       
                    } else {
                        taskObject.completedDate = Date()
                    }
                }
 
        for task in results {
            if task.parentList == parentList && task.completed == false && task.position > delTaskPosition {
                try! uiRealm.write {
                    task.position -= 1
                }
            }
        }
       
        if repeats == "" {
            delegate?.reloadTable()
            completed = true
            path = IndexPath(row: 0, section: 1)
        } else {
            self.tableView.reloadData { [self] in
                do {
                    Thread.sleep(forTimeInterval: 0.3)
                }
                check.removeFromSuperview()
                let titleText = taskTitle
                headerTitle.attributedText = .none
                headerTitle.text = titleText
            }
            completed = false
        }
    }
    
    func getAccessBool() {
        let center = UNUserNotificationCenter.current()
        let semasphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            center.getNotificationSettings(completionHandler: { [self] settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    accessBool2 = true
                    semasphore.signal()
                    return
                case .denied:
                    accessBool2 = false
                    semasphore.signal()
                    return
                case .notDetermined:
                    semasphore.signal()
                case .ephemeral:
                    semasphore.signal()
                @unknown default:
                    semasphore.signal()
                }
            })
        }
        semasphore.wait()
        return
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

        print(createdAt)
        let dash = createdAt.firstIndex(of: "-")
        let newStr = createdAt[..<dash!]
        createdLabel.text = "Created on \(newStr)"
        footer.addSubview(createdLabel)
        createdLabel.center(in: footer, offset: CGPoint(x: 0, y: -10))
        let trashcan = UIImageView()
        trashcan.image = UIImage(named: "Delete List")?.withTintColor(.red).resize(targetSize: CGSize(width: 34, height: 34))
        footer.addSubview(trashcan)
        trashcan.centerY(to: footer, offset: -10)
        trashcan.trailing(to: footer, offset: -30)
        
        let gestTrash = UITapGestureRecognizer(target: self, action: #selector(deleteList))
        trashcan.isUserInteractionEnabled = true
        trashcan.addGestureRecognizer(gestTrash)
    }
    @objc func deleteList() {
        let tasks = uiRealm.objects(TaskObject.self)
        var delIdx = 0
        var completedd = false
        for task in  tasks {
            if task.id == id {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
                for step in task.steps {
                    try! uiRealm.write {
                        uiRealm.delete(step)
                    }
                }
            }
            if path.section == 0 && task.id == id  {
                tasksList.removeAll(where: {$0.id == task.id})
                delIdx = task.position
                try! uiRealm.write {
                    uiRealm.delete(task)
                }
            } else if (path.section == 1  && task.id == id) {
                completedd = true
                completedTasks.removeAll(where: {$0.id == task.id})
                delIdx = task.position
                try! uiRealm.write {
                    uiRealm.delete(task)
                }
            }
        }
        
        if delIdx != -1 {
            for task in tasks {
                if task.parentList == listTitle && task.position > delIdx {
                    try! uiRealm.write {
                        task.position -= 1
                    }
                }
            }
        }
        delegate?.reloadTable()
        tappedBack()
    }
}


