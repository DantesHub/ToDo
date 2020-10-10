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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = .white
//        configureNavBar()
        configureUI()
    }
    let label = UILabel()
    func configureUI() {
        if creating {
            view.addSubview(bigTextField)
               bigTextField.font = UIFont(name: "OpenSans-Regular", size: 40)
            bigTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20).isActive = true
               bigTextField.leadingToSuperview()
               bigTextField.trailingToSuperview()
               bigTextField.height(100)
               bigTextField.placeholder = "Untitled List"
               bigTextField.textColor = .black
               bigTextField.text = "Fasfsa"
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
