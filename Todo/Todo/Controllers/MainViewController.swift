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
    var mainTableView = UITableView()
    var secondTableView = UITableView(frame: CGRect(), style: .plain)
    var pickUp = UITableView()
    var testArray = ["Fdafasd", "fdafas", "fdasf"]
    var isGroupsExpanded = true
    var isListsExpanded = true
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
    //MARK: - helper functions
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(mainTableView)
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        mainTableView.dragDelegate = self
        mainTableView.dropDelegate = self
        mainTableView.height(view.frame.height/2)
        mainTableView.leading(to: view)
        mainTableView.trailing(to: view)
        mainTableView.topToSuperview()
        mainTableView.backgroundColor = .white
        
        let groupHeader = UIView()
        groupHeader.backgroundColor = .white
        view.addSubview(groupHeader)
        groupHeader.leadingToSuperview()
        groupHeader.trailingToSuperview()
        groupHeader.topAnchor.constraint(equalTo: mainTableView.bottomAnchor,constant: 10).isActive = true
        groupHeader.height(30)
        let label = UILabel()
        view.addSubview(label)
        label.centerY(to: groupHeader)
        label.font = UIFont(name: "OpenSans-Regular", size: 20)
        label.textColor = .blue
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        let arw = UIImageView(image: UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 20, height: 20)))
        view.addSubview(arw)
        arw.image = arw.image?.rotate(radians: .pi/2)
        arw.centerY(to: groupHeader)
        arw.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        var tapGestureRecognizer: UITapGestureRecognizer
        label.text = "Groups"
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleExpandClose))
        arw.isUserInteractionEnabled = true
        arw.addGestureRecognizer(tapGestureRecognizer)
    
        
        view.addSubview(secondTableView)
        secondTableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupCell")
        secondTableView.dataSource = self
        secondTableView.delegate = self
        secondTableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        secondTableView.dragDelegate = self
        secondTableView.dropDelegate = self
        secondTableView.height(view.frame.height/3)
        secondTableView.leadingToSuperview()
        secondTableView.trailingToSuperview()
        secondTableView.topAnchor.constraint(equalTo: groupHeader.bottomAnchor).isActive = true
        secondTableView.backgroundColor = .white
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
    @objc func handleExpandClose() {
        print("Trying to expand and close section...")
        // we'll try to close the section first by deleting the rows
        var indexPaths = [IndexPath]()
        for row in model2.modelList2.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: 0)
            indexPaths.append(indexPath)
        }
        
        isGroupsExpanded = !isGroupsExpanded

//        button.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        if isGroupsExpanded {
            secondTableView.insertRows(at: indexPaths, with: .fade)
        } else {
            secondTableView.deleteRows(at: indexPaths, with: .fade)
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
        if(tableView == mainTableView){
            return model.modelList.count
        } else if (tableView == secondTableView) {
            if isGroupsExpanded == false {
                return 0
            }
            if !model2.modelList2[section].isExpanded {
                return 0
            }
            return model2.modelList2[section].lists.count
        } else {
            return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == mainTableView {
            return 1
        } else if tableView == secondTableView {
            return model2.modelList2.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let groupHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        if tableView == secondTableView {
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
            button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi/2), for: UIControl.State.normal)
            button.tag = section
            button.addTarget(self, action: #selector(groupExpandClose), for: UIControl.Event.touchDown)
            button.centerY(to: groupHeader)
            button.trailingAnchor.constraint(equalTo: groupHeader.trailingAnchor, constant: -20).isActive = true
        }
        return groupHeader
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if tableView == mainTableView {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "listCell")
            cell.textLabel?.text = model.modelList[indexPath.row]
        } else if tableView == secondTableView {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "groupCell")
            cell.textLabel?.text = model2.modelList2[indexPath.section].lists[indexPath.row]
        }
   
        return cell
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//    }
     func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        pickUp = tableView
        if tableView == mainTableView {
            return model.dragItems(for: indexPath)
        } else {
            return model2.dragItems(for: indexPath)
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
        if sourceIndexPath.section == destinationIndexPath.section {
            model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
        } else {
            return
        }

    }
    

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    @objc func groupExpandClose(button: UIButton) {
        print("Trying to expand and close section for grouplist...")
        
        let section = button.tag
        
        // we'll try to close the section first by deleting the rows
        var indexPaths = [IndexPath]()
        for row in model2.modelList2[section].lists.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
      
        let isExpanded = model2.modelList2[section].isExpanded
        model2.modelList2[section].isExpanded = !isExpanded
        if isExpanded {
            secondTableView.deleteRows(at: indexPaths, with: .fade)
              button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi), for: UIControl.State.normal)
        } else {
            secondTableView.insertRows(at: indexPaths, with: .fade)
              button.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi), for: UIControl.State.normal)
        }
    }
    @objc func tappedListArrow() {
        print("tappedListArrow")
    }
    @objc func tappedGroupArrow() {
        print("tappedGroupArrow")
    }
    
}
