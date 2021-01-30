//
//  TaskOptionCell.swift
//  Todo
//
//  Created by Dante Kim on 11/20/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints
import RealmSwift

class StepCell: UITableViewCell {
    var circleView = RoundView()
    var cellTitle = UILabel()
    var done = false
    var priColor = UIColor()
    var id = ""
    var taskDelegate: TaskViewDelegate?
    var delegate: TaskOptionProtocol?
    let check: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "circleCheck")?.resize(targetSize: CGSize(width: 25, height: 25))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    var x = UIImageView(image: UIImage(named: "plus")?.rotate(radians: -.pi/4)?.resize(targetSize: CGSize(width: 35, height: 35)).withTintColor(.gray))
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(circleView)
        contentView.addSubview(cellTitle)
        
        cellTitle.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 13).isActive = true
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        cellTitle.font = UIFont(name: "OpenSans-Regular", size: 18)
        cellTitle.textColor = UIColor.darkGray
        
        x.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(x)
        x.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        x.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        x.isUserInteractionEnabled = true
        let xTapped = UITapGestureRecognizer(target: self, action: #selector(tappedX))
        x.addGestureRecognizer(xTapped)
    }
    func configureCircle() {
        circleView.width(25)
        circleView.height(25)
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.darkGray.cgColor
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        circleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        circleView.isUserInteractionEnabled = true
        let circleTapped = UITapGestureRecognizer(target: self, action: #selector(tappedCircle))
        circleView.addGestureRecognizer(circleTapped)
        circleView.backgroundColor = priColor.modified(withAdditionalHue: 0.00, additionalSaturation: -0.70, additionalBrightness: 0.15)
        if priColor == UIColor.clear {
            circleView.layer.borderColor = listTextColor == .white ? UIColor.darkGray.cgColor : listTextColor.cgColor
        } else {
            circleView.layer.borderColor = priColor.cgColor
        }
        if done {
            configureCheck(priColor)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tappedCircle() {
        configureCheck(priColor)
        let steps = uiRealm.objects(Step.self)
        for step in steps {
            if step.id == id {
                try! uiRealm.write {
                    step.done = true
                }
            }
        }
    }
    private func configureCheck(_ color: UIColor) {
        circleView.addSubview(check)
        check.width(25)
        check.height(25)
        check.leadingAnchor.constraint(equalTo: circleView.leadingAnchor).isActive = true
        let checkGest = UITapGestureRecognizer(target: self, action: #selector(tappedCheck))
        check.addGestureRecognizer(checkGest)
        if priColor != UIColor.clear {
            check.image = check.image?.withTintColor(color)
        } else {
            check.image = check.image?.withTintColor(listTextColor == .white ? UIColor.darkGray : listTextColor)
        }
        let taskTitle = cellTitle.text
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskTitle!)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        cellTitle.attributedText = attributeString
    }
    
    @objc func tappedCheck() {
        check.removeFromSuperview()
        let steps = uiRealm.objects(Step.self)
        for step in steps {
            if step.id == id {
                try! uiRealm.write {
                    step.done = false
                }
            }
        }
        
        let titleText = cellTitle.text
        cellTitle.attributedText = .none
        cellTitle.text = titleText
        taskDelegate?.reloadTable()
    }
    
    @objc func tappedX() {
        let steps = uiRealm.objects(Step.self)
        for step in steps {
            if step.id == id {
                try! uiRealm.write {
                    uiRealm.delete(step)
                }
            }
        }
        delegate?.reloadStepsTable()
        taskDelegate?.reloadTable()
    }

}
