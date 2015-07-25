//
//  ViewController.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var uvIndexDescriptionLabel: UILabel!
    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var dateFormatter = NSDateFormatter()
    var locationManager : CLLocationManager!
    var indicator : SDevIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        getTheStuff()
    }
    
    func getTheStuff() {
        if indicator != nil {
            indicator.dismissIndicator()
        }
        indicator = SDevIndicator.generate(self.view)!
        
        infoLabel.text = ""
        uvIndexDescriptionLabel.text = ""
        uvIndexLabel.text = ""
        errorLabel.text = ""
        self.view.backgroundColor = UIColor.whiteColor()
        
        getLocation()
    }
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        locationManager.stopUpdatingLocation()
        var locationArray = locations as NSArray
        var currentLocation = locationArray.lastObject as? CLLocation
        getUVIndex(currentLocation!)
    }
    
    func getUVIndex(currentLocation : CLLocation) {
        ForecastRetriever(delegate: self).getUVIndex(currentLocation)
    }
    
    func didNotFindValidCountry(country : NSString) {
        indicator.dismissIndicator()
        
        errorLabel.text = "Oh no :( This app cannot find UV Index outside the Nordic countries, and you are in " + (country as String) + "."
    }
    
    func didNotReceivedUvIndexOrCity() {
        indicator.dismissIndicator()
        
        errorLabel.text = "Oh no :( Could for some reason not find any UV Index for your location. Make sure you have internet access, that this app has access to your location and then touch anywhere on the screen to try again."
    }
    
    func didReceiveUVIndexForLocationAndTime(uvIndex: String, city: String, timeStamp: NSDate) {
        indicator.dismissIndicator()
        
        var uvIndex = UvIndex(uvIndex: uvIndex, city: city, longitude: nil, latitude: nil)
        infoLabel.text = uvIndex.getInfoText()
        uvIndexDescriptionLabel.text = uvIndex.getUvIndexDescription()
        infoLabel.textColor = UIColor.blackColor()
        uvIndexDescriptionLabel.textColor = UIColor.blackColor()
        uvIndexLabel.textColor = UIColor.blackColor()
        uvIndexLabel.text = uvIndex.uvIndex
        self.view.backgroundColor = uvIndex.getBackgroundColorForUVIndex()
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        getTheStuff()
    }

}

