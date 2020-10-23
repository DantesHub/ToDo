//
//  AddTaskController.swift
//  Todo
//
//  Created by Dante Kim on 10/23/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

class TaskController: UIViewController {
    //MARK: - instance variables
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Helper functions
    func configureUI() {
        self.view.backgroundColor = .red
    }
}
