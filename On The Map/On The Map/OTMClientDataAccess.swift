//
//  OTMClientDataAccess.swift
//  On The Map
//
//  Created by Sascha Stanic on 18.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

extension OTMClient {
    
    //# MARK: Data Access StudentLocation
    func getStudentLocations(completionHandlerForGet: (success: Bool, results: [StudentInformation]?, error: NSError?) -> Void) {
        
        getDataAccessGetResults(OTMClient.DataConstants.StudentQueryLimit) { (success, results, error) in
            
            if success {
                if let resultList = results![DataJSONResponseKeys.Results] as? [[String:AnyObject]] {
                    var sLoc = [StudentInformation]()
                    for r in resultList {
                        let sl = StudentInformation(startValues: r)
                        sLoc.append(sl)
                    }
                    completionHandlerForGet(success: true, results: sLoc, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(DataJSONResponseKeys.Results)' not found in add-results."]
                    print(userInfo)
                    completionHandlerForGet(success: false, results: nil, error: NSError(domain: "getStudentLocations", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForGet(success: false, results: nil, error: error)
            }
        }
    }
    
    func addStudentLocation(studentInformation: StudentInformation, completionHandlerForAdd: (success: Bool, objectId: String?, error: NSError?) -> Void) {
        
        getDataAccessPostResults(studentInformation) { (success, results, error) in
            
            if success {
                if let objectId = results![DataJSONResponseKeys.ObjectId] as? String {
                    completionHandlerForAdd(success: true, objectId: objectId, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(DataJSONResponseKeys.ObjectId)' not found in add-results."]
                    print(userInfo)
                    completionHandlerForAdd(success: false, objectId: nil, error: NSError(domain: "addStudentLocation", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForAdd(success: false, objectId: nil, error: error)
            }
        }
    }
    
    func updateStudentLocation(studentInformation: StudentInformation, completionHandlerForUpdate: (success: Bool, error: NSError?) -> Void) {
        
        getDataAccessPutResults(studentInformation) { (success, results, error) in
            
            if success {
                
                // ignore <results>, not needed
                
                completionHandlerForUpdate(success: true, error: nil)
            }
            else {
                completionHandlerForUpdate(success: false, error: error)
            }
        }
    }
    
    func queryStudentLocation(uniqueKey: String, completionHandlerForQuery: (success: Bool, studentInformation: StudentInformation?, error: NSError?) -> Void) {
        
        getDataAccessQueryResults(uniqueKey) { (success, results, error) in
            
            if success {
                if let resultList = results![DataJSONResponseKeys.Results] as? [[String:AnyObject]] {
                    var sLoc = [StudentInformation]()
                    for r in resultList {
                        let sl = StudentInformation(startValues: r)
                        sLoc.append(sl)
                    }
                    
                    if sLoc.count > 0 {
                        completionHandlerForQuery(success: true, studentInformation: sLoc.first, error: nil)
                    }
                    else {
                        let userInfo = [NSLocalizedDescriptionKey : "User not found for unique key: \(uniqueKey)"]
                        print(userInfo)
                        completionHandlerForQuery(success: false, studentInformation: nil, error: NSError(domain: "queryStudentLocation", code: 2, userInfo: userInfo))
                    }
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(DataJSONResponseKeys.Results)' not found in query-results."]
                    print(userInfo)
                    completionHandlerForQuery(success: false, studentInformation: nil, error: NSError(domain: "queryStudentLocation", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForQuery(success: false, studentInformation: nil, error: error)
            }
        }
    }
    
    //# MARK: - URL Request Data Tasks Prep & Call
    private func getDataAccessGetResults(limit: Int, completionHandlerForGetResults: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        var parameters = [String:AnyObject]()
        parameters[DataParameterKeys.Limit] = limit
        parameters[DataParameterKeys.Order] = DataParameterKeys.OrderArg
        
        // make the request
        taskForDataGETMethod(parameters) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForGetResults(success: false, results: nil, error: error)
                
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForGetResults(success: true, results: results, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForGetResults(success: false, results: nil, error: NSError(domain: "getDataAccessGetResults", code: 2, userInfo: userInfo))

                }
            }
        }
    }
    
    private func getDataAccessQueryResults(uniqueKey: String, completionHandlerForQueryResults: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        var parameters = [String:AnyObject]()
        parameters[DataParameterKeys.Where] = "{\"uniqueKey\": \"\(uniqueKey)\"}"
        
        // make the request
        taskForDataGETMethod(parameters) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForQueryResults(success: false, results: nil, error: error)
                
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForQueryResults(success: true, results: results, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForQueryResults(success: false, results: nil, error: NSError(domain: "getDataAccessQueryResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    private func getDataAccessPostResults(studentInformation: StudentInformation, completionHandlerForPostResults: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        let parameters = [String:AnyObject]()
        
        let uniqueKey = studentInformation.uniqueKey
        let firstName = studentInformation.firstName
        let lastName = studentInformation.lastName
        let mapString = studentInformation.mapString
        let mediaUrl = studentInformation.mediaURL
        let latitude = studentInformation.latitude
        let longitude = studentInformation.longitude
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        // make the request
        taskForDataPOSTMethod(parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForPostResults(success: false, results: nil, error: error)
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForPostResults(success: true, results: results, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForPostResults(success: false, results: nil, error: NSError(domain: "getDataAccessPostResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    private func getDataAccessPutResults(studentInformation: StudentInformation, completionHandlerForPutResults: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let method = "/".stringByAppendingString(studentInformation.objectId)
        
        let uniqueKey = studentInformation.uniqueKey
        let firstName = studentInformation.firstName
        let lastName = studentInformation.lastName
        let mapString = studentInformation.mapString
        let mediaUrl = studentInformation.mediaURL
        let latitude = studentInformation.latitude
        let longitude = studentInformation.longitude
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        // make the request
        taskForDataPUTMethod(method, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForPutResults(success: false, results: nil, error: error)
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForPutResults(success: true, results: results, error: nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForPutResults(success: false, results: nil, error: NSError(domain: "getDataAccessPutResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    //# MARK: - URL Request Data Tasks
    private func taskForDataGETMethod(parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmDataURLFromParameters(parameters, withPathExtension: ""))
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.timeoutInterval = NSTimeInterval(OTMClient.DataConstants.Timeout)
        
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
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError.stringByAppendingString("\(error)"))
                return
            }
            
            // check HTTP status codes (2XX response)
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 0, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    private func taskForDataPOSTMethod(parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmDataURLFromParameters(parameters, withPathExtension: ""))
        request.HTTPMethod = "POST"
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = NSTimeInterval(DataConstants.Timeout)
        
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
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError.stringByAppendingString("\(error)"))
                return
            }
            
            // check HTTP status codes (2XX response)
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 0, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    private func taskForDataPUTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmDataURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "PUT"
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = NSTimeInterval(DataConstants.Timeout)
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: NSError?, localError: String) {
                print(error, localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForPUT(result: nil, error: NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            if let error = error {
                if error.code == NSURLErrorTimedOut {
                    sendError(error, localError: OTMClient.ErrorMessage.NetworkTimeout)
                    return
                }
            }

            guard (error == nil) else {
                sendError(error, localError: OTMClient.ErrorMessage.GeneralHttpRequestError.stringByAppendingString("\(error)"))
                return
            }
            
            // check HTTP status codes (2XX response)
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 0, completionHandlerForConvertData: completionHandlerForPUT)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    //# MARK: - URL Creation
    private func otmDataURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = OTMClient.DataConstants.ApiScheme
        components.host = OTMClient.DataConstants.ApiHost
        components.path = OTMClient.DataConstants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}