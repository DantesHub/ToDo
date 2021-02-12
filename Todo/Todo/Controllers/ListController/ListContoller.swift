import UIKit
import Layoutless
import TinyConstraints
import RealmSwift
import FSCalendar
import IQKeyboardManagerSwift
protocol ReloadDelegate {
    func reloadTableView()
}
var searching = false
var keyboard = false
var keyboard2 = false
var planned = false
var reminder = false
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
var selectedDict: [String: Bool] = [String:Bool]()
var listTextColor = UIColor.white
import AppsFlyerLib
class ListController: UIViewController, TaskViewDelegate {
    //MARK: - instance variables
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter
    }()

    let footer = UIView()
    var calendar = FSCalendar()
    var timePicker: UIDatePicker?
    let backArrow = UIButton(frame: CGRect(x: 10, y: 15, width: 25, height: 25))
    var set = UIButton()
    var reloadDelegate: ReloadDelegate?
    var creating = false;
    let bigTextField = UITextField()
    let titleLabel = UILabel()
    let tableView = UITableView(frame: .zero, style: .grouped)
    var lastKnowContentOfsset: CGFloat = 0
    var scrolledUp = false
    var tableViewTop : NSLayoutConstraint?
    var nameTaken = false
    var plusTaskView = UIImageView()
    var addTaskField = TextFieldWithPadding()
    var frameView = UIView()
    var tappedIcon = ""
    var favorited = false
    var dateLabel = UILabel()
    var sortType = ""
    var added50ToReminder = false
    var added50ToDueDate = false
    var selectedListTextColor = UIColor.white
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
    var selectedImage = UIImage()
    var customizeSelection = "Photo"
    var headerView = UIView()
    var customizeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero
                                  , collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        return cv
    }()
    var listName = ""
    var nameTaken2 = false
    var imagePicker = UIImagePickerController()
    let window = UIApplication.shared.keyWindow
    let selectAll = BoxOption()
    var photos: [String] = ["addPicture", "campfire", "mountain", "nature", "forest", "rain", "seaside", "seaside2", "space"]
    var backgroundColors:[UIColor] = [blue, purple, darkRed, darkOrange, darkGreen, turq, gray]
    var textColors:[UIColor] = [.white, blue, purple, darkRed, darkOrange, darkGreen, turq, gray]
    var backgroundButton = UIButton()
    var photoButton = UIButton()
    var textButton = UIButton()
    let screenSize = UIScreen.main.bounds.size
    let slideUpViewHeight: CGFloat = 350
    var completedExpanded = true
    var reversed = true
    var photoSelected = false
    let lists = uiRealm.objects(ListObject.self)
    var accessBool = false
    var listObject: ListObject = ListObject()
    var sortOptions: [String] = ["Important", "Alphabetically", "Priority", "Due Date", "Creation Date"]
    var listOptions: [String] = ["Rename List", "Select Tasks", "Sort", "Change Theme & Color", "Delete List"]
    lazy var swipeDown: UISwipeGestureRecognizer = {
        return UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
    }()
    lazy var swipeUp: UISwipeGestureRecognizer = {
        return UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
    }()
    lazy var searchBar = UISearchBar()
    var isFiltering = false
    var isSearchBarEmpty: Bool {
      return searchBar.text?.isEmpty ?? true
    }
    var taskDictionary = [TaskObject]()
    var completedTaskDictionary = [TaskObject]()
    var filteredTasks = [TaskObject]()
    var filteredCompletedTasks = [TaskObject]()
    var searching = false
     var image: UIImage?
     var croppedRect = CGRect.zero
     var croppedAngle = 0
    var keyboardHeight: CGFloat {
        get {
            var height: CGFloat = 312
            switch UIScreen.main.nativeBounds.height {
           case 1136:
                height = 350
           // print("iPhone 5 or 5S or 5C")
            case 1334: //iphone 8
               height = 350
           case 1920, 2208:
                height = 356
              //iphone 8 plus
            case 2436, 2532, 2778, 2388, 2732, 2688, 1792:
                height = 420
                // 11 pro
                //iphone 12
                //iphone 12 pro max
                // iphone 11
           default:
                //ipad
                height = 400
           }
            if UIDevice.current.userInterfaceIdiom == .pad {
                switch UIScreen.main.bounds.height {
                case 1366:
                    height = 480
                default:
                    print("yoman")
                }
            }
            return height
        }
       
    }

    //MARK: - init
    override func viewDidLoad() {
        print(UIScreen.main.bounds.height, "dsf")
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
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
        
        if !creating {
            UserDefaults.standard.set(listTitle, forKey: "lastOpened")
        }
        
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
        backgroundImage.addGestureRecognizer(tapRecognizer)
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
        tappedDoneEditing()
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
        plusTaskView = UIImageView(frame: CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 150, width: 60, height: 60))
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
        addTaskField.overrideUserInterfaceStyle = .light
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
    
    
    
    func createObservers() {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        center.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeObservers() {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func resignResponder() {
        addTaskField.resignFirstResponder()
    }
    
    func createSlider(createSlider: Bool = true, picker: Bool = false, listOptions: Bool = false, sortOptions: Bool = false) {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
   
        containerView.frame = self.view.frame
        window?.addSubview(containerView)
        containerView.alpha = 0
        if createSlider {
            let extraHeight: CGFloat = sortOptions ? 50 : listOptions ? 50 : 0
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
                            self.containerView.alpha = 0.3
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
        configureNavBar()
    }
    
    @objc func slideUpViewTapped(deleting: Bool = false) {
        UIView.animate(withDuration: 0.4,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.containerView.alpha = 0
                        self.slideUpView.frame = CGRect(x: 0, y: (self.window?.frame.height)!, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height
                        )
                       }) { (lo) in
            
            if deleting {
                    MainViewController().deleteList(name: listTitle)
                    self.tableView.removeFromSuperview()
                    self.reloadDelegate?.reloadTableView()
                    self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    func addBottomView() {
        view.insertSubview(footer, at: 1000)
        footer.leadingToSuperview()
        footer.trailingToSuperview()
        footer.bottomToSuperview()
        footer.height(100)
        footer.backgroundColor = lightGray
        
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
        addToList.image = "move"
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
    func allSelected() -> Bool {
        for id in selectedDict.keys {
            if selectedDict[id] == false {
                return false
            }
        }
        return true
    }
    func checkIfAllFalse() -> Bool {
        var allFalse = true
        for value in selectedDict.values {
            if value { allFalse = false }
        }
        if allFalse {
            let alertController = UIAlertController(title: "Please Select A Task", message: "", preferredStyle: UIAlertController.Style.alert)
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {
                                            (action : UIAlertAction!) -> Void in })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            return true
        } else {
            return false
        }
    }
    @objc func tappedDeleteTask() {
        if !checkIfAllFalse() {
            let alertController = UIAlertController(title: "Are you sure you want to these tasks?", message: "", preferredStyle: UIAlertController.Style.alert)
            let okayAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (action) in
                for task in tasksList {
                    if selectedDict[task.id] == true {
                        try! uiRealm.write {
                            uiRealm.delete(task)
                        }
                    }
                }
                
                for task in completedTasks {
                    if selectedDict[task.id] == true {
                        try! uiRealm.write {
                            uiRealm.delete(task)
                        }
                    }
                }
                
                self.getRealmData()
                for (idx,task) in tasksList.enumerated() {
                    try! uiRealm.write {
                        task.position = idx
                    }
                }
                self.reloadDelegate?.reloadTableView()
                self.tableView.reloadData()
                
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {
                                            (action : UIAlertAction!) -> Void in })
            alertController.addAction(okayAction)
            alertController.addAction(noAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @objc func tappedAddToList() {
        if !checkIfAllFalse() {
            tappedIcon = "Add to a List"
            slideUpView.reloadData()
            createSlider()
        }
    }
    @objc func tappedSelectAll() {
        if allSelected() {
            //deselect everything
            for id in selectedDict.keys {
                selectedDict[id] = false
            }
            selectAll.label.text = "Select All"
            tableView.reloadData()
        } else {
            for id in selectedDict.keys {
                selectedDict[id] = true
            }
            selectAll.label.text = "Deselect All"
            tableView.reloadData()
        }
        
    }
    
    
    func getRealmData() {
        var results = uiRealm.objects(TaskObject.self)
        results = results.sorted(byKeyPath: "position", ascending: true)
 
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
                if result.favorited == true && result.completed == false {
                    tasksList.append(result)
                }
            }
        } else if listTitle == "Planned"  {
            for result in results {
                if result.planned != "" && result.completed == false {
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
        var notFound = true
        
        for list in lists {
            if list.name == listTitle {
                notFound = false
                listObject = list
                sortType = list.sortType
                reversed = list.reversed
                selectedListBackground = K.getListColor(list.backgroundColor)
                selectedListTextColor = K.getListColor(list.textColor)
                selectedListImage = list.backgroundImage
                if selectedListImage == "addPicture" {
                    selectedImage = getSavedImage(named: list.name) ?? UIImage()
                }
            }
        }
        
        let premadeLists = uiRealm.objects(PremadeList.self)
        if notFound {
            for list in premadeLists {
                if list.name == listTitle {
                    notFound = false
                    selectedListBackground = K.getListColor(list.backgroundColor)
                    selectedListTextColor = K.getListColor(list.textColor)
                    selectedListImage = list.backgroundImage
                    if selectedListImage == "addPicture" {
                        selectedImage = getSavedImage(named: list.name) ?? UIImage()
                    }
                }
            }
        }
        if notFound {
            if listTitle == "Important" {
                selectedListImage = "redWall"
            } else if listTitle == "All Tasks" {
                selectedListImage = "greenWall"
            } else if listTitle == "Planned" {
                selectedListImage = "blueWall"
            }
            selectedListTextColor = .white
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
    @objc func tappedOutside3() {
        slideUpViewTapped()
        if !editingCell {
            self.view.endEditing(true)
            configureNavBar()
        }
    }
    
    @objc func tappedAddTask() {
        if tasksList.count + completedTasks.count == 14  && UserDefaults.standard.bool(forKey: "isPro") == false{
            let sub = SubscriptionController()
            AppsFlyerLib.shared().logEvent(name: "Sub_From_Limit_Tasks", values: [AFEventParamContent: "true", AFEventParamCountry: "\(Locale.current.regionCode ?? "Not Available")"])
            sub.idx = 1
            self.navigationController?.present(sub, animated: true, completion: nil)
            return
        }
        addTaskField.becomeFirstResponder()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        containerView.frame = self.view.frame
        containerView.alpha = 0
        view?.insertSubview(containerView, belowSubview: addTaskField)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tappedOutside3))
        tapGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGesture)
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseOut, animations: { [self] in
                        self.containerView.alpha = 0.3
                       }, completion: nil)
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
        if UserDefaults.standard.bool(forKey: "notif") {
            let content = UNMutableNotificationContent()
            content.title = self.addTaskField.text!
            content.body = "Let's Get To It!"
            let formatter3 = DateFormatter()
            formatter3.dateFormat = "MMM dd,yyyy h:mm a"
            
            var dat = Date()
            if dateReminderSelected == "" {
                dateReminderSelected = formatter.string(from: Date())
                dat = formatter3.date(from: dateReminderSelected + " " + timeReminderSelected)!
            } else if dateReminderSelected.contains("-"){
                dateReminderSelected = dateReminderSelected.replacingOccurrences(of: "-", with: " ")
                dat = formatter3.date(from: dateReminderSelected)!
            } else {
                dat = formatter3.date(from: dateReminderSelected + " " + timeReminderSelected)!
            }
           
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dat)
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
    }
    
    
    func changeTheme() {
        if K.getStringColor(selectedListBackground) != "" {
            backgroundImage.image = nil
            backgroundImage.backgroundColor = selectedListBackground
        } else if selectedListImage != "" {
            if selectedListImage == "addPicture" {
                backgroundImage.image = selectedImage
            } else {
                var selectedImage = ""
                if selectedListImage == "blueWall" || selectedListImage == "greenWall" || selectedListImage == "redWall" {
                     selectedImage = selectedListImage
                } else {
                     selectedImage = selectedListImage + "Background"

                }
                backgroundImage.image = UIImage(named: selectedImage)
            }
          
        }
        if K.getStringColor(selectedListTextColor) != "" {
            listTextColor = selectedListTextColor
            bigTextField.textColor = listTextColor
        }
    }
    //MARK: - Tapped Done
    @objc func tappedCreateDone(sender: UIButton) {
        createNewList(tag: sender.tag)
        addTaskField.isHidden = false
        if sender.tag == 0 {
            updateTheme()
        }
    }
    
    @objc func tappedDoneEditing() {
        self.tableView.isEditing = false
        editingCell = false
        configureNavBar()
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        selectedDict = [String:Bool]()
        footer.removeFromSuperview()
        tableView.reloadData()
        plusTaskView.isHidden = false
    }
    
    @objc func tappedDone() {
        self.addTaskField.resignFirstResponder()
        if addTaskField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""  {
            try! uiRealm.write {
                let toTop = UserDefaults.standard.bool(forKey: "toTop")
                let id = UUID().uuidString
                let task = TaskObject()
                task.id = id
                task.position = toTop ? 0 : tasksList.count
                task.completed = false
                task.name = addTaskField.text!
                if listTitle == "Important" {
                    task.favorited = true
                } else {
                    task.favorited = favorited
                }
                let formatter4 = DateFormatter()
                formatter4.dateFormat = "MMM dd,yyyy-h:mm a"
                task.createdAt = formatter4.string(from: Date())
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "h:mm a"
                if planned {
                    if dateDueSelected == "" {
                        formatter.dateFormat = "MMM dd,yyyy"
                        dateDueSelected = formatter.string(from: Date())
                        task.planned = dateDueSelected + " " + timeDueSelected
                    } else if dateDueSelected.contains("-"){
                        dateDueSelected = dateDueSelected.replacingOccurrences(of: "-", with: " ")
                        task.planned = dateDueSelected
                    } else {
                        task.planned = dateDueSelected + " " + timeDueSelected
                    }
                    
                } else if listTitle == "Planned" {
                    if dateDueSelected == "" {
                        formatter.dateFormat = "MMM dd,yyyy"
                        if timeDueSelected == "" {
                            let formatter4 = DateFormatter()
                            formatter4.dateFormat = "MMM dd,yyyy h:mm a"
                            dateDueSelected = formatter4.string(from: Date())
                            task.planned = dateDueSelected + " " + timeDueSelected
                        } else {
                            dateDueSelected = formatter.string(from: Date())
                        }
                        task.planned = dateDueSelected + " " + timeDueSelected
                    } else if dateDueSelected.contains("-"){
                        dateDueSelected = dateDueSelected.replacingOccurrences(of: "-", with: " ")
                        task.planned = dateDueSelected
                    } else {
                        task.planned = dateDueSelected + " " + timeDueSelected
                    }
                }
                
                if reminder {
                    if dateReminderSelected == "" {
                        dateReminderSelected = formatter.string(from: Date())
                        task.reminder = dateReminderSelected + "-" + timeReminderSelected
                    } else if dateReminderSelected.contains("-"){
                        dateReminderSelected = dateReminderSelected.replacingOccurrences(of: "-", with: " ")
                        task.reminder = dateReminderSelected
                    } else {
                        task.reminder = dateReminderSelected + " " + timeReminderSelected
                    }
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
                if toTop {
                    for task in tasksList {
                        task.position = task.position + 1
                    }
                    tasksList.insert(task, at: 0)
                } else {
                    tasksList.append(task)
                }
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
        addTaskField.text = ""
        tableView.reloadData()
        tappedOutside3()
        reloadDelegate?.reloadTableView()
    }
    
    @objc func tappedOutside() {
        if !editingCell {
            if !creating {
                self.view.endEditing(true)
                if !editingCell {
                    configureNavBar()
                }
            }
            cancelSearch()
        }
  
    }
    
    func createTableHeader() {
        headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        view.addSubview(headerView)
        headerView.addSubview(bigTextField)
        bigTextField.becomeFirstResponder()
        bigTextField.delegate = self
        bigTextField.font = UIFont(name: "OpenSans-Bold", size: 40)
        bigTextField.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        bigTextField.centerY(to: headerView)
        bigTextField.height(40)
        bigTextField.placeholder = listTitle
        bigTextField.textColor = listTextColor
        bigTextField.text = listTitle
        
        headerView.addSubview(dateLabel)
        dateLabel.topToBottom(of: bigTextField, offset: 5)
        dateLabel.font = UIFont(name: "OpenSans-Regular", size: 20)
        dateLabel.textColor = listTextColor
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        dateLabel.text = formatter.string(from: Date())
        dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        dateLabel.height(20)
        
        if !creating {
            bigTextField.isUserInteractionEnabled = false
        } else {
            createCustomListView()
        }
        headerView.top(to: view, offset: 125)
        headerView.leading(to: view, offset: 5)
    }

    
    //MARK: - custom list view
    func createCustomListView(change: Bool = false) {
        if change {
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            containerView.frame = self.view.frame
            window?.addSubview(containerView)
            containerView.alpha = 0
            window?.addSubview(customizeListView)
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(tappedOutsideCustom))
            tapGesture.cancelsTouchesInView = false
            containerView.addGestureRecognizer(tapGesture)
        } else {
            view.addSubview(customizeListView)
        }
        if !change {
            customizeListView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height * 0.17)
        } else {
            customizeListView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: view.frame.width, height: view.frame.height * 0.27)
            if change {
                UIView.animate(withDuration: 0.5,
                               delay: 0, usingSpringWithDamping: 1.0,
                               initialSpringVelocity: 1.0,
                               options: .curveEaseOut, animations: { [self] in
                                self.containerView.alpha = 0.3
                                self.customizeListView.frame = CGRect(x: 0, y: self.screenSize.height - 220, width: self.customizeListView.frame.width, height: self.customizeListView.frame.height)
                               }, completion: nil)
            }
        }
        if change {
            customizeListView.overrideUserInterfaceStyle = .light
            let title = UILabel()
            title.font = UIFont(name: "OpenSans-Bold", size: 18)
            title.text = "Change Theme"
            customizeListView.addSubview(title)
            title.top(to: customizeListView, offset: 20)
            title.centerX(to: customizeListView)
            let backArrow = UIButton()
            backArrow.setBackgroundImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 25, height: 25)).rotate(radians: -.pi/2)?.withTintColor(.black), for: .normal)
            backArrow.addTarget(self, action: #selector(tappedCustomBack), for: .touchUpInside)
            customizeListView.addSubview(backArrow)
            backArrow.top(to: customizeListView, offset: 20)
            backArrow.leading(to: customizeListView, offset: 10)
            let hr = UIView()
            hr.backgroundColor = .darkGray
            customizeListView.addSubview(hr)
            hr.topToBottom(of: title, offset: 10)
            hr.leading(to: customizeListView)
            hr.trailing(to: customizeListView)
            hr.height(0.5)
            
            let done = UIButton()
            done.setTitle("Done", for: .normal)
            done.setTitleColor(.blue, for: .normal)
            done.titleLabel?.font = UIFont(name: "OpenSans", size: 20)
            customizeListView.addSubview(done)
            done.trailing(to: customizeListView, offset: -20)
            done.top(to: customizeListView, offset: 20)
            done.addTarget(self, action: #selector(tappedDoneCustom), for: .touchUpInside)
        }

        customizeListView.layer.cornerRadius = 15
        customizeListView.backgroundColor = .white
        
        customizeListView.addSubview(photoButton)
        photoButton.height(35)
        photoButton.width(customizeListView.frame.width/5)
        photoButton.leading(to: customizeListView, offset: 20)
        photoButton.top(to: customizeListView, offset: change ? customizeListView.frame.height * 0.35 : 15)
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
        backgroundButton.top(to: customizeListView, offset: change ? customizeListView.frame.height * 0.35 : 15)
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
    
        textButton.top(to: customizeListView, offset: change ? customizeListView.frame.height * 0.35 : 15)
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
        
        customizeCollectionView.topToBottom(of: photoButton, offset: 0)
        customizeCollectionView.backgroundColor = .white
        customizeCollectionView.allowsSelection = true
        print(customizeCollectionView.frame.height, "gaho")
        customizeCollectionView.height(customizeListView.frame.height * (change ? 0.50 : 0.70))
 
    }
    @objc func tappedDoneCustom() {
        tappedOutsideCustom()
        customizeSelection = "Photo"
        photoButton.setTitleColor(.white, for: .normal)
        customizeCollectionView.reloadData()
        customizeCollectionView.removeFromSuperview()
        customizeListView.removeFromSuperview()
        creating = false
        updateTheme()
    }
     func updateTheme() {
        var foundList = false
        let premadeLists = uiRealm.objects(PremadeList.self)
        if listTitle == "Planned" || listTitle == "Important" || listTitle == "All Tasks" {
            try! uiRealm.write {
                for lst in premadeLists {
                    if listTitle == lst.name {
                        foundList = true
                        lst.backgroundColor = K.getStringColor(selectedListBackground)
                        if selectedListTextColor != UIColor.clear {
                            lst.textColor = K.getStringColor(selectedListTextColor)
                        } else {
                            lst.textColor = "white"
                        }
                        if selectedListBackground == UIColor.clear && selectedListImage == "" {
                            lst.backgroundImage = "mountain"
                        } else {
                            lst.backgroundImage = selectedListImage
                        }
                        changeTheme()
                    }
                }
            }
        }
        
        try! uiRealm.write {
            for list in lists  {
                if list.name == listTitle {
                    foundList = true
                    list.backgroundColor = K.getStringColor(selectedListBackground)
                    if selectedListTextColor != UIColor.clear {
                        list.textColor = K.getStringColor(selectedListTextColor)
                    } else {
                        list.textColor = "white"
                    }
                    if selectedListBackground == UIColor.clear && selectedListImage == "" {
                        list.backgroundImage = "mountain"
                    } else {
                        list.backgroundImage = selectedListImage
                    }
                    changeTheme()
                }
            }
        }
        if !foundList { // one of the default lists
            try! uiRealm.write {
                let lst = PremadeList()
                lst.name = listTitle
                if selectedListTextColor != UIColor.clear {
                    lst.textColor = K.getStringColor(selectedListTextColor)
                } else {
                    lst.textColor = "white"
                }
                if selectedListBackground == UIColor.clear && selectedListImage == "" {
                    if listTitle == "Important" {
                        lst.backgroundImage = "redWall"
                    } else if listTitle == "All Tasks" {
                        lst.backgroundImage = "greenWall"
                    } else if listTitle == "Planned" {
                        lst.backgroundImage = "blueWall"
                    }
                } else {
                    lst.backgroundImage = selectedListImage
                }
                changeTheme()
                uiRealm.add(lst)
            }
        }
        reloadDelegate?.reloadTableView()
    }
    @objc func tappedOutsideCustom() {

        creating = false
        UIView.animate(withDuration: 0.4,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.containerView.alpha = 0
                        self.customizeListView.frame = CGRect(x: 0, y: (self.window?.frame.height)!, width: self.customizeListView.frame.width, height: self.customizeListView.frame.height
                        )
                       }) { (bo) in
            self.customizeCollectionView.removeFromSuperview()
            self.customizeListView.removeFromSuperview()
        }
    }
    
    @objc func tappedCustomBack() {
        tappedOutsideCustom()
        creating = false
        customizeCollectionView.removeFromSuperview()
        customizeListView.removeFromSuperview()
        createSlider(listOptions: true)
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
    
    func createTableView(top: CGFloat = 145) {
        tableView.register(TaskCell.self, forCellReuseIdentifier: "list")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "completedHeader")
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)
        tableView.leadingToSuperview(offset: 10)
        tableView.trailingToSuperview(offset: 10)
        tableView.bottomToSuperview()
        tableViewTop = tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: sortType != "" ? top : 105)
        tableViewTop?.isActive = true
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
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.3
            fadeTextAnimation.type = .fade
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
            switch swipeGesture.direction {
            case .down:
                self.headerView.isHidden = false
                if sortType != "" {
                    self.tableViewTop?.constant = 145
                } else {
                    self.tableViewTop?.constant = 105
                }
                if tasksList.count + completedTasks.count <= 6  {
                    UIView.animate(withDuration: 0.4) {
                        self.tableView.layoutIfNeeded()
                    }
                }
                createHamburg()
                navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                self.navigationItem.title = ""
            case .up:
                self.headerView.isHidden = true
                self.tableViewTop?.constant = sortType != "" ? -20 : -60
                if tasksList.count + completedTasks.count <= 6 && UIDevice.current.hasNotch {
                    UIView.animate(withDuration: 0.4) {
                        self.tableView.layoutIfNeeded()
                    }
                } else {
                    navigationController?.navigationBar.setBackgroundImage(darkFilter.image, for: UIBarMetrics.default)
                }
                let hamburg = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(tappedBack))
                hamburg.image = UIImage(named: "Hamburger")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(.white)
                hamburg.tintColor = .white
                self.navigationItem.leftBarButtonItem = hamburg
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
        createHamburg()
//        backButton.tintColor = .white
        navigationItem.rightBarButtonItems = [elipsis, search]
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func createHamburg() {
        let circle = RoundView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        circle.backgroundColor = .white
        let hamburg = UIImageView()
        hamburg.image = UIImage(named: "Hamburger")?.resize(targetSize: CGSize(width: 35, height: 35)).withTintColor(.black)
        hamburg.backgroundColor = .white
        circle.addSubview(hamburg)
        hamburg.frame.size = CGSize(width: 27, height: 30)
        hamburg.center =  CGPoint(x:22.5, y:22.5)

        hamburg.isUserInteractionEnabled = true
        let circleGest = UITapGestureRecognizer(target: self, action: #selector(tappedBack))
        circle.addGestureRecognizer(circleGest)
        let backButton = UIBarButtonItem()
        backButton.customView = circle
        backButton.target = self
        backButton.action = #selector(tappedBack)
        //        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func searchTapped() {
        navigationItem.titleView = searchBar
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searching = true
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSearch))
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationItem.leftBarButtonItems = [spacer]
        spacer.width = 5
        headerView.isHidden = true
        self.tableViewTop?.constant = sortType != "" ? -20 : -60
        navigationItem.rightBarButtonItems = [spacer, cancel]
        filterContentForSearchText(searchBar.text!)
    }
    
    @objc func cancelSearch() {
        navigationItem.titleView = .none
        headerView.isHidden = false
        if sortType != "" {
            self.tableViewTop?.constant = 145
        } else {
            self.tableViewTop?.constant = 105
        }
        if !creating {
            configureNavBar()
        }
        searching = false
        tableView.reloadData()
    }
    
    @objc func ellipsisTapped() {
        print("elipsis")
        if listTitle == "Important" || listTitle == "Planned" || listTitle == "All Tasks" {
            createCustomListView(change: true)
        } else {
            tappedIcon = "List Options"
            slideUpView.reloadData()
            createSlider(listOptions: true)
        }
      
    }
    
}


