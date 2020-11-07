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
        cell.textLabel?.text = tasksList[indexPath.row].name
        cell.selectionStyle = .none
        cell.backgroundColor = .blue
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = false
        return cell
    }
    private func tableView(tableView: UITableView,
                 willDisplayCell cell: UITableViewCell,
          forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
