//
//  OTMClientContants.swift
//  On The Map
//
//  Created by Sascha Stanic on 04.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

extension OTMClient {
    
    //# MARK: Authentication
    struct AuthConstants {
        
        // URL
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    struct AuthMethods {

        // Authentication
        static let AuthenticationSessionNew = "/session"
    }
    
    struct AuthJSONResponseKeys {
        
        // Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let Account = "account"
        
        static let SessionID = "id"
        
        // Account
        static let UserKey = "key"
    }
    
    //# MARK: Data Access
    struct DataConstants {
        
        // App and Api Keys
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // URL
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes/StudentLocation"

        static let StudentQueryLimit = 100
        
        static let Timeout = 10
    }
    
    struct DataMethods {
        
        static let DataAccess = "/StudentLocation"
    }
    
    struct DataParameterKeys {
        
        static let Limit = "limit"
        static let Skip = "skip"
        static let Where = "where"
        static let Order = "order"
        static let OrderArg = "-updatedAt"
    }
    
    struct DataJSONResponseKeys {
        
        static let Results = "results"
        static let ObjectId = "objectId"
    }
    
    //# MARK: Udacity User Data
    struct UdacityUser {
        
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let UnknownUser = "<unknown>"
    }
    
    struct StudentInformationAttributes {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
    }
    
    struct ErrorMessage {
        static let NetworkTimeout = "Network timeout. Please check your network connection."
        static let GeneralHttpRequestError = "Http request error. Error message: "
        static let StatusCodeFailure = "Your request returned a status code other than 2xx."
        static let NoDataFoundInRequest = "No data was returned by the request."
        static let JsonParseError = "Could not parse the data as JSON. Data: "
        
        static let HttpDataTaskFailed = "Http data task failed. Cannot convert result data."
    }
}