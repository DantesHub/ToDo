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
var lists = [ListObject]()
var defaultColor = UIColor.blue
class MainViewController: UIViewController {
    //MARK: - instace variables
    var topTableView = SelfSizedTableView()
    var listTableView = SelfSizedTableView()
    var groupTableView = SelfSizedTableView()
    var pickUp = UITableView()
    var testArray = ["Fdafasd", "fdafas", "fdasf"]
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
    let popUpCellId = "popUpCell"
    let stackView = UIStackView()
    let footerView = UIView()
    let groupIV = UIImageView()
    var groups = [ListGroup]()
    var containerView = UIView()
    var slideUpView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero
        , collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    //MARK: - instantiate
    override func viewDidLoad() {
        super.viewDidLoad()
        getRealmData()
        UIFont.overrideInitialize()
        configureNavBar()
        configureUI()
    }
    

    
    //MARK: - helper functions
    func getRealmData() {
        groups = []
        lists = []
        let results = uiRealm.objects(ListGroup.self)
        for result in results {
            groups.append(result)
        }
        let listResults = uiRealm.objects(ListObject.self)
        for result in listResults {
            lists.append(result)
        }
        print(listResults)
    }
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.topToSuperview()
        scrollView.bottomToSuperview()
        createFooter()

        self.scrollView.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.axis = .vertical
        self.stackView.spacing = 10;
        //constrain stack view to scroll view
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true;
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true;
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true;
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true;

        //constrain width of stack view to width of self.view, NOT scroll view
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true;
        stackView.addArrangedSubview(topTableView)
        topTableView.register(MainMenuCell.self, forCellReuseIdentifier: "topCell")
        topTableView.dataSource = self
        topTableView.delegate = self
        topTableView.rowHeight = 70
        topTableView.height(210)
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
        view.addSubview(footerView)
        footerView.trailingToSuperview()
        footerView.leadingToSuperview()
        footerView.bottomToSuperview()
        footerView.height(80)
        footerView.backgroundColor = .white
        
