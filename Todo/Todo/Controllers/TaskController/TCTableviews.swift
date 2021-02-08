

import UIKit

extension TaskController: UITableViewDelegate, UITableViewDataSource, TaskOptionProtocol {
    func createDone() {
        createTappedDone(title: false, step: true)
    }
    func resetVariable(type: String) {
        switch type {
        case "Add Due Date":
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
    
    
    func reloadStepsTable() {
        getSteps()
        heightConstraint?.isActive = false
        heightConstraint = stepsTableView.heightAnchor.constraint(equalToConstant: heightConstraint!.constant - 60)
        heightConstraint?.isActive = true
        self.stepsTableView.reloadData()
    }
    func reloadTable() {
        self.stepsTableView.reloadData()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stepsTableView {
            return steps.count
        } else {
            return 5
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == stepsTableView {
            let stepsHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: taskTitle.count > 20 ?  taskTitle.count > 40 ? 260 : 160 : 80))
                       headerTitle = UITextView()
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
                       circle.backgroundColor = priColor.modified(withAdditionalHue: 0.00, additionalSaturation: -0.70, additionalBrightness: 0.25)

                       if priColor == UIColor.clear {
                           circle.layer.borderColor = listTextColor == .white ? UIColor.darkGray.cgColor : listTextColor.cgColor
                       } else {
                           circle.layer.borderColor = priColor.cgColor
                       }
                       
                       
                       if completed {
                           configureCircle(priColor)
                       }
                       stepsHeaderView.addSubview(headerTitle)
                       headerTitle.leadingToTrailing(of: circle, offset: 15)
                       headerTitle.trailingToSuperview(offset: 40)
                       headerTitle.height(min: stepsHeaderView.frame.height == 80 ? 50 : stepsHeaderView.frame.height == 160 ? 80 : 130 , max:  180, priority: .defaultHigh, isActive: true)
                       headerTitle.centerY(to: stepsHeaderView)

                       headerTitle.sizeToFit()
                       headerTitle.textContainer.maximumNumberOfLines = 3
                       headerTitle.textContainer.lineBreakMode = .byTruncatingTail;
                       headerTitle.font = UIFont(name: "OpenSans-Bold", size: 23)
                       headerTitle.attributedText = .none
                       headerTitle.text = taskTitle
                       headerTitle.delegate = self
                       
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
        DispatchQueue.main.async { [self] in
            print("fda")
            circle.addSubview(check)
            check.width(35)
            check.height(35)
            check.leadingAnchor.constraint(equalTo: circle.leadingAnchor).isActive = true
            let checkGest = UITapGestureRecognizer(target: self, action: #selector(tappedCheck))
            check.addGestureRecognizer(checkGest)
            if color == UIColor.clear {
                check.image = check.image?.withTintColor(listTextColor == .white ? .gray : listTextColor )
            } else {
                check.image = check.image?.withTintColor(color)
            }
            if completed {
                print("yogi")
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskTitle)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                headerTitle.attributedText = attributeString
                headerTitle.font = UIFont(name: "OpenSans-Bold", size: 23)
            }
        
         }
    }

    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == stepsTableView {
            stepsFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            stepsFooterView.addSubview(plus)
            configureDefaultFooter()
            stepsFooterView.backgroundColor = .white
            return stepsFooterView
        } else {
            return UIView(frame: .zero)
        }
    }
    
    private func configureDefaultFooter() {
        let col = listTextColor == .white ? .systemBlue : listTextColor
        plus.leading(to: stepsFooterView, offset: 20)
        plus.top(to: stepsFooterView, offset: -7)
        plus.image = plus.image?.withTintColor(col)
        addStepLabel.font = UIFont(name: "OpenSans-Regular", size: 20)
        addStepLabel.textColor = col
        addStepLabel.text = "Add Step"
        stepsFooterView.addSubview(addStepLabel)
        addStepLabel.top(to: stepsFooterView, offset:  3)
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
        circleStep.layer.borderColor = listTextColor == .white ? UIColor.darkGray.cgColor : listTextColor.cgColor
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
        let col = listTextColor == .white ? .gray : listTextColor
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.systemBlue, for: .normal)
        let img =  UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(.systemBlue)
        done.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 18)
        done.setImage(img, for: .normal)
        done.tintColor = .systemBlue
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
            cell.cellTitle.textColor = K.getColor(priority) == .clear ? listTextColor == .white ? .systemBlue : listTextColor : K.getColor(priority)
            cell.taskDelegate = delegate
            cell.selectionStyle = .none
//            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.35)
            cell.configureCircle()
            return cell
        } else  {
             let cell = tableView.dequeueReusableCell(withIdentifier: "taskOptionCell") as! TaskOptionCell
            cell.cellTitle.text = defaultList[indexPath.row]
            cell.cellTitle.textColor = .gray
            cell.type = defaultList[indexPath.row]
            cell.id = id
            cell.taskDelegate = delegate
            let col = listTextColor == .white ? .systemBlue : listTextColor
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
                cell.cellImage.image = UIImage(named: "list")?.resize(targetSize: CGSize(width: 22, height: 22)).withTintColor(!parented ? .gray : col)
                cell.cellTitle.textColor = !parented ? .gray : col
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
                        cell.cellImage.image = cell.cellImage.image?.withTintColor(orange)
                        cell.cellTitle.text = "Priority 2"
                        cell.cellTitle.textColor = orange
                    } else if priority == 3 {
                        cell.cellImage.image = cell.cellImage.image?.withTintColor(.systemBlue)
                        cell.cellTitle.text = "Priority 3"
                        cell.cellTitle.textColor = .systemBlue
                    } else if priority == 4 {
                        cell.cellImage.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 19, height: 22)).withTintColor(col)
                        cell.cellTitle.text = "Priority 4"
                        cell.cellTitle.textColor = col
                    }
                }
            case "Remind Me":
                cell.cellImage.image = UIImage(named: "bell")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(reminderDate == "" ? .gray : col)
                cell.cellTitle.textColor = reminderDate == "" ? .gray : col
                let newReminder = reminderDate.replacingOccurrences(of: "-", with: " ")
                if reminderDate != "" {
                    cell.createX()
                    cell.cellTitle.text = Date().getDifference(date: newReminder)
                }
            case "Add Due Date":
                cell.cellImage.image = UIImage(named: "calendarOne")?.resize(targetSize: CGSize(width: 25, height: 25)).withTintColor(plannedDate == "" ? .gray : .systemBlue)
                cell.cellTitle.textColor = plannedDate == "" ? .gray : col
                let newPlanned = plannedDate.replacingOccurrences(of: "-", with: " ")
                if plannedDate != "" {
                    cell.cellTitle.text = Date().getDifference(date: newPlanned)
                    cell.createX()
                }
            case "Repeat":
                cell.cellImage.image = UIImage(named: "repeat")?.resize(targetSize: CGSize(width: 23, height: 23)).withTintColor(repeatTask == "" ? .gray : col)
                cell.dueDate = plannedDate
                cell.reminder = reminderDate
                if repeatTask != "" {
                    cell.cellTitle.text = "Every " + repeatTask
                    cell.createX()
                    cell.cellTitle.textColor = col
                } else {
                    cell.removeX()
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
            if !cell.addedBorder {
                cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.35)
                cell.addedBorder = true
            }
            
            return cell
        }
    }
    func reloadMainTable() {
        delegate?.reloadMainTable()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if (defaultList[indexPath.row] == "Remind Me" || defaultList[indexPath.row] == "Repeat") && UserDefaults.standard.bool(forKey: "isPro") == false {
                let sub = SubscriptionController(idx:  defaultList[indexPath.row] == "Remind Me" ? 3 : 4)
                self.navigationController?.present(sub, animated: true, completion: nil)
                return
            }
            
            
            tappedIcon = defaultList[indexPath.row]
            slideUpView.reloadData()
            self.view.endEditing(true)
            if tappedIcon == "Repeat" {
                createSlider(repeatt: true)
            } else {
                createSlider()
            }
        } else {
            let stepCell = tableView.cellForRow(at: indexPath) as! StepCell
            editingStep = steps[indexPath.row]
            stepCell.cellTitle.becomeFirstResponder()
        }
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == stepsTableView {
            return taskTitle.count > 20 ?  taskTitle.count > 40 ? 110 : 100 : 80
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

