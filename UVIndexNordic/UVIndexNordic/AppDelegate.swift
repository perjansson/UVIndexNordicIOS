//
//  AppDelegate.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        println("### handleWatchKitExtensionRequest")
        
        var uvIndexDictionary = Dictionary<String, String>()
        
        let backgroundTaskIdentifier = application.beginBackgroundTaskWithName("watchKitExtensionRequest", expirationHandler: { () -> Void in
            uvIndexDictionary["error"] = "Oh no! The app timed out while getting the latest uv index."
            reply([:])
        })
        
        var locationManager = CLLocationManager()
        var location = locationManager.location
        var forecastRetriever = ForecastRetriever() { (uvIndex : UvIndex?, error : NSError?) in
            if uvIndex != nil {
                uvIndexDictionary["city"] = uvIndex!.city
                uvIndexDictionary["uvIndex"] = uvIndex!.uvIndex
                uvIndexDictionary["longitude"] = "\(uvIndex!.longitude)"
                uvIndexDictionary["latitude"] = "\(uvIndex!.latitude)"
            }
            if error != nil {
                uvIndexDictionary["error"] = error!.localizedDescription
            }
            reply!(uvIndexDictionary as [NSObject : AnyObject])
            application.endBackgroundTask(backgroundTaskIdentifier)
        }
        
        forecastRetriever.getUVIndex(location)
    }

}

