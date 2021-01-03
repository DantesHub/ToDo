import UIKit
import Layoutless
import TinyConstraints
import RealmSwift
import FSCalendar
import IQKeyboardManagerSwift
protocol ReloadDelegate {
    func reloadTableView()
}

var keyboard = false
var keyboard2 = false
var lastKeyboardHeight: CGFloat = 0
var stabilize = false
let toolbar = KeyboardToolbar()
var selectedPriority = UIColor.white
var selectedDate = ""
var selectedDueDate = ""
var dateDueSelected = ""
var timeDueSelected = ""
var dateReminderSelected = ""
var timeReminderSelected = ""
var premadeListTapped = false
var tasksList: [TaskObject] = [TaskObject]()
var completedTasks: [TaskObject] = [TaskObject]()
var selectedList = ""
var listTitle = "Untitled List"
var addedStep = false
var createdNewList = false
var editingCell = false
class ListController: UIViewController, TaskViewDelegate {
    //MARK: - instance variables
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter
    }()
    var calendar = FSCalendar()
    var timePicker: UIDatePicker?
    let backArrow = UIButton(frame: CGRect(x: 10, y: 15, width: 25, height: 25))
    var set = UIButton()
    var reloadDelegate: ReloadDelegate?
    var creating = false;
    let bigTextField = UITextField()
    let titleLabel = UILabel()
    let tableView = UITableView(frame: .zero, style: .grouped)
    var tableHeader = UIView()
    var lastKnowContentOfsset: CGFloat = 0
    var scrolledUp = false
    var listTextColor = UIColor.clear
    var tableViewTop : NSLayoutConstraint?
    var nameTaken = false
    var plusTaskView = UIImageView()
    var addTaskField = TextFieldWithPadding()
    var frameView = UIView()
    var tappedIcon = ""
    var favorited = false
    var planned = false
    var reminder = false
    var added50ToReminder = false
    var added50ToDueDate = false
    var laterTapped = false
    var slideUpView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero
                                  , collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .white
        return cv
    }()
    var backgroundImage: UIImageView = {
        let img = UIImage(named: "mountainBackground")
        let iv = UIImageView(image: img)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    var darkFilter: UIImageView = {
        let img = UIImage(named: "topDarkFilter")
        let iv = UIImageView(image: img)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    var selectedListImage = ""
    var selectedListBackground = UIColor.clear
    var selectedListTextColor = UIColor.clear
    var pickUpSection = 0
    var dueDateTapped = false
    var pickerTitle = UILabel()
    var pickerView  = UIView()
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 85))
    var containerView = UIView()
    var priorities = [UIColor.red, orange, .blue, UIColor.clear]
    var dates = ["Later Today", "Tomorrow", "Next Week", "Pick a Date & Time"]
    var firstAppend = true
    var customizeListView = UIView()
    var customizeSelection = "Photo"
    var customizeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero
                                  , collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        return cv
    }()
    let window = UIApplication.shared.keyWindow
    var photos: [String] = ["addPicture", "campfire", "mountain", "nature", "forest", "rain", "seaside", "seaside2", "space"]
    var backgroundColors:[UIColor] = [blue, purple, darkRed, darkOrange, darkGreen, turq, gray]
    var textColors:[UIColor] = [.white, blue, purple, darkRed, darkOrange, darkGreen, turq, gray]
    var backgroundButton = UIButton()
    var photoButton = UIButton()
    var textButton = UIButton()
    let screenSize = UIScreen.main.bounds.size
    let slideUpViewHeight: CGFloat = 350
    var completedExpanded = true
    let lists = uiRealm.objects(ListObject.self)
    var accessBool = false
    var listOptions: [String] = ["Rename List", "Select Tasks", "Sort", "Change Theme & Color", "Print List", "Delete List"]
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        if !creating {
            getRealmData()
        }
        self.view.isUserInteractionEnabled = true
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.leadingToSuperview()
        backgroundImage.trailingToSuperview()
        backgroundImage.topToSuperview()
        backgroundImage.bottomToSuperview()
        
        self.view.insertSubview(darkFilter, at: 1)
        darkFilter.leadingToSuperview()
        darkFilter.trailingToSuperview()
        darkFilter.topToSuperview()
        darkFilter.bottomToSuperview()
        
        configureUI()
    }
    
    var scrollHeight: CGFloat = 100
    override func viewDidLayoutSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsSelection = true
        tableView.backgroundColor = .clear
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutside))
        tapRecognizer.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        planned = false
        reminder = false
        favorited = false
        laterTapped = false
        dateReminderSelected = ""
        timeReminderSelected = ""
        dateDueSelected = ""
        timeDueSelected = ""
        selectedList = ""
        tappedIcon = ""
        selectedDate = ""
        firstAppend = true
        dueDateTapped = false
        added50ToReminder = false
        added50ToDueDate = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
    }
    
    deinit {
        removeObservers()
    }

    //MARK: - helper variables
    func configureUI() {
        configureNavBar()
        createTableView()
        createObservers()
        plusTaskView = UIImageView(frame: CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 200, width: 60, height: 60))
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

        addTaskField.isHidden = false
        addTaskField.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: 70)
        let leftBarButtons: [KeyboardToolbarButton] = premadeListTapped ? [.addToList, .priority, .dueDate, .reminder, .favorite] : [.priority, .dueDate, .reminder, .favorite]
        addTaskField.addKeyboardToolBar(leftButtons: leftBarButtons, rightButtons: [], toolBarDelegate: self)
        view.addSubview(addTaskField)
        addTaskField.font = UIFont(name: "OpenSans-Regular", size: 22)
        addTaskField.backgroundColor = .white
        addTaskField.delegate = self
        addTaskField.borderStyle = .none
        addTaskField.borderStyle = .roundedRect
        
        if creating {
            addTaskField.isHidden = true
            createTappedDone()
        }
        
        toolbar.textField = addTaskField
        toolbar.toolBarDelegate = self
        scrollView.addSubview(toolbar)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 85)
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        addTaskField.inputAccessoryView = scrollView
        slideUpView.dataSource = self
        slideUpView.delegate = self
        view.backgroundColor = .white
        createTableHeader()
    }
    func createTappedDone(tag: Int = 0, editingList: Bool = false) {
        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 18)
        done.setImage(UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 25, height: 25)), for: .normal)
        done.tintColor = .white
        done.tag = tag
        if editingList {
            done.addTarget(self, action: #selector(tappedDoneEditing), for: .touchUpInside)
        } else {
            done.addTarget(self, action: #selector(tappedCreateDone), for: .touchUpInside)
        }
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: done)]
    }
    
    @objc func tappedDoneEditing() {
        self.tableView.isEditing = false
        editingCell = false
        configureNavBar()
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func createObservers() {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func resignResponder() {
        addTaskField.resignFirstResponder()
    }
    
    func createSlider(createSlider: Bool = true, picker: Bool = false, listOptions: Bool = false) {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        containerView.frame = self.view.frame
        window?.addSubview(containerView)
        containerView.alpha = 0
        if createSlider {
            let extraHeight: CGFloat = listOptions ? 100 : 0
            slideUpView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: screenSize.width, height: slideUpViewHeight + (extraHeight))
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
                            self.slideUpView.frame = CGRect(x: 0, y: self.screenSize.height - slideUpViewHeight - extraHeight, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height + extraHeight)
                           }, completion: nil)
        } else {
            if picker == true {
                calendar.removeFromSuperview()
                set.removeFromSuperview()
                backArrow.removeFromSuperview()
                pickerView.frame = CGRect(x: 0, y: ((window?.frame.height)! + 40), width: screenSize.width, height: slideUpViewHeight - 40)
                pickerView.layer.cornerRadius = 15
                window?.addSubview(pickerView)
                animateSlider(height: slideUpViewHeight - 40, containerView: containerView, pickerView: pickerView)
                
            } else {
                pickerView.layer.cornerRadius = 15
                pickerView.frame = CGRect(x: 0, y: ((window?.frame.height)! - 50), width: screenSize.width, height: slideUpViewHeight + 50)
                window?.addSubview(pickerView)
                animateSlider(height: slideUpViewHeight + 25, containerView: containerView, pickerView: pickerView)
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tappedOutside2))
        tapGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGesture)
    }

    @objc func tappedOutside2() {
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
        timePicker?.removeFromSuperview()
        calendar.removeFromSuperview()
        pickerView.removeFromSuperview()
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
    
    func addBottomView() {
        let footer = UIView()
        view.insertSubview(footer, at: 1000)
        footer.leadingToSuperview()
        footer.trailingToSuperview()
        footer.bottomToSuperview()
        footer.height(100)
        footer.backgroundColor = lightGray
        
        let selectAll = BoxOption()
        footer.addSubview(selectAll)
        selectAll.image = "list"
        selectAll.createImage()
        selectAll.label.text = "Select All"
        selectAll.leading(to: footer, offset: 15)
        selectAll.bottom(to: footer, offset: -10)
        selectAll.height(125)
        selectAll.width(100)
        let selectRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedSelectAll))
        selectAll.addGestureRecognizer(selectRecognizer)
        
        let addToList = BoxOption()
        footer.addSubview(addToList)
        addToList.image = "list"
        addToList.createImage()
        addToList.label.text = "Add To List"
        addToList.centerX(to: footer)
        addToList.bottom(to: footer, offset: -10)
        addToList.height(125)
        addToList.width(100)
        let addToListRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddToList))
        addToList.addGestureRecognizer(addToListRecognizer)
        
        let deleteTask = BoxOption()
        footer.addSubview(deleteTask)
        deleteTask.image = "Delete List"
        deleteTask.createImage()
        deleteTask.label.text = "Delete Task"
        deleteTask.trailing(to: footer, offset: -15)
        deleteTask.bottom(to: footer, offset: -10)
        deleteTask.height(125)
        deleteTask.width(100)
        let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedDeleteTask))
        deleteTask.addGestureRecognizer(deleteRecognizer)
    }
    @objc func tappedDeleteTask() {
        print("delete")
    }
    @objc func tappedAddToList() {
        print("yoke")
    }
    @objc func tappedSelectAll() {
        print("ji")
    }
   
    
    func getRealmData() {
        var results = uiRealm.objects(TaskObject.self)
        results = results.sorted(byKeyPath: "position", ascending: true)
        for list in lists {
            if list.name == listTitle {
                selectedListBackground = K.getListColor(list.backgroundColor)
                selectedListTextColor = K.getListColor(list.textColor)
                selectedListImage = list.backgroundImage
            }
        }
        completedTasks = []
        tasksList = []
        if listTitle == "All Tasks" {
            for result in results {
                if result.completed == true {
                    completedTasks.append(result)
                } else {
                    tasksList.append(result)
                }
            }
        } else if listTitle == "Important" {
            for result in results {
                if result.favorited == true {
                    tasksList.append(result)
                }
            }
        } else if listTitle == "Planned"{
            for result in results {
                if result.planned != "" {
                    tasksList.append(result)
                }
            }
        } else {
            for result in results {
                if result.completed == true && result.parentList == listTitle {
                    completedTasks.append(result)
                } else if result.parentList == listTitle {
                    tasksList.append(result)
                }
            }
        }
        completedTasks = completedTasks.sorted {
            return $0.completedDate > $1.completedDate
        }
        changeTheme()
    }
    
    func getAccessBool() {
        let center = UNUserNotificationCenter.current()
        let semasphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            center.getNotificationSettings(completionHandler: { [self] settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    accessBool = true
                    semasphore.signal()
                    return
                case .denied:
                    accessBool = false
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
    
    @objc func tappedAddTask() {
        addTaskField.becomeFirstResponder()
        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 18)
        done.setImage(UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 25, height: 25)), for: .normal)
        done.addTarget(self, action: #selector(tappedDone), for: .touchUpInside)
        done.tintColor = .white
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: done)]
    }
    
    func createReminderNotification(id: String) {
        let content = UNMutableNotificationContent()
        content.title = self.addTaskField.text!
        content.body = "Let's Get To It!"
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "MMM dd,yyyy h:mm a"

        let dat = formatter3.date(from: dateReminderSelected + " " + timeReminderSelected)
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dat!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: id,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil { }
        }
    }
    @objc func tappedCreateDone(sender: UIButton) {
        createNewList(tag: sender.tag)
        addTaskField.isHidden = false
        if sender.tag == 0 {
            try! uiRealm.write {
                for list in lists  {
                    if list.name == listTitle {
                        list.backgroundColor = K.getStringColor(selectedListBackground)
                        list.textColor = K.getStringColor(selectedListTextColor)
                        list.backgroundImage = selectedListImage
                        changeTheme()
                    }
                }
            }

        }
    }
    
    func changeTheme() {
        if K.getStringColor(selectedListBackground) != "" {
            backgroundImage.image = nil
            backgroundImage.backgroundColor = selectedListBackground
        } else if selectedListImage != "" {
            let selectedImage = selectedListImage + "Background"
            backgroundImage.image = UIImage(named: selectedImage)
        } else if K.getStringColor(selectedListTextColor) != "" {
            listTextColor = selectedListTextColor
        }
    }
    
    @objc func tappedDone() {
        self.addTaskField.resignFirstResponder()
        if addTaskField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""  {
            try! uiRealm.write {
                let id = UUID().uuidString
                let task = TaskObject()
                task.id = id
                task.position = tasksList.count
                task.completed = false
                task.name = addTaskField.text!
                if listTitle == "Important" {
                    task.favorited = true
                } else {
                    task.favorited = favorited
                }
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "h:mm a"
                if planned {
                    dateDueSelected = formatter.string(from: Date())
                    task.planned = dateDueSelected + "-" + timeDueSelected
                } else if listTitle == "Planned" {
                    let date = Date()
                    task.planned = formatter.string(from: date) + "-" + formatter2.string(from: date)
                }
                
                if reminder {
                    dateReminderSelected = formatter.string(from: Date())
                    task.reminder = dateReminderSelected + "-" + timeReminderSelected
                    createReminderNotification(id: id)
                }
                
                if selectedList != "" {
                    task.parentList = selectedList
                } else {
                    task.parentList = listTitle
                }
                
                var pri = 0
                switch selectedPriority {
                case .red:
                    pri = 1
                case orange:
                    pri = 2
                case .blue:
                    pri = 3
                case .clear:
                    pri = 4
                default:
                    print("default")
                }
                task.priority = pri
                uiRealm.add(task)
            }
        } else {
            print("empty")
        }
        selectedPriority = UIColor.white
        laterTapped = false
        planned = false
        reminder = false
        favorited = false
        dateReminderSelected = ""
        timeReminderSelected = ""
        dateDueSelected = ""
        timeDueSelected = ""
        selectedList = ""
        selectedDate = ""
        firstAppend = true
        added50ToReminder = false
        tappedIcon = ""
        added50ToDueDate = false
        dueDateTapped = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 85)
        let leftBarButtons: [KeyboardToolbarButton] = premadeListTapped ? [.addToList, .priority, .dueDate, .reminder, .favorite] : [.priority, .dueDate, .reminder, .favorite]
        addTaskField.addKeyboardToolBar(leftButtons: leftBarButtons, rightButtons: [], toolBarDelegate: self)
        configureNavBar()
        addTaskField.text = ""
        getRealmData()
        tableView.reloadData()
    }
    
    @objc func tappedOutside() {
        print("fd")
        if !creating {
            self.view.endEditing(true)
        }
        configureNavBar()
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
        bigTextField.textColor = .white
        bigTextField.text = listTitle
        if !creating {
            bigTextField.isUserInteractionEnabled = false
        } else {
            createCustomListView()
        }

        self.tableView.tableHeaderView = headerView
    }
    //MARK: - custom list view
    private func createCustomListView() {
        view.addSubview(customizeListView)
        print("call")
        customizeListView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 150)
        customizeListView.layer.cornerRadius = 15
        customizeListView.backgroundColor = .white
        
        customizeListView.addSubview(photoButton)
        photoButton.height(35)
        photoButton.width(customizeListView.frame.width/5)
        photoButton.leading(to: customizeListView, offset: 20)
        photoButton.top(to: customizeListView, offset: 15)
        photoButton.setTitle("Photo", for: .normal)
        photoButton.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 18)
        photoButton.layer.cornerRadius = 20
        photoButton.backgroundColor = .darkGray
        let photoGest = UITapGestureRecognizer(target: self, action: #selector(tappedPhoto(button:)))
        photoGest.cancelsTouchesInView = false
        photoButton.addGestureRecognizer(photoGest)
        
        customizeListView.addSubview(backgroundButton)
        backgroundButton.height(35)
        backgroundButton.width(customizeListView.frame.width/2.5)
        backgroundButton.leadingAnchor.constraint(equalTo: photoButton.trailingAnchor, constant: 10).isActive = true
        backgroundButton.top(to: customizeListView, offset: 15)
        backgroundButton.setTitle("Background Color", for: .normal)
        backgroundButton.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 16)
        backgroundButton.layer.cornerRadius = 20
        backgroundButton.setTitleColor(.darkGray, for: .normal)
        backgroundButton.backgroundColor = lightGray
        let backGest = UITapGestureRecognizer(target: self, action: #selector(tappedBackground(button:)))
        backGest.cancelsTouchesInView = false
        backgroundButton.addGestureRecognizer(backGest)
        
        customizeListView.addSubview(textButton)
        textButton.height(35)
        textButton.width(customizeListView.frame.width/4)
        textButton.leadingAnchor.constraint(equalTo: backgroundButton.trailingAnchor, constant: 10).isActive = true
        textButton.top(to: customizeListView, offset: 15)
        textButton.setTitle("Text Color", for: .normal)
        textButton.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 16)
        textButton.layer.cornerRadius = 20
        textButton.setTitleColor(.darkGray, for: .normal)
        textButton.backgroundColor = lightGray
        let textGest = UITapGestureRecognizer(target: self, action: #selector(tappedText))
        textGest.cancelsTouchesInView = false
        textButton.addGestureRecognizer(textGest)
        
        self.view.isUserInteractionEnabled = true
        customizeCollectionView.register(CircleCell.self, forCellWithReuseIdentifier: K.circleCell)
        customizeCollectionView.isUserInteractionEnabled = true
        customizeListView.isUserInteractionEnabled = true
        customizeCollectionView.delegate = self
        customizeCollectionView.dataSource = self
        customizeListView.addSubview(customizeCollectionView)
        customizeCollectionView.leading(to: customizeListView)
        customizeCollectionView.trailing(to: customizeListView)
        customizeCollectionView.bottom(to: customizeListView)
        customizeCollectionView.backgroundColor = .white
        customizeCollectionView.allowsSelection = true
        customizeCollectionView.height(customizeListView.frame.height * 0.65)
    }
    @objc func tappedText() {
        customizeSelection = "Text Color"
        textButton.backgroundColor = .darkGray
        textButton.setTitleColor(.white, for: .normal)
        backgroundButton.backgroundColor = lightGray
        backgroundButton.setTitleColor(.black, for: .normal)
        photoButton.backgroundColor = lightGray
        photoButton.setTitleColor(.black, for: .normal)
        customizeCollectionView.reloadData()
    }
    @objc func tappedBackground(button: UIButton) {
        customizeSelection = "Background Color"
        backgroundButton.backgroundColor = .darkGray
        backgroundButton.setTitleColor(.white, for: .normal)
        photoButton.backgroundColor = lightGray
        photoButton.setTitleColor(.black, for: .normal)
        textButton.backgroundColor = lightGray
        textButton.setTitleColor(.black, for: .normal)
        customizeCollectionView.reloadData()
    }
    
    @objc func tappedPhoto(button: UIButton) {
        customizeSelection = "Photo"
        photoButton.backgroundColor = .darkGray
        photoButton.setTitleColor(.white, for: .normal)
        textButton.backgroundColor = lightGray
        textButton.setTitleColor(.black, for: .normal)
        backgroundButton.backgroundColor = lightGray
        backgroundButton.setTitleColor(.black, for: .normal)
        customizeCollectionView.reloadData()
    }
    
    func createTableView(top: CGFloat = -10) {
        tableView.register(TaskCell.self, forCellReuseIdentifier: "list")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "completedHeader")
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)
        tableView.leadingToSuperview(offset: 10)
        tableView.trailingToSuperview(offset: 10)
        tableView.bottomToSuperview()
        tableViewTop = tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: top)
        tableViewTop?.isActive = true
        tableView.tableHeaderView = tableHeader
        tableView.showsVerticalScrollIndicator = false
        swipeDown.direction = .down
        swipeDown.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeDown)
        swipeUp.direction = .up
        swipeUp.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeUp)
        tableView.isUserInteractionEnabled = true
        swipeUp.delegate = self
        swipeDown.delegate = self
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        if !creating {
            let _: CGFloat = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
            if stabilize {
                    self.addTaskField.frame.origin.y = self.addTaskField.frame.origin.y - lastKeyboardHeight - 65
            }
            addedStep = true
            stabilize = false
        } else {
            if keyboard == true || keyboard2 {
                lastKeyboardHeight = keyboardSize.height + 93
            } else {
                lastKeyboardHeight = keyboardSize.height
                keyboard2 = true
            }
            self.customizeListView.frame.origin.y = self.customizeListView.frame.origin.y - lastKeyboardHeight - 140
            createdNewList = true
        }
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        if !creating {
            if addedStep || createdNewList {
                lastKeyboardHeight = keyboardSize.height + 185
            } else {
                lastKeyboardHeight = keyboardSize.height
            }
        }
           
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.addTaskField.frame.origin.y = self.view.frame.height
        self.customizeListView.frame.origin.y = self.view.frame.height
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.3
            fadeTextAnimation.type = .fade
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
            switch swipeGesture.direction {
            case .down:
                self.tableView.tableHeaderView?.fadeIn()
                self.tableViewTop?.constant = -10
                    if tasksList.count + completedTasks.count <= 6  {
                        UIView.animate(withDuration: 0.4) {
                            self.tableView.layoutIfNeeded()
                        }
                    }
                    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                    self.navigationItem.title = ""
            case .up:
                self.tableView.tableHeaderView?.fadeOut()
                self.tableViewTop?.constant = -80
                if tasksList.count + completedTasks.count <= 6 {
                    UIView.animate(withDuration: 0.4) {
                        self.tableView.layoutIfNeeded()
                    }
                } else {
                    navigationController?.navigationBar.setBackgroundImage(darkFilter.image, for: UIBarMetrics.default)
                }
                self.navigationItem.title = listTitle
            default:
                break
            }
        }
    }
    
    @objc func tappedBack() {
        _ = navigationController?.popViewController(animated: true)
        tasksList = []
        completedTasks = []
    }
    
    func configureNavBar() {
        titleLabel.font = UIFont(name: "OpenSans-Regular", size: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let elipsis = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(ellipsisTapped))
        elipsis.image = UIImage(named: "ellipsis")?.resize(targetSize: CGSize(width: 25, height: 20))
        elipsis.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 10)
        elipsis.tintColor = .white
        let search = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(searchTapped))
        search.imageInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -10)
        search.image = UIImage(named: "search")?.resize(targetSize: CGSize(width: 25, height: 25))
        search.tintColor = .white
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(tappedBack))
        backButton.image = UIImage(named: "arrow")?.rotate(radians: -.pi/2)?.resize(targetSize: CGSize(width: 25, height: 25))
        backButton.title = "Back"
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = [elipsis, search]
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }
    
   
    
    @objc func searchTapped() {
        print("search Tapped")
    }
    
    @objc func ellipsisTapped() {
        tappedIcon = "List Options"
        createSlider(listOptions: true)
    }
    
}



