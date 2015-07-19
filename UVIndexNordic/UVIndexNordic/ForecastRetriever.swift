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
    
    var locationManager : CLLocationManager!
    let dateFormatter = NSDateFormatter()
    
    var delegate : ViewController?
    
    var currentLocation : CLLocation?
    var forecasts : [Forecast] = []
    var currentParsingForecast : Forecast?
    
    var uvIndex : NSString?
    var city : NSString?
    
    override init() {
        super.init()
    }
    
    init(delegate:ViewController) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.delegate = delegate
        self.uvIndex = ""
        self.city = ""
        
        super.init()
    }
    
    func getUVIndexAndReplyToWatchKitExtension() -> NSDictionary {
        var uvIndexDictionary = Dictionary<String, String>()
        uvIndexDictionary["city"] = "Rauma"
        uvIndexDictionary["uvIndexDescription"] = "High"
        uvIndexDictionary["uvIndex"] = "8"
        return uvIndexDictionary
    }
    
    func getUVIndex(currentLocation : CLLocation, delegate : ViewController) {
        self.currentLocation = currentLocation
        var url = NSURL(string : String(format: FORECAST_PROVIDER_URL, dateFormatter.stringFromDate(NSDate())))
        var xmlParser = NSXMLParser(contentsOfURL: url)
        xmlParser?.delegate = self
        xmlParser?.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        switch elementName {
        case "location" :
            currentParsingForecast = Forecast(longitude: (attributeDict["longitude"] as? NSString)!.doubleValue, latitude: (attributeDict["latitude"] as? NSString)!.doubleValue)
        case "uvi_forecast" :
            currentParsingForecast?.uvIndex = String(Int(round((attributeDict["value"] as! NSString).floatValue)))
            forecasts.append(currentParsingForecast!)
        default :
            break
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
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
        var location1 : CLLocation = CLLocation(latitude: CLLocationDegrees(forecast1.latitude!), longitude: CLLocationDegrees(forecast1.longitude!))
        var location2 : CLLocation = CLLocation(latitude: CLLocationDegrees(forecast2.latitude!), longitude: CLLocationDegrees(forecast2.longitude!))
        
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
                    let placeMark = placemarks[0] as! CLPlacemark
                    if self.isValidCountry(placeMark.ISOcountryCode) {
                        self.city = placeMark.locality
                        self.uvIndex = closestForecast.uvIndex!
                    } else {
                        self.delegate!.didNotFindValidCountry(placeMark.country)
                        return
                    }
                }
                self.returnResultToDelegate()
        })
    }
    
    func isValidCountry(ISOcountryCode : NSString) -> Bool {
        return ISOcountryCode == "SE" || ISOcountryCode == "NO" || ISOcountryCode == "DK" || ISOcountryCode == "FI" || ISOcountryCode == "IS"
    }
    
    func returnResultToDelegate() {
        if hasUVIndex() && hasCity() {
            self.delegate!.didReceiveUVIndexForLocationAndTime(self.uvIndex! as String, city: self.city! as String, timeStamp: NSDate())
        } else {
            self.delegate!.didNotReceivedUvIndexOrCity()
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
