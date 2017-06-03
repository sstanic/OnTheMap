//
//  DataStore.swift
//  On The Map
//
//  Created by Sascha Stanic on 03.05.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

class DataStore: NSObject {
    
    //# MARK: Attributes
    var studentInformationList: [StudentInformation]? = []
    
    dynamic var isLoading = false
    
    var isNotLoading: Bool {
        
        return !isLoading
    }
    
    fileprivate let concurrentDataQueue = DispatchQueue(label: "com.savvista.udacity.OnTheMap.dataQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    //# MARK: Load Student Data
    func loadStudentData(_ loadCompletionHandler : @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        self.notifyLoadingStudentData(true)
        self.concurrentDataQueue.sync(flags: .barrier, execute: {
            self.studentInformationList = nil
        }) 
        
        OTMClient.sharedInstance().getStudentLocations() { (success, results, error) in

            if success {
                self.notifyLoadingStudentData(false)
                self.concurrentDataQueue.sync(flags: .barrier, execute: {
                    self.studentInformationList = results!
                }) 
                
                // return with success and load async the udacity user names
                loadCompletionHandler(true, nil)
            }
            else {
                self.notifyLoadingStudentData(false)
                loadCompletionHandler(false, error)
            }
        }
    }
    
    func reloadStudentData(_ reloadCompletionHandler : @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        if isNotLoading {
            loadStudentData() { (success, error) in
                
                if success {
                    reloadCompletionHandler(true, nil)
                }
                else {
                    reloadCompletionHandler(false, error)
                }
            }
        }
    }
    
    //# MARK: Notifications
    fileprivate func notifyLoadingStudentData(_ isLoading: Bool) {
        Utils.GlobalMainQueue.async {
            self.isLoading = isLoading
        }
    }

    //# MARK: Shared Instance
    class func sharedInstance() -> DataStore {
        
        struct Singleton {
            static var sharedInstance = DataStore()
        }
        return Singleton.sharedInstance
    }
}
