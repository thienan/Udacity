//
//  ParseClient+Constants.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-27.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

// MARK: Class Extension

extension ParseClient {
    
    // MARK: Constants
    
    struct Constants {
        
        struct API {
            
            /// A value that statically represents the custom header names used by the Student Location Parse API.
            struct CustomHeader {
                static let appID = "X-Parse-Application-Id"
                static let key = "X-Parse-REST-API-Key"
            }
            
            /// A value that statically represents the URLs for calling the Student Location Parse API.
            struct Method {
                static let studentLocation = "https://parse.udacity.com/parse/classes/StudentLocation"
            }
            
            /// A value that statically represents the names of the response keys expected in the JSON result.
            struct ResponseKey {
                static let results = "results"
            }
        }
    }
}
