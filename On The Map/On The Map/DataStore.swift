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
    var studentInformationList = [StudentInformation]?()
    
    dynamic var isLoading = false
    dynamic var isLoadingUdacityUsers = false
    
    var isNotLoading: Bool {
        
        return !isLoading
    }
    
    private let concurrentDataQueue = dispatch_queue_create("eu.stanic.OnTheMap.dataQueue", DISPATCH_QUEUE_CONCURRENT)
    
    //# MARK: Load Student Data
    func loadStudentData(loadCompletionHandler : (success: Bool, error: NSError?) -> Void) {
        
        self.notifyLoadingStudentData(true)
        dispatch_barrier_sync(self.concurrentDataQueue) {
            self.studentInformationList = nil
        }
        
        OTMClient.sharedInstance().getStudentLocations() { (success, results, error) in

            if success {
                self.notifyLoadingStudentData(false)
                dispatch_barrier_sync(self.concurrentDataQueue) {
                    self.studentInformationList = results!
                }
                
                // return with success and load async the udacity user names
                loadCompletionHandler(success: true, error: nil)
                
                if Utils.LoadUserNamesFromUdacity {
                    self.loadUdacityUserNames()
                }
            }
            else {
                self.notifyLoadingStudentData(false)
                loadCompletionHandler(success: false, error: error)
            }
        }
    }
    
    func reloadStudentData(reloadCompletionHandler : (success: Bool, error: NSError?) -> Void) {
        
        if isNotLoading {
            loadStudentData() { (success, error) in
                
                if success {
                    reloadCompletionHandler(success: true, error: nil)
                }
                else {
                    reloadCompletionHandler(success: false, error: error)
                }
            }
        }
    }
    
    private func loadUdacityUserNames() {
        
        var queryCounter = studentInformationList!.count
        
        notifyLoadingUdacityUser(true)
        
        for (index, var s) in studentInformationList!.enumerate() {
            OTMClient.sharedInstance().requestUdacityUserName(s.uniqueKey) { (success, result, error) in
                
                if success {
                    // only change user name if Udacity sent it back
                    if let res = result {
                        
                        if res.name != OTMClient.UdacityUser.UnknownUser {
                            
                            s.firstName = res.firstName!
                            s.lastName = res.lastName!
                            
                            dispatch_barrier_sync(self.concurrentDataQueue) {
                                self.studentInformationList![index] = s
                            }
                        }
                    }
                }
                // ignore else case - cannot do anything about it here (in most cases someone added wrong data into the unique key)
                
                print(queryCounter)
                
                queryCounter = queryCounter - 1
                if queryCounter == 0 {
                    self.notifyLoadingUdacityUser(false)
                }
            }
        }
    }
    
    //# MARK: Notifications
    private func notifyLoadingStudentData(isLoading: Bool) {
        dispatch_async(Utils.GlobalMainQueue) {
            self.isLoading = isLoading
        }
    }
    
    private func notifyLoadingUdacityUser(isLoading: Bool) {
        dispatch_async(Utils.GlobalMainQueue) {
            self.isLoadingUdacityUsers = isLoading
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