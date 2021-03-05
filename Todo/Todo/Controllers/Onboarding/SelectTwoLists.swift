//
//  SelectTwoLists.swift
//  Todo
//
//  Created by Dante Kim on 3/3/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
import AppsFlyerLib

class SelectTwoListsController: UIViewController, PremadeDelegate{
    //MARK: - instance variables
    var instructionsTitle: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "OpenSans-Bold", size: 20)
        label.textColor = .black
        label.text = "Let's Start by Selecting 2 Lists"
        return label
    }()
    
    var instructions: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "OpenSans", size: 20)
        label.textColor = .darkGray
        label.text = "These lists are pre-made to show you how to use the app"
        label.numberOfLines = 2
        return label
    }()
    var selectedLists = 0

    var skipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "OpenSans", size: 10)
        label.textColor = .blue
        label.text = "Skip"
        return label
    }()
    var continueButton = UIButton()
    var maximumLabel = UILabel()
    var premadeLists: [String] = []
    //MARK: - init
    override func viewDidLoad() {
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        view.addSubview(instructionsTitle)
        view.addSubview(instructions)
        
        
        instructionsTitle.centerX(to: view)
        instructions.centerX(to: view)
        
        instructionsTitle.topToSuperview(offset: view.frame.height * 0.10)
        instructions.topToBottom(of: instructionsTitle)
        
        instructionsTitle.width(view.frame.width * 0.85)
        instructions.width(view.frame.width * 0.85)
        
        let shopping = PremadeView()
        shopping.label.text = "🥕 Shopping List"
        view.addSubview(shopping)
        shopping.leading(to: view, offset: view.frame.width * 0.07)
        shopping.topToBottom(of: instructions, offset: 35)
        shopping.width(view.frame.width * 0.405)
        shopping.height(view.frame.height * 0.10)
        shopping.delegate = self
        
        let watching = PremadeView()
        watching.label.text = "🍿 Watching List"
        view.addSubview(watching)
        watching.leadingToTrailing(of: shopping, offset: view.frame.width * 0.05)
        watching.topToBottom(of: instructions, offset: 35)
        watching.width(view.frame.width * 0.405)
        watching.height(view.frame.height * 0.10)
        watching.delegate = self
        
        let homework = PremadeView()
        homework.label.text = "📚 Homework"
        view.addSubview(homework)
        homework.leading(to: view, offset: view.frame.width * 0.07)
        homework.topToBottom(of: shopping, offset: 15)
        homework.width(view.frame.width * 0.405)
        homework.height(view.frame.height * 0.10)
        homework.delegate = self
        
        let workout = PremadeView()
        workout.label.text = "🏃‍♂️ Workout"
        view.addSubview(workout)
        workout.leadingToTrailing(of: homework, offset: view.frame.width * 0.05)
        workout.topToBottom(of: watching, offset: 15)
        workout.width(view.frame.width * 0.405)
        workout.height(view.frame.height * 0.10)
        workout.delegate = self
        
        let wish = PremadeView()
        wish.label.text = "❤️ Wish List"
        view.addSubview(wish)
        wish.leading(to: view, offset: view.frame.width * 0.07)
        wish.topToBottom(of: workout, offset: 15)
        wish.width(view.frame.width * 0.405)
        wish.height(view.frame.height * 0.10)
        wish.delegate = self
        
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
        
        view.addSubview(skipLabel)
        let skipGest = UITapGestureRecognizer(target: self, action: #selector(tappedSkip))
        skipLabel.addGestureRecognizer(skipGest)
        skipLabel.adjustsFontSizeToFitWidth = true
        skipLabel.centerX(to: view)
        skipLabel.isUserInteractionEnabled = true
        skipLabel.topToBottom(of: continueButton, offset: 20)
        skipLabel.width(view.frame.width * 0.10)
        skipLabel.addGestureRecognizer(skipGest)
                
    }
    //MARK: - helper functions
    func createMaximum() {
        view.addSubview(maximumLabel)
        maximumLabel.font = UIFont(name: "OpenSans",size: 8)
        maximumLabel.text = "You can select 2 lists max for this tutorial"
        maximumLabel.adjustsFontSizeToFitWidth = true
        maximumLabel.textColor = .red
        maximumLabel.centerX(to: view)
        maximumLabel.width(view.frame.width * 0.70)
        maximumLabel.bottomToTop(of: continueButton, offset: -10)
    }
    func updateSelectNumber(add: Bool, premadeList: String) {
        if add {
            premadeLists.append(premadeList)
            selectedLists += 1
        } else {
            selectedLists -= 1
            premadeLists.removeAll { (str) -> Bool in
                str == premadeList
            }
        }
        if selectedLists > 2 {
            createMaximum()
        } else {
            if self.maximumLabel.isDescendant(of: view) {
                maximumLabel.removeFromSuperview()
            }
        }
        print(premadeLists)
    }
    
    @objc func tappedSkip() {
        AppsFlyerLib.shared().logEvent(name: "Sub_From_Onboarding", values: [AFEventParamContent: "true"])
        AppsFlyerLib.shared().logEvent(name: "Onboarding_Step2_Skip_Clicked", values: [AFEventParamContent: "true"])
        let controller = SubscriptionController()
        controller.onboarding = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func tappedContinue() {
        if selectedLists <= 2 && selectedLists >= 1 {
            AppsFlyerLib.shared().logEvent(name: "Sub_From_Onboarding", values: [AFEventParamContent: "true"])
            AppsFlyerLib.shared().logEvent(name: "Onboarding_Step2_Continue_Clicked", values: [AFEventParamContent: "true"])
            let controller = SubscriptionController()
            controller.onboarding = true
            self.navigationController?.pushViewController(controller, animated: true)
 
            
            for (idx,lst) in premadeLists.enumerated() {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd,yyyy-h:mm a"
                let components =  lst.split(separator: " ", maxSplits: 1).map(String.init)
                let newTitle = components[1] + " " + components[0]
                let newList = ListObject()
                newList.name = newTitle
                newList.position = idx
                newList.backgroundColor = "blue"
                
                let task1 = TaskObject()
                task1.id = UUID().uuidString
                task1.priority = 1
                task1.position = 0
                task1.createdAt = formatter.string(from: Date())
                task1.name = "Click here 🎯 to edit task"
                task1.planned = "Sep 08,2021 3:18 PM"
                task1.completed = false
                task1.selectedCell = false
                task1.parentList = newTitle
                let step = Step()
                step.done = false
                step.stepName = "Step 1"
                task1.steps.append(step)
                
                let task2 = TaskObject()
                task2.id = UUID().uuidString
                task2.createdAt = formatter.string(from: Date())
                task2.parentList = newTitle
                task2.completed = true
                task2.position = -1
                task2.name = "This task is completed 💯"
                try! uiRealm.write {
                    uiRealm.add(task1)
                    uiRealm.add(task2)
                    uiRealm.add(newList)
                }
            }

     
        } 
    }
}


