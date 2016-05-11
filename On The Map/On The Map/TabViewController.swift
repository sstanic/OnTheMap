//
//  ViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 30.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    //# MARK: Outlets
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    //# MARK: Attributes
    var observeDataStore = false {
        didSet {
            if observeDataStore {
                DataStore.sharedInstance().addObserver(self, forKeyPath: Utils.OberserverKeyIsLoading, options: .New, context: nil)
            }
        }
    }
    
    //# MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeDataStore = true
    }
    
    override func viewDidAppear(animated: Bool) {
        refresh("initial data load")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == Utils.OberserverKeyIsLoading {
            // show or hide the logout dependent of the value
            dispatch_async(Utils.GlobalMainQueue) {
                if let val = change!["new"] as! Int? {
                    if val == 0 {
                        self.logoutButton.enabled = true
                    }
                    else {
                        self.logoutButton.enabled = false
                    }
                }
            }
        }
    }
    
    deinit {
        if observeDataStore {
            DataStore.sharedInstance().removeObserver(self, forKeyPath: Utils.OberserverKeyIsLoading)
        }
    }
    
    //# MARK: - Actions
    @IBAction func logout(sender: AnyObject) {
        
        if OTMClient.sharedInstance().fbToken != nil {
            
            OTMClient.sharedInstance().logoutFromFacebook()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            
            OTMClient.sharedInstance().logoutFromUdacity() { (success, error) in
                
                dispatch_async(Utils.GlobalMainQueue) {
                    if success {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                        Utils.showAlert(self, alertMessage: userInfo, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func refresh(sender: AnyObject) {
        
        if DataStore.sharedInstance().isNotLoading {
            self.refreshButton!.enabled = false
            DataStore.sharedInstance().loadStudentData() { (success, error) in
                
                dispatch_async(Utils.GlobalMainQueue) {
                    if success {
                        // yay! :)
                    }
                    else {
                        // load problem
                        let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                        Utils.showAlert(self, alertMessage: userInfo, completion: nil)
                    }
                    
                    self.refreshButton!.enabled = true
                }
            }
        }
    }
    
    @IBAction func postInformation(sender: AnyObject) {
        
        let infoPostController = self.storyboard?.instantiateViewControllerWithIdentifier("informationPosting") as! InformationPostingViewController
        presentViewController(infoPostController, animated: true, completion: nil)
    }
}

