//
//  ViewController.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        // TODO Get uv index for position, but until then we fake it
        didReceiveUVIndexForLocationAndTime("5", city: "Bromma", timeStamp: NSDate())
    }
    
    func didReceiveUVIndexForLocationAndTime(uvIndex: String, city: String, timeStamp: NSDate) {
        uvIndexLabel.text = uvIndex
        infoLabel.text = buildInfoText(city, timeStamp: timeStamp)
        
    }
    
    func buildInfoText(city: String, timeStamp: NSDate) -> NSString {
        return city + " " + dateFormatter.stringFromDate(timeStamp)
    }

}

