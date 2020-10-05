//
//  SelfSizedTableView.swift
//  Todo
//
//  Created by Dante Kim on 9/30/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
class SelfSizedTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override func reloadData() {
      super.reloadData()
      self.invalidateIntrinsicContentSize()
      self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
