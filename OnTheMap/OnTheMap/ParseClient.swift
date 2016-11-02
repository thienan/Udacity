//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-27.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// A singleton class that is used to perform HTTP requests using the Student Location Parse API.
final class ParseClient {
    
    // MARK: Instance Properties
    
    /// The HTTP client to use for performing HTTP requests.
    let client = HTTPClient.shared
    
    // MARK: Type Properties
    
    /// A shared instance of the ParseClient.
    static let shared = ParseClient()
    
    // MARK: Type Identifiers
    
    /// Constants that specify the types of errors that can occur while using the ParseClient.
    enum ClientError: Error {
        case parameterTypeMismatch(String)
        case putRequestFailed(Error)
        case getRequestFailed(Error)
        case noData
        case JSONParseFailed(Error)
        case updateStudentFailed
        case newStudentFailed
        case noUniqueKey
        case missingStudentInformation
        case postRequestFailed(Error)
    }
    
    // Type identifiers for handlers
    typealias CompletionHandlerForStudentLocation = (_ studentInformation: StudentInformation?, _ error: Error?) -> Void
    typealias CompletionHandlerForStudentLocations = (_ studentContainer: StudentContainer?, _ error: Error?) -> Void
    typealias CompletionHandlerForMergingStudentLocation = (_ success: Bool, _ error: Error?) -> Void
    typealias CompletionHandlerForUpdatingStudentLocation = (_ success: Bool, _ error: Error?) -> Void
    typealias CompletionHandlerForNewStudentLocation = (_ success: Bool, _ error: Error?) -> Void
    
    // MARK: Initializers
    
    private init() {
        // Do not allow this class to be directly instantiated
    }
    
    // MARK: Instance Methods
    
    /**
     
        Performs a HTTP GET+POST (SELECT+INSERT) or HTTP GET+PUT (SELECT+UPDATE), which is dependent on the provided student having an existing
        record on the Parse server.
     
        - Parameters:
            - student: The student to create or update.
            - completionHandler: Handler that is invoked to handle the outcome of the merge operation.
     
    */
    func mergeStudentLocation(with student: StudentInformation, completionHandler: @escaping CompletionHandlerForMergingStudentLocation) {
        // Create the where parameter
        guard let uniqueKey = student.uniqueKey else {
            completionHandler(false, ClientError.noUniqueKey)
            return
        }
        
        // Set the Parse where parameter
        let parameters: [ParseParameter] = [
            ParseParameter(operation: .whereClause, parameter: Where(keyName: StudentInformation.JSONKey.uniqueKey.rawValue, value: uniqueKey))
        ]
        
        // Perform a GET student location using the where clause and the provided student ID
        getStudentLocation(with: parameters) { (studentInformation, error) in
            // Was there an error?
            guard (error == nil) else {
                completionHandler(false, error)
                return
            }
            
            // If the provided student does not exist on the Parse server, post a new student location
            guard let studentInformation = studentInformation else {
                // Post a new student location using the provided student
                self.newStudentLocation(with: student) { (success, error) in
                    // Was there an error?
                    guard (error == nil) else {
                        completionHandler(false, error)
                        return
                    }
                    
                    // Success?
                    guard success == true else {
                        completionHandler(false, ClientError.newStudentFailed)
                        return
                    }
                    
                    // A new student location was created
                    completionHandler(true, nil)
                }
                return
            }
            
            // If the student exist, perform an update on their record
            guard let mapString = student.mapString, let mediaURL = student.mediaURL, let latitude = student.latitude, let longitude = student.longitude else {
                completionHandler(false, ClientError.missingStudentInformation)
                return
            }
            
            // Update the appropriate student information
            var updatedStudent = studentInformation
            updatedStudent.mapString = mapString
            updatedStudent.mediaURL = mediaURL
            updatedStudent.latitude = latitude
            updatedStudent.longitude = longitude
            
            // Put the student information to Parse
            self.updateStudentLocation(with: updatedStudent) { (success, error) in
                // Was there an error?
                guard (error == nil) else {
                    completionHandler(false, error)
                    return
                }
                
                // Success?
                guard success == true else {
                    completionHandler(false, ClientError.updateStudentFailed)
                    return
                }
                
                // A student location was updated
                completionHandler(true, nil)
                return
            }
        }
    }

