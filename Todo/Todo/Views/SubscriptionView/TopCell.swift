//
//  TopCell.swift
//  Todo
//
//  Created by Dante Kim on 1/15/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit

class TopCell: BaseCell {
    var imageView = UIImageView()
    var title = UILabel()
    var desc = UILabel()
    var imgName = ""

    override func setUpViews() {
        super.setUpViews()
        self.addSubview(imageView)
        self.addSubview(title)
        self.addSubview(desc)
    }
    func configureUI() {
        self.backgroundColor = lightGray
        imageView.centerX(to: self)
        imageView.top(to: self, offset: 0)
        imageView.width(self.frame.width * 0.70)
        imageView.height(self.frame.height * 0.70)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imgName)
        
        title.topToBottom(of: imageView, offset: -30)
        title.centerX(to: self)
        title.font = UIFont(name: "OpenSans-Bold", size: 22)
        
        desc.topToBottom(of: title)
        desc.leading(to: self,offset: 50)
        desc.trailing(to: self, offset: -50)
        desc.textAlignment = .center
        desc.text = "Repeat  feature will be accessible to premium users only. Whenever a freemium user clicks on “Repeat”"
        desc.numberOfLines = 2
        desc.textColor = .darkGray
        desc.font = UIFont(name: "OpenSans", size: 12)
    }
}
