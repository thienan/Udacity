//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-27.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// A representation of the StudentLocation object in Parse.
struct StudentInformation {
    
    // MARK: Instance Properties
    
    /// An auto-generated id/key generated by Parse which uniquely identifies a StudentLocation
    var objectID: String?
    
    /// An extra (optional) key used to uniquely identify a StudentLocation; you should populate this value using your Udacity account id
    var uniqueKey: String?
    
    /// The first name of the student which matches their Udacity profile first name
    var firstName: String?
    
    /// The last name of the student which matches their Udacity profile last name
    var lastName: String?
    
    /// The location string used for geocoding the student location
    var mapString: String?
    
    /// The URL provided by the student
    var mediaURL: String?
    
    /// The latitude of the student location (ranges from -90 to 90)
    var latitude: Double?
    
    /// The longitude of the student location (ranges from -180 to 180)
    var longitude: Double?
    
    /// The date when the student location was created
    var createdAt: Date?
    
    /// The date when the student location was last updated
    var updatedAt: Date?
    
    // MARK: Type Properties
    
    /// A data formatter used to parse Date data from JSON objects.
    private static var dateFormatter: DateFormatter?
    
    /// Keys used to identify properties of the JSON object.
    enum JSONKey: String {
        case objectID = "objectId"
        case uniqueKey = "uniqueKey"
        case firstName = "firstName"
        case lastName = "lastName"
        case mapString = "mapString"
        case mediaURL = "mediaURL"
        case latitude = "latitude"
        case longitude = "longitude"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
    
    // MARK: Initializers
    
    /**
        
        Initializes a new StudentInformation with a JSON object.
 
        - Parameters:
            - with: The JSON object
 
        - Returns: A new StudentInformation based on the JSON data provided.
    */
    init(with data: [String:AnyObject]) {
        for (key, value) in data {
            if let key = JSONKey(rawValue: key) {
                switch key {
                case .objectID:
                    self.objectID = value as? String
                case .uniqueKey:
                    self.uniqueKey = value as? String
                case .firstName:
                    self.firstName = value as? String
                case .lastName:
                    self.lastName = value as? String
                case .mapString:
                    self.mapString = value as? String
                case .mediaURL:
                    self.mediaURL = value as? String
                case .latitude:
                    self.latitude = value as? Double
                case .longitude:
                    self.longitude = value as? Double
                case .createdAt:
                    if let value = value as? String {
                        self.createdAt = dateFromString(value)
                    }
                case .updatedAt:
                    if let value = value as? String {
                        self.updatedAt = dateFromString(value)
                    }
                }
            }
        }
    }
    
    /**
     
        Initializes a new StudentInformation with select properties.
     
        - Parameters:
            - uniqueKey: An extra (optional) key used to uniquely identify a StudentLocation; you should populate this value using your Udacity account id
            - firstName: The first name of the student which matches their Udacity profile first name
            - lastName: The last name of the student which matches their Udacity profile last name
            - mapString: The location string used for geocoding the student location
            - mediaURL: The URL provided by the student
            - latitude: The latitude of the student location (ranges from -90 to 90)
            - longitude: The longitude of the student location (ranges from -180 to 180)
     
        - Returns: A new StudentInformation based on the properties provided.
     
     */
    init(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double) {
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: Instance Methods
    
    /**
        
        Attempts to return a date representation of the provided string. The date formatter used is specific to expected date format being received from Parse.
     
        - Parameters:
            - string: The string representation of a date.
     
        - Returns: A date representation of the provided string or nil if the string could not be formatted as a date.
     
        - Remark:
            - Stack Overflow:
                - Author: idris yıldız
                - Year: 2015
                - Title: How can I convert string date to NSDate?
                - Available at: http://stackoverflow.com/a/32104865
                - Accessed: 28 Oct 2016
 
    */
    private func dateFromString(_ string: String) -> Date? {
        // This operation is not cheap! Cache the date formatter for resuse
        // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
        if StudentInformation.dateFormatter == nil {
            StudentInformation.dateFormatter = DateFormatter()
            StudentInformation.dateFormatter?.locale = Locale.current
            StudentInformation.dateFormatter?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            StudentInformation.dateFormatter?.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return StudentInformation.dateFormatter?.date(from: string)
    }
}
