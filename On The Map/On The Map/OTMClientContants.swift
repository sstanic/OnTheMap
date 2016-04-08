//
//  OTMClientContants.swift
//  On The Map
//
//  Created by Sascha Stanic on 04.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

extension OTMClient {
    struct Constants {

        static let ApiKey : String = "..."
        
        // URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // Methods
    struct Methods {

        // Authentication
        static let AuthenticationSessionNew = "/session"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
//        static let ApiKey = "api_key"
//        static let SessionID = "id"
//        static let RequestToken = "request_token"
//        static let Query = "query"
        
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
//        static let MediaType = "media_type"
//        static let MediaID = "media_id"
//        static let Favorite = "favorite"
//        static let Watchlist = "watchlist"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
//        // General
//        static let StatusMessage = "status_message"
//        static let StatusCode = "status_code"
        
        // Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let Account = "account"
        
        static let SessionID = "id"
        
        // Account
        static let UserID = "key"
    }
}