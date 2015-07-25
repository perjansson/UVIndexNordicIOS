//
//  ForecastRepository.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ForecastRetriever : NSObject, NSXMLParserDelegate {
    
    let FORECAST_PROVIDER_URL = "http://api.yr.no/weatherapi/uvforecast/1.0/?time=%@T12:00:00Z;content_type=text/xml"
    
    var locationManager : CLLocationManager!
    let dateFormatter = NSDateFormatter()
    
    var delegate : ViewController?
    var handler : ((uvIndex : UvIndex?, error : NSError?) -> Void)?
    
    var currentLocation : CLLocation?
    var forecasts : [Forecast] = []
    var currentParsingForecast : Forecast?
    
    var uvIndex : String?
    var city : String?
    var latitude : Double?
    var longitude : Double?
    
    init(delegate : ViewController) {
        super.init()
        self.delegate = delegate
        self.initForecastRetriever()
    }
    
    init(handler : (uvIndex : UvIndex?, error : NSError?) -> Void) {
        super.init()
        self.handler = handler
        self.initForecastRetriever()
    }
    
    func initForecastRetriever() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.uvIndex = ""
        self.city = ""
    }
    
    func getUVIndex(currentLocation : CLLocation) {
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
                        self.latitude = closestForecast.latitude
                        self.longitude = closestForecast.longitude
                    } else {
                        if self.handler != nil {
                            var userInfo = Dictionary<String, String>()
                            userInfo[NSLocalizedDescriptionKey] = "Oh no :( This app cannot find UV Index outside the Nordic countries, and you are in \(placeMark.country)"
                            var error = NSError(domain: "forecast_retriever", code: 1, userInfo: userInfo)
                            self.handler!(uvIndex: nil, error: error)
                        }
                        if self.delegate != nil {
                            self.delegate!.didNotFindValidCountry(placeMark.country)
                        }
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
            if self.handler != nil {
                handler!(uvIndex: UvIndex(uvIndex: self.uvIndex!, city: self.city!, longitude: self.longitude!, latitude: self.latitude!), error: nil)
            }
            if self.delegate != nil {
                self.delegate!.didReceiveUVIndexForLocationAndTime(self.uvIndex! as String, city: self.city! as String, timeStamp: NSDate())
            }
        } else {
            if self.handler != nil {
                var userInfo = Dictionary<String, String>()
                userInfo[NSLocalizedDescriptionKey] = "Oh no :( Could for some reason not find any UV Index for your location. Make sure you have internet access, that this app has access to your location and then touch anywhere on the screen to try again."
                var error = NSError(domain: "forecast_retriever", code: 1, userInfo: userInfo)
                self.handler!(uvIndex: nil, error: error)
            }
            if self.delegate != nil {
                self.delegate!.didNotReceivedUvIndexOrCity()
            }
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
