//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 01.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    
    //# MARK: Outlets
    @IBOutlet weak var questionStack: UIStackView!
    @IBOutlet weak var studyingText: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //# MARK: Attributes
    let regionRadius: CLLocationDistance = 10000
    var parseUser: StudentInformation? // app user (parse data)
    
    // only bottom textfield will move keyboard up
    var moveKeyboard = false
    
    //# MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studyingText.delegate = self
        urlText.delegate = self
        
        changeButtonStyle(submitButton)
        changeButtonStyle(findOnTheMapButton)
        
        initializeActivityIndicator()
        
        hideMap()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        queryUser()
    }

    //# MARK: - Actions
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        let adr = studyingText.text!
        
        forwardGeocoding(adr) { (success, error) in
            if success {
                self.showMap()
            }
            // else do nothing (error is already shown in forwardGeocoding)
        }
    }
    
    @IBAction func submit(sender: AnyObject) {

        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        let url = urlText.text
        
        if !(isValidUrl(url)) {
            let alertMsg = "Please enter a valid URL"
            Utils.showAlert(self, alertMessage: alertMsg) { () in
                Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
            return
        }

        // collect data
        let localUser = OTMClient.sharedInstance().localUser!
        let studentInformationMapItem = mapView.annotations.first as! StudentInformationMapItem
        let mapString = studyingText.text!
        
        print(localUser)
        
        // create dictionary
        var studentInformationStartValues = [String:AnyObject]()
        studentInformationStartValues[OTMClient.StudentInformationAttributes.UniqueKey] = studentInformationMapItem.uniqueKey
        studentInformationStartValues[OTMClient.StudentInformationAttributes.FirstName] = localUser.firstName
        studentInformationStartValues[OTMClient.StudentInformationAttributes.LastName] = localUser.lastName
        studentInformationStartValues[OTMClient.StudentInformationAttributes.MapString] = mapString
        studentInformationStartValues[OTMClient.StudentInformationAttributes.MediaUrl] = url!
        studentInformationStartValues[OTMClient.StudentInformationAttributes.Latitude] = studentInformationMapItem.coordinate.latitude
        studentInformationStartValues[OTMClient.StudentInformationAttributes.Longitude] = studentInformationMapItem.coordinate.longitude
        
        // check if parse user already exists => use the objectId to update the user
        if let parseUser = self.parseUser {
            studentInformationStartValues["objectId"] = parseUser.objectId
        }
        
        // create StudentInformation
        let studentInformation = StudentInformation(startValues: studentInformationStartValues)
        
        // check, if student is already added to the parse-db, update or add accordingly
        if parseUser != nil {
            updateUser(studentInformation)
        }
        else {
            addUser(studentInformation)
        }
    }
    
    private func addUser(studentInformation: StudentInformation) {
        
        OTMClient.sharedInstance().addStudentLocation(studentInformation) { (success, objectId, error) in
            dispatch_async(Utils.GlobalMainQueue) {
                if success {
                    print("add student: success")
                    
                    self.parseUser?.objectId = objectId!
                    DataStore.sharedInstance().reloadStudentData() { (success, error) in
                        if error != nil {
                            Utils.showAlert(self, alertMessage: "Data reload failed. Please try to reload manually.", completion: nil)
                        }
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                else {
                    print("add student: failed.")
                    
                    let alertMsg = "There was a problem submitting your data (add user). Please check your network connection and try again."
                    Utils.showAlert(self, alertMessage: alertMsg, completion: nil)
                }
                
                Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
        }
    }
    
    private func updateUser(studentInformation: StudentInformation) {
        
        OTMClient.sharedInstance().updateStudentLocation(studentInformation) { (success, error) in
            dispatch_async(Utils.GlobalMainQueue) {
                if success {
                    print("update student: success")
                    
                    DataStore.sharedInstance().reloadStudentData() { (success, error) in
                        if error != nil {
                            Utils.showAlert(self, alertMessage: "Data reload failed. Please try to reload manually.", completion: nil)
                        }
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                else {
                    print("update student: failed.")
                    
                    let alertMsg = "There was a problem submitting your data (update user). Please check your network connection and try again."
                    Utils.showAlert(self, alertMessage: alertMsg, completion: nil)
                }
                
                Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //# MARK: - Validation
    func isValidUrl (urlString: String?) -> Bool {
        
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        
        return false
    }
    
    //# MARK: Data Access
    func queryUser() {
        
        let uniqueKey = OTMClient.sharedInstance().userKey!
        
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        OTMClient.sharedInstance().queryStudentLocation(uniqueKey) { (success, studentInformation, error) in
            dispatch_async(Utils.GlobalMainQueue) {
                if success {
                    self.parseUser = studentInformation!
                    self.urlText.text = self.parseUser?.mediaURL
                    self.studyingText.text = self.parseUser?.mapString
                }
                else {
                    if error?.code != 2 {
                        Utils.showAlert(self, alertMessage: "Data access to On The Map server failed (server not available or network timeout). Please check your network connection.") { () in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                    // else user not (yet) available - a new user will be created
                }
                
                Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
        }
    }
    
    //# MARK: Location & Geocoding
    func forwardGeocoding(address: String, forwardGeocodingCompletionHandler: (success: Bool, error: NSError?) -> Void) {
        
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            
            Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            
            if error != nil {
                if let clErr = CLError(rawValue: error!.code) {
                    
                    dispatch_async(Utils.GlobalMainQueue) {
                        switch clErr {
                        case CLError.GeocodeFoundNoResult:
                            let alertMsg = "Location not found, please check your input."
                            Utils.showAlert(self, alertMessage: alertMsg, completion: nil)
                            break
                        default:
                            let alertMsg = "There was a geocoding problem. Please check your input and try again."
                            Utils.showAlert(self, alertMessage: alertMsg, completion: nil)
                            break
                        }
                    }
                }
                
                forwardGeocodingCompletionHandler(success: false, error: error)
            }
            else {
                if placemarks?.count > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    
                    self.createMapAnnotation(coordinate!)
                    self.setCurrentLocation(location!)
                    
                    forwardGeocodingCompletionHandler(success: true, error: nil)
                }
                else {
                    dispatch_async(Utils.GlobalMainQueue) {
                        let alertMsg = "Location not found, please check your input."
                        Utils.showAlert(self, alertMessage: alertMsg, completion: nil)
                    }
                    
                    forwardGeocodingCompletionHandler(success: false, error: error)
                }
            }
        }
    }
    
    func createMapAnnotation(coordinate: CLLocationCoordinate2D) {
        
        let uniqueId = OTMClient.sharedInstance().userKey!
        var localUser: LocalUser? = nil
        
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        OTMClient.sharedInstance().requestUdacityUserName(uniqueId) { (success, result, error) in
            
            Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            
            dispatch_async(Utils.GlobalMainQueue) {
                if success {
                    localUser = result!
                    
                    print("create map annotation for udacity student: \(localUser)")
                    
                    let url = ""
                    let annotation = StudentInformationMapItem(uniqueKey: uniqueId, name: (localUser?.name)!, mediaUrl: url, location: coordinate)
                    
                    self.mapView.addAnnotation(annotation)
                }
                else {
                    let alertMsg = "Udacity user data could not be accessed. Cannot create map annotation."
                    Utils.showAlert(self, alertMessage: alertMsg, completion: nil)
                }
            }
        }
    }
    
    private func setCurrentLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //# MARK: Activity Indicator
    private func initializeActivityIndicator() {
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.hidesWhenStopped = true
    }
    
    //# MARK: UI Mgmt
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
    
    
    //# MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
