//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 01.04.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit
import MapKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        queryUser()
    }

    //# MARK: - Actions
    @IBAction func findOnTheMap(_ sender: AnyObject) {
        
        let adr = studyingText.text!
        
        forwardGeocoding(adr) { (success, error) in
            if success {
                self.showMap()
            }
            // else do nothing (error is already shown in forwardGeocoding)
        }
    }
    
    @IBAction func submit(_ sender: AnyObject) {

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
        studentInformationStartValues[OTMClient.StudentInformationAttributes.UniqueKey] = studentInformationMapItem.uniqueKey as AnyObject
        studentInformationStartValues[OTMClient.StudentInformationAttributes.FirstName] = localUser.firstName as AnyObject
        studentInformationStartValues[OTMClient.StudentInformationAttributes.LastName] = localUser.lastName as AnyObject
        studentInformationStartValues[OTMClient.StudentInformationAttributes.MapString] = mapString as AnyObject
        studentInformationStartValues[OTMClient.StudentInformationAttributes.MediaUrl] = url! as AnyObject
        studentInformationStartValues[OTMClient.StudentInformationAttributes.Latitude] = studentInformationMapItem.coordinate.latitude as AnyObject
        studentInformationStartValues[OTMClient.StudentInformationAttributes.Longitude] = studentInformationMapItem.coordinate.longitude as AnyObject
        
        // check if parse user already exists => use the objectId to update the user
        if let parseUser = self.parseUser {
            studentInformationStartValues["objectId"] = parseUser.objectId as AnyObject
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
    
    fileprivate func addUser(_ studentInformation: StudentInformation) {
        
        OTMClient.sharedInstance().addStudentLocation(studentInformation) { (success, objectId, error) in
            Utils.GlobalMainQueue.async {
                if success {
                    print("add student: success")
                    
                    self.parseUser?.objectId = objectId!
                    DataStore.sharedInstance().reloadStudentData() { (success, error) in
                        if error != nil {
                            Utils.showAlert(self, alertMessage: "Data reload failed. Please try to reload manually.", completion: nil)
                        }
                        
                        self.dismiss(animated: true, completion: nil)
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
    
    fileprivate func updateUser(_ studentInformation: StudentInformation) {
        
        OTMClient.sharedInstance().updateStudentLocation(studentInformation) { (success, error) in
            Utils.GlobalMainQueue.async {
                if success {
                    print("update student: success")
                    
                    DataStore.sharedInstance().reloadStudentData() { (success, error) in
                        if error != nil {
                            Utils.showAlert(self, alertMessage: "Data reload failed. Please try to reload manually.", completion: nil)
                        }
                        
                        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func cancel(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //# MARK: - Validation
    func isValidUrl (_ urlString: String?) -> Bool {
        
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        
        return false
    }
    
    //# MARK: Data Access
    func queryUser() {
        
        let uniqueKey = OTMClient.sharedInstance().userKey!
        
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        OTMClient.sharedInstance().queryStudentLocation(uniqueKey) { (success, studentInformation, error) in
            Utils.GlobalMainQueue.async {
                if success {
                    self.parseUser = studentInformation!
                    self.urlText.text = self.parseUser?.mediaURL
                    self.studyingText.text = self.parseUser?.mapString
                }
                else {
                    if error?.code != 2 {
                        Utils.showAlert(self, alertMessage: "Data access to On The Map server failed (server not available or network timeout). Please check your network connection.") { () in
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    // else user not (yet) available - a new user will be created
                }
                
                Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            }
        }
    }
    
    //# MARK: Location & Geocoding
    func forwardGeocoding(_ address: String, forwardGeocodingCompletionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            
            Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            
            if error != nil {
                if let clErr = error?._code {
                    
                    Utils.GlobalMainQueue.async {
                        switch clErr {
                        case CLError.geocodeFoundNoResult.rawValue:
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
                
                forwardGeocodingCompletionHandler(false, error! as NSError)
            }
            else {
                if placemarks?.count > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    
                    self.createMapAnnotation(coordinate!)
                    self.setCurrentLocation(location!)
                    
                    forwardGeocodingCompletionHandler(true, nil)
                }
                else {
                    Utils.GlobalMainQueue.async {
                        let alertMsg = "Location not found, please check your input."
                        Utils.showAlert(self, alertMessage: alertMsg, completion: nil)
                    }
                    
                    forwardGeocodingCompletionHandler(false, error! as NSError)
                }
            }
        }
    }
    
    func createMapAnnotation(_ coordinate: CLLocationCoordinate2D) {
        
        let uniqueId = OTMClient.sharedInstance().userKey!
        var localUser: LocalUser? = nil
        
        Utils.showActivityIndicator(view, activityIndicator: activityIndicator)
        
        OTMClient.sharedInstance().requestUdacityUserName(uniqueId) { (success, result, error) in
            
            Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
            
            Utils.GlobalMainQueue.async {
                if success {
                    localUser = result!
                    
                    print("create map annotation for udacity student: \(String(describing: localUser))")
                    
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
    
    fileprivate func setCurrentLocation(_ location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //# MARK: Activity Indicator
    fileprivate func initializeActivityIndicator() {
        
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
    }
    
    //# MARK: UI Mgmt
    fileprivate func changeButtonStyle(_ button: UIButton) {
        
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    fileprivate func showMap() {
        
        urlView.isHidden = false
        mapView.isHidden = false
        submitButton.isHidden = false

        questionStack.isHidden = true
        studyingText.isHidden = true
        inputView?.isHidden = true
        findOnTheMapButton.isHidden = true
    }
    
    fileprivate func hideMap() {
        
        urlView.isHidden = true
        mapView.isHidden = true
        submitButton.isHidden = true
        
        questionStack.isHidden = false
        studyingText.isHidden = false
        inputView?.isHidden = false
        findOnTheMapButton.isHidden = false
    }
    
    
    //# MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
