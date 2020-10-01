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

class MainViewController: UIViewController {
    //MARK: - instace variables
    var topTableView = UITableView()
    var listTableView = SelfSizedTableView()
    var groupTableView = UITableView(frame: CGRect(), style: .plain)
    var pickUp = UITableView()
    var testArray = ["Fdafasd", "fdafas", "fdasf"]
    var isGroupsExpanded = true
    var isListsExpanded = true
    var topList = ["Important", "Planned", "All Tasks"]
    //MARK: - instantiate
    override func viewDidLoad() {
        super.viewDidLoad()
        UIFont.overrideInitialize()
        configureNavBar()
        configureUI()
        let label = UILabel()
        label.text = "bing"
        view.addSubview(label)
    }
    var model = Model()
    var model2 = Model2()
    var arw = UIImageView(image: UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 20, height: 20)).rotate(radians: .pi))
    var listArw = UIImageView()
    var groupHeader = UIView()
    var listHeader = UIView()
    //MARK: - helper functions
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(topTableView)
        
        topTableView.register(UITableViewCell.self, forCellReuseIdentifier: "topCell")
        topTableView.dataSource = self
        topTableView.delegate = self
        topTableView.height(view.frame.height/3)
        topTableView.leading(to: view)
        topTableView.trailing(to: view)
        topTableView.topToSuperview()
        topTableView.allowsSelection = false
        topTableView.separatorStyle = .none
        
         listHeader = UIView()
        listHeader.backgroundColor = .white
        view.addSubview(listHeader)
        listHeader.leadingToSuperview()
        listHeader.trailingToSuperview()
        listHeader.topAnchor.constraint(equalTo: topTableView.bottomAnchor,constant: 10).isActive = true
        listHeader.height(30)
        let label1 = UILabel()
        view.addSubview(label1)
        label1.centerY(to: listHeader)
        label1.font = UIFont(name: "OpenSans-Regular", size: 20)
        label1.textColor = .blue
        label1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        listArw = UIImageView(image: UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 20, height: 20)))
        view.addSubview(listArw)
        listArw.image = listArw.image?.rotate(radians: .pi)
        listArw.centerY(to: listHeader)
        listArw.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        label1.text = "Lists"
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleListExpandClose))
        listArw.isUserInteractionEnabled = true
        listArw.addGestureRecognizer(tapGestureRecognizer2)
        createListSection()
        createGroupSection()
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
        view.addSubview(groupHeader)
        groupHeader.leadingToSuperview()
        groupHeader.trailingToSuperview()
        groupHeader.topAnchor.constraint(equalTo: listTableView.bottomAnchor,constant: 10).isActive = true
        groupHeader.height(30)
        let label = UILabel()
        view.addSubview(label)
        label.centerY(to: groupHeader)
        label.font = UIFont(name: "OpenSans-Regular", size: 20)
        label.textColor = .blue
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
  
        view.addSubview(arw)
        arw.centerY(to: groupHeader)
        arw.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        label.text = "Groups"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleExpandClose))
        arw.isUserInteractionEnabled = true
        arw.addGestureRecognizer(tapGestureRecognizer)

        view.addSubview(groupTableView)
        groupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupCell")
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        groupTableView.dragDelegate = self
        groupTableView.dropDelegate = self
        groupTableView.height(view.frame.height/3)
        groupTableView.leadingToSuperview()
        groupTableView.trailingToSuperview()
        groupTableView.topAnchor.constraint(equalTo: groupHeader.bottomAnchor).isActive = true
        groupTableView.backgroundColor = .white
        groupTableView.allowsSelection = false
        groupTableView.separatorStyle = .none
    }
    

    func createListSection() {
        view.addSubview(listTableView)
           listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
           listTableView.dataSource = self
           listTableView.delegate = self
           listTableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
           listTableView.dragDelegate = self
           listTableView.dropDelegate = self
           listTableView.leading(to: view)
           listTableView.trailing(to: view)
           listTableView.topToBottom(of: listHeader)
//           listTableView.estimatedRowHeight = 0;
           listTableView.backgroundColor = .white
           listTableView.allowsSelection = false
           listTableView.separatorStyle = .none
           listTableView.estimatedRowHeight = 30
    }
    
    @objc func handleListExpandClose() {
        var indexPaths = [IndexPath]()
        for row in model.modelList.indices {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        isListsExpanded = !isListsExpanded
        groupTableView.removeFromSuperview()
        groupHeader.removeFromSuperview()
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
        for row in model2.modelList2.indices {
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
        print("search Tapped")
    }
    @objc func ellipsisTapped() {
        print("ellipsis Tapped")
    }
    
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == listTableView){
            if isListsExpanded {
                return model.modelList.count
            }
            return 0
        } else if (tableView == groupTableView) {
            if !model2.modelList2[section].isExpanded {
                return 0
            }
            return model2.modelList2[section].lists.count
        } else if tableView == topTableView {
            return 1
        } else {
            return 0
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
                print("got here")
                return 0
            }
            return model2.modelList2.count
        } else {
            return topList.count
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
            label.text = model2.modelList2[section].title
            
            let button = UIButton(type: .custom)
            groupHeader.addSubview(button)
            button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi), for: UIControl.State.normal)
            button.tag = section
            button.addTarget(self, action: #selector(groupExpandClose), for: UIControl.Event.touchDown)
            button.centerY(to: groupHeader)
            button.trailingAnchor.constraint(equalTo: groupHeader.trailingAnchor, constant: -20).isActive = true
        } else if tableView == listTableView {
            groupHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        } else if tableView == topTableView {
              groupHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        }
        return groupHeader
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if tableView == listTableView {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "listCell")
            cell.textLabel?.text = model.modelList[indexPath.row]
     
            
        } else if tableView == groupTableView {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "groupCell")
            cell.textLabel?.text = model2.modelList2[indexPath.section].lists[indexPath.row]
        } else if tableView == topTableView {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "topCell")
            cell.textLabel?.text = "zingo"
        }
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print(indexPath.section)
        pickUp = tableView
        if tableView == listTableView {
            return model.dragItems(for: indexPath)
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
            let stringItems = items as! [String]
            
            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                self.model.addItem(item, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    //      func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
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
        for row in model2.modelList2[section].lists.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        
        let isExpanded = model2.modelList2[section].isExpanded
        model2.modelList2[section].isExpanded = !isExpanded
        if isExpanded {
            groupTableView.deleteRows(at: indexPaths, with: .fade)
            button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi/2), for: UIControl.State.normal)
        } else {
            groupTableView.insertRows(at: indexPaths, with: .fade)
            button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi), for: UIControl.State.normal)
        }
    }
    
}
