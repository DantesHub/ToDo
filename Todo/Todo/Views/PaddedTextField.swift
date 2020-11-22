//
//  PaddedTextField.swift
//  Todo
//
//  Created by Dante Kim on 11/20/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//
import UIKit

class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 25, bottom: UIScreen.main.bounds.height/6 - 25, right: 0)
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
