//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-26.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit
import MapKit

/// Responds to the tab bar, logout and reload actions of the view.
class TabBarController: UITabBarController, Alertable {
    
    // MARK: Instance Properties
    
    /// A shared UdacityClient instance.
    private let udacityClient = UdacityClient.shared
    
    /// An instance of UIActivityIndicatorView.
    private var activityIndicator = UIActivityIndicatorView()
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Enoch Huang (2015) UIActivityIndicatorView - Show an Activity Indicator Programmatically
         Available at: http://studyswift.blogspot.ca/2015/07/show-activity-indicator-programmatically.html (Accessed: 28 Oct 2016) */
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.black
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        // Load the student data from the Student Location Parse API
        DataService.loadStudents()
    }
    
    // MARK: Instance Methods
    
    /**
     
        Handles the touch action of the reload UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func reloadPressed(_ sender: Any) {
        // Load the student data from the Student Location Parse API
        DataService.loadStudents()
    }
    
    /**
     
        Handles the touch action of the logout UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func logoutPressed(_ sender: AnyObject) {
        activityIndicator.startAnimating()
        udacityClient.logout() { (success, errorMessage) in
            // Was there an error?
            guard (errorMessage == nil) else {
                DispatchQueue.main.async() {
                    self.displayAlert(title: "Unable to Logout", message: errorMessage)
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            // If successful, complete the logout
            if success {
                DispatchQueue.main.async() {
                    self.activityIndicator.stopAnimating()
                    self.completeLogout()
                }
            }
        }
    }
    
    /**
     
        Handles the touch action of the login with Udacity UIButton.
     
    */
    private func completeLogout() {
        dismiss(animated: true, completion: nil)
    }
}
