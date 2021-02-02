//
//  SettingsController.swift
//  Todo
//
//  Created by Dante Kim on 1/14/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
import StoreKit

class SettingsController: UIViewController, SKPaymentTransactionObserver {
    //MARK: - instance variables
    let tableView = UITableView()
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        SKPaymentQueue.default().add(self)
        configureUI()
    }
    
    //MARK: - helper functions
    func configureUI() {
        configureNavbar()
        view.backgroundColor = .red
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "settingsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.leadingToSuperview()
        tableView.topToSuperview()
        tableView.bottomToSuperview()
        tableView.trailingToSuperview()
        tableView.backgroundColor = .white
    }
    
    func configureNavbar() {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Settings"
        label.font = UIFont(name: "OpenSans-Regular", size: 22)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        label.textColor = .systemBlue
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(tappedDone))
        navigationItem.rightBarButtonItem = done
    }
    
    @objc func tappedDone() {
        self.navigationController?.popViewController(animated: true)
    }
}
 
