//
//  Constants.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import UIKit

let superPurple = hexStringToUIColor(hex: "#A73CDE")
let gold = hexStringToUIColor(hex: "#F8D003")
let lightGray = hexStringToUIColor(hex: "#EAEAEA")
let green = hexStringToUIColor(hex: "#50C778")
let medGray = hexStringToUIColor(hex: "#EEEEEE")
struct K {
    static let listGroupCell = "listGroupCell"
    static let taskSlideCell = "taskSlideCell"
    
    static func getColor(_ pri: Int) -> UIColor {
        switch pri {
        case 1:
            return UIColor.red
        case 2:
            return green
        case 3:
            return gold
        case 4:
            return UIColor.clear
        default:
            return UIColor.clear
        }
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
