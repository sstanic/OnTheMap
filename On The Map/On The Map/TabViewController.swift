//
//  ViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 30.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        if OTMClient.sharedInstance().fbToken != nil {
            
            OTMClient.sharedInstance().logoutFromFacebook()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            
            OTMClient.sharedInstance().logoutFromUdacity() { (success, error) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if success {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        self.showAlert(error!)
                    }
                }
            }
        }
    }
    
    @IBAction func postInformation(sender: AnyObject) {
        let infoPostController = self.storyboard?.instantiateViewControllerWithIdentifier("informationPosting") as! InformationPostingViewController
        presentViewController(infoPostController, animated: true, completion: nil)
    }
    
    private func showAlert(alertMessage: String) {
        let alertController = UIAlertController(title: "Info", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
        }
        alertController.addAction(action)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

