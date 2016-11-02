//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-28.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

/// Responds to the table view actions of the view.
class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Alertable, Linkable {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Instance Properties
    
    private var studentContainer: StudentContainer? = nil
    
    // MARK: View Controller Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Add observers for the notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updateStudentContainer), name: OnTheMapConstants.NotificationName.dataReceivedFromParse, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noStudentInformation), name: OnTheMapConstants.NotificationName.noDataReceivedFromParse, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload the table view
        tableView.reloadData()
    }
    
    // MARK: Instance Methods
    
    /**
     
        Updates the StudentInformation container and reloads the table view.
     
    */
    @objc private func updateStudentContainer() {
        studentContainer = DataService.students
        
        DispatchQueue.main.async() {
            if let tableView = self.tableView {
                tableView.reloadData()
            }
        }
    }
    
    /**
     
        Handles the "NoDataReceivedFromParse" notification.
     
    */
    @objc private func noStudentInformation() {
        DispatchQueue.main.async() {
            self.displayAlert(title: "Student Information", message: "Unable to get student information from Udacity.")
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = studentContainer?.count {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OnTheMapConstants.TableView.cellReuseIdentifier, for: indexPath)
        
        if let studentContainer = self.studentContainer {
            if let student = studentContainer[indexPath.row], let firstName = student.firstName, let lastName = student.lastName {
                cell.imageView?.image = UIImage(named: "Pin Orange")
                cell.textLabel?.text = "\(firstName) \(lastName)"
            }
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let studentContainer = self.studentContainer {
            if let student = studentContainer[indexPath.row], let mediaURL = student.mediaURL {
                openURL(mediaURL)
            }
        }
    }
}
