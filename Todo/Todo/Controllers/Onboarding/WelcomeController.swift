//
//  WelcomeController.swift
//  Todo
//
//  Created by Dante Kim on 3/3/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
import AppsFlyerLib
class WelcomeController: UIViewController {
    //MARK: - instance variables
    var mainImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "welcomeWoman")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var welcomeTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "OpenSans-Bold", size: 30)
        return label
    }()
    
    lazy var subtitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "OpenSans", size: 20)
        label.textColor = .darkGray
        label.text = "Build very efficient and customizable lists of tasks and checklists"
        return label
    }()
    
    var continueButton = UIButton()
    //MARK: - init
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        view.backgroundColor = .white
        
        view.addSubview(mainImage)
        mainImage.centerXToSuperview()
        mainImage.centerY(to: view, offset: -view.frame.height * 0.13)
        mainImage.width(view.frame.width * 0.70)
        mainImage.height(view.frame.height * 30)
        
        view.addSubview(welcomeTitle)
        welcomeTitle.text = "Welcome to To Do List"
        welcomeTitle.adjustsFontSizeToFitWidth = true
        welcomeTitle.centerX(to: view)
        welcomeTitle.centerY(to: view, offset: view.frame.height * 0.10)
        welcomeTitle.width(view.frame.width * 0.80)
        welcomeTitle.height(50)
        
        view.addSubview(subtitle)
        subtitle.centerX(to: view)
        subtitle.adjustsFontSizeToFitWidth = true
        subtitle.width(view.frame.width * 0.80)
        subtitle.numberOfLines = 2
        subtitle.textAlignment = .center
        subtitle.topToBottom(of: welcomeTitle, offset: 10)
        
        view.addSubview(continueButton)
        continueButton.centerX(to: view)
        continueButton.width(view.frame.width * 0.80)
        continueButton.bottom(to: view, offset: -view.frame.height * 0.11)
        continueButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        continueButton.height(self.view.frame.height * 0.08)
        continueButton.setTitle("CONTINUE", for: .normal)
        continueButton.backgroundColor = lightPurple
        continueButton.layer.cornerRadius = 15
        continueButton.addTarget(self, action: #selector(tappedContinue), for: .touchUpInside)
    }
    
    //MARK: - helper functions
    @objc func tappedContinue() {
        AppsFlyerLib.shared().logEvent(name: "Onboarding_Step1_Continue_Clicked", values: [AFEventParamContent: "true"])
        self.navigationController?.pushViewController(SelectTwoListsController(), animated: true)
    }
}
