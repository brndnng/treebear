//
//  extras.swift
//  treebear
//
//  Created by Ricky Cheng on 3/3/2018.
//  Copyright © 2018 Brandon Ng. All rights reserved.
//

import Foundation
import MapKit

class ExtenedColors{
    var tripColor = [
        ["light": UIColorFromRGB(rgbValue: 0xF48FB1), "dark": UIColorFromRGB(rgbValue: 0xAD1457)],
        ["light": UIColorFromRGB(rgbValue: 0xCE93D8), "dark": UIColorFromRGB(rgbValue: 0x6A1B9A)],
        ["light": UIColorFromRGB(rgbValue: 0x9FA8DA), "dark": UIColorFromRGB(rgbValue: 0x283593)],
        ["light": UIColorFromRGB(rgbValue: 0x80DEEA), "dark": UIColorFromRGB(rgbValue: 0x00838F)],
        ["light": UIColorFromRGB(rgbValue: 0xBCAAA4), "dark": UIColorFromRGB(rgbValue: 0x4E342E)],
    ]
    
    var noTripColor = ["light": UIColorFromRGB(rgbValue: 0xB0BEC5), "dark": UIColorFromRGB(rgbValue: 0x37474F)]
    
    var destColor = ["light": UIColorFromRGB(rgbValue: 0xA5D6A7), "dark": UIColorFromRGB(rgbValue: 0x2E7D32)]
}

class Helpers{
    func getDist(from:CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> Double {
        return 0.0
    }
}

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
