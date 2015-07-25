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

    @IBOutlet weak var uvIndexDescriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var uvIndexLabel: WKInterfaceLabel!
    @IBOutlet weak var errorMessageLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.showHideUvIndex(true)
        self.showHideErrorMessage(true)
        
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
        println("### requestUVIndexFromPhone")
        
        WKInterfaceController.openParentApplication(Dictionary<String, String>()) {
            (replyInfo, error) -> Void in
            
            if error == nil {
                println("### Got reply \(replyInfo)")
                let uvIndex = UvIndex(dictionary: replyInfo as NSDictionary)
                
                let uvIndexDescription = NSMutableAttributedString(string: "\(uvIndex.getInfoText()) \(uvIndex.getUvIndexDescription())", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(10)])
                uvIndexDescription.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSRange(location: 0, length: uvIndexDescription.length))
                self.uvIndexDescriptionLabel.setAttributedText(uvIndexDescription)

                let uvIndexText = NSMutableAttributedString(string: uvIndex.uvIndex, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(90)])
                uvIndexText.addAttribute(NSForegroundColorAttributeName, value: uvIndex.getBackgroundColorForUVIndex(), range: NSRange(location: 0, length: (uvIndex.uvIndex as NSString).length))
                self.uvIndexLabel.setAttributedText(uvIndexText)
                
                self.showHideUvIndex(false)
                
            } else {
                // TODO: Show error
                println("### Error: \(error)")
                var font = UIFont.systemFontOfSize(6)
                var specialString = NSAttributedString(string: "Whoops:\n \(error)" as String, attributes: [NSFontAttributeName:font])
                self.errorMessageLabel.setAttributedText(specialString)
                self.showHideErrorMessage(false)
            }

        }
    }
    
    func showHideUvIndex(hidden : Bool) {
        uvIndexDescriptionLabel.setHidden(hidden)
        uvIndexLabel.setHidden(hidden)
    }
    
    func showHideErrorMessage(hidden : Bool) {
        errorMessageLabel.setHidden(hidden)
    }

}
