//
//  OnTheMapClient.swift
//  On The Map
//
//  Created by Sascha Stanic on 04.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    //# MARK: Attributes
    var session = NSURLSession.sharedSession()
    var sessionID: String? = nil
    var userKey: String? = nil
    var fbToken: String? = nil
    
    var localUser: LocalUser? = nil // app user
    
    //# MARK: - Authentication
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
        self.fbToken = nil
    }
    
    func authenticateWithUdacity(username: String, password: String, completionHandlerForAuth: (success: Bool, error: NSError?) -> Void) {
        
        getUdacityAuthenticationResults(username, password: password) { (success, results, error) in
            
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
    
    private func saveLoginCredentials(results: [String:AnyObject], completionHandlerForSaveLoginCredentials: (success: Bool, error: NSError?) -> Void) {
        
        guard let session = results[OTMClient.AuthJSONResponseKeys.Session] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.Session)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(success: false, error: NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        guard let sId = session[OTMClient.AuthJSONResponseKeys.SessionID] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.SessionID)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(success: false, error: NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        guard let account = results[OTMClient.AuthJSONResponseKeys.Account] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.Account)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(success: false, error: NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        guard let uKey = account[OTMClient.AuthJSONResponseKeys.UserKey] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.UserKey)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(success: false, error: NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        self.sessionID = sId as? String
        self.userKey = uKey as? String
        
        requestUdacityUserName(self.userKey!) { (success, result, error) in
            
            if success {
                self.localUser = result!
                completionHandlerForSaveLoginCredentials(success: true, error: nil)

            }
            else {
                completionHandlerForSaveLoginCredentials(success: false, error: error)
            }
            
            print("login request results: \(results)")
        }
    }
    
    func logoutFromUdacity(completionHandlerForLogout: (success: Bool, error: NSError?) -> Void) {
        
        getLogoutResults() { (success, results, error) in
            
            self.sessionID = nil
            self.userKey = nil
            self.localUser = nil
            
            if success {
                completionHandlerForLogout(success: true, error: nil)
            }
            else {
                completionHandlerForLogout(success: false, error: error)
            }
        }
    }
    
    //# MARK: Udacity User Data
    func requestUdacityUserName(userID: String, completionHandlerForUdacityUserName: (success: Bool, result: LocalUser?, error: NSError?) -> Void) {

        getUdacityUserData(userID) { (success, results, error) in
            
            if success {
                if let user = results![UdacityUser.User] {
                    
                    let firstName = user[UdacityUser.FirstName] as? String ?? ""
                    let lastName = user[UdacityUser.LastName] as? String ?? ""
                    let localUser = LocalUser(firstName: firstName, lastName: lastName)
                    
                    completionHandlerForUdacityUserName(success: true, result: localUser, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(UdacityUser.User)' not found in login-results."]
                    print(userInfo)
                    completionHandlerForUdacityUserName(success: false, result: nil, error: NSError(domain: "requestUdacityUserName", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForUdacityUserName(success: false, result: nil, error: error)
            }
        }
    }

    //# MARK: - URL Request Data Tasks Prep & Call
    private func getUdacityAuthenticationResults(username: String, password: String, completionHandlerForUdacityAuthentication: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // create json body with username & password
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        // make the request
        taskForPOSTMethod(AuthMethods.AuthenticationSessionNew, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForUdacityAuthentication(success: false, results: nil, error: error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForUdacityAuthentication(success: true, results: results, error: nil)
                    
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForUdacityAuthentication(success: false, results: nil, error: NSError(domain: "getUdacityAuthenticationResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    private func getFacebookAuthenticationResults(accessToken: String, completionHandlerForFacebookAuthentication: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // create json body with fb access token
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
        
        // make the request
        taskForPOSTMethod(AuthMethods.AuthenticationSessionNew, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForFacebookAuthentication(success: false, results: nil, error: error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForFacebookAuthentication(success: true, results: results, error: nil)
                    
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForFacebookAuthentication(success: false, results: nil, error: NSError(domain: "getFacebookAuthenticationResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    private func getLogoutResults(completionHandlerForLogout: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // make the request
        taskForDELETEMethod(AuthMethods.AuthenticationSessionNew, parameters: parameters) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForLogout(success: false, results: nil, error: error)
                
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForLogout(success: true, results: results, error: nil)
                    
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForLogout(success: false, results: nil, error: NSError(domain: "getLogoutResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    private func getUdacityUserData(userId: String, completionHandlerForUserData: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        let method = "/users/\(userId)"
        
        // make the request
        taskForGETMethod(method, parameters: parameters) { (result, error) in
            
            if let error = error {
                print(error)
                completionHandlerForUserData(success: false, results: nil, error: error)
            }
            else {
                if let results = result as? [String:AnyObject] {
                    completionHandlerForUserData(success: true, results: results, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForUserData(success: false, results: nil, error: NSError(domain: "getUdacityUserData", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    //# MARK: - URL Request Data Tasks
    private func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmAuthURLFromParameters(parameters, withPathExtension: method))
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = NSTimeInterval(10)
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: NSError?, localError: String) {
                print(error, localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            if let error = error {
                if error.code == NSURLErrorTimedOut {
                    sendError(error, localError: OTMClient.ErrorMessage.NetworkTimeout)
                    return
                }
            }

            guard (error == nil) else {
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError.stringByAppendingString("\(error?.localizedDescription != nil ? error?.localizedDescription : "[No description]")"))
                return
            }

            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // check HTTP status codes (40x errors and 2XX response)
            if let statusCode = (response as? NSHTTPURLResponse)?.statusCode {
                if statusCode == 400 || statusCode == 401 || statusCode == 403 {
                    sendError(error, localError: String(statusCode))
                    return
                }
                
                if statusCode < 200 || statusCode > 299 {
                    sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
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
    
    private func taskForGETMethod(method: String, parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmAuthURLFromParameters(parameters, withPathExtension: method))
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: NSError?, localError: String) {
                print(error, localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            if let error = error {
                if error.code == NSURLErrorTimedOut {
                    sendError(error, localError: OTMClient.ErrorMessage.NetworkTimeout)
                    return
                }
            }
            
            guard (error == nil) else {
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError.stringByAppendingString("\(error?.localizedDescription != nil ? error?.localizedDescription : "[No description]")"))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 5, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    private func taskForDELETEMethod(method: String, parameters: [String:AnyObject], completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmAuthURLFromParameters(parameters, withPathExtension: method))

        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: NSError?, localError: String) {
                print(error, localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForDELETE(result: nil, error: NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            if let error = error {
                if error.code == NSURLErrorTimedOut {
                    sendError(error, localError: OTMClient.ErrorMessage.NetworkTimeout)
                    return
                }
            }

            guard (error == nil) else {
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError.stringByAppendingString("\(error?.localizedDescription != nil ? error?.localizedDescription : "[No description]")"))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 5, completionHandlerForConvertData: completionHandlerForDELETE)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    //# MARK: - URL Creation
    private func otmAuthURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = OTMClient.AuthConstants.ApiScheme
        components.host = OTMClient.AuthConstants.ApiHost
        components.path = OTMClient.AuthConstants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    //# MARK: JSON conversion
    func convertDataWithCompletionHandler(data: NSData, offset: Int, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.JsonParseError.stringByAppendingString("\(data)")]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    //# Shared Instance
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}