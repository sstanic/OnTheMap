//
//  Utils.swift
//  On The Map
//
//  Created by Sascha Stanic on 06.05.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import Foundation

class Utils {
    
    //# MARK: Queuing
    static var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    static var GlobalUserInteractiveQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
    }
    
    static var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    static var GlobalUtilityQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    }
    
    static var GlobalBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
    
    //# MARK: KVO for DataStore
    static let OberserverKeyIsLoading = "isLoading"
    static let OberserverKeyIsLoadingUdacityUser = "isLoadingUdacityUsers"
    
    //# MARK: Udacity user
    static let LoadUserNamesFromUdacity = false
    
    //# MARK: Alert
    static func showAlert(viewController: UIViewController, alertMessage: String, completion: (() -> Void)?) {
        
        let alertController = UIAlertController(title: "Info", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            if let c = completion {
                c()
            }
        }
        alertController.addAction(action)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //# MARK: Activity Indicator
    static func showActivityIndicator(view: UIView, activityIndicator: UIActivityIndicatorView) {
        
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        view.userInteractionEnabled = false
        
        for subview in view.subviews {
            subview.alpha = 0.3
        }
        
        // do not 'hide' the activity indicator
        activityIndicator.alpha = 1.0
    }
    
    static func hideActivityIndicator(view: UIView, activityIndicator: UIActivityIndicatorView) {
        
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        view.userInteractionEnabled = true
        
        for subview in view.subviews {
            subview.alpha = 1.0
        }
    }
}