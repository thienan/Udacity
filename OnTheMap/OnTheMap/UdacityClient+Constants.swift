//
//  UdacityClient+Constants.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-26.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

// MARK: Class Extension

extension UdacityClient {
    
    // MARK: Constants
    
    struct Constants {
        
        /* Francescu (2014) Global constants file in Swift
         Available at: http://stackoverflow.com/a/26252377 (Accessed: 25 Oct 2016) */
        
        struct API {
            
            /// A value that statically represents the URLs for calling the Udacity API.
            struct Method {
                static let session = "https://www.udacity.com/api/session"
                static let user = "https://www.udacity.com/api/users"
            }
            
            /// A value that statically represents the names of the parameters used for calling the Udacity API.
            struct ParameterKey {
                static let udacity = "udacity"
                static let username = "username"
                static let password = "password"
            }
            
            /// A value that statically represents the names of the response keys expected in the JSON result.
            struct ResponseKey {
                static let account = "account"
                static let key = "key"
                static let session = "session"
                static let ID = "id"
                static let user = "user"
                static let firstName = "first_name"
                static let lastName = "last_name"
            }
        }
        
        /// A value that statically represents the URL of website that should be used for signing up for a Udacity account.
        struct SignUp {
            /// The URL for the Udacity website.
            static let URL = "https://udacity.com"
        }
    }
}
