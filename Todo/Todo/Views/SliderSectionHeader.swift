//
//  SliderSectionHeader.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints
protocol ReloadSlider {
    func reloadSlider()
}
class SliderSectionHeader: UICollectionReusableView{
    var reloadDelegate: ReloadSlider?
     var label: UILabel = {
         let label: UILabel = UILabel()
        label.font = UIFont(name: "OpenSans-Bold", size: 18)
        label.sizeToFit()
         return label
     }()
    var keyboard = true
    var hr = UIView()
    var backArrow = UIImageView()
    var done = UIButton()
    var listOption = true
     override init(frame: CGRect) {
        super.init(frame: frame)
         addSubview(label)
        label.top(to: self, offset: 20)
        label.centerX(to: self)
        hr = UIView(frame: CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 1.0))
        hr.layer.borderWidth = 0.3
        hr.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 25
        addSubview(hr)
    }
    func createButton() {
        if !keyboard {
            addSubview(done)
            done.setTitle("Done", for: .normal)
            done.setTitleColor(.blue, for: .normal)
            done.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 18)!
            done.top(to: self, offset: 20)
            done.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            done.addTarget(self, action: #selector(tappedDone), for: .touchUpInside)

        } else {
            addSubview(backArrow)
            backArrow.image = UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 25, height: 25)).rotate(radians: -.pi/2)?.withTintColor(.gray)
            backArrow.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
            backArrow.top(to: self, offset: 20)
            let backReg = UITapGestureRecognizer(target: self, action: #selector(tappedBackArrow))
            backArrow.addGestureRecognizer(backReg)
            backArrow.isUserInteractionEnabled = true
        }
    }
    @objc func tappedDone() {
        reloadDelegate?.reloadSlider()
    }
    
    @objc func tappedBackArrow() {
        print("bink")
        if listOption {
            reloadDelegate?.reloadSlider()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
