//
//  BaseCell.swift
//  Todo
//
//  Created by Dante Kim on 10/13/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        
    }
}
