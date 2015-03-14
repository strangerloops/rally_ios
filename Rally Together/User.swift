//
//  User.swift
//  Rally Together
//
//  Created by Michael Hassin on 12/15/14.
//  Copyright (c) 2014 strangerware. All rights reserved.
//

import UIKIt
import CoreLocation

@objc(User) class User: NSRRemoteObject {
        
    var latitude : NSNumber?
    var longitude : NSNumber?
    var vendorID : String?
    var tag : Tag?
    
    override func shouldOnlySendIDKeyForNestedObjectProperty(property: String!) -> Bool {
        return property == "tag"
    }
    
    func hasLocation() -> Bool {
        return (latitude != nil) && (longitude != nil)
    }
    
    func hasTag() -> Bool {
        return tag != nil
    }
    
    func location() -> CLLocation { // TODO: unsafe
        return CLLocation(latitude: Double(latitude!), longitude: Double(longitude!))
    }
    
    func isCloserThan(otherUser: User) -> Bool {
        if let currentUser = UserBucket.loggedInUser() {
            return currentUser.location().distanceFromLocation(location()) < otherUser.location().distanceFromLocation(location())
        }
        return false
    }
}