    /**
     
        Perform a HTTP POST request to create a new student location.
     
        - Parameters:
            - student: The student to create.
            - completionHandler: Handler that is invoked to handle the outcome of the new student location operation.
     
    */
    private func newStudentLocation(with student: StudentInformation, completionHandler: @escaping CompletionHandlerForNewStudentLocation) {
        // Is the student information valid?
        guard let uniqueKey = student.uniqueKey,
              let firstName = student.firstName,
              let lastName  = student.lastName,
              let mapString = student.mapString,
              let mediaURL  = student.mediaURL,
              let latitude  = student.latitude,
              let longitude = student.longitude else {
                
            completionHandler(false, ClientError.missingStudentInformation)
            return
        }
        
        // Add custom Parse headers
        let customHTTPHeaders: [HTTPHeader] = [
            HTTPHeader(value: PrivateConstants.API.appID, name: Constants.API.CustomHeader.appID),
            HTTPHeader(value: PrivateConstants.API.key, name: Constants.API.CustomHeader.key),
            HTTPHeader(value: HTTPClient.Constants.Header.Value.applicationJSON, name: HTTPClient.Constants.Header.Name.contentType)
        ]
        
        // Build a native representation of the data that will be serialized to JSON
        let data: [String:Any] = [
            "\(StudentInformation.JSONKey.uniqueKey.rawValue)" : uniqueKey,
            "\(StudentInformation.JSONKey.firstName.rawValue)" : firstName,
            "\(StudentInformation.JSONKey.lastName.rawValue)"  : lastName,
            "\(StudentInformation.JSONKey.mapString.rawValue)" : mapString,
            "\(StudentInformation.JSONKey.mediaURL.rawValue)"  : mediaURL,
            "\(StudentInformation.JSONKey.latitude.rawValue)"  : latitude,
            "\(StudentInformation.JSONKey.longitude.rawValue)" : longitude
        ]
        
        var jsonBody: Data? = nil
        do {
            // Try to serialize the data
            jsonBody = try JSON.serialize(data)
        } catch {
            completionHandler(false, error)
        }
        
        // Perform the POST request
        _ = client.perform(.post, with: Constants.API.Method.studentLocation, andHTTPBody: jsonBody, andHTTPHeaders: customHTTPHeaders) { (response) in
            // Was there an error?
            guard (response.error == nil) else {
                if let error = response.error {
                    completionHandler(false, ClientError.postRequestFailed(error))
                }
                return
            }
            
            // Successful POST request
            completionHandler(true, nil)
            return
        }
    }
    
