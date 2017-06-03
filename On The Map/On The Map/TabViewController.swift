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
                DataStore.sharedInstance().addObserver(self, forKeyPath: Utils.OberserverKeyIsLoading, options: .new, context: nil)
            }
        }
    }
    
    //# MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeDataStore = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh("initial data load" as AnyObject)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == Utils.OberserverKeyIsLoading {
            // show or hide the logout dependent of the value
            Utils.GlobalMainQueue.async {
                if let val = change![.newKey] as! Int? {
                    if val == 0 {
                        self.logoutButton.isEnabled = true
                    }
                    else {
                        self.logoutButton.isEnabled = false
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
    @IBAction func logout(_ sender: AnyObject) {
        
        if OTMClient.sharedInstance().fbToken != nil {
            
            OTMClient.sharedInstance().logoutFromFacebook()
            self.dismiss(animated: true, completion: nil)
        }
        else {
            
            OTMClient.sharedInstance().logoutFromUdacity() { (success, error) in
                
                Utils.GlobalMainQueue.async {
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                        Utils.showAlert(self, alertMessage: userInfo, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        
        if DataStore.sharedInstance().isNotLoading {
            self.refreshButton!.isEnabled = false
            DataStore.sharedInstance().loadStudentData() { (success, error) in
                
                Utils.GlobalMainQueue.async {
                    if success {
                        // yay! :)
                    }
                    else {
                        // load problem
                        let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                        Utils.showAlert(self, alertMessage: userInfo, completion: nil)
                    }
                    
                    self.refreshButton!.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func postInformation(_ sender: AnyObject) {
        
        let infoPostController = self.storyboard?.instantiateViewController(withIdentifier: "informationPosting") as! InformationPostingViewController
        present(infoPostController, animated: true, completion: nil)
    }
}

