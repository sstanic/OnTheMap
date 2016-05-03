//
//  OTMClientContants.swift
//  On The Map
//
//  Created by Sascha Stanic on 04.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

extension OTMClient {
    struct AuthConstants {

        static let ApiKey : String = "..."
        
        // URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // Methods
    struct AuthMethods {

        // Authentication
        static let AuthenticationSessionNew = "/session"
    }
    
    // MARK: Parameter Keys
    struct AuthParameterKeys {
//        static let ApiKey = "api_key"
//        static let SessionID = "id"
//        static let RequestToken = "request_token"
//        static let Query = "query"
        
        
    }
    
    // MARK: JSON Body Keys
    struct AuthJSONBodyKeys {
//        static let MediaType = "media_type"
//        static let MediaID = "media_id"
//        static let Favorite = "favorite"
//        static let Watchlist = "watchlist"
    }
    
    // MARK: JSON Response Keys
    struct AuthJSONResponseKeys {
        
//        // General
//        static let StatusMessage = "status_message"
//        static let StatusCode = "status_code"
        
        // Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let Account = "account"
        
        static let SessionID = "id"
        
        // Account
        static let UserKey = "key"
    }
    
    struct UdacityUser {
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let UnknownUser = "<unknown>"
    }
    
    
    struct DataConstants {
        
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes/StudentLocation"
    }
    
    struct DataMethods {
        
        static let DataAccess = "/StudentLocation"
    }
    
    struct DataParameterKeys {
        
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
    }
    
    struct DataJSONBodyKeys {
        
    }
    
    struct DataJSONResponseKeys {
        
        static let Results = "results"
    }
}