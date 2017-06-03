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
    var session = URLSession.shared
    var sessionID: String? = nil
    var userKey: String? = nil
    var fbToken: String? = nil
    
    var localUser: LocalUser? = nil // app user
    
    //# MARK: - Authentication
    func authenticateWithFacebook(_ token: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        fbToken = token
        
        getFacebookAuthenticationResults(token) { (success, results, error) in
            
            if success {
                self.saveLoginCredentials(results!) { (success, error) in
                    if success {
                        completionHandlerForAuth(true, nil)
                    }
                    else {
                        completionHandlerForAuth(false, error)
                    }
                }
            }
            else {
                completionHandlerForAuth(false, error)
            }
        }
    }
    
    func logoutFromFacebook() {
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.fbToken = nil
    }
    
    func authenticateWithUdacity(_ username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        getUdacityAuthenticationResults(username, password: password) { (success, results, error) in
            
            if success {
                self.saveLoginCredentials(results!) { (success, error) in
                    if success {
                        completionHandlerForAuth(true, nil)
                    }
                    else {
                        completionHandlerForAuth(false, error)
                    }
                }
            }
            else {
                completionHandlerForAuth(false, error)
            }
        }
    }
    
    fileprivate func saveLoginCredentials(_ results: [String:AnyObject], completionHandlerForSaveLoginCredentials: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        guard let session = results[OTMClient.AuthJSONResponseKeys.Session] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.Session)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(false, NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        guard let sId = session[OTMClient.AuthJSONResponseKeys.SessionID] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.SessionID)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(false, NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        guard let account = results[OTMClient.AuthJSONResponseKeys.Account] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.Account)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(false, NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        guard let uKey = account[OTMClient.AuthJSONResponseKeys.UserKey] else {
            let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(OTMClient.AuthJSONResponseKeys.UserKey)' not found in login-results."]
            completionHandlerForSaveLoginCredentials(false, NSError(domain: "saveLoginCredentials", code: 1, userInfo: userInfo))
            return
        }
        
        self.sessionID = sId as? String
        self.userKey = uKey as? String
        
        requestUdacityUserName(self.userKey!) { (success, result, error) in
            
            if success {
                self.localUser = result!
                completionHandlerForSaveLoginCredentials(true, nil)

            }
            else {
                completionHandlerForSaveLoginCredentials(false, error)
            }
            
            print("login request results: \(results)")
        }
    }
    
    func logoutFromUdacity(_ completionHandlerForLogout: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        getLogoutResults() { (success, results, error) in
            
            self.sessionID = nil
            self.userKey = nil
            self.localUser = nil
            
            if success {
                completionHandlerForLogout(true, nil)
            }
            else {
                completionHandlerForLogout(false, error)
            }
        }
    }
    
    //# MARK: Udacity User Data
    func requestUdacityUserName(_ userID: String, completionHandlerForUdacityUserName: @escaping (_ success: Bool, _ result: LocalUser?, _ error: NSError?) -> Void) {

        getUdacityUserData(userID) { (success, results, error) in
            
            if success {
                if let user = results![UdacityUser.User] {
                    
                    let firstName = user[UdacityUser.FirstName] as? String ?? ""
                    let lastName = user[UdacityUser.LastName] as? String ?? ""
                    let localUser = LocalUser(firstName: firstName, lastName: lastName)
                    
                    completionHandlerForUdacityUserName(true, localUser, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(UdacityUser.User)' not found in login-results."]
                    print(userInfo)
                    completionHandlerForUdacityUserName(false, nil, NSError(domain: "requestUdacityUserName", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForUdacityUserName(false, nil, error)
            }
        }
    }

    //# MARK: - URL Request Data Tasks Prep & Call
    fileprivate func getUdacityAuthenticationResults(_ username: String, password: String, completionHandlerForUdacityAuthentication: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // create json body with username & password
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        // make the request
        _ = taskForPOSTMethod(AuthMethods.AuthenticationSessionNew, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForUdacityAuthentication(false, nil, error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForUdacityAuthentication(true, results, nil)
                    
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForUdacityAuthentication(false, nil, NSError(domain: "getUdacityAuthenticationResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    fileprivate func getFacebookAuthenticationResults(_ accessToken: String, completionHandlerForFacebookAuthentication: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // create json body with fb access token
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
        
        // make the request
        _ = taskForPOSTMethod(AuthMethods.AuthenticationSessionNew, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForFacebookAuthentication(false, nil, error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForFacebookAuthentication(true, results, nil)
                    
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForFacebookAuthentication(false, nil, NSError(domain: "getFacebookAuthenticationResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    fileprivate func getLogoutResults(_ completionHandlerForLogout: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        
        // make the request
        _ = taskForDELETEMethod(AuthMethods.AuthenticationSessionNew, parameters: parameters) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForLogout(false, nil, error)
                
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForLogout(true, results, nil)
                    
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForLogout(false, nil, NSError(domain: "getLogoutResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    fileprivate func getUdacityUserData(_ userId: String, completionHandlerForUserData: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        // specify parameters
        let parameters = [String:AnyObject]()
        let method = "/users/\(userId)"
        
        // make the request
        _ = taskForGETMethod(method, parameters: parameters) { (result, error) in
            
            if let error = error {
                print(error)
                completionHandlerForUserData(false, nil, error)
            }
            else {
                if let results = result as? [String:AnyObject] {
                    completionHandlerForUserData(true, results, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForUserData(false, nil, NSError(domain: "getUdacityUserData", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    //# MARK: - URL Request Data Tasks
    fileprivate func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // build the URL, Configure the request
        var request = URLRequest(url: otmAuthURLFromParameters(parameters, withPathExtension: method))
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        request.timeoutInterval = TimeInterval(10)
        
        // make the request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: Error?, localError: String) {
                print(error ?? "", localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            if let error = error {
                if error._code == NSURLErrorTimedOut {
                    sendError(error, localError: OTMClient.ErrorMessage.NetworkTimeout)
                    return
                }
            }

            guard (error == nil) else {
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError + "\(String(describing: error?.localizedDescription != nil ? error?.localizedDescription : "[No description]"))")
                return
            }

            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // check HTTP status codes (40x errors and 2XX response)
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
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
        };
        
        // start the request
        task.resume()
        
        return task
    }
    
    fileprivate func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = URLRequest(url: otmAuthURLFromParameters(parameters, withPathExtension: method))
        
        // make the request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            func sendError(_ error: Error?, localError: String) {
                print(error ?? "", localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            if let error = error {
                if error._code == NSURLErrorTimedOut {
                    sendError(error, localError: OTMClient.ErrorMessage.NetworkTimeout)
                    return
                }
            }
            
            guard (error == nil) else {
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError + "\(String(describing: error?.localizedDescription != nil ? error?.localizedDescription : "[No description]"))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 5, completionHandlerForConvertData: completionHandlerForGET)
        }) 
        
        // start the request
        task.resume()
        
        return task
    }
    
    fileprivate func taskForDELETEMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // build the URL, Configure the request
        var request = URLRequest(url: otmAuthURLFromParameters(parameters, withPathExtension: method))

        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // make the request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            func sendError(_ error: Error?, localError: String) {
                print(error ?? "", localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForDELETE(nil, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            if let error = error {
                if error._code == NSURLErrorTimedOut {
                    sendError(error, localError: OTMClient.ErrorMessage.NetworkTimeout)
                    return
                }
            }

            guard (error == nil) else {
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError + "\(String(describing: error?.localizedDescription != nil ? error?.localizedDescription : "[No description]" ))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 5, completionHandlerForConvertData: completionHandlerForDELETE)
        }) 
        
        // start the request
        task.resume()
        
        return task
    }
    
    //# MARK: - URL Creation
    fileprivate func otmAuthURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.AuthConstants.ApiScheme
        components.host = OTMClient.AuthConstants.ApiHost
        components.path = OTMClient.AuthConstants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    //# MARK: JSON conversion
    func convertDataWithCompletionHandler(_ data: Data, offset: Int, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any!
        do {
            let newData = data.subdata(in: offset ..< data.count - offset)
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.JsonParseError + "\(data)"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult as AnyObject, nil)
    }
    
    //# Shared Instance
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}
