//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 01.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {
    
    @IBOutlet weak var questionStack: UIStackView!
    @IBOutlet weak var studyingText: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        changeButtonStyle(submitButton)
        changeButtonStyle(findOnTheMapButton)
        
        hideMap()
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        showMap()
    }
    
    @IBAction func submit(sender: AnyObject) {
        // ....
    }
    
    func changeButtonStyle(button: UIButton) {
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func showMap() {
        urlView.hidden = false
        mapView.hidden = false
        submitButton.hidden = false

        questionStack.hidden = true
        studyingText.hidden = true
        inputView?.hidden = true
        findOnTheMapButton.hidden = true
    }
    
    func hideMap() {
        urlView.hidden = true
        mapView.hidden = true
        submitButton.hidden = true
        
        questionStack.hidden = false
        studyingText.hidden = false
        inputView?.hidden = false
        findOnTheMapButton.hidden = false
    }
}
