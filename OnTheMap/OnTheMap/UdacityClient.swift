//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-25.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// A singleton class that is used to perform HTTP requests using the Udacity API.
final class UdacityClient {
    
    // MARK: Instance Properties
    
    /// Mutable UdacityAccount instance.
    private var udacityAccount = UdacityAccount()
    
    /// Immutable UdacityAccount instance.
    var account: UdacityAccount? {
        return udacityAccount
    }
    
    /// The HTTP client to use for performing HTTP requests.
    let client = HTTPClient.shared
    
    // MARK: Type Properties
    
    /// A shared instance of the UdacityClient.
    static let shared = UdacityClient()
    
    /// Constants that specify the types of errors that can occur while using the UdacityClient.
    enum ClientError: Error {
        case postRequestFailed(Error)
        case noData
        case JSONParseFailed(Error)
        case keyNotFound(String)
        case noAccountFoundOrInvalidCredentials
        case deleteRequestFailed(Error)
    }
    
    // MARK: Type Identifiers
    
    // Type identifiers for handlers
    typealias CompletionHandlerForLogin = (_ success: Bool, _ errorMessage: String?) -> Void
    typealias CompletionHandlerForSession = (_ success: Bool, _ sessionID: String?, _ error: Error?) -> Void
    typealias CompletionHandlerForDeleteSession = (_ success: Bool, _ error: Error?) -> Void
    typealias CompletionHandlerForLogout = (_ success: Bool, _ errorMessage: String?) -> Void
    typealias CompletionHandlerForPublicUserData = (_ udacityAccount: UdacityAccount?, _ error: Error?) -> Void
    
    // MARK: Initializers
    
    private init() {
        // Do not allow this class to be directly instantiated.
    }
    
    // MARK: Instance Methods
    
    /**
        
        Performs the login operation on the Udacity API.
     
        - Parameters:
            - username: The username of the Udacity account.
            - password: The password of the Udacity account.
            - completionHandler: Handler that is invoked to handle the outcome of the login operation.
     
    */
    func login(withUsername username: String, andPassword password: String, completionHandler: @escaping CompletionHandlerForLogin) {
        getSessionID(username: username, password: password) { (success, sessionID, error) in
            guard (error == nil) else {
                switch error as! ClientError {
                case .noAccountFoundOrInvalidCredentials:
                    completionHandler(false, "No account found or invalid credentials.")
                default:
                    completionHandler(false, "Unable to connect. Please try again.")
                }
                return
            }
            
            guard success == true else {
                completionHandler(false, "Unable to connect. Please try again.")
                return
            }
            
            guard sessionID != nil else {
                completionHandler(false, "Unable to connect. Please try again.")
                return
            }
            
            completionHandler(true, nil)
        }
    }
    
    /**
     
        Performs the logout operation on the Udacity API.
     
        - Parameters:
            - completionHandler: Handler that is invoked to handle the outcome of the logout operation.
     
    */
    func logout(completionHandler: @escaping CompletionHandlerForLogout) {
        deleteSession() { (success, error) in
            // Was there an Error?
            guard (error == nil) else {
                completionHandler(false, "Unable to logout. Please try again.")
                return
            }
            
            // Was the operation successful?
            guard success == true else {
                completionHandler(false, "Unable to logout. Please try again.")
                return
            }

            completionHandler(true, nil)
        }
    }
    
    /**
     
        Performs the operation for getting public user data from the Udacity API.
     
        - Parameters:
            - ID: The ID of the Udacity user.
            - completionHandler: Handler that is invoked to handle the outcome of getting public user data.
     
    */
    func getPublicUserData(using ID: String, completionHandler: @escaping CompletionHandlerForPublicUserData) {
        // Set the URL for the HTTP request
        var url = Constants.API.Method.user
        
        // Append the ID of the Udacity user to the URL
        url.append("/\(ID)")
        
        // Perform the GET request
        _ = client.perform(.get, with: url) { (response) in
            // Was there an error?
            guard (response.error == nil) else {
                if let error = response.error {
                    completionHandler(nil, error)
                    return
                }
                return
            }
            
            // Is there data?
            guard let data = response.data else {
                completionHandler(nil, ClientError.noData)
                return
            }
            
            // Remove the first five bytes of the data received
            let modifiedData = data.subdata(with: NSMakeRange(5, data.length - 5))
            
            do {
                // Try to deserialize the byte representation of the JSON result
                let json = try JSON.deserialize(modifiedData)
                
                // Get the values for first name and last name from the JSON result
                if let user      = json[Constants.API.ResponseKey.user]      as? [String:AnyObject],
                   let firstName = user[Constants.API.ResponseKey.firstName] as? String,
                   let lastName  = user[Constants.API.ResponseKey.lastName]  as? String {
                    // Set the first name and last name properties of the UdacityAccount instance.
                    // This information will be used when saving a student location to the Parse API.
                    self.udacityAccount.firstName = firstName
                    self.udacityAccount.lastName = lastName
                    
                    completionHandler(self.udacityAccount, nil)
                } else {
                    let message = "Could not find the following keys in JSON response: \(Constants.API.ResponseKey.session), \(Constants.API.ResponseKey.ID)"
                    completionHandler(nil, ClientError.keyNotFound(message))
                }
            } catch {
                // There was an error while deserializing the JSON
                completionHandler(nil, ClientError.JSONParseFailed(error))
            }
        }
    }
    
