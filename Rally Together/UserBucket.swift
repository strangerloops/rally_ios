//
//  UserBucket.swift
//  Rally Together
//
//  Created by Michael Hassin on 12/16/14.
//  Copyright (c) 2014 strangerware. All rights reserved.
//

import UIKit

class UserBucket: NSObject {
    
    private var user : User?
    private var everyUser : [User]!
    
    override init() {
        everyUser = []
    }
    
    class func refreshAllUsersWithCallback(callback: () -> Void) {
        User.remoteAllAsync { response, error in
            if error != nil {
                println(error)
            } else {
                self.sharedInstance.everyUser = response as [User]
                callback()
            }
        }
    }
    
    class func logUserIn(user: User) {
        sharedInstance.user = user
    }
    
    class func loggedInUser() -> User? {
        return sharedInstance.user
    }
    
    class func allUsers() -> [User] {
        return sharedInstance.everyUser
    }
    
    class var sharedInstance : UserBucket {
        struct Static {
            static var instance : UserBucket = UserBucket()
        }
        return Static.instance
    }
}