        let tappedListImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddList))
        let plusIV = UIImageView()
        plusIV.image = UIImage(named: "plus")?.resize(targetSize: CGSize(width: 40, height: 40)).withTintColor(defaultColor)
        footerView.addSubview(plusIV)
        plusIV.centerY(to: footerView)
        plusIV.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20).isActive = true
        plusIV.addGestureRecognizer(tappedListImageRecognizer)
        plusIV.isUserInteractionEnabled = true
        
        let tappedListLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddList))
        let newListLabel = UILabel()
        newListLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
        newListLabel.text = "New List"
        newListLabel.textColor = defaultColor
        footerView.addSubview(newListLabel)
        newListLabel.leadingAnchor.constraint(equalTo: plusIV.trailingAnchor, constant: 5).isActive = true
        newListLabel.centerY(to: footerView)
        newListLabel.addGestureRecognizer(tappedListLabelRecognizer)
        newListLabel.isUserInteractionEnabled = true
        
        let tappedGroupImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddGroup))
        groupIV.image = UIImage(named: "folderPlus")?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(defaultColor)
        footerView.addSubview(groupIV)
        groupIV.centerY(to: footerView)
        groupIV.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20).isActive = true
        groupIV.addGestureRecognizer(tappedGroupImageRecognizer)
        groupIV.isUserInteractionEnabled = true
        
        let tappedGroupLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAddGroup))
        let newGroupLabel = UILabel()
        newGroupLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
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
        label.text = "Monday August, 17"
        label.font = UIFont(name: "OpenSans-Regular", size: 18)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        label.textColor = .blue
        navigationController?.navigationBar.barTintColor = .white
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
  
        view.addSubview(arw)
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
        groupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupCell")
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        groupTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(groups.count * 70)).isActive = true
        groupTableView.dragDelegate = self
        groupTableView.dropDelegate = self
        groupTableView.backgroundColor = .white
        groupTableView.rowHeight = 70
        groupTableView.allowsSelection = false
        groupTableView.separatorStyle = .none
    }
    

    func createListSection() {
        stackView.addArrangedSubview(listTableView)
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        listTableView.dataSource = self
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
        let alertController = UIAlertController(title: "Add New Group", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Untitled Group"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let createdGroup = ListGroup()
            createdGroup.name = firstTextField.text ?? "Untitled Groupr"
            createdGroup.position = (self.groups.count - 1) + 1
            try! uiRealm.write {
                uiRealm.add(createdGroup)
            }
            self.getRealmData()
            self.groupTableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func tappedAddList() {
        let controller = ListController()
        controller.creating = true;
//        let CreateListController = UINavigationController(rootViewController: controller)
//        CreateListController.modalPresentationStyle = .fullScreen
//        present(CreateListController,animated: true)
        controller.navigationController?.isNavigationBarHidden = false
        self.navigationController?.view.layer.add(CATransition().popFromRight(), forKey: nil)
        self.navigationController?.pushViewController(controller, animated: false)
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
            print("shine")
            listArw.image = listArw.image?.rotate(radians: .pi/2)
            listTableView.insertRows(at: indexPaths, with: .fade)
            listTableView.invalidateIntrinsicContentSize()
            createGroupSection()
        } else {
            print("brave")
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
    
        
    }
    @objc func ellipsisTapped() {
        print("ellipsis Tapped")
    }
    
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == listTableView){
            if isListsExpanded {
                return lists.count
            }
            return 0
        } else if (tableView == groupTableView) {
            if !groups[section].isExpanded {
                return 0
            }
            return groups[section].lists.count
        } else { //topTableView
            return topList.count
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == listTableView {
            if isListsExpanded == false {
                return 1
            }
            return 1
        } else if tableView == groupTableView {
            if isGroupsExpanded == false {
                return 0
            }
            return groups.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var groupHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        if tableView == groupTableView {
            groupHeader.backgroundColor = .white
            let label = UILabel()
            groupHeader.addSubview(label)
            let folderImage = UIImageView(image: UIImage(named: "folder")?.resize(targetSize: CGSize(width: 25, height: 25)))
            groupHeader.addSubview(folderImage)
            folderImage.leadingAnchor.constraint(equalTo: groupHeader.leadingAnchor, constant: 20).isActive = true
            folderImage.centerY(to: groupHeader)
            label.centerY(to: groupHeader)
            label.font = UIFont(name: "OpenSans-Bold", size: 16)
            label.textColor = .black
            label.leadingAnchor.constraint(equalTo: folderImage.leadingAnchor, constant: 40).isActive = true
            print(groups[section].name)
            label.text = groups[section].name
            
            let arw = UIButton(type: .custom)
            groupHeader.addSubview(arw)
            arw.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi), for: UIControl.State.normal)
            arw.tag = section
            arw.addTarget(self, action: #selector(groupExpandClose), for: UIControl.Event.touchDown)
            arw.centerY(to: groupHeader)
            arw.trailingAnchor.constraint(equalTo: groupHeader.trailingAnchor, constant: -20).isActive = true
            
            
            let elips = UIButton(type: .custom)
            groupHeader.addSubview(elips)
            elips.setImage(UIImage(named: "ellipsis")?.resize(targetSize: CGSize(width: 18, height: 18)), for: UIControl.State.normal)
            elips.addTarget(self, action: #selector(groupElipsTapped), for: UIControl.Event.touchDown)
            elips.centerY(to: groupHeader)
            elips.trailingAnchor.constraint(equalTo: arw.trailingAnchor, constant: -30).isActive = true
        } else if tableView == listTableView {
            groupHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        } else if tableView == topTableView {
              groupHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        }
        return groupHeader
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == listTableView {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "listCell")
            cell.textLabel?.text = lists[indexPath.row].name
            return cell
        } else if tableView == groupTableView {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "groupCell")
            cell.textLabel?.text = groups[indexPath.section].lists[indexPath.row].name
            return cell
        } else {//topTableView
            let cell = tableView.dequeueReusableCell(withIdentifier: "topCell", for: indexPath) as! MainMenuCell
            cell.cellImage.image = UIImage(named: topList[indexPath.row].imgName)?.resize(targetSize: CGSize(width: 25, height: 25))
            cell.cellTitle.text = topList[indexPath.row].title
            cell.selectionStyle = .none
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == topTableView {
            print("topper")
        } else if tableView == listTableView {
            print("tapping")
            let results = uiRealm.objects(ListGroup.self)
            let resutls2 = uiRealm.objects(ListObject.self)
            for result in results {
                if result.name == "bingo" {
                    for list in resutls2 {
                        if list.name == "fsdaf" {
                            print("added")
                            try! uiRealm.write {
                                result.lists.append(list)
                            }
                        }
                    }
                
                }
            }
            
        }
    }
    

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print(indexPath.section)
        pickUp = tableView
        if tableView == listTableView {
            return lists.dragItems(for: indexPath)
        } else {
            return model2.dragSections(for: indexPath.section)
        }
    }
    
    
    /**
     A drop proposal from a table view includes two items: a drop operation,
     typically .move or .copy; and an intent, which declares the action the
     table view will take upon receiving the items. (A drop proposal from a
     custom view does includes only a drop operation, not an intent.)
     */
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                if(pickUp != tableView) {
                    return UITableViewDropProposal(operation: .cancel)
                } else {
                    return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
                }
            }
        } else {
            if(pickUp != tableView) {
                return UITableViewDropProposal(operation: .cancel)
            }
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    /**
     This delegate method is the only opportunity for accessing and loading
     the data representations offered in the drag item. The drop coordinator
     supports accessing the dropped items, updating the table view, and specifying
     optional animations. Local drags with one item go through the existing
     `tableView(_:moveRowAt:to:)` method on the data source.
     */
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // Consume drag items.
            let stringItems = items as! [ListObject]
            
            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                lists.addItem(item, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    //      func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        lists.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == groupTableView {
            return 40
        } else {
            return 0
        }
    }

    
    @objc func groupExpandClose(button: UIButton) {
        let section = button.tag
        // we'll try to close the section first by deleting the rows
        var indexPaths = [IndexPath]()
        for row in groups[section].lists.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        
        let isExpanded = groups[section].isExpanded
        try! uiRealm.write {
            groups[section].isExpanded = !isExpanded
        }
        if isExpanded {
            groupTableView.deleteRows(at: indexPaths, with: .fade)
            button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi/2), for: UIControl.State.normal)
        } else {
            groupTableView.insertRows(at: indexPaths, with: .fade)
            button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi), for: UIControl.State.normal)
        }
    }
    
}
