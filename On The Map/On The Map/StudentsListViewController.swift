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
                DataStore.sharedInstance().addObserver(self, forKeyPath: Utils.OberserverKeyIsLoading, options: .new, context: nil)
            }
        }
    }
    
    //# MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeAcitivityIndicator()
        
        observeDataStore = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == Utils.OberserverKeyIsLoading {
            
            // show or hide the activity indicator dependent of the value
            if let val = change![.newKey] as! Int? {
                if val == 0 {
                    Utils.hideActivityIndicator(self.view, activityIndicator: self.activityIndicator)
                }
                else {
                    Utils.showActivityIndicator(self.view, activityIndicator: self.activityIndicator)
                }
            }
            
            Utils.GlobalMainQueue.async {
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
    fileprivate func initializeAcitivityIndicator() {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.color = UIColor.darkGray
        
        // seperators not visible without setting them in code
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine;
        
        tableView.backgroundView = activityIndicator
        
        self.activityIndicator = activityIndicator
    }
    
    //# MARK: TableView Overrides
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomStudentsListTableViewCell
        
        let studentLocation = DataStore.sharedInstance().studentInformationList![indexPath.row]
        
        cell.studentNameTextField.text = (studentLocation.firstName + " ") + studentLocation.lastName
        cell.studentMediaURLTextField.text = studentLocation.mediaURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DataStore.sharedInstance().studentInformationList!.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentInformation = DataStore.sharedInstance().studentInformationList![indexPath.row]
        
        if let url = URL(string: studentInformation.mediaURL) {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 66
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard (DataStore.sharedInstance().studentInformationList) != nil else {
            return 0
        }
        
        return (DataStore.sharedInstance().studentInformationList!.count == 0) ? 0 : 1
    }
}
