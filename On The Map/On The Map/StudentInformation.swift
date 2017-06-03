//
//  StudentInformation.swift
//  On The Map
//
//  Created by Sascha Stanic on 08.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var updatedAt: String
    var acl: String
    
    init(startValues: [String:AnyObject]) {
        
        objectId = ""
        uniqueKey = ""
        firstName = ""
        lastName = ""
        mapString = ""
        mediaURL = ""
        latitude = 0.0
        longitude = 0.0
        createdAt = ""
        updatedAt = ""
        acl = ""
        
        if isAvailable("objectId", dict: startValues) {
            objectId = startValues["objectId"] as! String
        }
        
        if isAvailable("uniqueKey", dict: startValues) {
            uniqueKey = startValues["uniqueKey"] as! String
        }
        
        if isAvailable("firstName", dict: startValues) {
            firstName = startValues["firstName"] as! String
        }
        
        if isAvailable("lastName", dict: startValues) {
            lastName = startValues["lastName"] as! String
        }
        
        if isAvailable("mapString", dict: startValues) {
            mapString = startValues["mapString"] as! String
        }
        
        if isAvailable("mediaURL", dict: startValues) {
            mediaURL = startValues["mediaURL"] as! String
        }
        
        if isAvailable("latitude", dict: startValues) {
            latitude = startValues["latitude"] as! Double
        }
        
        if isAvailable("longitude", dict: startValues) {
            longitude = startValues["longitude"] as! Double
        }
        
        if isAvailable("createdAt", dict: startValues) {
            createdAt = startValues["createdAt"] as! String
        }
        
        if isAvailable("updatedAt", dict: startValues) {
            updatedAt = startValues["updatedAt"] as! String
        }
        
        if isAvailable("acl", dict: startValues) {
            acl = startValues["acl"] as! String
        }
    }
    
    fileprivate func isAvailable(_ key: String, dict: [String:AnyObject]) -> Bool {
        
        guard dict[key] != nil else {
            return false
        }
        
        return true
    }
}
