//
//  ForecastRepository.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import Foundation

class ForecastRepository {
    
    var delegate:ViewController
    
    var uvIndex:NSString
    var city:NSString
    
    init(delegate:ViewController) {
        self.delegate = delegate
        self.uvIndex = ""
        self.city = ""
    }
    
    func getUVIndex(delegate : ViewController) {
        
        
        // TODO Get uv index for position, but until then we fake it
        self.uvIndex = "6"
        self.city = "Stockholm"
        tryToReturnResultToDelegate()
    }
    
    func tryToReturnResultToDelegate() {
        if hasUVIndex() && hasCity() {
            self.delegate.didReceiveUVIndexForLocationAndTime(self.uvIndex, city: self.city, timeStamp: NSDate())
        }
    }
    
    func hasUVIndex() -> Bool {
        return self.uvIndex != ""
    }
    
    func hasCity() -> Bool {
        return self.city != ""
    }
    
}
