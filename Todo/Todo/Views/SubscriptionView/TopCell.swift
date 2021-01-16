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
        imageView.top(to: self, offset: 20)
        imageView.width(self.frame.width * 0.65)
        imageView.height(self.frame.height * 0.70)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imgName)
    }
}
