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

    @IBOutlet weak var uxIndexGroup: WKInterfaceGroup!
    @IBOutlet weak var uvIndexDescriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var uvIndexLabel: WKInterfaceLabel!
    
    @IBOutlet weak var errorMessageLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.uxIndexGroup.setHidden(true)
        self.errorMessageLabel.setHidden(true)
        
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
    
    @IBAction func refreshUvIndexAction() {
        self.requestUVIndexFromPhone()
    }
    
    func requestUVIndexFromPhone() {
        println("### Requesting uv index")
        
        WKInterfaceController.openParentApplication(Dictionary<String, String>()) {
            (replyInfo, error) -> Void in
            
            println("### Got reply \(replyInfo) and error \(error)")
            if error == nil {
                if (replyInfo["error"] == nil) {
                    self.showUvIndex(replyInfo as! Dictionary<String, String>)
                } else {
                    self.showError(replyInfo["error"]!)
                }
                
            } else {
                self.showError(error)
            }
            
        }
    }
    
    func showUvIndex(dictionary : Dictionary<String, String>) {
        let uvIndex = UvIndex(dictionary: dictionary)
        self.uxIndexGroup.setBackgroundColor(uvIndex.getColorForUVIndex())
        self.uvIndexDescriptionLabel.setText("\(uvIndex.getInfoText()) \(uvIndex.getUvIndexDescription())")
        self.uvIndexLabel.setText(uvIndex.uvIndex)
        self.uxIndexGroup.setHidden(false)
        self.errorMessageLabel.setHidden(true)
    }
    
    func showError(error : AnyObject) {
        var font = UIFont.systemFontOfSize(6)
        self.errorMessageLabel.setAttributedText(NSAttributedString(string: "\(error)\n\n Make sure you have internet access, that this app has access to your location and then press hard anywhere on the screen to try again." as String, attributes: [NSFontAttributeName:font]))
        self.uxIndexGroup.setHidden(true)
        self.errorMessageLabel.setHidden(false)    }

}
