//
//  LCTableView.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
extension ListController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    func reloadTaskTableView(at: IndexPath, checked: Bool, repeats: String = "") {
        if checked {
            let task = completedTasks.remove(at: at.row)
            tasksList.append(task)
            self.tableView.performBatchUpdates({
                self.tableView.moveRow(at: at, to: IndexPath(item: tasksList.count - 1, section: 0))
            }, completion: { [self] finished in
                self.tableView.reloadData()
            })
        } else {
            let cell = tableView.cellForRow(at: at) as! TaskCell
            var removedTask = TaskObject()
            for (idx,task) in tasksList.enumerated() {
                if cell.id == task.id {
                    removedTask = tasksList.remove(at: idx)
                }
            }
            completedTasks.insert(removedTask, at: 0)
            self.tableView.performBatchUpdates({
                self.tableView.moveRow(at: at, to: IndexPath(item: 0, section: 1))
            }, completion: {  finished in
                self.tableView.reloadData { [self] in
                    if repeats != "" {
                       reloadTaskTableView(at: IndexPath(row: 0, section: 1), checked: true)
//                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func reloadTable() {
        getRealmData()
        tableView.reloadData()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
           return true
       }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
           return true
       }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tasksList.count
        } else {
            if completedExpanded == true {
                return completedTasks.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let completedView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "completedHeader")
        completedView!.backgroundColor = .clear
        if section == 1 && completedTasks.count != 0 {
            let label = UIButton()
            label.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 18)
            label.titleLabel?.textColor = .white
            label.setTitle("Completed", for: .normal)
            label.setImage(UIImage(named: "arrow")?.rotate(radians: .pi)!.withTintColor(.white).resize(targetSize: CGSize(width: 18, height: 20)), for: .normal)
            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            completedView!.addSubview(label)
            label.top(to: completedView!, offset: 10)
            label.leadingAnchor.constraint(equalTo: completedView!.leadingAnchor, constant: 5).isActive = true
            label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            label.width(tableView.frame.width * 0.35)
            label.height(25)
            label.layer.cornerRadius = 10
            label.addTarget(self, action: #selector(tappedCompleted), for: .touchUpInside)
        }
        
        return completedView
    }
    
    
    @objc func tappedCompleted(button: UIButton) {
        if completedExpanded {
            button.setImage(UIImage(named: "arrow")?.withTintColor(.white).resize(targetSize: CGSize(width: 18, height: 20)), for: .normal)
        } else {
            button.setImage(UIImage(named: "arrow")?.withTintColor(.white).resize(targetSize: CGSize(width: 18, height: 20)).rotate(radians: .pi), for: .normal)
        }
        var indexPaths = [IndexPath]()
        for row in completedTasks.indices {
            indexPaths.append(IndexPath(row: row, section: 1))
        }
        completedExpanded = !completedExpanded
        if completedExpanded {
            tableView.insertRows(at: indexPaths, with: .fade)
            tableView.invalidateIntrinsicContentSize()
        } else {
            tableView.deleteRows(at: indexPaths, with: .fade)
            tableView.invalidateIntrinsicContentSize()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && completedTasks.count != 0  {
            return 40
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TaskCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "list")
        var task = TaskObject()
        if indexPath.section == 0 {
            task = tasksList[indexPath.row]
        } else {
            task = completedTasks[indexPath.row]
        }
        cell.allSteps = task.steps.map { $0 }
        cell.title.text = task.name
        cell.prioritized = task.priority
        cell.taskPlannedDate = task.planned
        cell.path = indexPath
        cell.taskCellDelegate = self
        cell.favorited = task.favorited
        cell.reminderDate.text = task.reminder
        cell.completed = task.completed
        cell.repeatTask = task.repeated
        cell.id = task.id
        cell.position = task.position
        cell.parentList = task.parentList
        cell.configureBottomView()
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.navigationController = (self.navigationController)!
        cell.layer.cornerRadius = 10
        cell.isUserInteractionEnabled = true
        return cell
    }
    
    private func tableView(tableView: UITableView,
                 willDisplayCell cell: UITableViewCell,
          forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90; //Choose your custom row height
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath { return }
        let results = uiRealm.objects(TaskObject.self)
        tasksList = []
        try! uiRealm.write {
            for result in results {
                if result.parentList == listTitle && result.completed == false {
                    let pos = result.position
                    if (sourceIndexPath[1] < pos && destinationIndexPath[1] < pos) || (sourceIndexPath[1] > pos && destinationIndexPath[1]  > pos) {
                        } else if pos == destinationIndexPath[1] {
                            if sourceIndexPath[1] > destinationIndexPath[1]  {
                                result.position += 1
                            } else {
                                result.position -= 1
                            }
                        } else if pos == sourceIndexPath[1] {
                            result.position = destinationIndexPath[1]
                        } else if sourceIndexPath[1] > pos {
                            result.position += 1
                        } else if pos < destinationIndexPath[1]   {
                            result.position -= 1
                        }
                    tasksList.append(result)
                }
            }
        }
        tasksList.sort { (one, two) -> Bool in
            one.position < two.position
        }
        tableView.reloadData()
//         for (idx,_) in tasksList.enumerated() {
//            let cell = self.tableView.cellForRow(at: IndexPath(item: idx, section: 0)) as! TaskCell
//            for task in tasksList {
//                if cell.title.text == task.name && cell.id == task.id {
//                    cell.path = IndexPath(item: task.position, section: 0)
//                    cell.position = task.position
//                    cell.completed = false
//                }
//            }
//         }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        if editingStyle == .delete {
            let tasks = uiRealm.objects(TaskObject.self)
            var delIdx = 0
            var completedd = false
            for task in  tasks {
                if task.id == cell.id {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
                    for step in task.steps {
                        try! uiRealm.write {
                            uiRealm.delete(step)
                        }
                    }
                }
                if indexPath.section == 0 && task.parentList == listTitle && task.id == cell.id && task.name == cell.title.text {
                    tasksList.removeAll(where: {$0.id == task.id})
                    delIdx = task.position
                    try! uiRealm.write {
                        uiRealm.delete(task)
                    }
                } else if (indexPath.section == 1 && task.parentList == listTitle && task.id == cell.id && cell.title.text == task.name) {
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
            
            if completedd {
                tableView.deleteRows(at: [indexPath], with: .fade)
                for idx in 0..<completedTasks.count {
                        let cell = self.tableView.cellForRow(at: IndexPath(item: idx, section: 1)) as! TaskCell
                        cell.path = IndexPath(item: idx, section: 1)
                        cell.position = -1
                        cell.completed = true
                }
            } else {
                for idx in 0..<tasksList.count {
                    if idx > delIdx {
                        let cell = self.tableView.cellForRow(at: IndexPath(item: idx, section: 0)) as! TaskCell
                        cell.path = IndexPath(item: idx - 1, section: 0)
                        cell.position = idx - 1
                        cell.completed = false
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
           
        }
    }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        let cell = tableView.cellForRow(at: indexPath!) as! TaskCell
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 10
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            pickUpSection = indexPath.section
            return tasksList.dragItems(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                if pickUpSection == 1 || listTitle == "Planned" || listTitle == "All Tasks" || listTitle == "Important" || destinationIndexPath?.section == 1{
                    return UITableViewDropProposal(operation: .cancel)
                }
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
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
            let stringItems = items as! [TaskObject]
            
            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                tasksList.addItem(item, at: indexPath.row)
                indexPaths.append(indexPath)
            }

            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
}