    /**
     
        Performs a HTTP PUT request to update an existing student location.
     
        - Parameters:
            - student: The student to update.
            - completionHandler: Handler that is invoked to handle the outcome of the update operation.
     
    */
    private func updateStudentLocation(with student: StudentInformation, completionHandler: @escaping CompletionHandlerForUpdatingStudentLocation) {
        // Add custom Parse headers
        let customHTTPHeaders: [HTTPHeader] = [
            HTTPHeader(value: PrivateConstants.API.appID, name: Constants.API.CustomHeader.appID),
            HTTPHeader(value: PrivateConstants.API.key, name: Constants.API.CustomHeader.key),
            HTTPHeader(value: HTTPClient.Constants.Header.Value.applicationJSON, name: HTTPClient.Constants.Header.Name.contentType)
        ]
        
        // Set the base URL
        var url = Constants.API.Method.studentLocation
        
        var jsonBody: Data? = nil
        if let uniqueKey = student.uniqueKey,
           let firstName = student.firstName,
           let lastName  = student.lastName,
           let mapString = student.mapString,
           let mediaURL  = student.mediaURL,
           let latitude  = student.latitude,
           let longitude = student.longitude,
           let objectID  = student.objectID {
            
            // Build a native representation of the data that will be serialized to JSON
            let data: [String:Any] = [
                "\(StudentInformation.JSONKey.uniqueKey.rawValue)" : uniqueKey,
                "\(StudentInformation.JSONKey.firstName.rawValue)" : firstName,
                "\(StudentInformation.JSONKey.lastName.rawValue)"  : lastName,
                "\(StudentInformation.JSONKey.mapString.rawValue)" : mapString,
                "\(StudentInformation.JSONKey.mediaURL.rawValue)"  : mediaURL,
                "\(StudentInformation.JSONKey.latitude.rawValue)"  : latitude,
                "\(StudentInformation.JSONKey.longitude.rawValue)" : longitude
            ]
            
            do {
                // Try to serialize the data
                jsonBody = try JSON.serialize(data)
            } catch {
                completionHandler(false, error)
            }
            
            // Append the object ID to the base URL
            url.append("/\(objectID)")
        } else {
            completionHandler(false, ClientError.missingStudentInformation)
            return
        }
        
        // Perform PUT request
        _ = client.perform(.put, with: url, andHTTPBody: jsonBody, andHTTPHeaders: customHTTPHeaders) { (response) in
            guard (response.error == nil) else {
                if let error = response.error {
                    completionHandler(false, ClientError.putRequestFailed(error))
                }
                return
            }
            
            guard let _ = response.data as? Data else {
                completionHandler(false, ClientError.noData)
                return
            }
            
            completionHandler(true, nil)
        }
    }
    
    /**
     
        Performs a HTTP GET request to get a single student location.
     
        - Parameters:
            - parameters: The Parse parameters to use for the HTTP GET request.
            - completionHandler: Handler that is invoked to handle the outcome of the get student location operation.
     
    */
    func getStudentLocation(with parameters: [ParseParameter]?, completionHandler: @escaping CompletionHandlerForStudentLocation) {
        // Set the base URL
        var url = Constants.API.Method.studentLocation
        
        do {
            // Try to append the query string to the URL
            try appendQueryString(to: &url, withParameters: parameters)
        } catch {
            completionHandler(nil, error)
        }
        
        // Add custom Parse headers
        let customHTTPHeaders: [HTTPHeader] = [
            HTTPHeader(value: PrivateConstants.API.appID, name: Constants.API.CustomHeader.appID),
            HTTPHeader(value: PrivateConstants.API.key, name: Constants.API.CustomHeader.key)
        ]
        
        // Perform GET request
        _ = client.perform(.get, with: url, andHTTPHeaders: customHTTPHeaders) { (response) in
            // Was there an error?
            guard (response.error == nil) else {
                if let error = response.error {
                    completionHandler(nil, ClientError.getRequestFailed(error))
                }
                return
            }
            
            // Is there data?
            guard let data = response.data as? Data else {
                completionHandler(nil, ClientError.noData)
                return
            }
            
            do {
                // Try to deserialize the byte representation of the JSON result
                let json = try JSON.deserialize(data)
                
                // Get the results value from the JSON result
                if let results = json[Constants.API.ResponseKey.results] as? [[String:AnyObject]] {
                    // Create a new student container to store the StudentInformation instances
                    // that created from the JSON results
                    var studentContainer = StudentContainer()
                    for result in results {
                        // Create new StudentInformation instance with the JSON result
                        let student = StudentInformation(with: result)
                        studentContainer.add(student)
                    }
                    
                    if studentContainer.count > 0 {
                        // There is 1 or more students, call the completion handler with the first student
                        // information instance
                        if let studentInformation = studentContainer[0] {
                            completionHandler(studentInformation, nil)
                        }
                    } else {
                        // There are no students.. This is OK
                        completionHandler(nil, nil)
                    }
                }
            } catch {
                completionHandler(nil, ClientError.JSONParseFailed(error))
            }
        }
    }
    
