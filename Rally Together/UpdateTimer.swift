//
//  UpdateTimer.swift
//  Rally Together
//
//  Created by Michael Hassin on 1/22/15.
//  Copyright (c) 2015 strangerware. All rights reserved.
//

import UIKit

class UpdateTimer: NSObject {
    
    var timer: NSTimer?
    
    let interval = 5.0 // seconds

    func go() {
        stop()
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("pulse"), userInfo: nil, repeats: true)
    }
    
    func stop() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func pulse() {
        UserBucket.refreshAllUsersWithCallback { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("didRefreshUsers", object: nil)
        }
    }
}
