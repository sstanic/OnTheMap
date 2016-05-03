//
//  OTMClientDataAccess.swift
//  On The Map
//
//  Created by Sascha Stanic on 18.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

extension OTMClient {
    
    func getStudentLocations(completionHandlerForGet: (success: Bool, results: [StudentInformation]?, error: NSError?) -> Void) {
        
        getDataAccessGetResults(100) { (success, results, error) in
            
            if success {
//                print("student locations get result: \(results!)")
//                print("////////")
                
                let resultList = results![DataJSONResponseKeys.Results] as! [[String:AnyObject]]
                var sLoc = [StudentInformation]()
                for r in resultList {
                    let sl = StudentInformation(startValues: r)
                    sLoc.append(sl)
                }
                
                completionHandlerForGet(success: true, results: sLoc, error: nil)
            }
            else {
                completionHandlerForGet(success: false, results: nil, error: error)
            }
        }
    }
    
    func addStudentLocation(studentInformation: StudentInformation, completionHandlerForAdd: (success: Bool, error: NSError?) -> Void) {
        
        getDataAccessPostResults(studentInformation) { (success, results, error) in
            
            if success {
                
                // .... do sth with the results
                
                completionHandlerForAdd(success: true, error: nil)
            }
            else {
                completionHandlerForAdd(success: false, error: error)
            }
        }
    }
    
    func updateStudentLocation(studentInformation: StudentInformation, completionHandlerForUpdate: (success: Bool, error: NSError?) -> Void) {
        
        getDataAccessPutResults(studentInformation) { (success, results, error) in
            
            if success {
                
                // .... do sth with the results
                
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
                print("student locations get result: \(results!)")
                print("////////")
                
                let resultList = results![DataJSONResponseKeys.Results] as! [[String:AnyObject]]
                var sLoc = [StudentInformation]()
                for r in resultList {
                    let sl = StudentInformation(startValues: r)
                    sLoc.append(sl)
                }
                
                completionHandlerForQuery(success: true, studentInformation: sLoc.first, error: nil)
            }
            else {
                completionHandlerForQuery(success: false, studentInformation: nil, error: error)
            }

        }
    }
    
    private func getDataAccessGetResults(limit: Int, completionHandlerForGetResults: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
        // specify parameters
        var parameters = [String:AnyObject]()
        parameters[DataParameterKeys.Limit] = limit
        parameters[DataParameterKeys.Order] = "-updatedAt"
        
        // make the request
        taskForDataGETMethod(parameters) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForGetResults(success: false, results: nil, error: error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForGetResults(success: true, results: results, error: nil)
                    
                } else {
                    print("Could not find \(OTMClient.AuthJSONResponseKeys.Session) in \(results)")
                    completionHandlerForGetResults(success: false, results: nil, error: error)
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
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForQueryResults(success: true, results: results, error: nil)
                    
                } else {
                    print("Could not find \(OTMClient.AuthJSONResponseKeys.Session) in \(results)")
                    completionHandlerForQueryResults(success: false, results: nil, error: error)
                }
            }
        }
    }
    
    private func getDataAccessPostResults(studentInformation: StudentInformation, completionHandlerForPutResults: (success: Bool, results: [String:AnyObject]?, error: NSError?) -> Void) {
        
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
                completionHandlerForPutResults(success: false, results: nil, error: error)
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForPutResults(success: true, results: results, error: nil)
                    
                } else {
                    print("Could not find \(OTMClient.AuthJSONResponseKeys.Session) in \(results)")
                    completionHandlerForPutResults(success: false, results: nil, error: error)
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
                
            } else {
                if let results = results as? [String:AnyObject] {
                    
                    completionHandlerForPutResults(success: true, results: results, error: nil)
                    
                } else {
                    print("Could not find \(OTMClient.AuthJSONResponseKeys.Session) in \(results)")
                    completionHandlerForPutResults(success: false, results: nil, error: error)
                }
            }
        }
    }
    
    func taskForDataGETMethod(parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmDataURLFromParameters(parameters, withPathExtension: ""))
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
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
            self.convertDataWithCompletionHandler(data, offset: 0, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    func taskForDataPOSTMethod(parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmDataURLFromParameters(parameters, withPathExtension: ""))
        request.HTTPMethod = "POST"
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = NSTimeInterval(5)
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
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
            self.convertDataWithCompletionHandler(data, offset: 0, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    func taskForDataPUTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //  build the URL, Configure the request
        let request = NSMutableURLRequest(URL: otmDataURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "PUT"
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = NSTimeInterval(5)
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPUT(result: nil, error: NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
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
            self.convertDataWithCompletionHandler(data, offset: 0, completionHandlerForConvertData: completionHandlerForPUT)
        }
        
        // start the request
        task.resume()
        
        return task
    }
    
    // create a URL from parameters
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