    /**
     
        Performs a HTTP GET request to get student locations.
     
        - Parameters:
            - parameters: The Parse parameters to use for the HTTP GET request.
            - completionHandler: Handler that is invoked to handle the outcome of the get student locations operation.
     
     */
    func getStudentLocations(with parameters: [ParseParameter]?, completionHandler: @escaping CompletionHandlerForStudentLocations) {
        // Set the base URL
        var url = Constants.API.Method.studentLocation
        
        do {
            // Try to append the query string to the URL
            try appendQueryString(to: &url, withParameters: parameters)
        } catch {
            completionHandler(nil, error)
        }
        
        // Add custom Parse headers
        let customHTTPHeaders: [HTTPHeader] = [
            HTTPHeader(value: PrivateConstants.API.appID, name: Constants.API.CustomHeader.appID),
            HTTPHeader(value: PrivateConstants.API.key, name: Constants.API.CustomHeader.key)
        ]
        
        // Perform GET request
        _ = client.perform(.get, with: url, andHTTPHeaders: customHTTPHeaders) { (response) in
            // Was there an error?
            guard (response.error == nil) else {
                if let error = response.error {
                    completionHandler(nil, ClientError.getRequestFailed(error))
                }
                return
            }
            
            // Is there data?
            guard let data = response.data as? Data else {
                completionHandler(nil, ClientError.noData)
                return
            }
            
            do {
                // Try to deserialize the byte representation of the JSON result
                let json = try JSON.deserialize(data)
                
                // Get the results value from the JSON result
                if let results = json[Constants.API.ResponseKey.results] as? [[String:AnyObject]] {
                    // Create a new student container to store the StudentInformation instances
                    // that created from the JSON results
                    var studentContainer = StudentContainer()
                    for result in results {
                        // Create new StudentInformation instance with the JSON result
                        let student = StudentInformation(with: result)
                        studentContainer.add(student)
                    }
                    completionHandler(studentContainer, nil)
                }
            } catch {
                completionHandler(nil, ClientError.JSONParseFailed(error))
            }
        }
    }
    
    /**
     
        Attempts to append the provided Parse parameters to the query string portion of the URL.
     
        - Parameters:
            - url: The URL to append the query string to.
            - parameters: Parse parameters to append to the query string portion of the URL.
     
        - Throws: An error if the parameter is invalid.
     
        - Remark:
            - Stack Overflow:
                - Author: zaph
                - Year: 2014
                - Title: Swift - encode URL
                - Available at: http://stackoverflow.com/a/24552028
                - Accessed: 31 Oct 2016
     
    */
    private func appendQueryString(to url: inout String, withParameters parameters: [ParseParameter]?) throws {
        if let parameters = parameters {
            
            var seperator = ""
            for (index, parameter) in parameters.enumerated() {
                if index == 0 {
                    url.append("?")
                } else {
                    seperator = "&"
                }
                
                switch parameter.operation {
                case .limit:
                    if let limit = parameter.parameter as? Limit {
                        let queryString = ("\(seperator)\(limit.name)=\(limit.limit)")
                        url.append(queryString)
                    } else {
                        throw ClientError.parameterTypeMismatch("Invalid limit parameter.")
                    }
                case .skip:
                    if let skip = parameter.parameter as? Skip {
                        let queryString = ("\(seperator)\(skip.name)=\(skip.skip)")
                        url.append(queryString)
                    } else {
                        throw ClientError.parameterTypeMismatch("Invalid skip parameter.")
                    }
                case .orderBy:
                    if let orderBy = parameter.parameter as? OrderBy {
                        let queryString = ("\(seperator)\(orderBy.name)=\(orderBy.order.rawValue)\(orderBy.keyName)")
                        url.append(queryString)
                    } else {
                        throw ClientError.parameterTypeMismatch("Invalid order parameter.")
                    }
                case .whereClause:
                    if let whereClause = parameter.parameter as? Where {
                        let unencodedClause = "{\"\(whereClause.keyName)\":\"\(whereClause.value)\"}"
                        
                        if let encodedClause = unencodedClause.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                            let queryString = ("\(seperator)\(whereClause.name)=\(encodedClause)")
                            url.append(queryString)
                        } else {
                            throw ClientError.parameterTypeMismatch("Invalid where parameter.")
                        }
                    } else {
                        throw ClientError.parameterTypeMismatch("Invalid where parameter.")
                    }
                }
            }
        }
    }
}
