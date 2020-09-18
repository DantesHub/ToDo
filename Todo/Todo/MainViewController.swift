//
//  ViewController.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    //MARK: - instace variables
    
    //MARK: - instantiate
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureUI()
    }
    
    
    //MARK: - helper functions
    func configureUI() {
        view.backgroundColor = .blue
    }
    func configureNavBar() {
        // Make the navigation bar's title with red text.
        self.navigationController!.navigationBar.barStyle = .black
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }

}

