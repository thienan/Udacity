//
//  HTTPClientResponse.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-26.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// Defines a value for representing the response from performing a HTTP request.
struct HTTPClientResponse {
    
    // MARK: Instance Properties
    
    /// A byte representaion of the data provided by the HTTP response.
    let data: NSData?
    
    /// An error type object that describes the error that has occured in relation to the HTTP request.
    let error: Error?
}
