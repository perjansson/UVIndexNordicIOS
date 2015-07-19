//
//  Forecast.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import Foundation

class Forecast {
    
    var city: String?
    var state: String?
    var uvIndex: String?
    var longitude: Double?
    var latitude: Double?
    
    init (longitude : Double, latitude : Double) {
        self.longitude = longitude
        self.latitude = latitude
    }    
    
    init(city : String, state : String, uvIndex : String) {
        self.city = city
        self.state = state
        self.uvIndex = uvIndex
    }
    
}