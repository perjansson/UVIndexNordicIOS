//
//  InterfaceController.swift
//  UV Index WatchKit Extension
//
//  Created by Per Jansson on 2015-07-19.
//  Copyright (c) 2015 Per Jansson. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var cityLabel: WKInterfaceLabel!
    @IBOutlet weak var uvIndexDescriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var uvIndexLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.requestUVIndexFromPhone()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func requestUVIndexFromPhone() {
        WKInterfaceController.openParentApplication(Dictionary<String, String>()) {
            (replyInfo, error) -> Void in
            
            if (error == nil) {
                var dictionary = replyInfo as NSDictionary
                let city = dictionary["city"] as! String
                let uvIndexDescription = dictionary["uvIndexDescription"] as! String
                let uvIndex = dictionary["uvIndex"] as! String
                
                self.cityLabel.setText(city)
                self.uvIndexDescriptionLabel.setText(uvIndexDescription)
                self.uvIndexLabel.setText(uvIndex)
                
            } else {
                // TODO: Show error
            }

        }
    }

}
