//
//  StudentListViewController.swift
//  On The Map
//
//  Created by Sascha Stanic on 31.03.16.
//  Copyright © 2016 Sascha Stanic. All rights reserved.
//

import UIKit

class StudentsListViewController: UITableViewController {
    
    @IBOutlet var studentsTableView: UITableView!
    
    weak var activityIndicatorView: UIActivityIndicatorView!
    let cellIdentifier = "studentTableCell"
    var refreshButton: UIBarButtonItem? = nil
    
    var students = [StudentInformation]()
    var queryCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(loadData))
        parentViewController!.navigationItem.rightBarButtonItem = refreshButton
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.activityIndicatorView = activityIndicatorView
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // seperators not visible without setting them in code
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
    }
    
    @objc private func loadData() {
        self.refreshButton!.enabled = false
        self.students = [StudentInformation]()
        self.studentsTableView.reloadData()
        
        OTMClient.sharedInstance().getStudentLocations() { (success, results, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    self.students = results!
                    self.studentsTableView.reloadData()
                }
                else {
                    self.activityIndicatorView.stopAnimating()
                    let userInfo = error!.userInfo[NSLocalizedDescriptionKey] as! String
                    self.showAlert(userInfo)
                }
                
                self.loadUdacityUserNames()
            }
        }
    }
    
    private func loadUdacityUserNames() {
        queryCounter = students.count
        
        for (index, var s) in students.enumerate() {
            OTMClient.sharedInstance().requestUdacityUserName(s.uniqueKey) { (success, result, error) in
                if success {
                    // only change user name if Udacity sent it back
                    if let res = result {
//                        print("result name: \(res)")
                        
                        if res.name != OTMClient.UdacityUser.UnknownUser {
                            
                            s.firstName = res.firstName!
                            s.lastName = res.lastName!
                            
                            self.students[index] = s
                        }
                    }
                }
                
                self.queryCounter = self.queryCounter - 1
                print(self.queryCounter)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentsTableView.reloadData()
                    self.activityIndicatorView.stopAnimating()
                    
                    if (self.queryCounter <= 0) {
                        self.refreshButton!.enabled = true
                        print("refresh button re-enabled.")
                    }
                    else {
                        self.refreshButton!.enabled = false
                    }
                }
            }
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


extension StudentsListViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("studentTableViewCell", forIndexPath: indexPath) as! CustomStudentsListTableViewCell
        
        let studentLocation = students[indexPath.row]
        cell.studentNameTextField.text = studentLocation.firstName.stringByAppendingString(" ").stringByAppendingString(studentLocation.lastName)
        cell.studentMediaURLTextField.text = studentLocation.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let studentInformation = students[indexPath.row]
        
        if let url = NSURL(string: studentInformation.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (students.count == 0) ? 0 : 1
    }
}
