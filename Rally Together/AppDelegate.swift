

//  AppDelegate.swift
//  Rally Together
//
//  Created by Michael Hassin on 12/7/14.
//  Copyright (c) 2014 strangerware. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: LocationManager!
    var timer: UpdateTimer!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let serverURL = "your server url"
        let httpAuthUsername = "your auth username"
        let httpAuthPassword = "your auth password"

        NSRConfig.defaultConfig().rootURL = NSURL(string:serverURL)
        NSRConfig.defaultConfig().basicAuthUsername = httpAuthUsername
        NSRConfig.defaultConfig().basicAuthPassword = httpAuthPassword
        NSRConfig.defaultConfig().configureToRailsVersion(NSRRailsVersion.Version3)
        
        UserBucket.refreshAllUsersWithCallback { }
        
        timer = UpdateTimer()
        locationManager = LocationManager()
        startUpdaters()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = LaunchViewController()
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        stopUpdaters()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        stopUpdaters()
    }
    
    
    func applicationDidBecomeActive(application: UIApplication) {
        startUpdaters()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        startUpdaters()
    }
    
    func stopUpdaters(){
        timer.stop()
        if let user = UserBucket.loggedInUser() {
            if !user.hasTag() {
                locationManager.stop()
            }
        }
    }
    
    func startUpdaters(){
        timer.go()
        locationManager.go()
    }
}