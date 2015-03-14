//
//  LocationManager.swift
//  Rally Together
//
//  Created by Michael Hassin on 1/25/15.
//  Copyright (c) 2015 strangerware. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    let distanceUpdateThreshold = 15.0 // meters
    
    override init() {
        locationManager = CLLocationManager()
    }
    
    func go() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let user = UserBucket.loggedInUser() {
            let newLocation = locations.last as CLLocation
            if !user.hasLocation() || user.location().distanceFromLocation(newLocation) > distanceUpdateThreshold {
                user.latitude  = newLocation.coordinate.latitude
                user.longitude = newLocation.coordinate.longitude
                user.remoteUpdateAsync { error in
                    if error != nil {
                        println(error)
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName("didRefreshLocation", object: nil)
                    }
                }
            }
        }
    }
}