//
//  LaunchViewController.swift
//  Rally Together
//
//  Created by Michael Hassin on 1/15/15.
//  Copyright (c) 2015 strangerware. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("attemptLaunch"), name: "didRefreshLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("attemptLaunch"), name: "didRefreshUsers", object: nil)
        imageView = UIImageView(frame: view.bounds)
        view.addSubview(imageView)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "Launch")
        configureUser()
    }
    
    func configureUser() {
        let deviceVendorID = UIDevice.currentDevice().identifierForVendor.UUIDString
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if firstAppLaunch() {
            setUpNewUserWithVendorID(deviceVendorID)
        } else {
            getUserForVendorID(deviceVendorID)
        }
    }
    
    func firstAppLaunch() -> Bool {
        return !(NSUserDefaults.standardUserDefaults().boolForKey("alreadySynced"))
    }
    
    func getUserForVendorID(vendorID: String) {
        let request = NSRRequest.GET().routeToClass(object_getClass(User()), withCustomMethod: "user_for_vendor_id")
        request.queryParameters = ["vendor_id":vendorID]
        request.sendAsynchronous { jsonRep, error in
            if error != nil {
                println(error)
            } else {
                let user = User.objectsWithRemoteDictionaries([jsonRep]).first as User
                UserBucket.logUserIn(user)
            }
        }
    }
    
    func setUpNewUserWithVendorID(vendorID: String) {
        let user = User()
        user.vendorID = vendorID
        user.remoteCreateAsync { error in
            if error != nil {
                println(error)
            } else {
                UserBucket.logUserIn(user)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: "alreadySynced")
                defaults.synchronize()
            }
        }
    }
    
    func attemptLaunch() {
        if let user = UserBucket.loggedInUser() {
            if user.hasLocation() {
                presentAppInterior()
            }
        }
    }
    
    func presentAppInterior() {
        let mapView = MapViewController()
        let tagsNav = UINavigationController()
        tagsNav.viewControllers = [TagsViewController()]
        
        let tabs = UITabBarController()
        tabs.viewControllers = [mapView, tagsNav]
        mapView.tabBarItem = UITabBarItem(title:  "Map", image: UIImage(named: "Marker"), tag: 0)
        tagsNav.tabBarItem = UITabBarItem(title: "Tags", image: UIImage(named:   "Tags"), tag: 1)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didRefreshLocation", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didRefreshUsers", object: nil)
        presentViewController(tabs, animated: true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
