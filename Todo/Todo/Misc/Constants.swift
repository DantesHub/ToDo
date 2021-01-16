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
var blue = hexStringToUIColor(hex: "4b68e9")
var purple = hexStringToUIColor(hex: "94609b")
var darkRed = hexStringToUIColor(hex: "b3536c")
var darkOrange = hexStringToUIColor(hex: "b3564e")
var turq = hexStringToUIColor(hex: "427f7c")
var darkGreen = hexStringToUIColor(hex: "458160")
var gray = hexStringToUIColor(hex: "6a7580")
let lightPurple = hexStringToUIColor(hex: "#4C69E9")
let gold = hexStringToUIColor(hex: "#F8D003")
let lightGray = hexStringToUIColor(hex: "#EAEAEA")
let green = hexStringToUIColor(hex: "#096408")
let medGray = hexStringToUIColor(hex: "#EEEEEE")
let orange = hexStringToUIColor(hex: "#F08802")
struct K {
    static let listGroupCell = "listGroupCell"
    static let taskSlideCell = "taskSlideCell"
    static let circleCell = "circleCell"
    static func getColor(_ pri: Int) -> UIColor {
        switch pri {
        case 1:
            return UIColor.red
        case 2:
            return orange
        case 3:
            return UIColor.blue
        case 4:
            return UIColor.clear
        default:
            return UIColor.clear
        }
    }
    
    static func getListColor(_ col: String) -> UIColor {
        switch col {
        case "white":
            return UIColor.white
        case "blue":
            return blue
        case "purple":
            return purple
        case "darkOrange":
            return darkOrange
        case "darkRed":
            return darkRed
        case "turq":
            return turq
        case "gray":
            return gray
        case "darkGreen":
            return darkGreen
        default:
            return UIColor.clear
        }
    }
    
    static func getStringColor(_ col: UIColor) -> String {
        switch col {
        case UIColor.white:
            return "white"
        case blue:
            return "blue"
        case purple:
            return "purple"
        case darkOrange:
           return "darkOrange"
        case darkRed:
            return "darkRed"
        case turq:
            return "turq"
        case gray:
            return "gray"
        case darkGreen:
            return "darkGreen"
        default:
            return ""
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
