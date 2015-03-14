//
//  Tag.swift
//  Rally Together
//
//  Created by Michael Hassin on 12/15/14.
//  Copyright (c) 2014 strangerware. All rights reserved.
//

import UIKit

@objc(Tag) class Tag: NSRRemoteObject {
    
    var name: String!

    func equalsTag(otherTag: Tag) -> Bool {
        if remoteID != nil && otherTag.remoteID != nil {
            return (remoteID.intValue == otherTag.remoteID.intValue || name.lowercaseString == otherTag.name.lowercaseString)
        } else {
            return name.lowercaseString == otherTag.name.lowercaseString
        }
    }
    
    func marker() -> UIImage {
        let  hash = name.lowercaseString.hashValue
        let   red = CGFloat((hash & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hash & 0x00FF00) >> 8 ) / 255.0
        let  blue = CGFloat (hash & 0x0000FF)        / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return tintImage(UIImage(named: "Marker")!, withColor: color)
    }
    
    func tintImage(originalImage: UIImage, withColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, 0.0)
        let rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)
        originalImage.drawInRect(rect)
        color.set()
        UIRectFillUsingBlendMode(rect, kCGBlendModeScreen)
        originalImage.drawInRect(rect, blendMode: kCGBlendModeDestinationIn, alpha: 1.0)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        return image
    }
}