    /**
     
        Performs the operation for getting a session ID from the Udacity API.
     
        - Parameters:
            - ID: The ID of the Udacity user.
            - completionHandler: Handler that is invoked to handle the outcome of getting a session ID.
     
    */
    private func getSessionID(username: String, password: String, completionHandler: @escaping CompletionHandlerForSession) {
        // Add custom Parse headers
        let customHTTPHeaders: [HTTPHeader] = [
            HTTPHeader(value: HTTPClient.Constants.Header.Value.applicationJSON, name: HTTPClient.Constants.Header.Name.accept),
            HTTPHeader(value: HTTPClient.Constants.Header.Value.applicationJSON, name: HTTPClient.Constants.Header.Name.contentType)
        ]
        
        // Build a native representation of the data that will be serialized to JSON
        let data = [
            "\(Constants.API.ParameterKey.udacity)": [
                "\(Constants.API.ParameterKey.username)": "\(username)",
                "\(Constants.API.ParameterKey.password)": "\(password)"
            ]
        ]
        
        var jsonBody: Data? = nil
        do {
            // Try to serialize the data
            jsonBody = try JSON.serialize(data)
        } catch {
            completionHandler(false, nil, nil)
        }
        
        // Perform POST request
        _ = client.perform(.post, with: Constants.API.Method.session, andHTTPBody: jsonBody, andHTTPHeaders: customHTTPHeaders) { (response) in
            // Was there an error?
            guard (response.error == nil) else {
                if let error = response.error {
                    // Handle specific error cases
                    switch error {
                    // A status code of 403 from this API means that the account does not exist or the provided credentials were incorrect
                    case HTTPClient.ClientError.requestNotSuccessful(let statusCode) where statusCode == 403:
                        completionHandler(false, nil, ClientError.noAccountFoundOrInvalidCredentials)
                    default:
                        completionHandler(false, nil, ClientError.postRequestFailed(error))
                    }
                }
                return
            }
            
            // Is there data?
            guard let data = response.data else {
                completionHandler(false, nil, ClientError.noData)
                return
            }
            
            // Remove the first five bytes of the data received
            let newData = data.subdata(with: NSMakeRange(5, data.length - 5))
            
            do {
                // Try to deserialize the byte representation of the JSON result
                let json = try JSON.deserialize(newData)
                
                // Get the values for key and session ID from the JSON result
                if let account = json[Constants.API.ResponseKey.account] as? [String:AnyObject],
                   let key = account[Constants.API.ResponseKey.key]      as? String,
                   let session = json[Constants.API.ResponseKey.session] as? [String:AnyObject],
                   let sessionID = session[Constants.API.ResponseKey.ID] as? String {
                    // Set the ID property of the UdacityAccount instance.
                    // This information will be used when saving a student location to the Parse API.
                    self.udacityAccount.ID = key
                    
                    completionHandler(true, sessionID, nil)
                } else {
                    let message = "Could not find the following keys in JSON response: \(Constants.API.ResponseKey.session), \(Constants.API.ResponseKey.ID)"
                    completionHandler(false, nil, ClientError.keyNotFound(message))
                }
            } catch {
                completionHandler(false, nil, ClientError.JSONParseFailed(error))
            }
        }
    }

    /**
     
     Performs the operation for deleting a session ID from the Udacity API.
     
     - Parameters:
     - ID: The ID of the Udacity user.
     - completionHandler: Handler that is invoked to handle the outcome of deleting a session ID.
     
    */
    private func deleteSession(completionHandler: @escaping CompletionHandlerForDeleteSession) {
        // Perform DELETE request
        _ = client.perform(.delete, with: Constants.API.Method.session) { (response) in
            // Was there an error?
            guard (response.error == nil) else {
                if let error = response.error {
                    completionHandler(false, ClientError.deleteRequestFailed(error))
                } else {
                    completionHandler(false, nil)
                }
                return
            }
            
            // Is there data?
            guard let data = response.data else {
                completionHandler(false, ClientError.noData)
                return
            }
            
            // Remove the first five bytes of the data received
            let newData = data.subdata(with: NSMakeRange(5, data.length - 5))
            
            do {
                // Try to deserialize the byte representation of the JSON result
                let json = try JSON.deserialize(newData)
                
                // Ensure the values for session and ID are present in the JSON result
                if let session = json[Constants.API.ResponseKey.session] as? [String:AnyObject], let _ = session[Constants.API.ResponseKey.ID] as? String {
                    // Nil the properties of the UdacityAccount instance
                    // This ensures that the Udacity account is empty and ready for another login operation.
                    self.udacityAccount.ID = nil
                    self.udacityAccount.firstName = nil
                    self.udacityAccount.lastName = nil
                    
                    completionHandler(true, nil)
                } else {
                    let message = "Could not find the following keys in JSON response: \(Constants.API.ResponseKey.session), \(Constants.API.ResponseKey.ID)"
                    completionHandler(false, ClientError.keyNotFound(message))
                }
            } catch {
                completionHandler(false, ClientError.JSONParseFailed(error))
            }
        }
    }
}
