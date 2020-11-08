//
//  MainTableViews.swift
//  Todo
//
//  Created by Dante Kim on 10/23/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//
import UIKit
import RealmSwift
import TinyConstraints
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
        label.text = groups[section].name
        
        let arw = UIButton(type: .custom)
        groupHeader.addSubview(arw)
        
        arw.tag = section
        arw.addTarget(self, action: #selector(groupExpandClose), for: UIControl.Event.touchDown)
        arw.centerY(to: groupHeader)
        arw.trailingAnchor.constraint(equalTo: groupHeader.trailingAnchor, constant: -20).isActive = true
        
        if groups[section].isExpanded {
            arw.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi), for: UIControl.State.normal)
        } else {
             arw.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 15, height: 15)).rotate(radians: .pi/2), for: UIControl.State.normal)
        }
        
        let elips = UIButton(type: .custom)
        elips.accessibilityIdentifier = groups[section].name
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! MainMenuCell
        cell.cellImage.image = UIImage(named: "star")?.resize(targetSize: CGSize(width: 25, height: 25))
        cell.cellTitle.text = lists[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    } else if tableView == groupTableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        cell.cellTitle.text = groups[indexPath.section].lists[indexPath.row].name
        cell.cellImage.image = UIImage(named: topList[indexPath.row].imgName)?.resize(targetSize: CGSize(width: 22, height: 22))
        cell.selectionStyle = .none
        return cell
    } else {//topTableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "topCell", for: indexPath) as! MainMenuCell
        if indexPath.row == 0 {
            cell.cellImage.image = UIImage(named: topList[indexPath.row].imgName)?.resize(targetSize: CGSize(width: 25, height: 25))
        } else {
            cell.cellImage.image = UIImage(named: topList[indexPath.row].imgName)?.resize(targetSize: CGSize(width: 30, height: 30))
        }
        cell.cellTitle.text = topList[indexPath.row].title
        cell.selectionStyle = .none
        return cell
    }
    
}
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == topTableView {
        let controller = ListController()
        controller.reloadDelegate = self
        controller.creating = false;
        premadeListTapped = true
        controller.listTitle = topList[indexPath.row].title
        controller.navigationController?.isNavigationBarHidden = false
        self.navigationController?.view.layer.add(CATransition().popFromRight(), forKey: nil)
        self.navigationController?.pushViewController(controller, animated: false)
    } else if tableView == listTableView {
        let controller = ListController()
        controller.reloadDelegate = self
        controller.creating = false;
        premadeListTapped = false
        controller.listTitle = lists[indexPath.row].name
        controller.navigationController?.isNavigationBarHidden = false
        self.navigationController?.view.layer.add(CATransition().popFromRight(), forKey: nil)
        self.navigationController?.pushViewController(controller, animated: false)
    }
}


func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    pickUp = tableView
    pickUpSection = indexPath.section
    if tableView == listTableView {
        return lists.dragItems(for: indexPath)
    } else {
        selectedGroupName = groups[indexPath.section].name
        return groups.dragSections(for: indexPath.section)
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
            } else if pickUpSection != destinationIndexPath?.section {
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

//deleting lists and groups
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let listName = lists[indexPath.row].name
    if tableView == listTableView {
        if editingStyle == .delete {
            lists.remove(at: indexPath.row)
            listTableView.deleteRows(at: [indexPath], with: .fade)
            let lists = uiRealm.objects(ListObject.self)
            let positions = uiRealm.objects(GroupPosition.self)
            var deletedPozs: [(pos: Int, name: String)] = []
            try! uiRealm.write {
                var deletedIndex = 0
                for (idx,list) in lists.enumerated() {
                    if list.name == listName{
                        deletedIndex = idx
                        //delete group positions for deleted list
                        for poz in list.groupPositions {
                            for poz2 in positions {
                                if poz.groupName == poz2.groupName && poz.groupPosition == poz2.groupPosition {
                                    deletedPozs.append((poz2.groupPosition, poz2.groupName))
                                    uiRealm.delete(poz2)
                                    break
                                }
                            }
                        }
                        uiRealm.delete(list)
                        break
                    }
                }
                //update group positions in group positions realm
                for pos in positions {
                    for deletedPos in deletedPozs {
                        if deletedPos.name == pos.groupName && pos.groupPosition > deletedPos.pos {
                            pos.groupPosition -= 1
                        }
                    }
                }
                //update list positions in realm
                for list in lists {
                    if list.position > deletedIndex {
                        list.position -= 1
                    }
                }
            }
        }
        getRealmData()
        groupTableView.reloadData()
    } else if tableView == groupTableView {
        let selectedGroupName = groups[indexPath.section].name
        let selectedListName = groups[indexPath.section].lists[indexPath.row].name
        if editingStyle == .delete {
                        groups[indexPath.section].lists.remove(at: indexPath.row)
                       groupTableView.deleteRows(at: [indexPath], with: .fade)
            let groups = uiRealm.objects(ListGroup.self)
            let groupPositions = uiRealm.objects(GroupPosition.self)
            try! uiRealm.write {
                for group in groups {
                    if group.name == selectedGroupName {
                        for (idx, lst) in group.lists.enumerated() {
                            if lst.name == selectedListName { //remove selected list idx
                                var i = 0
                                group.lists.forEach{
                                    for poz in $0.groupPositions {
                                        if poz.groupPosition == idx
                                            && poz.groupName == selectedGroupName {
                                            group.lists.remove(at: i)
                                        }
                                    }
                                    i += 1
                                }
                                print(idx)
                                for position in groupPositions {
                                    if position.groupPosition == idx && position.groupName == selectedGroupName {
                                        uiRealm.delete(position)
                                    }
                                }
                                for listInGroup in group.lists {
                                    for groupPosition in listInGroup.groupPositions {
                                        if groupPosition.groupPosition > idx && groupPosition.groupName == selectedGroupName {
                                            groupPosition.groupPosition -= 1
                                        }
                                    }
                                }
                            }
                           
                        }
                    }
                }
            }
        }
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

func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    if tableView == listTableView {
        lists.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
    } else if tableView == groupTableView {
        let results = uiRealm.objects(ListObject.self)
        //updating list positions within groups
        for result in results {
            //traverse through all groups the list is part of
            for position in result.groupPositions {
                if position.groupName == selectedGroupName {
                    if position.groupPosition == sourceIndexPath[1] {
                        try! uiRealm.write {
                            position.groupPosition = destinationIndexPath[1]
                        }
                    } else if position.groupPosition == destinationIndexPath[1] {
                        try! uiRealm.write {
                            position.groupPosition = sourceIndexPath[1]
                        }
                    }
                }
            }
        }

    }
}


func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if tableView == groupTableView {
        return 40
    } else {
        return 0
    }
}
        @objc func groupExpandClose(button: UIButton) {
            print("expanding")
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

