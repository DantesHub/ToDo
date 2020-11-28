

import UIKit

extension TaskController: UITableViewDelegate, UITableViewDataSource, TaskOptionProtocol {
    func resetVariable(type: String) {
        switch type {
        case "Add Due Date":
            print("fking shibal")
            plannedDate = ""
        case "Remind Me":
            reminderDate = ""
        case "Priority":
            priority = 0
        case "Add to a List":
            parentList = "All Tasks"
        case "Repeat":
            repeatTask = ""
        default:
            break
        }
        self.tableView.reloadData()
    }
    
    func reloadTable() {
        getSteps()
        heightConstraint?.isActive = false
        heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: heightConstraint!.constant - 60)
        heightConstraint?.isActive = true
        self.stepsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stepsTableView {
            return steps.count
        } else {
            return 6
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
            let priColor = K.getColor(priority)
            circle.backgroundColor = priColor.modified(withAdditionalHue: 0.00, additionalSaturation: -0.65, additionalBrightness: 0.30)
            if priColor == UIColor.clear {
                circle.layer.borderColor = UIColor.gray.cgColor
            } else {
                circle.layer.borderColor = priColor.cgColor
            }
            
            if completed {
                configureCircle(priColor)
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
    func configureCircle(_ color: UIColor) {
        circle.addSubview(check)
        check.width(35)
        check.height(35)
        check.leadingAnchor.constraint(equalTo: circle.leadingAnchor).isActive = true
        let checkGest = UITapGestureRecognizer(target: self, action: #selector(tappedCheck))
        check.addGestureRecognizer(checkGest)
        check.image = check.image?.withTintColor(color)
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskTitle)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        headerTitle.attributedText = attributeString
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == stepsTableView {
            stepsFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            stepsFooterView.addSubview(plus)
            configureDefaultFooter()
            return stepsFooterView
        } else {
            return UIView(frame: .zero)
        }
    }
    
    private func configureDefaultFooter() {
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
    }
    
    @objc func addStep() {
        plus.removeFromSuperview()
        circleStep.width(25)
        circleStep.height(25)
        circleStep.backgroundColor = .white
        circleStep.layer.borderWidth = 2
        circleStep.layer.borderColor = UIColor.darkGray.cgColor
        stepsFooterView.addSubview(circleStep)
        circleStep.leading(to: stepsFooterView, offset: 30)
        circleStep.top(to: stepsFooterView)
        
        addStepLabel.removeFromSuperview()
        stepsFooterView.addSubview(addStepField)
        addStepField.delegate = self
        addStepField.top(to: stepsFooterView, offset: 3)
        addStepField.leadingAnchor.constraint(equalTo: circleStep.trailingAnchor, constant: 15).isActive = true
        addStepField.becomeFirstResponder()
        
        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.blue, for: .normal)
        done.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 18)
        done.setImage(UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 25, height: 25)), for: .normal)
        done.addTarget(self, action: #selector(tappedDone), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: done)]
    }
    
    @objc func tappedDone() {
        createNewStep(textField: addStepField)
        stepsFooterView.addSubview(plus)
        addStepField.resignFirstResponder()
        addStepField.removeFromSuperview()
        circleStep.removeFromSuperview()
        configureDefaultFooter()
        configureNavBar()
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == stepsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell") as! StepCell
            cell.done = steps[indexPath.row].done
            cell.priColor = K.getColor(priority)
            cell.cellTitle.text = steps[indexPath.row].stepName
            cell.id = steps[indexPath.row].id
            cell.delegate = self
            cell.taskDelegate = delegate
            cell.selectionStyle = .none
//            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.35)
            cell.configureCircle()
            return cell
        } else  {
             let cell = tableView.dequeueReusableCell(withIdentifier: "taskOptionCell") as! TaskOptionCell
            cell.cellTitle.text = defaultList[indexPath.row]
            cell.type = defaultList[indexPath.row]
            cell.id = id
            cell.taskDelegate = delegate
            switch defaultList[indexPath.row] {
            case "Add to a List":
                var parented = false
                if parentList != "All Tasks" && parentList != "Important" && parentList != "Planned" {
                    parented = true
                    cell.cellTitle.text = parentList
                    if !(parentList == "All Tasks") {
                        cell.createX()
                    }
                }
                cell.cellImage.image = UIImage(named: "list")?.resize(targetSize: CGSize(width: 22, height: 22)).withTintColor(!parented ? .gray : .blue)
                cell.cellTitle.textColor = !parented ? .gray : .blue
            case "Priority":
                if priority == 0 {
                    cell.cellImage.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 19, height: 22)).withTintColor(.gray)
                    cell.cellTitle.text = "Priority"
                } else {
                    cell.createX()
                    cell.cellImage.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 19, height: 22))
                    if priority == 1 {
                        cell.cellImage.image = cell.cellImage.image?.withTintColor(.red)
                        cell.cellTitle.text = "Priority 1"
                        cell.cellTitle.textColor = .red
                    } else if priority == 2 {
                        cell.cellImage.image = cell.cellImage.image?.withTintColor(green)
                        cell.cellTitle.text = "Priority 2"
                        cell.cellTitle.textColor = green
                    } else if priority == 3 {
                        cell.cellImage.image = cell.cellImage.image?.withTintColor(gold)
                        cell.cellTitle.text = "Priority 3"
                        cell.cellTitle.textColor = gold
                    } else if priority == 4 {
                        cell.cellImage.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 19, height: 22)).withTintColor(.blue)
                        cell.cellTitle.text = "Priority 4"
                        cell.cellTitle.textColor = .blue
                    }
                }
            case "Remind Me":
                cell.cellImage.image = UIImage(named: "bell")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(reminderDate == "" ? .gray : .blue)
                cell.cellTitle.textColor = reminderDate == "" ? .gray : .blue
                let newReminder = reminderDate.replacingOccurrences(of: "-", with: " ")
                if reminderDate != "" {
                    cell.createX()
                    cell.cellTitle.text = Date().getDifference(date: newReminder)
                }
            case "Add Due Date":
                cell.cellImage.image = UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(plannedDate == "" ? .gray : .blue)
                cell.cellTitle.textColor = plannedDate == "" ? .gray : .blue
                let newPlanned = plannedDate.replacingOccurrences(of: "-", with: " ")
                if plannedDate != "" {
                    cell.cellTitle.text = Date().getDifference(date: newPlanned)
                    cell.createX()
                }
            case "Repeat":
                cell.cellImage.image = UIImage(named: "repeat")?.resize(targetSize: CGSize(width: 23, height: 23)).withTintColor(repeatTask == "" ? .gray : .blue)
                cell.dueDate = plannedDate
                cell.reminder = reminderDate
                if repeatTask != "" {
                    cell.createX()
                    cell.cellTitle.textColor = .blue
                }
            case "Add File":
                cell.cellImage.image = UIImage(named: "file")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(.gray)
            default:
                break
            }
            cell.delegate = self
            cell.dueDate = plannedDate
            cell.reminder = reminderDate
            cell.parentList = parentList
            cell.selectionStyle = .none
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.35)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            tappedIcon = defaultList[indexPath.row]
            slideUpView.reloadData()
            if tappedIcon == "Repeat" {
                createSlider(repeatt: true)
            } else {
                createSlider()
            }
        } else {
            return
        }
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

