//
//  LoginViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 31.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    //# MARK: Outlets
    @IBOutlet weak var signUpStack: UIStackView!
    @IBOutlet weak var accountQuestionText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginFacebookButton: FBSDKLoginButton!
    
    //# MARK: Attributes
    let signInURL = URL(string: "https://www.udacity.com/account/auth#!/signin")
    // let signUpURL = NSURL(string: "https://www.udacity.com/account/auth#!/signup") // app spec: Link to sign-in (not to sign-up)
    
    //# MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide border
        signUpStack.layer.borderWidth = 0
        
        Utils.hideActivityIndicator(view, activityIndicator: activityIndicator)
        
        initializeTextfields()
        initializeFacebook()
    }
    
    //# MARK: - Actions
    @IBAction func login(_ sender: AnyObject) {
        
        let email = emailText.text!
        let pass = passwordText.text!
        
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        OTMClient.sharedInstance().authenticateWithUdacity(email, password: pass) { (success, error) in
        
            Utils.GlobalMainQueue.async {
                if success {
                    self.openOnTheMap()
                    Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
                }
                else {
                    let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                    
                    switch userInfo {
                    case "400", "401", "403":
                        Utils.showAlert(self, alertMessage: "Login failed. Wrong username or password.", completion: nil)
                        
                    case String(NSURLErrorTimedOut):
                        Utils.showAlert(self, alertMessage: OTMClient.ErrorMessage.NetworkTimeout, completion: nil)
                        
                    default:
                        Utils.showAlert(self, alertMessage: userInfo, completion: nil)
                    }
                    
                    Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
                }
            }
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject) {
        
        // The login is handeled by the FB framework (see loginButton(...)), this action is only called to show the activity indicator
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        if let requestUrl = signInURL {
            UIApplication.shared.openURL(requestUrl)
        }
    }
    
    fileprivate func openOnTheMap() {
        
        let tabViewController = self.storyboard!.instantiateViewController(withIdentifier: "navigationController")
        present(tabViewController, animated: true, completion: nil)
    }
    
    //# MARK: - Initialization
    fileprivate func initializeTextfields() {
        
        let textAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)
        ]
        
        let emailPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.emailText.frame.height))
        let passwordPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.passwordText.frame.height))
        
        emailText.leftView = emailPaddingView
        emailText.leftViewMode = UITextFieldViewMode.always
        
        passwordText.leftView = passwordPaddingView
        passwordText.leftViewMode = UITextFieldViewMode.always
        
        emailText.defaultTextAttributes = textAttributes
        passwordText.defaultTextAttributes = textAttributes
        
        emailText.delegate = self
        passwordText.delegate = self
    }
    
    fileprivate func initializeFacebook() {
        
        loginFacebookButton.delegate = self
        loginFacebookButton.loginBehavior = .native
        
        if let cachedToken = FBSDKAccessToken.current() {
            Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
            OTMClient.sharedInstance().authenticateWithFacebook(cachedToken.tokenString) { (success, bool) in
                if success {
                    self.openOnTheMap()
                }
                else {
                    OTMClient.sharedInstance().logoutFromFacebook()
                }
                
                Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
        }
    }
    
    
    //# MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == passwordText) {
            textField.resignFirstResponder()
            login("return tapped :)" as AnyObject)
        }

        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // clear textfield only, if initial text 'Email' is shown
        if (textField == emailText) {
            if textField.text == "Email" {
                textField.text = ""
            }
        }
    }
    
    //# MARK: - FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if let error = error {
            let userInfo = error.localizedDescription
            Utils.showAlert(self, alertMessage: userInfo, completion: nil)
            Utils.hideActivityIndicator(view, activityIndicator: activityIndicator)
        }
        else {
            if let fbAccessToken = FBSDKAccessToken.current() {
                OTMClient.sharedInstance().authenticateWithFacebook(fbAccessToken.tokenString) { (success, error) in
                    if success {
                        self.openOnTheMap()
                    }
                    else {
                        let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                        Utils.showAlert(self, alertMessage: userInfo, completion: nil)
                    }
                    
                    Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
                }
            }
            else { //User did not login
                Utils.hideActivityIndicator(view, activityIndicator: activityIndicator)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        // This function will usually never be called.
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        Utils.hideActivityIndicator(view, activityIndicator: activityIndicator)
    }
}
