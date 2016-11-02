//
//  DataService.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-29.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// An abstraction for retreiving and posting Student Information using the Student Location Parse API 
/// and Udacity API.
class DataService {
    
    // MARK: Type Properties
    
    /// The client to use for interfacing with the Student Location Parse API.
    private static let parseClient = ParseClient.shared
    
    /// The client to use for interfacing wiht the Udacity API.
    private static let udacityClient = UdacityClient.shared
    
    /// The collection to use for storing StudentInformation values.
    private static var container: StudentContainer?
    
    /// A collection of StudentInformation values.
    static var students: StudentContainer? {
        return container
    }
    
    // MARK: Type identifier
    typealias CompletionHandlerForPostingStudentLocation = (_ success: Bool) -> Void
    
    // MARK: Type Methods
    
    /**
     
        Loads the student location data from the Student Location Parse API.
     
    */
    class func loadStudents() {
        // TODO: Allow Parse parameters to be modified by end user.
        let parameters: [ParseParameter] = [
            ParseParameter(operation: .limit, parameter: Limit(limit: 100)),
            ParseParameter(operation: .orderBy, parameter: OrderBy(keyName: StudentInformation.JSONKey.updatedAt.rawValue, order: OrderBy.Order.descending))
        ]
        
        // Use the Parse client to get student information
        parseClient.getStudentLocations(with: parameters) { (studentContainer, error) in
            // Was there an error?
            guard (error == nil) else {
                NotificationCenter.default.post(name: OnTheMapConstants.NotificationName.noDataReceivedFromParse, object: self)
                return
            }
            
            if let container = studentContainer {
                self.container = container
            } else {
                // No student information... this an acceptable condition and no further action is required
                self.container = nil
            }
            
            /* ignacioz (2015) Pass data between UITabBarController views
             Available at: http://stackoverflow.com/a/32296446 (Accessed: 30 Oct 2016) */
            NotificationCenter.default.post(name: OnTheMapConstants.NotificationName.dataReceivedFromParse, object: self)
        }
    }

    /**
     
        Post the student's location.
     
        - Parameters:
            - locationString: A string representation of the location.
            - latitude: The latitude.
            - longitude: The longitude
            - website: The website URL.
            - completionHandler: Handler that is invoked to handle the outcome of the posting operation.
     
    */
    class func postStudentLocation(locationString: String, latitude: Double, longitude: Double, website: String, completionHandler: @escaping CompletionHandlerForPostingStudentLocation) {
        // Do we have an account and Udacity student ID?
        if let account = udacityClient.account, let ID = account.ID {
            // Get student information from Udacity
            udacityClient.getPublicUserData(using: ID) { (udacityAccount, error) in
                // Was there an error?
                guard (error == nil) else {
                    completionHandler(false)
                    return
                }
                
                // Is the UdacityAccount data complete?
                guard let udacityAccount = udacityAccount, let firstName = udacityAccount.firstName, let lastName = udacityAccount.lastName else {
                    completionHandler(false)
                    return
                }
                
                // Create a StudentInformation instance with the UdacityAccount data, user entered data, and geocoded data.
                let student = StudentInformation(uniqueKey: ID, firstName: firstName, lastName: lastName, mapString: locationString,
                                                 mediaURL: website, latitude: latitude, longitude: longitude)
                
                // Create new or update an existing student location on the Parse server
                parseClient.mergeStudentLocation(with: student) { (success, error) in
                    // Was there an error?
                    guard (error == nil) else {
                        completionHandler(false)
                        return
                    }
                    
                    // Success?
                    guard success == true else {
                        completionHandler(false)
                        return
                    }
                    
                    completionHandler(true)
                }
                
            }
        } else {
            completionHandler(false)
        }
    }
}
