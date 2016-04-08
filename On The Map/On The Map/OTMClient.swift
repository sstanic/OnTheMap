//
//  OnTheMapClient.swift
//  On The Map
//
//  Created by Sascha Stanic on 04.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    var sessionID: String? = nil
    var userID: String? = nil
    var fbToken: String? = nil
    
    func authenticateWithFacebook(token: String, completionHandlerForAuth: (success: Bool, error: NSError?) -> Void) {
        
        fbToken = token
        
        getFacebookAuthenticationResults(token) { (success, results, error) in
            
            if success {
                self.saveLoginCredentials(results!) { (success, error) in
                    if success {
                        completionHandlerForAuth(success: true, error: nil)
                    }
                    else {
                        completionHandlerForAuth(success: false, error: error)
                    }
                }
            }
            else {
                completionHandlerForAuth(success: false, error: error)
            }
        }
    }
    
    func logoutFromFacebook() {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
//        let fbAccessToken = FBSDKAccessToken.currentAccessToken()
//        print("--logout--")
//        print("access token: \(fbAccessToken)")
//        print("----")
        
        self.fbToken = nil
    }
    
    func authenticateWithUdacity(username: String, password: String, completionHandlerForAuth: (success: Bool, error: NSError?) -> Void) {
        
        getUdacityAuthenticationResults(username, password: password) { (success, results, error) in
            
            if success {
//                let session = results!["session"]
//                let account = results!["account"]
//                
//                self.sessionID = session!["id"] as? String
//                self.userID = account!["key"] as? String
//                
//                let reg = account!["registered"] as? Bool
//                print("login request results: \(results!)")
//                print("registered: \(reg)")
                
                self.saveLoginCredentials(results!) { (success, error) in
                    if success {
                        completionHandlerForAuth(success: true, error: nil)
                    }
                    else {
                        completionHandlerForAuth(success: false, error: error)
                    }
                }
            }
            else {
                completionHandlerForAuth(success: false, error: error)
            }
        }
    }
    
    private func saveLoginCredentials(results: [String:AnyObject], completionHandlerForSaveLoginCredentials: (success: Bool, error: NSError?) -> Void) {
        
        guard let session = results["session"] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter 'session' not found in login-results."]
            completionHandlerForSaveLoginCredentials(success: false, error: NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        guard let account = results["account"] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter 'account' not found in login-results."]
            completionHandlerForSaveLoginCredentials(success: false, error: NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        self.sessionID = session["id"] as? String
        self.userID = account["key"] as? String
        
        completionHandlerForSaveLoginCredentials(success: true, error: nil)
        
        //        let reg = account["registered"] as? Bool
        //        print("login request results: \(results)")
        //        print("registered: \(reg)")
    }
    
    func logoutFromUdacity(completionHandlerForLogout: (success: Bool, errorString: String?) -> Void) {
        
        getLogoutResults() { (success, results, errorString) in
//            print("logout request results: \(results!)")
            
            self.sessionID = nil
            self.userID = nil
            
            if success {
                completionHandlerForLogout(success: true, errorString: nil)
            }
            else {
                completionHandlerForLogout(success: false, errorString: errorString)
            }
        }
    }

    private func getUdacityAuthenticationResults(username: String, password: String, completionHandlerForAuthentication: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // create json body with username & password
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        // make the request
        taskForPOSTMethod(Methods.AuthenticationSessionNew, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForAuthentication(success: false, results: nil, error: error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForAuthentication(success: true, results: results, error: nil)
                    
                } else {
                    print("Could not find \(OTMClient.JSONResponseKeys.Session) in \(results)")
                    completionHandlerForAuthentication(success: false, results: nil, error: error)
                }
            }
        }
    }
    
    private func getFacebookAuthenticationResults(accessToken: String, completionHandlerForAuthentication: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // create json body with fb access token
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
        
        // make the request
        taskForPOSTMethod(Methods.AuthenticationSessionNew, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForAuthentication(success: false, results: nil, error: error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForAuthentication(success: true, results: results, error: nil)
                    
                } else {
                    print("Could not find \(OTMClient.JSONResponseKeys.Session) in \(results)")
                    completionHandlerForAuthentication(success: false, results: nil, error: error)
                }
            }
        }
    }
    
    private func getLogoutResults(completionHandlerForLogout: (success: Bool, results: [String:AnyObject]?, errorString: String?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // make the request
        taskForDELETEMethod(Methods.AuthenticationSessionNew, parameters: parameters) { (results, error) in
            
            // check for errors and call the completion handler            
            if let error = error {
                print(error)
                completionHandlerForLogout(success: false, results: nil, errorString: "Login Failed.")
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForLogout(success: true, results: results, errorString: nil)
                    
                } else {
                    print("Could not find \(OTMClient.JSONResponseKeys.Session) in \(results)")
                    completionHandlerForLogout(success: false, results: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
//    private func getUserID(completionHandlerForUserID: (success: Bool, userID: Int?, errorString: String?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [OTMClient.ParameterKeys.SessionID: OTMClient.sharedInstance().sessionID!]
//        
//        /* 2. Make the request */
//        taskForGETMethod(Methods.Account, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                print(error)
//                completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
//            } else {
//                if let userID = results[OTMClient.JSONResponseKeys.UserID] as? Int {
//                    completionHandlerForUserID(success: true, userID: userID, errorString: nil)
//                } else {
//                    print("Could not find \(OTMClient.JSONResponseKeys.UserID) in \(results)")
//                    completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
//                }
//            }
//        }
//    }
    
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withPathExtension: method))
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = NSTimeInterval(5)
        
//        print("    ")
//        print("request: \(request)")
//        print("    ")
//        print("request body: \(jsonBody)")
//        print("    ")
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // check for specific error first
            if let error = error {
                if error.code == NSURLErrorTimedOut {
                    sendError(String(NSURLErrorTimedOut))
                    return
                }
            }
            
            // guard: Was there another error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // guard: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // check for 40x errors
            if let statusCode = (response as? NSHTTPURLResponse)?.statusCode {
                if statusCode == 400 || statusCode == 401 || statusCode == 403 {
                    sendError(String(statusCode))
                    return
                }
                
                // check: Did we get a successful 2XX response?
                if statusCode < 200 || statusCode > 299 {
                    sendError("Your request returned a status code other than 2xx! (\(statusCode)")
                    return
                }
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 5, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    func taskForGETMethod(method: String, parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withPathExtension: method))
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // guard: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // guard: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // guard: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 5, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    func taskForDELETEMethod(method: String, parameters: [String:AnyObject], completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
//        
//        print("    ")
//        print("cookie: \(xsrfCookie)")
//        print("    ")
//        print("request: \(request)")
//        print("    ")
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(result: nil, error: NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
            
            // guard: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // guard: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // guard: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 5, completionHandlerForConvertData: completionHandlerForDELETE)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    // create a URL from parameters
    private func otmURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = OTMClient.Constants.ApiHost
        components.path = OTMClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, offset: Int, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}