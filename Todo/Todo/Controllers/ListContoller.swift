//
//  TestViewController.swift
//  Todo
//
//  Created by Dante Kim on 10/2/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import Layoutless
import TinyConstraints
class ListController: UIViewController {
    var creating = false;
    let bigTextField = UITextField()
    let titleLabel = UILabel()
    let tableView = UITableView(frame: .zero, style: .grouped)
    var tableHeader = UIView()
    var lastKnowContentOfsset: CGFloat = 0
    var scrolledUp = false
    var tableViewTop : NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = .white
        configureUI()
        createTableHeader()
    }
    var scrollHeight: CGFloat = 100
    override func viewDidLayoutSubviews() {
        tableView.delegate = self
    }
    
    func configureUI() {
        createTableHeader()
        createTableView()
    }
    func createTableHeader() {
        let headerView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        view.addSubview(headerView)
        if creating {
            headerView.addSubview(bigTextField)
            bigTextField.becomeFirstResponder()
            bigTextField.font = UIFont(name: "OpenSans-Regular", size: 40)
            
            bigTextField.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
            bigTextField.centerY(to: headerView)
            bigTextField.height(100)
            bigTextField.placeholder = "Untitled List"
            bigTextField.textColor = .black
            bigTextField.text = "Fasfsa"
        }
        self.tableView.tableHeaderView = headerView
    }
    func createTableView(top: CGFloat = -10) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "list")
        tableView.dataSource = self
        tableView.separatorStyle = .none
   
        view.addSubview(tableView)
        tableView.leadingToSuperview()
        tableView.trailingToSuperview()
        tableView.bottomToSuperview()
        tableViewTop = tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: top)
        tableViewTop?.isActive = true
        tableView.tableHeaderView = tableHeader
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.tableView.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
          swipeUp.direction = .up
          self.tableView.addGestureRecognizer(swipeUp)
        tableView.isUserInteractionEnabled = true
        swipeUp.delegate = self
        swipeDown.delegate = self
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
                self.tableView.tableHeaderView?.isHidden = false
                tableViewTop?.constant = -10
            case .left:
                print("Swiped left")
            case .up:
                self.tableView.tableHeaderView?.isHidden = true
                tableViewTop?.constant = -70
            default:
                break
            }
        }
    }
    
    func configureNavBar() {
          titleLabel.textColor = UIColor.white
          titleLabel.text = ""
          titleLabel.font = UIFont(name: "OpenSans-Regular", size: 18)
          self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
          titleLabel.textColor = .blue
          navigationController?.navigationBar.barTintColor = .white
      }
    
    
}

extension ListController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "list")
        cell.textLabel?.text = "ghibli"
        cell.selectionStyle = .none
        cell.backgroundColor = .red
        return cell
    }
    
}
