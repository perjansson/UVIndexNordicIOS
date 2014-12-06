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
        indicator = SDevIndicator.generate(self.view)!
        getLocation()
    }
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        ForecastRetriever(delegate: self).getUVIndex(currentLocation, delegate: self)
    }
    
    func didReceiveUVIndexForLocationAndTime(uvIndex: String, city: String, timeStamp: NSDate) {
        indicator.dismissIndicator()
        infoLabel.text = buildInfoText(city, timeStamp: timeStamp)
        uvIndexDescriptionLabel.text = buildDescriptionForUVIndex(uvIndex)
        infoLabel.textColor = UIColor.blackColor()
        uvIndexDescriptionLabel.textColor = UIColor.blackColor()
        uvIndexLabel.textColor = UIColor.blackColor()
        uvIndexLabel.text = uvIndex
        self.view.backgroundColor = getBackgroundColorForUVIndex(uvIndex)
    }
    
    func buildInfoText(city: String, timeStamp: NSDate) -> NSString {
        return "UV Index in " + city + " at " + dateFormatter.stringFromDate(timeStamp)
    }
    
    func buildDescriptionForUVIndex(uvIndex: String) -> NSString {
        return "is " + getDescriptionForUVIndex(uvIndex)
    }
    
    func getDescriptionForUVIndex(uvIndex: String) -> NSString {
        switch uvIndex {
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
    
    func getBackgroundColorForUVIndex(uvIndex: String) -> UIColor {
        switch uvIndex {
        case "":
            return UIColor.lightGrayColor()
        case "0", "1", "2":
            return UIColor.greenColor()
        case "3", "4", "5":
            return UIColor.yellowColor()
        case "6", "7":
            return UIColor.orangeColor()
        case "8", "9", "10":
            return UIColor.redColor()
        default:
            return UIColor.purpleColor()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        getTheStuff()
    }

}

