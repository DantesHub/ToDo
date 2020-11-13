//
//  LCTableView.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
extension ListController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    func reloadTaskTableView(at: IndexPath, checked: Bool) {
        getRealmData()
        if checked {
            self.tableView.moveRow(at: at, to: IndexPath(item: tasksList.count - 1, section: 0))
            for idx in 0..<completedTasks.count {
                let cell = self.tableView.cellForRow(at: IndexPath(item: idx, section: 1)) as! TaskCell
                cell.path = IndexPath(item: idx, section: 1)
                cell.position = -1
                cell.completed = true
            }
            let cell = self.tableView.cellForRow(at: IndexPath(item: tasksList.count - 1, section: 0)) as! TaskCell
            cell.path = IndexPath(item: tasksList.count - 1, section: 0)
            cell.position = tasksList.count - 1
            cell.completed = true
        } else {
            self.tableView.moveRow(at: at, to: IndexPath(item: completedTasks.count - 1, section: 1))
            for idx in 0..<tasksList.count {
                let cell = self.tableView.cellForRow(at: IndexPath(item: idx, section: 0)) as! TaskCell
                cell.path = IndexPath(item: idx, section: 0)
                cell.position = idx
                cell.completed = false
            }
            let cell = self.tableView.cellForRow(at: IndexPath(item: completedTasks.count - 1, section: 1)) as! TaskCell
            cell.path = IndexPath(item: completedTasks.count - 1 , section: 1)
            cell.position = -1
            cell.completed = false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        let completedView = UIView()
        completedView.backgroundColor = .clear
        if section == 1 {
            let label = UIButton()
            label.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 18)
            label.titleLabel?.textColor = .white
            label.setTitle("Completed", for: .normal)
            label.setImage(UIImage(named: "arrow")?.rotate(radians: .pi)!.withTintColor(.white).resize(targetSize: CGSize(width: 18, height: 20)), for: .normal)
            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            completedView.addSubview(label)
            label.top(to: completedView, offset: 10)
            label.leadingAnchor.constraint(equalTo: completedView.leadingAnchor, constant: 5).isActive = true
            label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            label.width(tableView.frame.width * 0.35)
            label.height(30)
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
        if section == 1 {
            return 40
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "list") as! TaskCell
        var task = TaskObject()
        if indexPath.section == 0 {
            task = tasksList[indexPath.row]
        } else {
            task = completedTasks[indexPath.row]
        }
        cell.title.text = task.name
        cell.prioritized = task.priority
        
        if let index = task.planned.firstIndex(of: ",") {
            cell.plannedDate.text = String(task.planned[..<index])
        } else {
            cell.plannedDate.text = String(task.planned)
        }
        cell.path = indexPath
        cell.taskCellDelegate = self
        cell.favorited = task.favorited
        cell.reminderDate.text = task.reminder
        cell.completed = task.completed
        cell.repeatTask = true
        cell.position = task.position
        cell.parentList = task.parentList
        cell.configureBottomView()
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = CGFloat(4)
            cell.layer.borderColor = tableView.backgroundColor?.cgColor
        cell.contentView.layoutMargins.bottom = 25
        
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
        return 80; //Choose your custom row height
    }
}
