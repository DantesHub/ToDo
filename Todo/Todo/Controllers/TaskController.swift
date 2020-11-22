//
//  AddTaskController.swift
//  Todo
//
//  Created by Dante Kim on 10/23/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import RealmSwift
import TinyConstraints
class TaskController: UIViewController {
    //MARK: - instance variables
    var plannedDate = ""
    var completed = false
    var reminderDate = ""
    var taskTitle = ""
    var favorited = false
    let titleTextField = UITextField()
    let addStepField = UITextField()
    let noteTextField = PaddedTextField()
    let tableView = UITableView(frame: .zero, style: .grouped)
    let stepsTableView = SelfSizedTableView()
    var tableViewTop : NSLayoutConstraint?
    var steps = [Step]()
    var parentList = ""
    var heightConstraint: NSLayoutConstraint?
    let circle = RoundView()
    let star = UIImageView()

    let check: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 35, height: 35)).withTintColor(.red)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    var path = IndexPath()
    let headerTitle = UILabel()
    var id = ""
    let stackView = UIStackView()
    var delegate: TaskViewDelegate?
    lazy var scrollView: UIScrollView = {
       let view = UIScrollView()
       view.showsVerticalScrollIndicator = false
       return view
    }()
    var defaultList = ["Add to a List", "Remind Me", "Add Due Date", "Repeat", "Add File"]
    var footer = UIView()
    let results = uiRealm.objects(TaskObject.self)
    var stepsFooterView = UIView()
    let plus = UIImageView(image: UIImage(named: "plus")?.resize(targetSize: CGSize(width: 45, height: 45)).withTintColor(.blue))
    let addStepLabel = UILabel()
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Helper functions
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -90).isActive = true
        scrollView.topToSuperview()
        
        self.scrollView.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.axis = .vertical
        self.stackView.spacing = 10;
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true;
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true;
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true;
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true;
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true;
        
       createStepsTable()
        createTableView()
       createNoteTextField()
        createFooter()
    }
    func createTableView() {
        self.stackView.addArrangedSubview(tableView)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskOptionCell.self, forCellReuseIdentifier: "taskOptionCell")
        tableView.isScrollEnabled = false
        tableView.height(320)
        tableView.backgroundColor = .red
    }
    
    func createNoteTextField() {
        self.stackView.addArrangedSubview(noteTextField)
        noteTextField.height(UIScreen.main.bounds.height/6)
        noteTextField.backgroundColor = .white
        noteTextField.placeholder = "Add Note"
        noteTextField.font = UIFont(name: "OpenSans-Regular", size: 20)
        let hr = UIView()
        self.view.addSubview(hr)
        hr.topToBottom(of: noteTextField)
        hr.leadingToSuperview(offset: 25)
        hr.trailingToSuperview(offset: 25)
        hr.height(0.5)
        hr.backgroundColor = .lightGray
        noteTextField.delegate = self
    }
    func createStepsTable() {
        self.stackView.addArrangedSubview(stepsTableView)
        stepsTableView.register(StepCell.self, forCellReuseIdentifier: "stepCell")
        stepsTableView.delegate = self
        heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: 130)
        heightConstraint?.isActive = true
        stepsTableView.dataSource = self
        stepsTableView.backgroundColor = .white
        stepsTableView.estimatedRowHeight = 60
        stepsTableView.separatorStyle = .none
    }

    
    @objc func addStep() {
        plus.removeFromSuperview()
        let circle = RoundView()
        circle.width(25)
        circle.height(25)
        circle.backgroundColor = .white
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.darkGray.cgColor
        stepsFooterView.addSubview(circle)
        circle.leading(to: stepsFooterView, offset: 30)
        circle.top(to: stepsFooterView)
        
        addStepLabel.removeFromSuperview()
        stepsFooterView.addSubview(addStepField)
        addStepField.delegate = self
        addStepField.top(to: stepsFooterView, offset: 3)
        addStepField.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 15).isActive = true
        addStepField.becomeFirstResponder()
    }
    
    @objc func tappedStar() {
        for result in results {
            if result.id == id {
                let isFavorited = result.favorited
                try! uiRealm.write {
                    result.favorited = !isFavorited
                }
                star.image = UIImage(named: result.favorited ? "starfilled" : "star")?.resize(targetSize: CGSize(width: 30, height: 30))
            }
        }
        delegate?.reloadTable()
    }
    
    @objc func tappedCheck() {
        check.removeFromSuperview()
        var totalTasks = 0
        for task in results {
            if task.completed == false && task.parentList == parentList {
                totalTasks += 1
            }
        }
        
        for result in results {
            if result.id == id {
                try! uiRealm.write {
                    result.completed = false
                    result.position = totalTasks
                }
            }
        }
        let titleText = taskTitle
        headerTitle.attributedText = .none
        headerTitle.text = titleText
        delegate?.reloadTaskTableView(at: path, checked: true, reload: true)
    }
    
    @objc func tappedCircle() {
        configureCircle()
        var delTaskPosition = 0
        for result in results {
            if result.id == id {
                try! uiRealm.write {
                    result.completed = true
                    delTaskPosition = result.position
                    result.position = -1
                }
            }
        }
        for task in results {
            if task.parentList == parentList && task.completed == false && task.position > delTaskPosition {
                try! uiRealm.write {
                    task.position -= 1
                }
            }
        }
       
        
        delegate?.reloadTaskTableView(at: path, checked: false, reload: true)
    }
    
    func configureCircle() {
        circle.addSubview(check)
        check.width(35)
        check.height(35)
        check.leadingAnchor.constraint(equalTo: circle.leadingAnchor).isActive = true
        let checkGest = UITapGestureRecognizer(target: self, action: #selector(tappedCheck))
        check.addGestureRecognizer(checkGest)
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskTitle)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        headerTitle.attributedText = attributeString
    }
    
    func createFooter() {
        view.insertSubview(footer, at: 1000)
        footer.leadingToSuperview()
        
        footer.trailingToSuperview()
        footer.bottomToSuperview()
        footer.height(75)
        footer.backgroundColor = .white
        
        
        let createdLabel = UILabel()
        createdLabel.font = UIFont(name: "OpenSans-Regular", size: 18)
        createdLabel.textColor = .gray
        createdLabel.text = "Completed on Nov 19, 2020"
        footer.addSubview(createdLabel)
        createdLabel.center(in: footer)
    }
}
extension TaskController:  UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("over here")
        if textField == addStepField {
            if textField.text! != "" {
                
                for result in results {
                    if result.id == id {
                        try! uiRealm.write {
                            let step = Step()
                            step.stepName = textField.text!
                            step.done = false
//                            noteTextField.removeFromSuperview()
//                            tableView.removeFromSuperview()
                        
                            self.steps.append(step)
                            heightConstraint?.isActive = false
                            heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: CGFloat(130 + (60 * steps.count)))
                            heightConstraint?.isActive = true
                            self.stepsTableView.reloadData()
                            result.steps.append(step)
                        }
                    }
                }
            }
        }
        
       
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension TaskController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stepsTableView {
            return steps.count
        } else {
            return 5
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == stepsTableView {
            let stepsHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 80))
            stepsHeaderView.backgroundColor = .white
            circle.width(35)
            circle.height(35)
            circle.backgroundColor = .white
            circle.layer.borderWidth = 2
            circle.layer.borderColor = UIColor.darkGray.cgColor
            stepsHeaderView.addSubview(circle)
            circle.leading(to: stepsHeaderView, offset: 25)
            circle.centerY(to: stepsHeaderView)
            let circleTapped = UITapGestureRecognizer(target: self, action: #selector(tappedCircle))
            circle.addGestureRecognizer(circleTapped)
            circle.isUserInteractionEnabled = true
            
            if completed {
                configureCircle()
            }
            
            headerTitle.font = UIFont(name: "OpenSans-Bold", size: 25)
            headerTitle.text = taskTitle
            stepsHeaderView.addSubview(headerTitle)
            headerTitle.leadingToTrailing(of: circle, offset: 25)
            headerTitle.centerY(to: stepsHeaderView)
            
            star.image = UIImage(named: favorited ? "starfilled" : "star")?.resize(targetSize: CGSize(width: 30, height: 30))
            stepsHeaderView.addSubview(star)
            star.centerY(to: stepsHeaderView)
            star.trailing(to: stepsHeaderView, offset: -25)
            let starTapped = UITapGestureRecognizer(target: self, action: #selector(tappedStar))
            star.addGestureRecognizer(starTapped)
            star.isUserInteractionEnabled = true
            return stepsHeaderView
        } else {
            return UIView(frame: .zero)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == stepsTableView {
            stepsFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            stepsFooterView.addSubview(plus)
            plus.leading(to: stepsFooterView, offset: 20)
            plus.top(to: stepsFooterView, offset: -7)
            addStepLabel.font = UIFont(name: "OpenSans-Regular", size: 20)
            addStepLabel.textColor = .blue
            addStepLabel.text = "Add Step"
            stepsFooterView.addSubview(addStepLabel)
            addStepLabel.top(to: stepsFooterView)
            addStepLabel.leadingAnchor.constraint(equalTo: plus.trailingAnchor, constant: 15).isActive = true
            let tappedAddStep = UITapGestureRecognizer(target: self, action: #selector(addStep))
            stepsFooterView.addGestureRecognizer(tappedAddStep)
            return stepsFooterView
        } else {
            return UIView(frame: .zero)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == stepsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell") as! StepCell
            cell.done = steps[indexPath.row].done
            cell.cellTitle.text = steps[indexPath.row].stepName
            cell.selectionStyle = .none
//            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.35)
            return cell
        } else  {
             let cell = tableView.dequeueReusableCell(withIdentifier: "taskOptionCell") as! TaskOptionCell
            cell.cellTitle.text = defaultList[indexPath.row]
            switch defaultList[indexPath.row] {
            case "Add to a List":
                cell.cellImage.image = UIImage(named: "list")?.resize(targetSize: CGSize(width: 28, height: 28)).withTintColor(.gray)
            case "Remind Me":
                cell.cellImage.image = UIImage(named: "bell")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(.gray)
            case "Add Due Date":
                cell.cellImage.image = UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 28, height: 28)).withTintColor(.gray)
            case "Repeat":
                cell.cellImage.image = UIImage(named: "repeat")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(.gray)
            case "Add File":
                cell.cellImage.image = UIImage(named: "file")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(.gray)
            default:
                break
            }
            cell.selectionStyle = .none
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.35)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Mushyvenom")
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == stepsTableView {
            return 80
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == stepsTableView {
            return 50
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stepsTableView {
            return 60
        } else {
            return 65
        }
    }
}
