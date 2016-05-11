//
//  StudentListViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 31.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit

class StudentsListViewController: UITableViewController {
    
    //# MARK: Outlets
    @IBOutlet var studentsTableView: UITableView!
    
    //# MARK: Attributes
    weak var activityIndicator: UIActivityIndicatorView!
    let cellIdentifier = "studentTableViewCell"
    
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
        
        initializeAcitivityIndicator()
        
        observeDataStore = true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
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
                
                self.studentsTableView.reloadData()
            }
        }

    }
    
    deinit {
        if observeDataStore {
            DataStore.sharedInstance().removeObserver(self, forKeyPath: Utils.OberserverKeyIsLoading)
        }
    }
    
    //# MARK: - Initialize
    private func initializeAcitivityIndicator() {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.color = UIColor.darkGrayColor()
        
        // seperators not visible without setting them in code
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
        
        tableView.backgroundView = activityIndicator
        
        self.activityIndicator = activityIndicator
    }
    
    //# MARK: TableView Overrides
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomStudentsListTableViewCell
        
        let studentLocation = DataStore.sharedInstance().studentInformationList![indexPath.row]
        
        cell.studentNameTextField.text = studentLocation.firstName.stringByAppendingString(" ").stringByAppendingString(studentLocation.lastName)
        cell.studentMediaURLTextField.text = studentLocation.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DataStore.sharedInstance().studentInformationList!.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let studentInformation = DataStore.sharedInstance().studentInformationList![indexPath.row]
        
        if let url = NSURL(string: studentInformation.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 66
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        guard (DataStore.sharedInstance().studentInformationList) != nil else {
            return 0
        }
        
        return (DataStore.sharedInstance().studentInformationList!.count == 0) ? 0 : 1
    }
}
