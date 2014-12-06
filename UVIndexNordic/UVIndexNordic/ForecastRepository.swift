//
//  ForecastRepository.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import Foundation

class ForecastRepository {
    
    func getUVIndex(delegate : ViewController) {
        
        
        // TODO Get uv index for position, but until then we fake it
        delegate.didReceiveUVIndexForLocationAndTime("5", city: "Bromma", timeStamp: NSDate())
    }
    
}
