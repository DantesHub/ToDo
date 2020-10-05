//
//  HorizontalBorder.swift
//  Todo
//
//  Created by Dante Kim on 10/2/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

class HorizontalBorder: UIView {
    override init(frame: CGRect) {
      super.init(frame: frame)
        setUpView(frame2: frame.width)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView(frame2: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 50))
        path.addLine(to: CGPoint(x: frame2, y: 50))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.fillColor = UIColor.gray.cgColor
        shapeLayer.lineWidth = 0.5
        self.layer.addSublayer(shapeLayer)
    }
  
}
