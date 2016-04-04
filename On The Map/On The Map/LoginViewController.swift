//
//  LoginViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 31.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signUpStack: UIStackView!
    @IBOutlet weak var accountQuestionText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        signUpStack.layer.borderWidth = 0
        
        initializeTextfields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        // ....
        
        let tabViewController = self.storyboard!.instantiateViewControllerWithIdentifier("navigationController")
        presentViewController(tabViewController, animated: true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
    }
    
    func initializeTextfields() {
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
    
}
