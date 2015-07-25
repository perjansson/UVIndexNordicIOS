//
//  UvIndex.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2015-07-21.
//  Copyright (c) 2015 Per Jansson. All rights reserved.
//

import Foundation
import UIKit

class UvIndex {
    
    let dateFormatter = NSDateFormatter()
    
    var uvIndex : String
    var city: String
    var longitude : Double?
    var latitude : Double?
    
    init(uvIndex : String, city : String, longitude : Double?, latitude : Double?) {
        self.uvIndex = uvIndex
        self.city = city
        self.longitude = longitude
        self.latitude = latitude
    }
    
    init(dictionary : NSDictionary) {
        self.uvIndex = dictionary["uvIndex"] as! String
        self.city = dictionary["city"] as! String
        self.longitude = dictionary["longitude"] as? Double
        self.latitude = dictionary["latitude"] as? Double
    }
    
    func getColorForUVIndex() -> UIColor {
        switch self.uvIndex {
        case "":
            return UIColor.lightGrayColor()
        case "0", "1", "2":
            return UIColor(red: 0.459, green: 0.757, blue: 0.282, alpha: 1.0)
        case "3", "4", "5":
            return UIColor(red: 0.918, green: 0.925, blue: 0.4, alpha: 1.0)
        case "6", "7":
            return UIColor(red: 0.886, green: 0.455, blue: 0.184, alpha: 1.0)
        case "8", "9", "10":
            return UIColor(red: 0.886, green: 0.204, blue: 0.184, alpha: 1.0)
        default:
            return UIColor(red: 0.6, green: 0.125, blue: 0.561, alpha: 1.0)
        }
    }
    
    func getInfoText() -> String {
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return "UV Index in " + self.city + " at " + dateFormatter.stringFromDate(NSDate())
    }
    
    func getUvIndexDescription() -> String {
        return "is " + getUVIndexText() as String
    }
    
    func getUVIndexText() -> String {
        switch self.uvIndex {
        case "":
            return "UNKNOWN :("
        case "0", "1", "2":
            return "LOW"
        case "3", "4", "5":
            return "MODERATE"
        case "6", "7":
            return "HIGH"
        case "8", "9", "10":
            return "VERY HIGH"
        default:
            return "EXTREME"
        }
    }
    
}