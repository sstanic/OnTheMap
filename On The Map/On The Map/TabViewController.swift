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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender: AnyObject) {
    }
    
    @IBAction func postInformation(sender: AnyObject) {
        let infoPostController = self.storyboard?.instantiateViewControllerWithIdentifier("informationPosting") as! InformationPostingViewController
        
        presentViewController(infoPostController, animated: true, completion: nil)
    }
    
    @IBAction func refreshData(sender: AnyObject) {
    }
    
    
}

