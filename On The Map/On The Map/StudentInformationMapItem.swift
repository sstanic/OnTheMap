//
//  StudentInformationMapItem.swift
//  On The Map
//
//  Created by Sascha Stanic on 19.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation
import MapKit

class StudentInformationMapItem: NSObject, MKAnnotation {
    
    let uniqueKey: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(uniqueKey: String, name: String, mediaUrl: String, location: CLLocationCoordinate2D) {
        
        self.uniqueKey = uniqueKey
        title = name
        subtitle = mediaUrl
        self.coordinate = location
        
        super.init()
    }
    
    var title: String? {
        
        willSet { willChangeValueForKey("title") }
        didSet { didChangeValueForKey("title") }
    }
}