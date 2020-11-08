//
//  CircleView.swift
//  Todo
//
//  Created by Dante Kim on 11/7/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

class RoundView:UIView {
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.bounds.width/2
        self.layer.masksToBounds = true
  
    }
}
