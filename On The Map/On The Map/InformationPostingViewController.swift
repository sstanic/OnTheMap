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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let regionRadius: CLLocationDistance = 10000
    
    var parseUser: StudentInformation? // app user (parse data)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        changeButtonStyle(submitButton)
        changeButtonStyle(findOnTheMapButton)
        
        initializeActivityIndicator()
        
        hideMap()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        queryUser()
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        let adr = studyingText.text!
        
        forwardGeocoding(adr) { (success, error) in
            if success {
                self.showMap()
            }
        }
    }
    
    @IBAction func submit(sender: AnyObject) {

        showActivityIndicator()
        
        let url = urlText.text
        
        if !(isValidUrl(url)) {
            let alertMsg = "Please enter a valid URL"
            showAlert(alertMsg)
            return
        }

        let udacityStudent = OTMClient.sharedInstance().udacityStudent!
        let studentInformationMapItem = mapView.annotations.first as! StudentInformationMapItem
        let mapString = studyingText.text!
        
        var studentInformationStartValues = [String:AnyObject]()
        studentInformationStartValues["uniqueKey"] = studentInformationMapItem.uniqueKey
        studentInformationStartValues["firstName"] = udacityStudent.firstName
        studentInformationStartValues["lastName"] = udacityStudent.lastName
        studentInformationStartValues["mapString"] = mapString
        studentInformationStartValues["mediaURL"] = url!
        studentInformationStartValues["latitude"] = studentInformationMapItem.coordinate.latitude
        studentInformationStartValues["longitude"] = studentInformationMapItem.coordinate.longitude
        
        // check if parse user already exists => use the objectId to update the user
        if let parseUser = self.parseUser {
            studentInformationStartValues["objectId"] = parseUser.objectId
        }
        
        let studentInformation = StudentInformation(startValues: studentInformationStartValues)
        
        // check, if student is already added to the parse-db
        // update or add accordingly
        if parseUser != nil {
            // update
            
            OTMClient.sharedInstance().updateStudentLocation(studentInformation) { (success, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if success {
                        print("update student: success")
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        print("update student: failed.")
                        
                        let alertMsg = "There was a problem submitting your data (update user). Please check your network connection and try again."
                        self.showAlert(alertMsg)
                    }
                    
                    self.hideActivityIndicator()
                }
            }
        }
        else {
            // add
            
            OTMClient.sharedInstance().addStudentLocation(studentInformation) { (success, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if success {
                        print("add student: success")
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        print("add student: failed.")
                        
                        let alertMsg = "There was a problem submitting your data (add user). Please check your network connection and try again."
                        self.showAlert(alertMsg)
                    }
                    
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    func isValidUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        
        return false
    }
    
    func queryUser() {
        let uniqueKey = OTMClient.sharedInstance().userKey!
        
        showActivityIndicator()
        OTMClient.sharedInstance().queryStudentLocation(uniqueKey) { (success, studentInformation, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    self.parseUser = studentInformation!
                    self.urlText.text = self.parseUser?.mediaURL
                    self.studyingText.text = self.parseUser?.mapString
                }
                
                self.hideActivityIndicator()
            }
        }
    }
    
    func forwardGeocoding(address: String, forwardGeocodingCompletionHandler: (success: Bool, error: NSError?) -> Void) {
        
        showActivityIndicator()
        
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.hideActivityIndicator()
                
                if error != nil {
                    if let clErr = CLError(rawValue: error!.code) {
                        
                        switch clErr {
                        case CLError.GeocodeFoundNoResult:
                            let alertMsg = "Location not found, please check your input."
                            self.showAlert(alertMsg)
                            break
                        default:
                            let alertMsg = "There was a geocoding problem. Please check your input and try again."
                            self.showAlert(alertMsg)
                            break
                        }
                    }
                    
                    forwardGeocodingCompletionHandler(success: false, error: error)
                    return
                }
                
                if placemarks?.count > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    
                    self.createMapAnnotation(coordinate!)
                    self.setCurrentLocation(location!)
                    forwardGeocodingCompletionHandler(success: true, error: nil)
                }
                else {
                    let alertMsg = "Location not found, please check your input."
                    self.showAlert(alertMsg)
                    forwardGeocodingCompletionHandler(success: false, error: error)
                }
            }
        }
    }
    
    func createMapAnnotation(coordinate: CLLocationCoordinate2D) {
        let uniqueId = OTMClient.sharedInstance().userKey!
        var udacityStudent: UdacityStudent? = nil
        
        print("create map annotation for unique id: \(uniqueId)")
        
        showActivityIndicator()
        
        OTMClient.sharedInstance().requestUdacityUserName(uniqueId) { (success, result, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.hideActivityIndicator()
                
                if success {
                    udacityStudent = result!
                }
                
                print("create map annotation for udacity student: \(udacityStudent)")
                
                let url = ""
                let annotation = StudentInformationMapItem(uniqueKey: uniqueId, name: (udacityStudent?.name)!, mediaUrl: url, location: coordinate)
                
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func setCurrentLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
    
    private func showAlert(msg: String) {
        let alertController = UIAlertController(title: "Info", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
        }
        alertController.addAction(action)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func changeButtonStyle(button: UIButton) {
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    private func showMap() {
        urlView.hidden = false
        mapView.hidden = false
        submitButton.hidden = false

        questionStack.hidden = true
        studyingText.hidden = true
        inputView?.hidden = true
        findOnTheMapButton.hidden = true
    }
    
    private func hideMap() {
        urlView.hidden = true
        mapView.hidden = true
        submitButton.hidden = true
        
        questionStack.hidden = false
        studyingText.hidden = false
        inputView?.hidden = false
        findOnTheMapButton.hidden = false
    }
}
