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
    
    @IBOutlet weak var errorMessageLabel: WKInterfaceLabel!
    
    @IBOutlet weak var uxIndexGroup: WKInterfaceGroup!
    @IBOutlet weak var uvIndexDescriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var uvIndexLabel: WKInterfaceLabel!
    
    @IBOutlet weak var loadingGroup: WKInterfaceGroup!
    @IBOutlet weak var spinnerImage: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.hideUIWhileLoadingUVIndex()
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
        
        self.hideUIWhileLoadingUVIndex()
        
        WKInterfaceController.openParentApplication(Dictionary<String, String>()) {
            (replyInfo, error) -> Void in
            
            println("### Got reply \(replyInfo) and error \(error)")
            
            self.loadingGroup.setHidden(true)
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
        self.errorMessageLabel.setText("\(error.localizedDescription)\n\nIf you get this error try and start UV Index on your phone. Make sure you have internet access, that this app has access to your location and then press hard anywhere on the screen to try again.")
        self.uxIndexGroup.setHidden(true)
        self.errorMessageLabel.setHidden(false)
    }
    
    func hideUIWhileLoadingUVIndex() {
        self.loadingGroup.setHidden(false)
        spinnerImage.startAnimatingWithImagesInRange(NSMakeRange(1, 42), duration: 1.10, repeatCount: 100)
        self.uxIndexGroup.setHidden(true)
        self.errorMessageLabel.setHidden(true)
    }

}
