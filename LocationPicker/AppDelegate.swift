//
//  AppDelegate.swift
//  LocationPicker
//
//  Created by Tomas Radvansky on 19/08/2015.
//  Copyright © 2015 Radvansky Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

let CURRENTLOCATIONCHANGED = "CurrentLocationChangedNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    var currentStringLocation:String?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyBz3zWo0bW1jrYjCxK_lhWYZnlXr0Oc980")
        self.startUpdatingLocation()
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
    
    func startUpdatingLocation()
    {
        print("\(NSDate()) - <LocationManager> - StartUpdatingLocation - INIT")
        if let locMan:CLLocationManager = self.locationManager
        {
            if CLLocationManager.locationServicesEnabled() {
                //Check if we have permissions
                let authorizationStatus:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
                if (authorizationStatus == CLAuthorizationStatus.AuthorizedAlways ||
                    authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse)
                {
                    print("\(NSDate()) - <LocationManager> - StartUpdatingLocation - Success")
                    locMan.startUpdatingLocation()
                }
                else
                {
                    //User disabled location services manually !
                }
            }
            else
            {
                //User disabled location services manually !
            }
        }
        else
        {
            //Proper init
            self.locationManager = CLLocationManager()
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.distanceFilter = 100 // meters
            self.locationManager?.delegate = self
            if (self.locationManager?.respondsToSelector(Selector("requestAlwaysAuthorization")) != nil) {
                self.locationManager?.requestWhenInUseAuthorization()
            }
            if CLLocationManager.locationServicesEnabled() {
                //Check if we have permissions
                let authorizationStatus:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
                if (authorizationStatus == CLAuthorizationStatus.AuthorizedAlways ||
                    authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse)
                {
                    print("\(NSDate()) - <LocationManager> - StartUpdatingLocation - Success")
                    self.locationManager?.startUpdatingLocation()
                }
                else
                {
                    //User disabled location services manually !
                }
            }
            else
            {
                //User disabled location services manually !
            }
        }
        
    }

    
    func stopUpdatingLocation()
    {
        print("\(NSDate()) - <LocationManager> - StopUpdatingLocation")
        if let locMan:CLLocationManager = self.locationManager
        {
            locMan.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(NSDate()) - <LocationManager> - Error - \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocation = locations.last
        {
            print("\(NSDate()) - <LocationManager> Location - \(location.coordinate.latitude) : \(location.coordinate.longitude)")
            self.currentLocation = location
            let geoCoder:CLGeocoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if placemarks != nil
                {
                    if placemarks?.count > 0
                    {
                        self.currentStringLocation = placemarks!.first!.locality!
                    }
                    else
                    {
                        self.currentStringLocation = ""
                    }
                }
                else
                {
                    self.currentStringLocation = ""
                }
            })
            NSNotificationCenter.defaultCenter().postNotificationName(CURRENTLOCATIONCHANGED, object: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var statusStr:String = "Unhandled authorization status"
        
        switch status {
        case .NotDetermined:
            statusStr = ".NotDetermined"
            break
            
        case .AuthorizedAlways:
            statusStr = ".Authorized"
            break
            
        case .AuthorizedWhenInUse:
            statusStr = ".Authorized"
            break
            
        case .Denied:
            statusStr = ".Denied"
            break
            
        default:
            statusStr = "Unhandled authorization status"
            break
            
        }
        print("\(NSDate()) - <LocationManager> - didChangeAuthorizationStatus - \(statusStr)")
    }}

