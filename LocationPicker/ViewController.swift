//
//  ViewController.swift
//  LocationPicker
//
//  Created by Tomas Radvansky on 19/08/2015.
//  Copyright © 2015 Radvansky Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class ViewController: UIViewController,GMSMapViewDelegate {
    
    @IBOutlet weak var mapContainer: GMSMapView!
    
    @IBOutlet weak var dropOffButton: UIButton!
    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var currentStrLabel: UILabel!
    
    var currentTabIndex = 0
    var pickUpLocation:CLLocation?
    var dropOffLocation:CLLocation?
    var pickUpLocationStr:String = ""
    var dropOffLocationStr:String = ""
    var pickUpMarker:GMSMarker?
    var dropOffMarker:GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Find locations"
        self.mapContainer.delegate = self
        
        self.mapContainer.settings.myLocationButton = false
        
        //Setup notifications
        NSNotificationCenter.defaultCenter().addObserverForName(CURRENTLOCATIONCHANGED, object: nil, queue: nil) { (notif:NSNotification) -> Void in
            if let currentDelegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            {
                if let currentLocation:CLLocation = currentDelegate.currentLocation
                {
                    self.mapContainer.myLocationEnabled = true
                    self.mapContainer.settings.myLocationButton = true
                    self.mapContainer.camera = GMSCameraPosition.cameraWithTarget(currentLocation.coordinate, zoom: 6)
                }
            }
        }
        
        self.setCurrentTab(currentTabIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- GMSMapViewDelegate
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        if let currentDelegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        {
            if let currentLocation:CLLocation = currentDelegate.currentLocation
            {
                self.mapContainer.camera = GMSCameraPosition.cameraWithTarget(currentLocation.coordinate, zoom: 6)
                return true
            }
        }
        return false
    }
    
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        if self.currentTabIndex == 0
        {
            //Pickup
            if self.pickUpMarker != nil
            {
                self.pickUpMarker?.map = nil
            }
            self.pickUpMarker = GMSMarker(position: coordinate)
            
            self.pickUpMarker?.map = self.mapContainer
            self.pickUpLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geoCoder:CLGeocoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(self.pickUpLocation!, completionHandler: { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if placemarks != nil
                {
                    if placemarks?.count > 0
                    {
                        self.pickUpLocationStr = placemarks!.first!.locality!
                        self.pickUpMarker?.title = self.pickUpLocationStr
                    }
                    else
                    {
                        self.pickUpLocationStr = ""
                    }
                }
                else
                {
                    self.pickUpLocationStr = ""
                }
                self.setCurrentTab(self.currentTabIndex)
            })
        }
        else
        {
            //DropOff
            if self.dropOffMarker != nil
            {
                self.dropOffMarker?.map = nil
            }
            self.dropOffMarker = GMSMarker(position: coordinate)
            self.dropOffMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.dropOffMarker?.map = self.mapContainer
            self.dropOffLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geoCoder:CLGeocoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(self.dropOffLocation!, completionHandler: { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if placemarks != nil
                {
                    if placemarks?.count > 0
                    {
                        self.dropOffLocationStr = placemarks!.first!.locality!
                        self.dropOffMarker?.title = self.pickUpLocationStr
                    }
                    else
                    {
                        self.dropOffLocationStr = ""
                    }
                }
                else
                {
                    self.dropOffLocationStr = ""
                }
                self.setCurrentTab(self.currentTabIndex)
            })
            
        }
    }
    
    
    //MARK:- Tabs
    func setCurrentTab(index:Int)
    {
        if index == 0
        {
            //Pickup
            self.pickUpButton.backgroundColor = UIColor.blueColor()
            self.dropOffButton.backgroundColor = UIColor.lightGrayColor()
            self.currentStrLabel.text = self.pickUpLocationStr
            self.currentTabIndex = 0
        }
        else
        {
            //DropOff
            self.pickUpButton.backgroundColor = UIColor.lightGrayColor()
            self.dropOffButton.backgroundColor = UIColor.blueColor()
            self.currentStrLabel.text = self.dropOffLocationStr
            self.currentTabIndex = 1
        }
    }
    
    @IBAction func pickUpBtnClicked(sender: AnyObject) {
        self.setCurrentTab(0)
    }
    
    @IBAction func dropOffBtnClicked(sender: AnyObject) {
        self.setCurrentTab(1)
    }
    
    
    //MARK:- Delegate
    @IBAction func doneBtnClicked(sender: AnyObject) {
        let currentDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
       let locationString = "User location: \(currentDelegate.currentStringLocation) Lat(\(currentDelegate.currentLocation?.coordinate.latitude)) Lon(\(currentDelegate.currentLocation?.coordinate.longitude)), Pickup location: \(self.pickUpLocationStr) Lat(\(self.pickUpLocation?.coordinate.latitude)) Lon(\(self.pickUpLocation?.coordinate.longitude)), Dropoff location \(self.dropOffLocationStr) Lat(\(self.dropOffLocation?.coordinate.latitude)) Lon(\(self.dropOffLocation?.coordinate.longitude))"
        let alert:UIAlertController = UIAlertController(title: "Picked Location", message: locationString, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            //
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}

