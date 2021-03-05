//
//  PremadeView.swift
//  Todo
//
//  Created by Dante Kim on 3/3/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
protocol PremadeDelegate {
    func updateSelectNumber(add: Bool, premadeList: String)
}

class PremadeView: UIView {
    var label = UILabel()
    var selected = false
    var width = UIScreen.main.bounds.width * 0.405
    override init(frame: CGRect) {
       super.init(frame: frame)
       setupView()
     }
    var delegate:PremadeDelegate?
     //initWithCode to init view from xib or storyboard
     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       setupView()
     }
     
     //common func to init our view
     func setupView() {
        self.backgroundColor = .white
        self.addSubview(label)
        label.text = "on my shit"
        label.font = UIFont(name: "OpenSans", size: 17)
        label.centerY(to: self)
        label.centerX(to: self)
        label.adjustsFontSizeToFitWidth = true
        label.width(self.width * 0.80)
        label.textColor = .black
        
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.40
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        self.layer.cornerRadius = 15
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tappedSelf))
        self.addGestureRecognizer(tapped)
        
     }
    
    @objc func tappedSelf() {
        configure()
    }
    
    func configure() {
        if selected {
            self.backgroundColor = .white
            label.textColor = .black
            delegate?.updateSelectNumber(add: false, premadeList: label.text ?? "")
        } else {
            self.backgroundColor = lightPurple
            label.textColor = .white
            delegate?.updateSelectNumber(add: true, premadeList: label.text ?? "")
        }
        
        selected = !selected
    }
}
