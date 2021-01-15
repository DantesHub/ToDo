//
//  SCTableview.swift
//  Todo
//
//  Created by Dante Kim on 1/14/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
import StoreKit
extension SettingsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
        if section != 0 {
            header.layer.addBorder(edge: .bottom, color: .lightGray, thickness: 0.7)
            header.backgroundColor = .white
            let label = UILabel()
            header.addSubview(label)
            label.font = label.font.withSize(22)
            label.textColor = .systemBlue
            label.leading(to: header, offset: 20)
            label.bottom(to: header, offset: -15)
            label.text = section == 1 ? "General" : "Help & Feedbacks"
        } else {
            header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        }
  

        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            SKStoreReviewController.requestReview()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsCell
        if indexPath.section != 0  {
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 1)
        }
        cell.sectionNumber = indexPath.section
        cell.rowNum = indexPath.row
        cell.configureSide()
        return cell
    }
    
    
}
