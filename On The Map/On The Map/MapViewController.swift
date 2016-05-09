//
//  MapViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 31.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //# MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //# MARK: Attributes
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000000
    var isMapInitialized = false
    
    var observeDataStore = false {
        didSet {            
            if observeDataStore {
                DataStore.sharedInstance().addObserver(self, forKeyPath: Utils.OberserverKeyIsLoading, options: .New, context: nil)
            }
        }
    }
    
    //# MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeMapAndLocationManager()
        observeDataStore = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        checkLocationAuthorizationStatus()
        getData()
    }

    deinit {
        if observeDataStore {
            DataStore.sharedInstance().removeObserver(self, forKeyPath: Utils.OberserverKeyIsLoading)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        guard activityIndicator != nil else {
            return
        }
        
        if keyPath == Utils.OberserverKeyIsLoading {
            
            // show or hide the activity indicator dependent of the value
            dispatch_async(Utils.GlobalMainQueue) {
                if let val = change!["new"] as! Int? {
                    if val == 0 {
                        Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
                    }
                    else {
                        Utils.showActivityIndicator(self.view, activityIndicator: self.activityIndicator)
                    }
                }
            }
            
            self.getData()
        }
    }
    
    //# MARK: - Initialization
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
    
    //# MARK: Data access
    private func getData() {
        
        dispatch_async(Utils.GlobalMainQueue) {
            if DataStore.sharedInstance().isNotLoading {
                if let students = DataStore.sharedInstance().studentInformationList {
                    self.createMapItems(students)
                }
            }
        }
    }
    
    //# MARK: Location & Geocoding
    private func checkLocationAuthorizationStatus() {
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func setCurrentLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func createMapItems(results: [StudentInformation]) {
        
        var mapItems = [StudentInformationMapItem]()
        
        for r in results {
            
            // use name from parse data
            let name = r.firstName.stringByAppendingString(" ").stringByAppendingString(r.lastName)
            let mapItem = StudentInformationMapItem(uniqueKey: r.uniqueKey, name: name, mediaUrl: r.mediaURL, location: CLLocationCoordinate2D(latitude: r.latitude, longitude: r.longitude))
            
            // get udacity username
            if Utils.LoadUserNamesFromUdacity {
                mapItem.willChangeValueForKey("title")
                
                OTMClient.sharedInstance().requestUdacityUserName(r.uniqueKey) { (success, result, error) in
                    if success {
                        // only change user name if Udacity sent it back
                        if result!.name != OTMClient.UdacityUser.UnknownUser {
                            mapItem.title = result!.name
                        }
                    }
                    // ignore failure - the udacity user name cannot be used
                    
                    mapItem.didChangeValueForKey("title")
                }
            }
            
            mapItems.append(mapItem)
        }
        
        // in case of a reload: keep it simple. Remove all available annotations and re-add them.
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(mapItems)
    }
    
    
    //# MARK: - MKMapViewDelegate
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
    
    
    //# MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isMapInitialized {
            setCurrentLocation(locations.last!)
            isMapInitialized = true
        }
    }
}