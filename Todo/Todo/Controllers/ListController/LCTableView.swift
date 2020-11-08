//
//  LCTableView.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
extension ListController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "list") as! TaskCell
        cell.title.text = tasksList[indexPath.row].name
        cell.prioritized = tasksList[indexPath.row].priority
        if let index = tasksList[indexPath.row].planned.firstIndex(of: ",") {
            cell.plannedDate.text = String(tasksList[indexPath.row].planned[..<index])
        } else {
            cell.plannedDate.text = String(tasksList[indexPath.row].planned)
        }
        cell.reminderDate.text = tasksList[indexPath.row].reminder
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
