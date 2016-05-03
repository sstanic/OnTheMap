//
//  UdacityStudent.swift
//  On The Map
//
//  Created by Sascha Stanic on 25.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

struct UdacityStudent {
    var firstName: String?
    var lastName: String?
    
    var name: String? {
        let n = firstName!.stringByAppendingString(" ").stringByAppendingString(lastName!)
        
        if firstName!.isEmpty && lastName!.isEmpty {
            return OTMClient.UdacityUser.UnknownUser
        }
        else {
            return n
        }
    }
    
    init(firstName: String?, lastName: String?) {
        
        self.firstName = firstName ?? ""
        self.lastName = lastName ?? ""
    }
}