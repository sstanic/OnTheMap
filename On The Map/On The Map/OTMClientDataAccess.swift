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
    func getStudentLocations(_ completionHandlerForGet: @escaping (_ success: Bool, _ results: [StudentInformation]?, _ error: NSError?) -> Void) {
        
        getDataAccessGetResults(OTMClient.DataConstants.StudentQueryLimit) { (success, results, error) in
            
            if success {
                if let resultList = results![DataJSONResponseKeys.Results] as? [[String:AnyObject]] {
                    var sLoc = [StudentInformation]()
                    for r in resultList {
                        let sl = StudentInformation(startValues: r)
                        sLoc.append(sl)
                    }
                    completionHandlerForGet(true, sLoc, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(DataJSONResponseKeys.Results)' not found in add-results."]
                    print(userInfo)
                    completionHandlerForGet(false, nil, NSError(domain: "getStudentLocations", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForGet(false, nil, error)
            }
        }
    }
    
    func addStudentLocation(_ studentInformation: StudentInformation, completionHandlerForAdd: @escaping (_ success: Bool, _ objectId: String?, _ error: NSError?) -> Void) {
        
        getDataAccessPostResults(studentInformation) { (success, results, error) in
            
            if success {
                if let objectId = results![DataJSONResponseKeys.ObjectId] as? String {
                    completionHandlerForAdd(true, objectId, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(DataJSONResponseKeys.ObjectId)' not found in add-results."]
                    print(userInfo)
                    completionHandlerForAdd(false, nil, NSError(domain: "addStudentLocation", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForAdd(false, nil, error)
            }
        }
    }
    
    func updateStudentLocation(_ studentInformation: StudentInformation, completionHandlerForUpdate: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        getDataAccessPutResults(studentInformation) { (success, results, error) in
            
            if success {
                
                // ignore <results>, not needed
                
                completionHandlerForUpdate(true, nil)
            }
            else {
                completionHandlerForUpdate(false, error)
            }
        }
    }
    
    func queryStudentLocation(_ uniqueKey: String, completionHandlerForQuery: @escaping (_ success: Bool, _ studentInformation: StudentInformation?, _ error: NSError?) -> Void) {
        
        getDataAccessQueryResults(uniqueKey) { (success, results, error) in
            
            if success {
                if let resultList = results![DataJSONResponseKeys.Results] as? [[String:AnyObject]] {
                    var sLoc = [StudentInformation]()
                    for r in resultList {
                        let sl = StudentInformation(startValues: r)
                        sLoc.append(sl)
                    }
                    
                    if sLoc.count > 0 {
                        completionHandlerForQuery(true, sLoc.first, nil)
                    }
                    else {
                        let userInfo = [NSLocalizedDescriptionKey : "User not found for unique key: \(uniqueKey)"]
                        print(userInfo)
                        completionHandlerForQuery(false, nil, NSError(domain: "queryStudentLocation", code: 2, userInfo: userInfo))
                    }
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Parameter '\(DataJSONResponseKeys.Results)' not found in query-results."]
                    print(userInfo)
                    completionHandlerForQuery(false, nil, NSError(domain: "queryStudentLocation", code: 1, userInfo: userInfo))
                }
            }
            else {
                completionHandlerForQuery(false, nil, error)
            }
        }
    }
    
    //# MARK: - URL Request Data Tasks Prep & Call
    fileprivate func getDataAccessGetResults(_ limit: Int, completionHandlerForGetResults: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        // specify parameters
        var parameters = [String:AnyObject]()
        parameters[DataParameterKeys.Limit] = limit as AnyObject
        parameters[DataParameterKeys.Order] = DataParameterKeys.OrderArg as AnyObject
        
        // make the request
        _ = taskForDataGETMethod(parameters) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForGetResults(false, nil, error)
                
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForGetResults(true, results, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForGetResults(false, nil, NSError(domain: "getDataAccessGetResults", code: 2, userInfo: userInfo))

                }
            }
        }
    }
    
    fileprivate func getDataAccessQueryResults(_ uniqueKey: String, completionHandlerForQueryResults: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        // specify parameters
        var parameters = [String:AnyObject]()
        parameters[DataParameterKeys.Where] = "{\"uniqueKey\": \"\(uniqueKey)\"}" as AnyObject
        
        // make the request
        _ = taskForDataGETMethod(parameters) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForQueryResults(false, nil, error)
                
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForQueryResults(true, results, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForQueryResults(false, nil, NSError(domain: "getDataAccessQueryResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    fileprivate func getDataAccessPostResults(_ studentInformation: StudentInformation, completionHandlerForPostResults: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
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
        _ = taskForDataPOSTMethod(parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForPostResults(false, nil, error)
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForPostResults(true, results, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForPostResults(false, nil, NSError(domain: "getDataAccessPostResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    fileprivate func getDataAccessPutResults(_ studentInformation: StudentInformation, completionHandlerForPutResults: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let method = "/" + studentInformation.objectId
        
        let uniqueKey = studentInformation.uniqueKey
        let firstName = studentInformation.firstName
        let lastName = studentInformation.lastName
        let mapString = studentInformation.mapString
        let mediaUrl = studentInformation.mediaURL
        let latitude = studentInformation.latitude
        let longitude = studentInformation.longitude
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        // make the request
        _ = taskForDataPUTMethod(method, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // check for errors and call the completion handler
            if let error = error {
                print(error)
                completionHandlerForPutResults(false, nil, error)
            }
            else {
                if let results = results as? [String:AnyObject] {
                    completionHandlerForPutResults(true, results, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : OTMClient.ErrorMessage.HttpDataTaskFailed]
                    completionHandlerForPutResults(false, nil, NSError(domain: "getDataAccessPutResults", code: 2, userInfo: userInfo))
                }
            }
        }
    }
    
    //# MARK: - URL Request Data Tasks
    fileprivate func taskForDataGETMethod(_ parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //  build the URL, Configure the request
        var request = URLRequest(url: otmDataURLFromParameters(parameters, withPathExtension: ""))
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.timeoutInterval = TimeInterval(OTMClient.DataConstants.Timeout)
        
        // make the request
        let task = session.dataTask(with: request) { (data, response, error) in
            
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
            
            // check HTTP status codes (2XX response)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
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
    
    fileprivate func taskForDataPOSTMethod(_ parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //  build the URL, Configure the request
        var request = URLRequest(url: otmDataURLFromParameters(parameters, withPathExtension: ""))
        request.httpMethod = "POST"
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        request.timeoutInterval = TimeInterval(DataConstants.Timeout)
        
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
            
            // check HTTP status codes (2XX response)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
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
    
    fileprivate func taskForDataPUTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //  build the URL, Configure the request
        var request = URLRequest(url: otmDataURLFromParameters(parameters, withPathExtension: method))
        request.httpMethod = "PUT"
        request.addValue(DataConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(DataConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        request.timeoutInterval = TimeInterval(DataConstants.Timeout)
        
        // make the request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            func sendError(_ error: Error?, localError: String) {
                print(error ?? "", localError)
                let userInfo = [NSLocalizedDescriptionKey : localError]
                completionHandlerForPUT(nil, NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
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
            
            // check HTTP status codes (2XX response)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error, localError: OTMClient.ErrorMessage.StatusCodeFailure)
                return
            }
            
            guard let data = data else {
                sendError(error, localError: OTMClient.ErrorMessage.NoDataFoundInRequest)
                return
            }
            
            // parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, offset: 0, completionHandlerForConvertData: completionHandlerForPUT)
        }) 
        
        // start the request
        task.resume()
        
        return task
    }
    
    //# MARK: - URL Creation
    fileprivate func otmDataURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.DataConstants.ApiScheme
        components.host = OTMClient.DataConstants.ApiHost
        components.path = OTMClient.DataConstants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}
