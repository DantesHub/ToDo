//
//  BottomCell.swift
//  Todo
//
//  Created by Dante Kim on 1/15/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit

class BottomCell: BaseCell {
    let one = UIImageView()
    let two = UIImageView()
    let three = UIImageView()
    let four = UIImageView()
    let five = UIImageView()
    let review = UILabel()
    override func setUpViews() {
        let stars = [one, two, three, four,five]
        for star in stars {
            star.image = UIImage(named: "star2filled")?.withTintColor(gold).resize(targetSize: CGSize(width: 30, height: 30))
            self.addSubview(star)
            star.top(to: self, offset: 40)
        }
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        self.layer.cornerRadius = 15
        
        three.centerX(to: self)
        two.trailingToLeading(of: three, offset: -14)
        one.trailingToLeading(of: two, offset: -14)
        four.leadingToTrailing(of: three, offset: 14)
        five.leadingToTrailing(of: four, offset: 14)
        self.addSubview(review)
        review.leading(to: self, offset: 35)
        review.trailing(to: self, offset:  -35)
        review.topToBottom(of: three, offset: 30)
        review.numberOfLines = 2
        review.font = UIFont(name: "OpenSans", size: 16)
        review.text = "\"I have always used them because I liked the way they looked. Last job change I used\""
    }
    
}

