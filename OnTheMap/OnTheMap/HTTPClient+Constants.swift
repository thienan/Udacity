//
//  HTTPClient+Constants.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-25.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

// MARK: Class Extension

extension HTTPClient {
    
    // MARK: Constants
    
    struct Constants {
        
        /// A value that statically represents the names of HTTP Methods supported by this client.
        struct Method {
            static let post = "POST"
            static let delete = "DELETE"
            static let get = "GET"
            static let put = "PUT"
        }
        
        /// A value that statically represents the names or values of HTTP Header fields.
        struct Header {
            struct Name {
                static let accept = "Accept"
                static let contentType = "Content-Type"
                static let xsrfToken = "X-XSRF-TOKEN"
            }
            
            struct Value {
                static let applicationJSON = "application/json"
            }
        }
        
        /// A value that statically represents the name of the XSRF token.
        static let xsrfTokenCookieName = "XSRF-TOKEN"
    }
}
