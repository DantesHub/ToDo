//
//  ViewController.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints
import MobileCoreServices
import Layoutless
import RealmSwift
import Realm
import Purchases
import AppsFlyerLib
var mainIsRoot = false
var lists = [ListObject]()
var groups = [ListGroup]()
var tappedSearch = false
var defaultColor: UIColor = .systemBlue

class MainViewController: UIViewController, ReloadDelegate {
    //MARK: - instace variables
    var topTableView = SelfSizedTableView()
    var listTableView = SelfSizedTableView()
    var groupTableView = SelfSizedTableView()
    var pickUp = UITableView()
    var pickUpSection = 0
    var isGroupsExpanded = true
    var isListsExpanded = true
    var topList = [MainMenuTop(imgName: "star", title: "Important"), MainMenuTop(imgName: "calendarOne", title: "Planned"), MainMenuTop(imgName: "infinity", title: "All Tasks")]
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 400)
    var model = Model()
    var model2 = Model2()
    var arw = UIImageView(image: UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 20, height: 20)).rotate(radians: .pi))
    var listArw = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var groupHeader = UIView()
    var listHeader = UIView()
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    var wait = true
    var stackBottom: NSLayoutConstraint?
    var groupHeight: NSLayoutConstraint?
    let plusIV = UIImageView()
    let newListLabel = UILabel()
    let popUpCellId = "popUpCell"
    let stackView = UIStackView()
    let footerView = UIView()
    let groupIV = UIImageView()
    var containerView = UIView()
    var slideUpView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero
                                  
                                  , collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    var selectedGroupName = ""
    var groupTableHeight: CGFloat = 0
    //MARK: - instantiate
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        topTableView.overrideUserInterfaceStyle = .light
        getRealmData()
        UIFont.overrideInitialize()
        configureNavBar()
        
        configureUI()
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["premium"]?.isActive == true {
                UserDefaults.standard.setValue(true, forKey: "isPro")
            } else {
                UserDefaults.standard.setValue(false, forKey: "isPro")
            }
        } 
    }
    
    //MARK: - helper functions
    func reloadTableView() {
        getRealmData()
    }
    
    func getRealmData() {
        groups = []
        lists = []
        var results = uiRealm.objects(ListGroup.self)
        results = results.sorted(byKeyPath: "position", ascending: true)
        for result in results {
            
                let groupList = List<ListObject>()
                for _ in 0..<result.lists.count {
                    groupList.append(ListObject())
                }
                for list in result.lists {
                    for position in list.groupPositions {
                        if position.groupName == result.name {
                            groupList[position.groupPosition] = list
                        }
                    }
                }
                try! uiRealm.write {
                    result.lists = groupList
                }
                
                groups.append(result)
            
        }
        var listResults = uiRealm.objects(ListObject.self)
        let sortedListResults = listResults.sorted {
            $0.position < $1.position
        }
        lists = sortedListResults.map { $0 }
        groupTableView.reloadData()
        topTableView.reloadData()
        listTableView.reloadData()
    }
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.topToSuperview()
        scrollView.bottom(to: view, offset: -80)
        createFooter()
        
        self.scrollView.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.axis = .vertical
        self.stackView.spacing = 10;
        //constrain stack view to scroll view
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true;
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true;
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true;
        stackBottom = self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
        stackBottom?.isActive = true
        
        //constrain width of stack view to width of self.view, NOT scroll view
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true;
        stackView.addArrangedSubview(topTableView)
        topTableView.register(MainMenuCell.self, forCellReuseIdentifier: "topCell")
        topTableView.dataSource = self
        topTableView.delegate = self
        topTableView.rowHeight = 60
        topTableView.height(180)
        topTableView.allowsSelection = true
        topTableView.separatorStyle = .none
        topTableView.isScrollEnabled = false
        self.topTableView.contentInset = UIEdgeInsets(top: 10,left: 0,bottom: 0,right: 0)
        
        listHeader = UIView()
        listHeader.backgroundColor = .white
        stackView.addArrangedSubview(listHeader)
        listHeader.height(50)
        let label1 = UILabel()
        listHeader.addSubview(label1)
        label1.centerY(to: listHeader)
        label1.font = UIFont(name: "OpenSans-Regular", size: 20)
        label1.textColor = .blue
        label1.leadingAnchor.constraint(equalTo: listHeader.leadingAnchor, constant: 20).isActive = true
        listArw.image = UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 20, height: 20))
        stackView.addSubview(listArw)
        listArw.image = listArw.image?.rotate(radians: .pi)
        listArw.centerY(to: self.listHeader)
        listArw.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        label1.text = "Lists"
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleListExpandClose))
        listArw.isUserInteractionEnabled = true
        listArw.addGestureRecognizer(tapGestureRecognizer2)
        
        let hr = HorizontalBorder(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        listHeader.addSubview(hr)
        createListSection()
        createGroupSection()
        
   
    }
    func createFooter() {
        view.insertSubview(footerView, aboveSubview: groupHeader)
        footerView.trailingToSuperview()
        footerView.leadingToSuperview()
        footerView.bottomToSuperview()
        footerView.height(80)
        footerView.backgroundColor = .white
        
        let tappedListImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddList))
        plusIV.image = UIImage(named: "plus")?.resize(targetSize: CGSize(width: 35, height: 35)).withTintColor(defaultColor)
        footerView.addSubview(plusIV)
        plusIV.centerY(to: footerView)
        plusIV.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20).isActive = true
        plusIV.addGestureRecognizer(tappedListImageRecognizer)
        plusIV.isUserInteractionEnabled = true
        
        let tappedListLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddList))
        
        newListLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
        newListLabel.text = "New List"
        newListLabel.textColor = defaultColor
        footerView.addSubview(newListLabel)
        newListLabel.leadingAnchor.constraint(equalTo: plusIV.trailingAnchor, constant: 5).isActive = true
        newListLabel.centerY(to: footerView)
        newListLabel.addGestureRecognizer(tappedListLabelRecognizer)
        newListLabel.isUserInteractionEnabled = true
        
        let tappedGroupImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddGroup))
        groupIV.image = UIImage(named: "folderPlus")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(defaultColor)
        footerView.addSubview(groupIV)
        groupIV.centerY(to: footerView)
        groupIV.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20).isActive = true
        groupIV.addGestureRecognizer(tappedGroupImageRecognizer)
        groupIV.isUserInteractionEnabled = true
        
        let tappedGroupLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddGroup))
        let newGroupLabel = UILabel()
        newGroupLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
        newGroupLabel.text = "New Group"
        newGroupLabel.textColor = defaultColor
        footerView.addSubview(newGroupLabel)
        newGroupLabel.trailingAnchor.constraint(equalTo: groupIV.leadingAnchor, constant: -5).isActive = true
        newGroupLabel.centerY(to: footerView)
        newGroupLabel.addGestureRecognizer(tappedGroupLabelRecognizer)
        newGroupLabel.isUserInteractionEnabled = true
    }
    
    func configureNavBar() {
        let label = UILabel()
        label.textColor = UIColor.white
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        label.text = formatter.string(from: Date())
        label.font = UIFont(name: "OpenSans-Regular", size: 18)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        label.textColor = .systemBlue
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        let elipsis = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(ellipsisTapped))
        elipsis.image = UIImage(named: "ellipsis")?.resize(targetSize: CGSize(width: 25, height: 20))
        elipsis.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 10)
        let search = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(searchTapped))
        search.imageInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -10)
        search.image = UIImage(named: "search")?.resize(targetSize: CGSize(width: 25, height: 25))
        navigationItem.rightBarButtonItems = [elipsis, search]
        
    }
    func createGroupSection() {
        groupHeader = UIView()
        groupHeader.backgroundColor = .white
        stackView.addArrangedSubview(groupHeader)
        groupHeader.height(50)
        let label = UILabel()
        stackView.addSubview(label)
        label.centerY(to: groupHeader)
        label.font = UIFont(name: "OpenSans-Regular", size: 20)
        label.textColor = .blue
        label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20).isActive = true
        
        view.insertSubview(arw, belowSubview: footerView)
        arw.centerY(to: groupHeader)
        arw.height(20)
        arw.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20).isActive = true
        label.text = "Groups"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleExpandClose))
        arw.isUserInteractionEnabled = true
        arw.addGestureRecognizer(tapGestureRecognizer)
        
        let hr = HorizontalBorder(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        groupHeader.addSubview(hr)
        
        stackView.addArrangedSubview(groupTableView)
        groupTableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        for group in groups {
            for _ in group.lists {
                groupTableHeight += 40
            }
            groupTableHeight += 70
        }
        groupHeight = groupTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(groupTableHeight))
        groupHeight?.isActive = true
        groupTableView.dragDelegate = self
        groupTableView.dropDelegate = self
        groupTableView.backgroundColor = .white
        groupTableView.rowHeight = 40
        groupTableView.allowsSelection = true
        groupTableView.separatorStyle = .none
        groupTableView.isScrollEnabled = false
        if !mainIsRoot {
            let controller = ListController()
            controller.reloadDelegate = self
            controller.creating = false;
            if UserDefaults.standard.string(forKey: "lastOpened") != nil {
                listTitle = UserDefaults.standard.string(forKey: "lastOpened")!
                if listTitle == "Planned" || listTitle == "All Tasks" || listTitle == "Important" {
                    premadeListTapped = true
                }
            }
            let existingLists = uiRealm.objects(ListObject.self)
            var doesExist = false
            for lst in existingLists {
                if lst.name == listTitle {
                    doesExist = true
                }
            }
            if doesExist {
                controller.navigationController?.isNavigationBarHidden = false
                self.navigationController?.view.layer.add(CATransition().popFromRight(), forKey: nil)
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }
    }
    
    
    func createListSection() {
        stackView.addArrangedSubview(listTableView)
        listTableView.register(MainMenuCell.self, forCellReuseIdentifier: "listCell")
        listTableView.dataSource = self
        listTableView.isScrollEnabled = false
        listTableView.delegate = self
        listTableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        listTableView.dragDelegate = self
        listTableView.dropDelegate = self
        listTableView.backgroundColor = .white
        listTableView.allowsSelection = true
        listTableView.separatorStyle = .none
        listTableView.estimatedRowHeight = 40
    }
    
    @objc func tappedAddGroup() {
        let isPro = UserDefaults.standard.bool(forKey: "isPro")
        if isPro == true {
            addedStep = true
            let alertController = UIAlertController(title: "Add New Group", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.overrideUserInterfaceStyle = .light
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Untitled Group"
            }
            let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                let createdGroup = ListGroup()
                createdGroup.name = firstTextField.text ?? "Untitled Group"
                createdGroup.position = (groups.count - 1) + 1
                let groups = uiRealm.objects(ListGroup.self)
                var nameTaken = false
                for group in groups {
                    if group.name == firstTextField.text {
                        nameTaken = true
                        let alertController = UIAlertController(title: "Name is already in use, please use a different name", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okayAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {
                                                        (action : UIAlertAction!) -> Void in })
                        
                        alertController.addAction(okayAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                if !nameTaken {
                    try! uiRealm.write {
                        uiRealm.add(createdGroup)
                    }
                    self.groupTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(groups.count * 70)).isActive = true
                    self.getRealmData()
                    self.groupTableView.reloadData()
                }
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                                                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        AppsFlyerLib.shared().logEvent(name: "Sub_From_Group", values: [AFEventParamContent: "true", AFEventParamCountry: "\(Locale.current.regionCode ?? "Not Available")"])
        self.navigationController?.present(SubscriptionController(), animated: true, completion: nil)
    }
    @objc private func tappedAddList() {
        if lists.count == 3 && UserDefaults.standard.bool(forKey: "isPro") == false {
            let sub = SubscriptionController()
            AppsFlyerLib.shared().logEvent(name: "Sub_From_Limit_Lists", values: [AFEventParamContent: "true"])
            sub.idx = 1
            self.navigationController?.present(sub, animated: true, completion: nil)
            return
        }
        let controller = ListController()
        listTitle = "Untitled List"
        controller.reloadDelegate = self
        controller.creating = true;
        tasksList = []
        completedTasks = []
        controller.navigationController?.isNavigationBarHidden = false
        premadeListTapped = false
        self.navigationController?.view.layer.add(CATransition().popFromRight(), forKey: nil)
        self.navigationController?.pushViewController(viewController: controller, animated: false) { [self] in
            plusIV.alpha = 1
            newListLabel.alpha = 1
        }
    }
    
    
    @objc func handleListExpandClose() {
        var indexPaths = [IndexPath]()
        for row in lists.indices {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        isListsExpanded = !isListsExpanded
        stackView.removeArrangedSubview(groupTableView)
        stackView.removeArrangedSubview(groupHeader)
        if isListsExpanded {
            listArw.image = listArw.image?.rotate(radians: .pi/2)
            listTableView.insertRows(at: indexPaths, with: .fade)
            listTableView.invalidateIntrinsicContentSize()
            createGroupSection()
        } else {
            listArw.image = listArw.image?.rotate(radians: -.pi/2)
            listTableView.deleteRows(at: indexPaths, with: .fade)
            listTableView.invalidateIntrinsicContentSize()
            createGroupSection()
        }
    }
    @objc func handleExpandClose() {
        // we'll try to close the section first by deleting the rows
        var indexPaths = [Int]()
        for row in groups.indices {
            indexPaths.append(row)
        }
        let indexSet = IndexSet(indexPaths)
        isGroupsExpanded = !isGroupsExpanded
        
        if isGroupsExpanded {
            arw.image = arw.image?.rotate(radians: .pi/2)
            groupTableView.insertSections(indexSet, with: .fade)
        } else {
            arw.image = arw.image?.rotate(radians: -.pi/2)
            groupTableView.deleteSections(indexSet, with: .fade)
        }
    }
    
    @objc func searchTapped() {
        let listGroupTableView = AddListToGroupTableView(frame: view.bounds)
        listGroupTableView.reloadDelegate = self
        listGroupTableView.parentView = self
        listGroupTableView.searching = true
        listGroupTableView.configureUI()
        view.addSubview(listGroupTableView)
    }
    
    @objc func ellipsisTapped() {
        self.navigationController?.pushViewController(SettingsController(), animated: true)
    }
    
}


