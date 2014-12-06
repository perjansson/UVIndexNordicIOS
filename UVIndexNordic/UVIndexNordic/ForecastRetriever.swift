//
//  ForecastRepository.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import Foundation
import CoreLocation

class ForecastRetriever : NSObject, NSXMLParserDelegate {
    
    let FORECAST_PROVIDER_URL = "http://api.yr.no/weatherapi/uvforecast/1.0/?time=%@T12:00:00Z;content_type=text/xml"
    
    let dateFormatter = NSDateFormatter()
    
    var delegate : ViewController
    
    var currentLocation : CLLocation? = CLLocation(latitude: CLLocationDegrees("59.3311630".doubleValue), longitude: CLLocationDegrees("17.9089110".doubleValue))
    var forecasts : [Forecast] = []
    var currentParsingForecast : Forecast?
    
    var uvIndex : NSString
    var city : NSString
    
    init(delegate:ViewController) {
        self.delegate = delegate
        self.uvIndex = ""
        self.city = ""
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func getUVIndex(delegate : ViewController) {
        var url = NSURL(string : String(format: FORECAST_PROVIDER_URL, dateFormatter.stringFromDate(NSDate())))
        var xmlParser = NSXMLParser(contentsOfURL: url)
        xmlParser?.delegate = self
        xmlParser?.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        switch elementName {
        case "location" :
            currentParsingForecast = Forecast()
            currentParsingForecast?.latitude = attributeDict["latitude"] as? NSString
            currentParsingForecast?.longitude = attributeDict["longitude"] as? NSString
        case "uvi_forecast" :
            currentParsingForecast?.uvIndex = String(Int(round((attributeDict["value"] as NSString).floatValue)))
            forecasts.append(currentParsingForecast!)
        default :
            break
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        findClosestForecast()
    }
    
    func findClosestForecast() {
        if !hasForecasts() || !hasCurrentLocation() {
            return
        }
        
        var closestForecast = forecasts[0] as Forecast
        for forecast in forecasts {
            closestForecast = getClosestForecastToLocation(currentLocation!, forecast1: closestForecast, forecast2: forecast)
        }

        findCityOfCurrentLocation(currentLocation!, closestForecast: closestForecast)
    }
    
    func getClosestForecastToLocation(currentLocation : CLLocation, forecast1 : Forecast, forecast2 : Forecast) -> Forecast {
        var location1 : CLLocation = CLLocation(latitude: CLLocationDegrees(forecast1.latitude!.doubleValue), longitude: CLLocationDegrees(forecast1.longitude!.doubleValue))
        var location2 : CLLocation = CLLocation(latitude: CLLocationDegrees(forecast2.latitude!.doubleValue), longitude: CLLocationDegrees(forecast2.longitude!.doubleValue))
        
        var meters1 : CLLocationDistance = location1.distanceFromLocation(currentLocation)
        var meters2 : CLLocationDistance = location2.distanceFromLocation(currentLocation)
        
        if meters1 < meters2 {
            return forecast1;
        } else {
            return forecast2;
        }
    }
    
    func findCityOfCurrentLocation(currentLocation : CLLocation, closestForecast : Forecast) {
        CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler:
            {(placemarks, error) in
                if placemarks.count > 0 {
                    let pm = placemarks[0] as CLPlacemark
                    self.city = pm.locality
                    self.uvIndex = closestForecast.uvIndex!
                    self.returnResultToDelegate()
                }
        })
    }
    
    func returnResultToDelegate() {
        if hasUVIndex() && hasCity() {
            self.delegate.didReceiveUVIndexForLocationAndTime(self.uvIndex, city: self.city, timeStamp: NSDate())
        }
    }
    
    func hasForecasts() -> Bool {
        return !forecasts.isEmpty
    }
    
    func hasCurrentLocation() -> Bool {
        return currentLocation != nil
    }
    
    func hasUVIndex() -> Bool {
        return self.uvIndex != ""
    }
    
    func hasCity() -> Bool {
        return self.city != ""
    }
    
}
