//
//  MapViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 31.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000000
    var isMapInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentViewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(loadData))
        
        initializeMapAndLocationManager()
        initializeActivityIndicator()

        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        checkLocationAuthorizationStatus()
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func initializeMapAndLocationManager() {
        mapView.delegate = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setCurrentLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc private func loadData() {
        
        showActivityIndicator()
        OTMClient.sharedInstance().getStudentLocations() { (success, results, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.hideActivityIndicator()
                
                if success {
                    var mapItems = [StudentInformationMapItem]()
                    for r in results! {
                        
                        // use name from parse data
                        let name = r.firstName.stringByAppendingString(" ").stringByAppendingString(r.lastName)
                        let mapItem = StudentInformationMapItem(uniqueKey: r.uniqueKey, name: name, mediaUrl: r.mediaURL, location: CLLocationCoordinate2D(latitude: r.latitude, longitude: r.longitude))
                        
                        // get udacity username
                        mapItem.willChangeValueForKey("title")
                        OTMClient.sharedInstance().requestUdacityUserName(r.uniqueKey) { (success, result, error) in
                            if success {
                                
                                // only change user name if Udacity sent it back
                                if result!.name != OTMClient.UdacityUser.UnknownUser {
                                    mapItem.title = result!.name
                                }
                            }
                            mapItem.didChangeValueForKey("title")
                        }
                        
                        mapItems.append(mapItem)
                    }
                    
                    // in case of a reload: keep it simple. Remove all available annotations and re-add them.
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotations(mapItems)
                }
                else {
                    let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                    self.showAlert(userInfo)
                }
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
    
    private func showAlert(alertMessage: String) {
        let alertController = UIAlertController(title: "Info", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
        }
        alertController.addAction(action)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? StudentInformationMapItem {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
                
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let btn = UIButton(type: .DetailDisclosure)
                view.rightCalloutAccessoryView = btn as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            if let url = view.annotation!.subtitle {
                UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
            }
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isMapInitialized {
            setCurrentLocation(locations.last!)
            isMapInitialized = true
        }
    }
}