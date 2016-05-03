//
//  LoginViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 31.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var signUpStack: UIStackView!
    @IBOutlet weak var accountQuestionText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginFacebookButton: FBSDKLoginButton!
    
    let signInURL = NSURL(string: "https://www.udacity.com/account/auth#!/signin")
    // let signUpURL = NSURL(string: "https://www.udacity.com/account/auth#!/signup") // app spec: Link to sign-in (not to sign-up)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpStack.layer.borderWidth = 0
        
        initializeTextfields()
        initializeActivityIndicator()
        initializeFacebook()
    }
    
    @IBAction func login(sender: AnyObject) {
        let email = emailText.text!
        let pass = passwordText.text!
        
        showActivityIndicator()
        
        OTMClient.sharedInstance().authenticateWithUdacity(email, password: pass) { (success, error) in
        
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    //            print("====")
                    //            print("login success. \(success)")
                    //            print("session id: \(OTMClient.sharedInstance().sessionID!)")
                    //            print("account key: \(OTMClient.sharedInstance().userID!)")
                    //            print("  ")
                    
                    self.openOnTheMap()
                    self.hideActivityIndicator()
                }
                else {
                    let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                    
                    switch userInfo {
                    case "400", "401", "403":
                        self.showAlert("Login failed. Wrong username or password.")
                        
                    case String(NSURLErrorTimedOut):
                        self.showAlert("Network timeout. Please check network connection and try again.")
                        
                    default:
                        self.showAlert(userInfo)
                    }
                    
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        // The login is handeled by the FB framework (see loginButton(...)), this action is only called to show the activity indicator
        showActivityIndicator()
    }
    
    @IBAction func signUp(sender: AnyObject) {
        if let requestUrl = signInURL {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    // initialization
    private func initializeTextfields() {
        let textAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(20)
        ]
        
        let emailPaddingView = UIView(frame: CGRectMake(0, 0, 10, self.emailText.frame.height))
        let passwordPaddingView = UIView(frame: CGRectMake(0, 0, 10, self.passwordText.frame.height))
        
        emailText.leftView = emailPaddingView
        emailText.leftViewMode = UITextFieldViewMode.Always
        
        passwordText.leftView = passwordPaddingView
        passwordText.leftViewMode = UITextFieldViewMode.Always
        
        emailText.defaultTextAttributes = textAttributes
        passwordText.defaultTextAttributes = textAttributes
    }
    
    private func initializeFacebook() {
        loginFacebookButton.delegate = self
        loginFacebookButton.loginBehavior = .Native
        
        if let cachedToken = FBSDKAccessToken.currentAccessToken() {
            showActivityIndicator()
            OTMClient.sharedInstance().authenticateWithFacebook(cachedToken.tokenString) { (success, bool) in
                if success {
                    self.openOnTheMap()
                }
                else {
                    OTMClient.sharedInstance().logoutFromFacebook()
                }
                self.hideActivityIndicator()
            }
        }
    }
    
    // activity indicator
    private func initializeActivityIndicator() {
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.hidesWhenStopped = true
    }
    
    private func showActivityIndicator() {
        activityIndicator.startAnimating()
        view.userInteractionEnabled = false
        
        for subview in view.subviews {
            subview.alpha = 0.3
        }
        
        // do not 'hide' the activity indicator
        activityIndicator.alpha = 1.0
    }
    
    private func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        view.userInteractionEnabled = true
        
        for subview in view.subviews {
            subview.alpha = 1.0
        }
    }
    
    // login: open map or show alert message
    private func openOnTheMap() {
        let tabViewController = self.storyboard!.instantiateViewControllerWithIdentifier("navigationController")
        presentViewController(tabViewController, animated: true, completion: nil)
    }
    
    private func showAlert(msg: String) {
        let alertController = UIAlertController(title: "Info", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
        }
        alertController.addAction(action)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // facebook button delegates
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
//        print("----")
//        print("fb login result")
//        print("result: \(result)")
//        print("error: \(error)")
//        print("access token: \(fbAccessToken)")
        
        if let error = error {
            let userInfo = error.userInfo[NSLocalizedDescriptionKey] as! String
            self.showAlert(userInfo)
            self.hideActivityIndicator()
        }
        else {
            if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
                OTMClient.sharedInstance().authenticateWithFacebook(fbAccessToken.tokenString) { (success, error) in
                    if success {
                        self.openOnTheMap()
                    }
                    else {
                        let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                        self.showAlert(userInfo)
                    }
                    
                    self.hideActivityIndicator()
                }
            }
            else { //User did not login
                self.hideActivityIndicator()
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // This function will usually never be called. You'd need to stop while debugging with the sim and logged in and then start again
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        self.hideActivityIndicator()
    }
}
